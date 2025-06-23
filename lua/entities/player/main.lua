local Helpers = include("lua.helpers.Helpers")
include("lua.entities.player.unlock")

if CustomHealthAPI then
	CustomHealthAPI.PersistentData.CharactersThatCantHaveRedHealth[EdithRestored.Enums.PlayerType.EDITH] = true
	CustomHealthAPI.PersistentData.CharactersThatCantHaveRedHealth[EdithRestored.Enums.PlayerType.EDITH_B] = true
	CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[EdithRestored.Enums.PlayerType.EDITH] = "SOUL_HEART"
	CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[EdithRestored.Enums.PlayerType.EDITH_B] = "BLACK_HEART"
	CustomHealthAPI.Library.AddCallback("EdithRestored", CustomHealthAPI.Enums.Callbacks.CAN_PICK_HEALTH, 0, function (player,key)
		if Helpers.IsPlayerEdith(player, true, true) and CustomHealthAPI.Library.GetInfoOfKey(key, 'Type') == CustomHealthAPI.Enums.HealthTypes.RED then
			return false
		end
	end)
end

local Player = {}
local MinJumpVal = 10
local JumpChargeMul = 1.5
local JumpCharge = 1.5

local function IsPlayerOnGravityGrid(player, position)
	local pos = position or player.Position
	local grid = EdithRestored.Room():GetGridEntityFromPos(pos)
	return not player.CanFly and grid and grid:GetType() == GridEntityType.GRID_GRAVITY
end

local function EdithJump(player, pos)
	local data = EdithRestored:GetData(player)
	local anim = "EdithJump"
	if data.BombStomp ~= nil and player:HasCollectible(CollectibleType.COLLECTIBLE_FAST_BOMBS) then
		anim = anim.."Quick"
	end
	player:PlayExtraAnimation(anim)
	data.TargetJumpPos = pos
	data.EdithJumpCharge = 0
	data.EdithTargetMovementPosition = nil
end

local function ChangeToEdithTear(tear)
	tear:ChangeVariant(TearVariant.ROCK)
	tear.Color = Color(
		tear.Color.R + 0.8 + (tear.Parent.Color.R - 1), 
		tear.Color.G + 1 + (tear.Parent.Color.G - 1), 
		tear.Color.B + 1 + (tear.Parent.Color.B - 1), 
		tear.Color.A + (tear.Parent.Color.A - 1), 
		tear.Color.RO + tear.Parent.Color.RO, 
		tear.Color.GO + tear.Parent.Color.GO, 
		tear.Color.BO + tear.Parent.Color.BO
	)
end

local function IsEdithExtraAnim(player)
	local s = player:GetSprite():GetAnimation()
	return s:sub(1,5) == "Edith"
end

---@param player EntityPlayer
local function CheckEdithsCollisionWithGrid(player, data)
	local effects = player:GetEffects()
	local hasMarsEffect = effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS)
	local room = EdithRestored.Room()

	local gridEntities = {
		room:GetGridEntityFromPos(player.Position + Vector(-40, 0)),	--Left
		room:GetGridEntityFromPos(player.Position + Vector(40, 0)),		--Right
		room:GetGridEntityFromPos(player.Position + Vector(0, -40)),	--Up
		room:GetGridEntityFromPos(player.Position + Vector(0, 40)),		--Down
	}

	for _, gridEntity in pairs(gridEntities) do
		--Only check for collission if the grid entity is the appropiate collission class
		--And if we're moving it it's direction
		--TODO: Maybe it'd be better to check for collission with the grid entity twice?
		if gridEntity.CollisionClass ~= 0 and gridEntity.CollisionClass ~= 5 and
		(gridEntity.Position - player.Position):Normalized():DistanceSquared(player.Velocity:Normalized() + room:GetWaterCurrent()) < 0.1 then
			--Check if player is intersecting with the gridEntity
			--From https://stackoverflow.com/questions/401847/circle-rectangle-collision-detection-intersection
			local isIntersecting
			local circleDistanceX = math.abs(player.Position.X - gridEntity.Position.X)
			local circleDistanceY = math.abs(player.Position.Y - gridEntity.Position.Y)

			if circleDistanceX > 20 + player.Size + 0.1 or
			circleDistanceY > 20 + player.Size + 0.1  then
				isIntersecting = false
			elseif circleDistanceX <= 20 or circleDistanceY <= 20 then
				isIntersecting = true
			else
				local cornerDistanceSq = (circleDistanceX - 20)^2 + (circleDistanceY - 20)^2
				isIntersecting = cornerDistanceSq <= (player.Size + 0.1)^2
			end

			if isIntersecting then
				if gridEntity.CollisionClass == GridCollisionClass.COLLISION_WALL or
				(not player:IsFlying() and (
					gridEntity.CollisionClass == GridCollisionClass.COLLISION_PIT or
					gridEntity:GetType() == GridEntityType.GRID_ROCKB
				)) then
					if gridEntity.CollisionClass == GridCollisionClass.COLLISION_WALL then
						player.Velocity = Vector.Zero
						data.EdithTargetMovementPosition = nil

						if hasMarsEffect then
							local marsEffect = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_MARS)
							local marsCooldown = marsEffect.Cooldown

							EdithRestored.Game:ShakeScreen(marsCooldown + 10)
						end
					end
				end

				--Check if we can open a door
				if gridEntity:GetType() == GridEntityType.GRID_DOOR and room:IsClear() then
					local door = gridEntity:ToDoor()
					if door:IsLocked() then
						door:TryUnlock(player, false)
					end
				end
			end
		end
	end
end


---@param player EntityPlayer
local function CheckEdithsCollisionWithSlots(player, data)
	local slots = Isaac.FindByType(EntityType.ENTITY_SLOT)

	local isCollidingWithSlot = false

	for _, slot in ipairs(slots) do
		if slot:GetData().sizeMulti then
			if (math.abs(slot.Position.X - player.Position.X) ^ 2 <= (slot.Size*slot.SizeMulti.X + player.Size) ^ 2) and
			(math.abs(slot.Position.Y-player.Position.Y) ^ 2 <= (slot.Size*slot.SizeMulti.Y + player.Size) ^ 2) then
				isCollidingWithSlot = true
			end
		else
			if slot.Position:DistanceSquared(player.Position) <= (slot.Size + player.Size) ^ 2 then
				isCollidingWithSlot = true
			end
		end
	end

	if not isCollidingWithSlot then return end

	player.Velocity = Vector.Zero
	data.EdithTargetMovementPosition = nil
end

---@param player EntityPlayer
local function EdithGridMovement(player, data)
	local firstFrameOfMovement = false

	if (player.ControlsEnabled ~= true or Helpers.IsMenuing()) and not data.EdithTargetMovementPosition then return end
	
	local effects = player:GetEffects()
	local hasMarsEffect = effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS)
	local hasMegaMush = effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH)
	
	local playerSprite = player:GetSprite()
	if playerSprite:IsPlaying("EdithJump") or playerSprite:IsPlaying("EdithJumpQuick") then return end

	if not data.EdithTargetMovementPosition and Helpers.CanMove(player) and not hasMegaMush then
		--If EdithTargetMovementPosition is nil, it means we are not moving
		--Calculate movement direction
		local controllerIndex = player.ControllerIndex

		local isPressingLeft
		local isPressingRight
		local isPressingUp
		local isPressingDown
		local allowHolding = EdithRestored:GetDefaultFileSave("AllowHolding")

		if allowHolding == true then
			isPressingLeft = Input.IsActionPressed(ButtonAction.ACTION_LEFT, controllerIndex)
			isPressingRight = Input.IsActionPressed(ButtonAction.ACTION_RIGHT, controllerIndex)
			isPressingUp = Input.IsActionPressed(ButtonAction.ACTION_UP, controllerIndex)
			isPressingDown = Input.IsActionPressed(ButtonAction.ACTION_DOWN, controllerIndex)
		elseif allowHolding ~= true then
			isPressingLeft = Input.IsActionTriggered(ButtonAction.ACTION_LEFT, controllerIndex)
			isPressingRight = Input.IsActionTriggered(ButtonAction.ACTION_RIGHT, controllerIndex)
			isPressingUp = Input.IsActionTriggered(ButtonAction.ACTION_UP, controllerIndex)
			isPressingDown = Input.IsActionTriggered(ButtonAction.ACTION_DOWN, controllerIndex)
		end
		
		if data.InputBuffer then
			isPressingLeft = isPressingLeft or data.InputBuffer.input == ButtonAction.ACTION_LEFT
			isPressingRight = isPressingRight or data.InputBuffer.input == ButtonAction.ACTION_RIGHT
			isPressingUp = isPressingUp or data.InputBuffer.input == ButtonAction.ACTION_UP
			isPressingDown = isPressingDown or data.InputBuffer.input == ButtonAction.ACTION_DOWN

			data.InputBuffer = nil
		end

		--If we're not pressing anything, return
		if not isPressingLeft and not isPressingRight and
		not isPressingUp and not isPressingDown then return end

		local room = EdithRestored.Room()
		local clampedPlayerPos = room:GetGridPosition(room:GetGridIndex(player.Position))
		local targetMovementPosition
		local targetMovementDirection

		local mirrorWorldReverser
		if Helpers.InMirrorWorld() then
			mirrorWorldReverser = -1
		else
			mirrorWorldReverser = 1
		end

		if isPressingLeft then
			targetMovementPosition = clampedPlayerPos + Vector(-40, 0) * mirrorWorldReverser
			targetMovementDirection = Vector(-1, 0)
		elseif isPressingRight then
			targetMovementPosition = clampedPlayerPos + Vector(40, 0) * mirrorWorldReverser
			targetMovementDirection = Vector(1, 0)
		elseif isPressingDown then
			targetMovementPosition = clampedPlayerPos + Vector(0, 40)
			targetMovementDirection = Vector(0, 1)
		elseif isPressingUp then
			targetMovementPosition = clampedPlayerPos + Vector(0, -40)
			targetMovementDirection = Vector(0, -1)
		end

		data.EdithTargetMovementPosition = targetMovementPosition
		data.EdithTargetMovementDirection = targetMovementDirection

		data.PreLastEdithPosition = nil
		data.LastEdithPosition = nil

		if player:HasCollectible(CollectibleType.COLLECTIBLE_JUPITER) then
			local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_JUPITER)

			local smokeNum = rng:RandomInt(3) + 1

			for _ = 1, smokeNum, 1 do
				local randomVel = rng:RandomFloat() * 2 - 1
				local spawningVel
				if data.EdithTargetMovementDirection.X == 0 then
					spawningVel = Vector(randomVel, -data.EdithTargetMovementDirection.Y)
				else
					spawningVel = Vector(-data.EdithTargetMovementDirection.X, randomVel)
				end

				local smokeCloud = TSIL.EntitySpecific.SpawnEffect(EffectVariant.SMOKE_CLOUD, 0, player.Position, spawningVel:Normalized() * 10, player)
				local randomScale = rng:RandomFloat() * 0.3
				smokeCloud.SpriteScale = Vector(0.5 + randomScale, 0.5 + randomScale)
				smokeCloud:SetTimeout(70)
			end

			local particleNum = rng:RandomInt(4) + 2
			for _ = 1, particleNum, 1 do
				local randomVel = rng:RandomFloat() * 1 - 0.5
				local spawningVel
				if data.EdithTargetMovementDirection.X == 0 then
					spawningVel = Vector(randomVel, -data.EdithTargetMovementDirection.Y)
				else
					spawningVel = Vector(-data.EdithTargetMovementDirection.X, randomVel)
				end

				local waterParticle = TSIL.EntitySpecific.SpawnEffect(EffectVariant.WATER_SPLASH, 1, player.Position, spawningVel:Normalized() * 10, player)
				local randomScale = rng:RandomFloat() * 0.3
				waterParticle.SpriteScale = Vector(2 + randomScale, 2 + randomScale)
				waterParticle:SetTimeout(10)
				waterParticle:GetSprite().Color = Color(0.3, 0.42, 0.25)
			end

			SFXManager():Play(SoundEffect.SOUND_FART)
		end

		firstFrameOfMovement = true
	end

	if data.EdithTargetMovementPosition then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and not EdithRestored.Game:IsPaused() then
			data.EdithJumpCharge = math.max(0,data.EdithJumpCharge - JumpCharge / 2)
		end
		--[[if data.EdithJumpTarget then
			data.EdithJumpTarget:Remove()
			data.EdithJumpTarget = nil
		end]]
		if not hasMarsEffect and data.HadMarsEffect then
			data.EdithTargetMovementPosition = nil
		end

		if not Helpers.CanMove(player) or hasMegaMush then
			data.EdithTargetMovementPosition = nil
			player.Velocity = Vector.Zero
			return
		end

		--If EdithTargetMovementPosition is not nil, we are moving
		--Handle her velocity
		local velocityMagnitude = 5 * player.MoveSpeed
		if hasMarsEffect then
			velocityMagnitude = velocityMagnitude * 2
			local velocityDirection = (data.EdithTargetMovementDirection):Normalized()
			local vel = velocityDirection * velocityMagnitude
			if IsPlayerOnGravityGrid(player) then
				player.Velocity.X = vel.X
			else
				player.Velocity = vel
			end
		elseif data.EdithTargetMovementPosition then
			if IsPlayerOnGravityGrid(player, data.EdithTargetMovementPosition) then
				data.EdithTargetMovementPosition.Y = player.Position.Y
				player.Velocity.Y = Helpers.Lerp(player.Velocity.Y, 1, 0.1)
			end
			local velocityDirection = (data.EdithTargetMovementPosition - player.Position):Normalized()
			local distanceToTarget = player.Position:DistanceSquared(data.EdithTargetMovementPosition)
			
			if distanceToTarget < 5 then
				player.Position = data.EdithTargetMovementPosition
				player.Velocity = Vector.Zero
				data.EdithTargetMovementPosition = nil
			elseif (velocityMagnitude * velocityMagnitude) > distanceToTarget then
				--We squared the distace before dummy
				player.Velocity = velocityDirection * math.sqrt(distanceToTarget)
			else
				player.Velocity = velocityDirection * velocityMagnitude
			end
		end

		CheckEdithsCollisionWithGrid(player, data)

		if not firstFrameOfMovement then
			--Don't check for slot collission the first frame, so we can use them and move away
			CheckEdithsCollisionWithSlots(player, data)
		end
		
		local directionStuff 
			if data.EdithTargetMovementDirection.X == 1 or data.EdithTargetMovementDirection.Y == 1 then
				directionStuff = 1
			elseif data.EdithTargetMovementDirection.X == -1 or data.EdithTargetMovementDirection.Y == -1 then
				directionStuff = -1
			else
				directionStuff = 1
			end
			
				
		if data.EdithTargetMovementPosition and not player:IsFlying() then
			if firstFrameOfMovement then
				local dustVelocity = (-player.Velocity):Normalized() * 10
				local bdType = EdithRestored.Room():GetBackdropType()
				local chap4 = (bdType == 10 or bdType == 11 or bdType == 12 or bdType == 13 or bdType == 34 or bdType == 43 or bdType == 44)

				if chap4 then
					SFXManager():Play(SoundEffect.SOUND_MEAT_JUMPS)
				else
					SFXManager():Play(EdithRestored.Enums.SFX.Edith.ROCK_SLIDE)
				end
				
				if EdithRestored.Room():HasWater() then
					local waterStart = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 1, player.Position, Vector(0,0), nil):ToEffect() 
					waterStart.SpriteScale = (Vector(1 * (directionStuff), 1 ))
					if bdType == 44 then
						waterStart.Color = Color(1, 0.2, 0.2, 1, 0, 0, 0)
					elseif bdType == 45 then
						waterStart.Color = Color(92/255, 81/255, 71/255, 1, 0, 0, 0)
					end
				else
					if not chap4 then
						Isaac.Spawn(EdithRestored.Enums.Entities.CUSTOM_DUST_CLOUD.Type, EdithRestored.Enums.Entities.CUSTOM_DUST_CLOUD.Variant, 0, player.Position, dustVelocity, nil)
					else
						local bloodCloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, player.Position, Vector.Zero, nil):ToEffect() 
						bloodCloud.SpriteScale = Vector(0.4 * (directionStuff), 0.25)
						if bdType == 13 then
							bloodCloud.Color = Color(0, 0, 0, 1, 0.3, 0.4, 0.6)
						elseif bdType == 34 then
							bloodCloud.Color = Color(0, 0, 0, 1, 0.62, 0.65, 0.62)
						elseif bdType == 43 then
							bloodCloud.Color = Color(0, 0, 0, 1, 0.55, 0.57, 0.55)
						end
					end
				end
	
				EdithRestored.Game:ShakeScreen(1)
			end

			-- if EdithRestored.Game:GetFrameCount() % 6 == 0 then
				-- local rockParticleVelocity = Vector(0, 0)

				-- if math.random(2) == 2 then
					-- rockParticleVelocity = - (player.Velocity:Rotated(45) / 2)
				-- else
					-- rockParticleVelocity = - (player.Velocity:Rotated(-45) / 2)
				-- end

				-- local rockParticleSpawn = player.Position - player.Velocity / 2
				-- rockParticleSpawn = rockParticleSpawn + Vector(0, 20)

				-- local rockParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0,
				-- rockParticleSpawn, rockParticleVelocity, nil)
				-- rockParticle:SetColor(player.Color, -1, -20, false, true)

				-- rockParticle.DepthOffset = -20
			-- end
		end

		--Store last input in a buffer
		if not firstFrameOfMovement then
			--We need to check if it's the first frame of movement because we'd be recording the first input twice
			local controllerIndex = player.ControllerIndex

			local isPressingLeft = Input.IsActionTriggered(ButtonAction.ACTION_LEFT, controllerIndex)
			local isPressingRight = Input.IsActionTriggered(ButtonAction.ACTION_RIGHT, controllerIndex)
			local isPressingUp = Input.IsActionTriggered(ButtonAction.ACTION_UP, controllerIndex)
			local isPressingDown = Input.IsActionTriggered(ButtonAction.ACTION_DOWN, controllerIndex)

			if isPressingLeft then
				data.InputBuffer = {input = ButtonAction.ACTION_LEFT, frame = 5}
			elseif isPressingRight then
				data.InputBuffer = {input = ButtonAction.ACTION_RIGHT, frame = 5}
			elseif isPressingUp then
				data.InputBuffer = {input = ButtonAction.ACTION_UP, frame = 5}
			elseif isPressingDown then
				data.InputBuffer = {input = ButtonAction.ACTION_DOWN, frame = 5}
			elseif data.InputBuffer then
				data.InputBuffer.frame = data.InputBuffer.frame - 1

				if data.InputBuffer == 0 then
					data.InputBuffer = nil
				end
			end

			--Also check if we moved
			if player.Position:DistanceSquared(data.LastEdithPosition) <= 0.1 or
			(data.PreLastEdithPosition and (player.Position:DistanceSquared(data.PreLastEdithPosition) <= 0.1
			or data.LastEdithPosition:DistanceSquared(data.PreLastEdithPosition) <= math.min(player.MoveSpeed * 2.5, 2))) then
				--If we barely moved between 2 frames, cancel the movement
				data.EdithTargetMovementPosition = nil
			end
		end

		data.PreLastEdithPosition = data.LastEdithPosition
		data.LastEdithPosition = player.Position

		if not data.EdithTargetMovementPosition then
			effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_MARS)
		end
	end

	data.HadMarsEffect = hasMarsEffect
end

function Player:LoadUpdate(isLoading)
    for _, player in ipairs(Helpers.GetPlayers()) do
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
        Helpers.ChangeSprite(player,true)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Player.LoadUpdate)

function Player:ChargeBarRender(player)
	local data = EdithRestored:GetData(player)
	if not Helpers.IsPlayerEdith(player,true,false) then return end
	
	data.EdithJumpCharge = data.EdithJumpCharge or 0
	if not data.ChargeBar then
		data.ChargeBar = Sprite("gfx/chargebar.anm2", true)
		
	end
	data.ChargeBar.Offset = Vector(-12 * player.SpriteScale.X,-35 * player.SpriteScale.Y)
	HudHelper.RenderChargeBar(data.ChargeBar, math.max(0, data.EdithJumpCharge - MinJumpVal), JumpChargeMul * 100, EdithRestored.Room():WorldToScreenPosition(player.Position))
	
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Player.ChargeBarRender, 0)

if EdithRestored.DebugMode then
	function Player:StompRadiusRender()
		for _, player in ipairs(Helpers.GetPlayersByType(EdithRestored.Enums.PlayerType.EDITH)) do
			local shape = player:GetDebugShape(true)
			shape:Circle(player.Position, EdithRestored:GetDebugValue("StompRadius"))
		end
	end
	EdithRestored:AddCallback(ModCallbacks.MC_POST_RENDER, Player.StompRadiusRender)
end

---@param target EntityEffect
function Player:TargetJumpRender(target)
	if EdithRestored.Game:IsPaused() then return end
	target:GetSprite().PlaybackSpeed = 0.05
	target:GetSprite():Update()
	
	local player = target.Parent or target.SpawnerEntity
	if player and player:ToPlayer() and Helpers.IsPlayerEdith(player:ToPlayer(), true, false) then
		local data = EdithRestored:GetData(player)
		
		
		target.Color = Color(1, 1, 1, 0, 0, 0, 0)
		
		if data.BombStomp ~= nil then
			target:GetSprite():ReplaceSpritesheet(0, "gfx/effects/target_edith_bomb.png")
		elseif data.BombStomp ~= true then
			target:GetSprite():ReplaceSpritesheet(0, "gfx/effects/target_edith.png")
		end
		target:GetSprite():LoadGraphics()
		
		local TargetColor = EdithRestored:GetDefaultFileSave("TargetColor")

		if TargetColor then
			target.Color = Color(TargetColor.R/255, TargetColor.G/255, TargetColor.B/255, 1, 0, 0, 0)
		else
			target.Color = Color(155/255, 0, 0, 1, 0, 0, 0)
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, Player.TargetJumpRender, EdithRestored.Enums.Entities.EDITH_TARGET.Variant)

---@param target EntityEffect
function Player:TargetJumpUpdate(target)
	local player = TSIL.Players.GetPlayerFromEntity(target)

	if not player or not Helpers.IsPlayerEdith(player:ToPlayer(), true, false) then
		target:Remove()
		return
	end

	if Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and Options.MouseControl
	and Input.GetDeviceNameByIdx(player.ControllerIndex) == "Keyboard" then
		target.Position = Input.GetMousePosition(true)
	else
		target.Velocity = player:GetShootingInput():Resized(12)
	end
	
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Player.TargetJumpUpdate, EdithRestored.Enums.Entities.EDITH_TARGET.Variant)

function Player:OnInitPlayer(player)
	-- If the player is Edith it will apply the hood
	::EdithCheck::
	if Helpers.IsPlayerEdith(player, true, false) then			
		local mySprite = player:GetSprite()
		mySprite:Load(EdithRestored.Enums.PlayerSprites.EDITH, true)
		mySprite:Update()
		Helpers.ChangeSprite(player)
	elseif Helpers.IsPlayerEdith(player, false, true) then -- Apply different costume for her tainted variant
		if Helpers.IsPlayerEdith(player, false, true) then
			player:ChangePlayerType(EdithRestored.Enums.PlayerType.EDITH)
		end
		goto EdithCheck
		local mySprite = player:GetSprite()
		mySprite:Load(EdithRestored.Enums.PlayerSprites.EDITH_B, true)
		mySprite:LoadGraphics()
		Helpers.ChangeSprite(player,true)
		player:SetPocketActiveItem(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL, ActiveSlot.SLOT_POCKET, false)
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Player.OnInitPlayer)

---@param player EntityPlayer
function Player:OnUpdatePlayer(player)
	if Helpers.IsPlayerEdith(player, false, true) then
		player:ChangePlayerType(EdithRestored.Enums.PlayerType.EDITH)
		player:EvaluateItems()
	end
	local data = EdithRestored:GetData(player)	
	local dataP = EdithRestored:RunSave(player)
	if not dataP then return end

	if Helpers.IsPlayerEdith(player, true, false) then
		local TargetColor = EdithRestored:GetDefaultFileSave("TargetColor")
		if Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then
			if not data.BombStomp then
				data.BombStomp = true
			else
				data.BombStomp = nil
			end
		end
		local sprite = player:GetSprite()
		Helpers.ChangeSprite(player)
		if not player:IsDead() and not player:HasCurseMistEffect() then
			if sprite:GetAnimation():find("Walk") then
				sprite:Play(sprite:GetAnimation():match("%w*[Walk]").."Down", true)
			end
			---@diagnostic disable-next-line: undefined-field
			player:SetGnawedLeafTimer(0)
			if JumpLib:CanJump(player) then
				EdithGridMovement(player, data)
			end
			
			local room = EdithRestored.Room()
			local MinJumpCharge = MinJumpVal
			data.EdithJumpCharge = data.EdithJumpCharge or 0
			local isJumping = JumpLib:GetData(player).Jumping
			if isJumping and player:HasCollectible(CollectibleType.COLLECTIBLE_BOBBY_BOMB)
			and data.BombStomp then
				for _, enemy in ipairs(Helpers.Filter(Helpers.GetEnemies(), function(_, enemy) return enemy.Position:Distance(player.Position) <= Helpers.GetStompRadius() end)) do
					enemy.Velocity = enemy.Velocity + (player.Position - enemy.Position):Resized(2)
				end
			end
			if sprite:GetAnimation():sub(1, 9) ~= "EdithJump" and
			not isJumping and not Helpers.IsMenuing() and not EdithRestored.Game:IsPaused()
			and EdithRestored.Game:GetFrameCount() > 1 then
				if EdithRestored.DebugMode and EdithRestored:GetDebugValue("InstantJumpCharge") then
					data.EdithJumpCharge = 100 * JumpChargeMul + MinJumpCharge
				else
					data.EdithJumpCharge = math.max(0, math.min(data.EdithJumpCharge + JumpCharge * (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 2 or 1), 100 * JumpChargeMul + MinJumpCharge))
				end
			end
			local hasMegaMush = player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH)
			if player:GetSprite():GetAnimation():find("Teleport") then
				player.ControlsEnabled = true
				player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				player.GridCollisionClass = player.CanFly and EntityGridCollisionClass.GRIDCOLL_WALLS or EntityGridCollisionClass.GRIDCOLL_GROUND
			end
			if Helpers.CanMove(player) and not hasMegaMush then
				if data.EdithJumpTarget and Input.IsActionTriggered(ButtonAction.ACTION_BOMB, player.ControllerIndex)
				and JumpLib:CanJump(player) then
					EdithJump(player, data.EdithJumpTarget.Position)
					
				end
				if data.EdithJumpCharge >= (100 * JumpChargeMul + MinJumpCharge) then
					data.LockBombs = true
					if not data.EdithJumpTarget and Input.IsActionTriggered(ButtonAction.ACTION_BOMB, player.ControllerIndex) and not JumpLib:GetData(player).Jumping then
						data.EdithJumpTarget = Isaac.Spawn(1000, EdithRestored.Enums.Entities.EDITH_TARGET.Variant, 0, player.Position, Vector(0, 0), player):ToEffect()
						data.EdithJumpTarget.Parent = player
						data.EdithJumpTarget.SpawnerEntity = player
						data.EdithJumpTarget.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
						data.EdithJumpTarget:GetSprite():Play("Blink", true)
						
						-- target.Color = Color(1, 1, 1, 0, 0, 0, 0)
						if TargetColor then
							data.EdithJumpTarget.Color = Color(TargetColor.R/255, TargetColor.G/255, TargetColor.B/255, 1, 0, 0, 0)
						else
							data.EdithJumpTarget.Color = Color(155/255, 0, 0, 1, 0, 0, 0)
						end
					end
				end
			elseif data.EdithJumpTarget then
				data.EdithJumpTarget:Remove()
				data.EdithJumpTarget = nil
			end
			if sprite:GetAnimation() == "Trapdoor" then
				if room:GetGridEntityFromPos(player.Position) and room:GetGridEntityFromPos(player.Position):GetType() == GridEntityType.GRID_TRAPDOOR then
					if data.TrapDoorFallFrame then
						player:StopExtraAnimation()
						player:PlayExtraAnimation("EdithTrapdoorFall")
						data.TrapDoorFallFrame = nil
					else
						player:StopExtraAnimation()
						player:PlayExtraAnimation("EdithTrapdoor")
					end
				end
			end
			if sprite:IsEventTriggered("EdithJumpFinish") and sprite:GetAnimation():match("EdithJump") and data.Landed then
				local IFrames = data.PostLandingKill and 25 or 10
				for _, callback in ipairs(Isaac.GetCallbacks(EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_LANDING_IFRAMES)) do
					local ret = callback.Function(callback.Mod, player, IFrames, data.BombStomp or false, data.PostLandingKill or false)
					if type(ret) == "number" then
						IFrames = Helpers.Round(ret, 0)
					end
				end
				if EdithRestored.DebugMode then
					if EdithRestored:GetDebugValue("UseIFrames") then
						IFrames = EdithRestored:GetDebugValue("IFrames")
					end
				end
				if IFrames > 0 then
					player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, EdithRestored:GetDebugValue("ShowBoSEffect"), IFrames, true)
				end
				data.Landed = nil
				data.PostLandingKill = nil
			end
			if sprite:GetAnimation() == "EdithJump" and not sprite:IsEventTriggered("EdithLanding")
			or sprite:GetAnimation() == "EdithJumpQuick" then
				if sprite:IsEventTriggered("EdithJumpStart") and JumpLib:CanJump(player) then
					JumpLib:Jump(player, {
						Height = Helpers.GetJumpHeight(),
						Speed = Helpers.GetJumpGravity(),
						Flags = JumpLib.Flags.NO_HURT_PITFALL | JumpLib.Flags.FAMILIAR_FOLLOW_ORBITALS | JumpLib.Flags.FAMILIAR_FOLLOW_TEARCOPYING,
						Tags = {"EdithJump"}
					})
				end
				if data.TargetJumpPos and sprite:IsEventTriggered("EdithJumpStart") then
					player.Velocity = (data.TargetJumpPos - player.Position):Normalized() * (data.TargetJumpPos - player.Position):Length() / 7
				end
				--[[for i = 0, room:GetGridSize() do
					local grid = room:GetGridEntity(i)]]
					local grid = room:GetGridEntityFromPos(player.Position)
					if grid then
						if sprite:GetFrame() > 14 then
							if grid:GetType() == GridEntityType.GRID_TRAPDOOR and grid.State == 1 and (player.Position - grid.Position):Length() <= 30 then
								player.Position = grid.Position
								data.TrapDoorFallFrame = true
								player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
								player.GridCollisionClass = player.CanFly and EntityGridCollisionClass.GRIDCOLL_WALLS or EntityGridCollisionClass.GRIDCOLL_GROUND
								player.Velocity = Vector.Zero
								if data.EdithJumpTarget then
									data.EdithJumpTarget:Remove()
									data.EdithJumpTarget = nil
								end
								data.TargetJumpPos = nil
								player.ControlsEnabled = true
								player:StopExtraAnimation()
							end
						end
					end
				--end
			end
		else
			if data.EdithJumpTarget then
				data.EdithJumpTarget:Remove()
				data.EdithJumpTarget = nil
			end
			data.EdithJumpCharge = 0
		end
	else
		data.LockBombs = nil
	end
	if Helpers.IsPlayerEdith(player, false, true) then -- Apply different costume for her tainted variant		
		if dataP.Pepper == 5 and Helpers.CantMove(player) then
			player.Velocity = Vector.Zero
		end
		local sprite = player:GetSprite()
		if sprite:IsPlaying("Death") and dataP.Pepper < 5 then
			if sprite:GetFrame() == 5 or sprite:GetFrame() == 6 
			or sprite:GetFrame() == 7 or sprite:GetFrame() == 8 or
			sprite:GetFrame() == 9 then
				dataP.Pepper = dataP.Pepper + 1
				Helpers.ChangeSprite(player,false)
			end
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Player.OnUpdatePlayer, 0)

---@param jumpData JumpData
function Player:Landing(player, jumpData, inPit)
	if not inPit then
		local data = EdithRestored:GetData(player)
		Helpers.Stomp(player)
		data.Landed = true
		for _, pickup in ipairs(Isaac.FindInRadius(player.Position, 30, EntityPartition.PICKUP)) do
			--pickup.Velocity = Vector.Zero
		end
		player.Velocity = Vector.Zero
		if data.EdithJumpTarget then
			data.EdithJumpTarget:Remove()
			data.EdithJumpTarget = nil
		end
		
		data.TargetJumpPos = nil

		for _, v in pairs(Isaac.FindInRadius(player.Position, 55, EntityPartition.BULLET)) do
			local projectile = v:ToProjectile() ---@cast projectile EntityProjectile
			local angle = ((player.Position - projectile.Position) * -1):GetAngleDegrees()
			projectile.Velocity = Vector.FromAngle(angle):Resized(10)
			projectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
			projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
		end
		if EdithRestored.Room():GetGridCollisionAtPos(player.Position) == GridCollisionClass.COLLISION_SOLID
		and not player.CanFly then
			data.BombStomp = nil
			EdithJump(player, EdithRestored.Room():FindFreePickupSpawnPosition(player.Position, 0, false, false))
		end
	end
end
EdithRestored:AddCallback(JumpLib.Callbacks.ENTITY_LAND, Player.Landing, {tag = "EdithJump", type = EntityType.ENTITY_PLAYER})

---@param entity Entity
---@param amount number
---@param flags DamageFlag | integer
---@param source EntityRef
---@param cd integer
---@return boolean?
function Player:DamageHandling(entity, amount, flags, source, cd)
	if entity and entity:ToPlayer() and Helpers.IsPlayerEdith(entity:ToPlayer(), true, false) then
		local player = entity:ToPlayer()
		local data = EdithRestored:GetData(player)
		if flags & DamageFlag.DAMAGE_PITFALL > 0 then
			data.EdithTargetMovementPosition = nil
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Player.DamageHandling, EntityType.ENTITY_PLAYER)


---@param player EntityPlayer
---@param amount number
---@param flags DamageFlag | integer
---@param source EntityRef
---@param cd integer
---@return boolean?
function Player:DamageHandling2(player, amount, flags, source, cd)
	if Helpers.IsPlayerEdith(player, true, false) then
		local sprite = player:GetSprite()
		if sprite:GetAnimation():match("Edith") and sprite:WasEventTriggered("EdithLanding") then
			if not (flags & DamageFlag.DAMAGE_INVINCIBLE > 0 or flags & DamageFlag.DAMAGE_RED_HEARTS > 0) then
				return false
			end
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, Player.DamageHandling2)

---@param entity Entity
---@param amount number
---@param flags DamageFlag | integer
---@param source EntityRef
---@param cd integer
function Player:IFAfterFromJump(entity, amount, flags, source, cd)
	if Helpers.IsEnemy(entity, true) and entity:HasMortalDamage() and source.Entity and source.Entity:ToPlayer() and
	flags == DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_CRUSH then
		local player = source.Entity:ToPlayer()
		---@cast player EntityPlayer
		local data = EdithRestored:GetData(player)
		data.PostLandingKill = true
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, Player.IFAfterFromJump)

function Player:edith_Stats(player, cacheFlag)
	if Helpers.IsPlayerEdith(player, true, false) then -- If the player is Edith it will apply her specific stats
		Helpers.ChangeSprite(player)
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.1
		end
	elseif Helpers.IsPlayerEdith(player, false, true) then -- If the player is Tainted Edith ^^
		Helpers.ChangePepperValue(player)
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Player.edith_Stats)

function Player:Home()
	for i = 0, EdithRestored.Game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if Helpers.IsPlayerEdith(player, true, false) and EdithRestored.Level():GetCurrentRoomIndex() == 94 and EdithRestored.Level():GetStage() == LevelStage.STAGE8 and EdithRestored.Unlocks.Edith.Tainted.Unlock ~= true  then
			for _, entity in ipairs(Isaac.GetRoomEntities()) do
				if (((entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE)
				or (entity.Type == EntityType.ENTITY_SHOPKEEPER)) and EdithRestored.Room():IsFirstVisit()) then
					entity:Remove()
					local slot = Isaac.Spawn(EntityType.ENTITY_SLOT, 14, 0, entity.Position, Vector.Zero, nil)
					slot:GetSprite():ReplaceSpritesheet(0,"gfx/characters/costumes/Character_001_Edith_b.png")
					slot:GetSprite():LoadGraphics()
				end
			end
		end
	end
end
--EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Player.Home)

function Player:NewRoom()
	for i = 0, EdithRestored.Game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = EdithRestored:GetData(player)
		--No need to check for edith here because for other players its gonna be nil anyways
		data.EdithTargetMovementPosition = nil
		if Helpers.IsPlayerEdith(player, true, false) then
			player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			player.GridCollisionClass = player.CanFly and EntityGridCollisionClass.GRIDCOLL_WALLS or EntityGridCollisionClass.GRIDCOLL_GROUND
			data.TrapDoorFall = nil
		end
		Helpers.ChangeSprite(player)
		data.TargetJumpPos = nil
		data.PostLandingKill = nil
		data.Landed = nil
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Player.NewRoom)

---@param pickup EntityPickup
---@param collider Entity
function Player:OnCollectibleCollission(pickup, collider)
	if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then return end
	if not collider:ToPlayer() then return end

	local player = collider:ToPlayer()
	if not Helpers.IsPlayerEdith(player, true, false) then return end

	local data = EdithRestored:GetData(player)
	if not data.EdithTargetMovementPosition then return end

	player.Velocity = Vector.Zero
	data.EdithTargetMovementPosition = nil
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Player.OnCollectibleCollission, PickupVariant.PICKUP_COLLECTIBLE)


function Player:OnMegaChestCollision(pickup, collider)
	if pickup.Variant ~= PickupVariant.PICKUP_MEGACHEST then return end
	if not collider:ToPlayer() then return end

	local player = collider:ToPlayer()
	if not Helpers.IsPlayerEdith(player, true, false) then return end

	local data = EdithRestored:GetData(player)
	if not data.EdithTargetMovementPosition then return end

	player.Velocity = Vector.Zero
	data.EdithTargetMovementPosition = nil
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Player.OnMegaChestCollision, PickupVariant.PICKUP_MEGACHEST)

---@param entity EntityNPC
---@param collider Entity
function Player:OnNPCCollision(entity, collider)
	--We can only push enemies with less than 10 mass (arbitrary value, requires testing)
	if entity.Mass < 10 then return end
	if not collider:ToPlayer() then return end

	local player = collider:ToPlayer()
	if not Helpers.IsPlayerEdith(player, true, false) then return end

	local data = EdithRestored:GetData(player)
	if not data.EdithTargetMovementPosition then return end

	player.Velocity = Vector.Zero
	data.EdithTargetMovementPosition = nil
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, Player.OnNPCCollision)

---@param tear EntityTear
function Player:OnEdithFireTear(tear)
	if not tear.SpawnerEntity:ToPlayer() then return end

	local player = tear.SpawnerEntity:ToPlayer()
	if not Helpers.IsPlayerEdith(player, true, false) or player:HasCurseMistEffect()
	or tear.Variant == TearVariant.FETUS then return end
	ChangeToEdithTear(tear)
	tear.Scale = tear.Scale * 0.9
	tear.SpriteScale = tear.SpriteScale * 0.9

end
EdithRestored:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Player.OnEdithFireTear)

---@param entity Entity
function Player:EdithMovement(entity, hook, button)
	if entity and not entity:IsDead() then
	
		local player = entity:ToPlayer()
		if player and Helpers.IsPlayerEdith(player, true, false) then
			local OnlyStomps = EdithRestored:GetDefaultFileSave("OnlyStomps")
			if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) or player:HasCurseMistEffect() then return end
			local data = EdithRestored:GetData(player)
			if hook == InputHook.GET_ACTION_VALUE then
				if data.ForceMovementInput then
					local forceInput = false
					if data.EdithTargetMovementDirection:DistanceSquared(Vector(-1, 0)) == 0 and
					button == ButtonAction.ACTION_LEFT then
						forceInput = true
					elseif data.EdithTargetMovementDirection:DistanceSquared(Vector(1, 0)) == 0 and
					button == ButtonAction.ACTION_RIGHT then
						forceInput = true
					elseif data.EdithTargetMovementDirection:DistanceSquared(Vector(0, -1)) == 0 and
					button == ButtonAction.ACTION_UP then
						forceInput = true
					elseif data.EdithTargetMovementDirection:DistanceSquared(Vector(0, 1)) == 0 and
					button == ButtonAction.ACTION_DOWN then
						forceInput = true
					end

					if forceInput then
						data.ForceMovementInput = data.ForceMovementInput - 1
						if data.ForceMovementInput == 0 then
							if data.PonyItem then
								player:UseActiveItem(data.PonyItem, UseFlag.USE_NOANIM)
								data.PonyItem = nil
							end

							data.ForceMovementInput = nil
						end

						return 1
					end
				else
					if button == ButtonAction.ACTION_LEFT or button == ButtonAction.ACTION_RIGHT or
					button == ButtonAction.ACTION_UP or button == ButtonAction.ACTION_DOWN then
						return 0
					end
				end
			else
				if IsEdithExtraAnim(player) then
					return false
				end
				if button == ButtonAction.ACTION_BOMB and (data.LockBombs or OnlyStomps) then
					data.LockBombs = nil
					return false
				end
			end
		end
	end
end
EdithRestored:AddPriorityCallback(ModCallbacks.MC_INPUT_ACTION, CallbackPriority.EARLY, Player.EdithMovement)

function Player:PreUsePony(item, _, player)
	if item ~= CollectibleType.COLLECTIBLE_PONY and item ~= CollectibleType.COLLECTIBLE_WHITE_PONY then return end
	if not Helpers.IsPlayerEdith(player, true, false) then return end

	local data = EdithRestored:GetData(player)

	if not data.ForceMovementInput then
		data.ForceMovementInput = 3
		data.PonyItem = item
		return true
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, Player.PreUsePony)


---@param laser EntityLaser
function Player:OnMontezumaLaserInit(laser)
	if laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer() then
		laser.Visible = false
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, Player.OnMontezumaLaserInit, LaserVariant.THICK_BROWN)


---@param laser EntityLaser
function Player:OnMontezumaLaserUpdate(laser)
	--12 is poop laser variant
	--if laser.Variant ~= LaserVariant.THICK_BROWN then laser.Visible = true; return end
	if laser.MaxDistance ~= 120 then laser.Visible = true; return end
	if not laser.SpawnerEntity or not laser.SpawnerEntity:ToPlayer() then laser.Visible = true; return end

	local player = laser.SpawnerEntity:ToPlayer()
	local data = EdithRestored:GetData(player)

	if not Helpers.IsPlayerEdith(player, true, false) then laser.Visible = true; return end

	local laserData = laser:GetData()
	if not laserData.IsFakeMontezumaLaserEdith then
		local spawningRotation
		if not data.EdithTargetMovementDirection then
			spawningRotation = 180
		else
			spawningRotation = (-data.EdithTargetMovementDirection):GetAngleDegrees()
		end

		local newLaser = EntityLaser.ShootAngle(12, player.Position, spawningRotation, laser.Timeout, Vector.Zero, player)
		newLaser:SetMaxDistance(laser.MaxDistance)

		newLaser:GetData().IsFakeMontezumaLaserEdith = true
		newLaser:GetData().TargetRotation = spawningRotation

		laser:Remove()
		return
	end
	laser.Visible = true

	--Shoot corn
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONTEZUMAS_REVENGE)
	if rng:RandomInt(100) < 15 then
		local baseVelocityAmount = 7 + rng:RandomFloat() * 5
		local baseVelocity = Vector(-baseVelocityAmount, 0)
		if data.EdithTargetMovementDirection then
			---@diagnostic disable-next-line: cast-local-type
			baseVelocity = -data.EdithTargetMovementDirection * baseVelocityAmount
		end
		local randomOffset = rng:RandomFloat() * 10 - 5

		local spawningVel
		if baseVelocity.X == 0 then
			spawningVel = Vector(randomOffset, baseVelocity.Y)
		else
			spawningVel = Vector(baseVelocity.X, randomOffset)
		end

		local cornProjectile = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_CORN, 0,
											player.Position, spawningVel, nil)
		cornProjectile = cornProjectile:ToProjectile()

		cornProjectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES)
		cornProjectile.CollisionDamage = 6
		cornProjectile.FallingSpeed = 0.65
		cornProjectile.Height = -22
	end

	if not data.EdithTargetMovementDirection then return end

	--Rotation the laser should have
	local trueRotation = (-data.EdithTargetMovementDirection):GetAngleDegrees()

	if laser:GetData().TargetRotation ~= trueRotation then
		--Rotate
		local chosenRotation
		local laserToTrue = trueRotation - laser.Angle
		local trueToLaser = trueRotation + laser.Angle
		if laserToTrue == 0 then laserToTrue = math.maxinteger end
		if trueToLaser == 0 then trueToLaser = math.maxinteger end

		if laserToTrue == math.maxinteger and trueToLaser == math.maxinteger then
			chosenRotation = 0
		elseif math.min(math.abs(laserToTrue), math.abs(trueToLaser)) == math.abs(laserToTrue) then
			chosenRotation = laserToTrue
		else
			chosenRotation = trueToLaser
		end

		local chosenVelocity = 10
		if chosenRotation < 0 then
			chosenVelocity = -chosenVelocity
		end

		laser:SetActiveRotation(0, chosenRotation, chosenVelocity, false)
		laser:GetData().TargetRotation = trueRotation
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, Player.OnMontezumaLaserUpdate, LaserVariant.THICK_BROWN)

---@param effect EntityEffect
function Player:OnCustomDustInit(effect)
	local dustData = effect:GetData()
	local Rotation = math.random(2) == 2 and 1 or -1
	local color = effect.Color
	
	dustData.RotationDir = Rotation * (math.random() + 0.7) * 3
	dustData.AnimFrame = math.random(8) - 1
	effect:GetSprite():SetFrame("Clouds", dustData.AnimFrame)
	
	color:SetTint(1, 1, 1, 0.7)
	effect.Color = color
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Player.OnCustomDustInit, EdithRestored.Enums.Entities.CUSTOM_DUST_CLOUD.Variant)

---@param effect EntityEffect
function Player:OnCustomDustCloudUpdate(effect)
	local data = effect:GetData()
	effect.SpriteRotation = effect.SpriteRotation + data.RotationDir
	effect.SpriteScale = effect.SpriteScale + Vector.One * 0.05
	local color = effect.Color
	color:SetTint(1, 1, 1, color.A - 0.1)
	effect.Color = color

	effect:GetSprite():SetFrame("Clouds", data.AnimFrame)

	if effect.Color.A <= 0 then
		effect:Remove()
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Player.OnCustomDustCloudUpdate, EdithRestored.Enums.Entities.CUSTOM_DUST_CLOUD.Variant)

function Player:AccessToMirrorWorld(p)
	if Helpers.IsPlayerEdith(p,true,false) and p:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
		for _, Door in ipairs(TSIL.Doors.GetDoorsToRoomIndex(-100)) do
			if Door.State == 1 then
				if (p.Position - Door.Position):Length() <= 30 then
					if not EdithRestored.Room():IsMirrorWorld() then
						EdithRestored.Game:StartRoomTransition(EdithRestored.Level():GetCurrentRoomIndex(), Door.Slot % 4, RoomTransitionAnim.FADE_MIRROR, p, 1)
					else
						EdithRestored.Game:StartRoomTransition(EdithRestored.Level():GetCurrentRoomIndex(), Door.Slot % 4, RoomTransitionAnim.FADE_MIRROR, p, 0)
					end
					level.LeaveDoor = Door.Slot
				end
			end
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Player.AccessToMirrorWorld)

local function drawLine(fx, from, to, frame)
	local TargetColor = EdithRestored:GetDefaultFileSave("TargetColor")
	if not fx:GetData().Line then
		fx:GetData().Line = Sprite()
		fx:GetData().Line:Load("gfx/edith line.anm2", true)
	end
	if not fx:GetData().Line:IsLoaded() then return end

	local targetSprite = fx:GetData().Line

	local diffVector = to - from;
	local angle = diffVector:GetAngleDegrees();
	local sectionCount = diffVector:Length() / 16;
	
	if TargetColor then
		targetSprite.Color = Color(TargetColor.R/255, TargetColor.G/255, TargetColor.B/255, 1, 0, 0, 0)
	else
		targetSprite.Color = Color(155/255, 0, 0, 1, 0, 0, 0)
	end
	
	local fxSprite = fx:GetSprite()
	
	if (fxSprite:GetAnimation() == "Blink" and fxSprite:GetFrame() >= 1) then
		targetSprite.Color = Color(targetSprite.Color.R * 0.606451613, targetSprite.Color.G * 0.60784313725, targetSprite.Color.B * 0.60784313725, fx.Color.A, 0, 0, 0)
	end

	targetSprite.Rotation = angle;
		targetSprite:SetFrame("Line", 0)
	for i = 1, sectionCount do
		targetSprite:Render(Isaac.WorldToScreen(from))
		from = from + Vector.One * 16 * Vector.FromAngle(angle)
	end

	targetSprite.Rotation = 0
	targetSprite:SetFrame("Idle", 0)
	targetSprite:Render(Isaac.WorldToScreen(to))
end

function Player:RenderTargetLine(fx)
	local room = EdithRestored.Room()
	if room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	
	local d = fx:GetData()
	local p = fx.SpawnerEntity
	if not p or p and not p:ToPlayer() then return end
	p = p:ToPlayer()
	if Helpers.IsPlayerEdith(p,true,false) then
		drawLine(fx, p.Position, fx.Position, 0)
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, Player.RenderTargetLine, EdithRestored.Enums.Entities.EDITH_TARGET.Variant)

---@param player EntityPlayer
function Player:OnInitPlayerWithShaker(player)
	if not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.SALT_SHAKER) then
		player:RemoveCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALT_SHAKER)
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, Player.OnInitPlayerWithShaker, EdithRestored.Enums.PlayerType.EDITH)

function Player:TargetCamera()
	local list = {}
	for _,entity in ipairs(Isaac.FindByType(EdithRestored.Enums.Entities.EDITH_TARGET.Type, EdithRestored.Enums.Entities.EDITH_TARGET.Variant)) do
		list[#list+1] = entity
	end
	if #list > 0 then
		for _, player in ipairs(Helpers.GetPlayers(true)) do
			list[#list+1] = player
			if player:GetFocusEntity() then
				list[#list+1] = player:GetFocusEntity()
			end
		end
		local minx, miny, maxx, maxy = 9999,9999,-9999,-9999
		for _,ent in ipairs(list) do
			minx = math.min(minx, ent.Position.X)
			miny = math.min(miny, ent.Position.Y)
			maxx = math.max(maxx, ent.Position.X)
			maxy = math.max(maxy, ent.Position.Y)
		end
		local camera = EdithRestored.Room():GetCamera()
		camera:SetFocusPosition(Vector((maxx + minx), (maxy +  miny)) / 2)
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_UPDATE, Player.TargetCamera)

function Player:OnStompBloodBombs(player)
	if not Helpers.HasBombs(player) then
		player:TakeDamage(1, DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(nil), 60)
		return true
	end
end
EdithRestored:AddPriorityCallback(EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION_EFFECT, CallbackPriority.LATE, Player.OnStompBloodBombs, CollectibleType.COLLECTIBLE_BLOOD_BOMBS)