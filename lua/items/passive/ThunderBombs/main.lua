local ThunderBombs = {}
local Helpers = include("lua.helpers.Helpers")

---@param bomb Entity
---@return boolean
local function IsThunderBomb(bomb)
	if not bomb then return false end
	if bomb.Type ~= EntityType.ENTITY_BOMB then return false end
	bomb = bomb:ToBomb()
	return BombFlagsAPI.HasCustomBombFlag(bomb, "THUNDER_BOMB")
end

local function DoesItemSlotHaveCharge(player, slot)
	local item = player:GetActiveItem(slot)
	local itemConf = Isaac.GetItemConfig():GetCollectible(item)
	if itemConf and itemConf.ChargeType == 0 then
		if Helpers.GetCharge(player, slot) > 0 then
			return true
		end
	end
	return false
end

local function DoesPlayerHaveCharge(player)
	for i = 0, 2 do
		if DoesItemSlotHaveCharge(player, i) then
			return true
		end
	end
	return false
end

local function CanPlayerPlaceThunderBomb(player)
	return player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS) and
	player:GetNumBombs() == 0 and not player:HasGoldenBomb() and DoesPlayerHaveCharge(player)
end

---@param bomb EntityBomb
local function ThunderBombInit(bomb)
	if EdithRestored:GetData(bomb).BombInit then return end
	local player = Helpers.GetPlayerFromTear(bomb)
	--[[if bomb.Variant ~= BombVariant.BOMB_NORMAL and bomb.Variant ~= BombVariant.BOMB_GIGA and
	bomb.Variant ~= BombVariant.BOMB_ROCKET 
	and bomb.Variant ~= BombVariant.BOMB_TROLL and bomb.Variant ~= BombVariant.BOMB_SUPERTROLL then return false end]]
	if player then
		local rng = bomb:GetDropRNG()
		
		local thunderChance = player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS) and 
        (not bomb.IsFetus or bomb.IsFetus and rng:RandomInt(100) < 20)
		
		local nancyChance = player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) and
		player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) < 7
		and not Helpers.IsItemDisabled(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS)
		
		if thunderChance or nancyChance then
			BombFlagsAPI.AddCustomBombFlag(bomb, "THUNDER_BOMB")
		end
	end
end

local function SpawnThunderBombLaser(bomb, parent, damage, radius)
	EdithRestored.Room():DoLightningStrike()
	Game():MakeShockwave(bomb.Position, .035, .01, 10)

	local ring = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THIN_RED, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, bomb.Position, Vector.Zero, parent):ToLaser()
	ring.Radius = 80 * (bomb.RadiusMultiplier and bomb.RadiusMultiplier or 1)
	ring.CollisionDamage = damage and damage or bomb.ExplosionDamage / 2
	ring:SetTimeout(10)
	ring:SetOneHit(false)
	ring.Parent = bomb
	ring.Color = Color.LaserNumberOne
	EdithRestored:GetData(ring).FromThunderBomb = true
end

---@param bomb EntityBomb
function ThunderBombs:BombUpdate(bomb)
	
	if bomb.FrameCount == 1 then
		ThunderBombInit(bomb)
	end

	if not IsThunderBomb(bomb) then return end

	local data = EdithRestored:GetData(bomb)
	local sprite = bomb:GetSprite()

	if data.IsBlankBombInstaDetonating then
		return
	end

	if sprite:IsPlaying("Explode") then
		SpawnThunderBombLaser(bomb, Helpers.GetPlayerFromTear(bomb))
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, ThunderBombs.BombUpdate)

function ThunderBombs:EdithStompThunderBombProc(player)
	local data = EdithRestored:GetData(player)
	return CanPlayerPlaceThunderBomb(player) and not data.LockBombs
end
EdithRestored:AddCallback(EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION_EFFECT, ThunderBombs.EdithStompThunderBombProc, EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS)

function ThunderBombs:EdithStompThunderBomb(player, damage, radius, forced)
	local data = EdithRestored:GetData(player)
	if CanPlayerPlaceThunderBomb(player) and not data.LockBombs then
		for i = 0,2 do
			if DoesItemSlotHaveCharge(player, i) then
				player:AddActiveCharge(-3, i)
				Game():GetHUD():FlashChargeBar(player, i)
				SFXManager():Play(SoundEffect.SOUND_BATTERYDISCHARGE, 1 , 0)
				player:SetMinDamageCooldown(60)
				SpawnThunderBombLaser(player, player, damage / 2)
				break
			end
		end
	end
end
EdithRestored:AddCallback(EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION, ThunderBombs.EdithStompThunderBomb, EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS)

function ThunderBombs:HandleRingDamage(laser) --this exists because it doesnt properly hit everything inside of it
	local data = EdithRestored:GetData(laser)

	if data and data.FromThunderBomb == true then
		for i, enemy in ipairs(Isaac.FindInRadius(laser.Position, laser.Radius, EntityPartition.ENEMY)) do
			enemy:TakeDamage(0, DamageFlag.DAMAGE_LASER | DamageFlag.DAMAGE_EXPLOSION, EntityRef(laser), 0)
		end
	end

end
EdithRestored:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, ThunderBombs.HandleRingDamage)

function ThunderBombs:EntityHit(entity, dmg, flags, source, countdown)
	source = source.Entity

	if source then
		local data = EdithRestored:GetData(source)
		if IsThunderBomb(source) or data and data.FromThunderBomb == true then
			local lightning = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CHAIN_LIGHTNING, 0, entity.Position, Vector.Zero, bomb):ToEffect()
			lightning:SetDamageSource(EntityType.ENTITY_PLAYER)
			lightning.CollisionDamage = source.CollisionDamage
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ThunderBombs.EntityHit)


---@param bomb EntityBomb
function ThunderBombs:BombRender(bomb)

	if not IsThunderBomb(bomb) then return end

	local data = EdithRestored:GetData(bomb)

	if data.ThunderBombsOverlay then
		if bomb.FrameCount % 2 == 0 and not Game():IsPaused() then
			data.ThunderBombsOverlay:Update()
		end
		if bomb.Variant == BombVariant.BOMB_TROLL or bomb.Variant == BombVariant.BOMB_SUPERTROLL then
			local sprite = bomb:GetSprite()
			local frameData = sprite:GetCurrentAnimationData():GetLayer(0):GetFrame(sprite:GetFrame())
			data.ThunderBombsOverlay.Scale = frameData:GetScale()
			if sprite:GetFrame() > 4 then
				data.ThunderBombsOverlay:Render(Isaac.WorldToScreen(bomb.Position + bomb.PositionOffset + frameData:GetPos()))
			end
		else
			data.ThunderBombsOverlay:Render(Isaac.WorldToScreen(bomb.Position + bomb.PositionOffset))
		end

	else
		ThunderBombs:ReplaceCostume(bomb)
	end

end
EdithRestored:AddCallback(ModCallbacks.MC_POST_BOMB_RENDER, ThunderBombs.BombRender)

---@param collectible CollectibleType | integer
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param VarData integer
---@param player EntityPlayer
function ThunderBombs:AddCharge(collectible, charge, firstTime, slot, VarData, player)
	if firstTime then
		for i = 0,2 do
			local item = player:GetActiveItem(i)
			local itemConf = Isaac.GetItemConfig():GetCollectible(item)
			if itemConf and itemConf.ChargeType ~= 2 then
				player:FullCharge(i)
			end
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, ThunderBombs.AddCharge, EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS)

---@param player EntityPlayer
function ThunderBombs:TryPlaceBomb(player)
	if Helpers.CanMove(player, true) then
		if player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS) and player:GetBombPlaceDelay() <= 0 and player:GetNumBombs() <= 0 and not player:HasGoldenBomb() then
			local bombButton = Input.IsActionTriggered(ButtonAction.ACTION_BOMB, player.ControllerIndex)
			local data = EdithRestored:GetData(player)
			if bombButton and not (Helpers.IsPlayerEdith(player, true, false) and data.LockBombs) then
				for i = 0,2 do
					if DoesItemSlotHaveCharge(player, i) then
						player:AddActiveCharge(-3, i)
						Game():GetHUD():FlashChargeBar(player, i)
						SFXManager():Play(SoundEffect.SOUND_BATTERYDISCHARGE, 1 , 0)
						local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, 0, 0, player.Position, Vector.Zero, player)
						local delay = player:HasCollectible(CollectibleType.COLLECTIBLE_FAST_BOMBS) and 10 or 30
						player:SetBombPlaceDelay(delay)
						if player:IsExtraAnimationFinished() then
							player:PlayExtraAnimation("Hit")
						end
						player:SetMinDamageCooldown(60)
						break
					end
				end
			end
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, ThunderBombs.TryPlaceBomb)

---@param player EntityPlayer
function ThunderBombs:TryPlaceBombInput(entity, hook, button)
	if entity and entity:ToPlayer() and hook ~= InputHook.GET_ACTION_VALUE then
		local player = entity:ToPlayer()
		if Helpers.CanMove(player, true) then
			if button == ButtonAction.ACTION_BOMB and CanPlayerPlaceThunderBomb(player) then
				return false
			end
		end
	end
end
EdithRestored:AddPriorityCallback(ModCallbacks.MC_INPUT_ACTION, CallbackPriority.LATE, ThunderBombs.TryPlaceBombInput)

---@param bomb EntityBomb
function ThunderBombs:ReplaceCostume(bomb)
	local sprite = bomb:GetSprite()
	local data = EdithRestored:GetData(bomb)

	-- local bombentry = XMLData.GetEntryById(XMLNode.BOMBCOSTUME, 1)

	-- for i=1, #bombentry.rule do
	-- 	if bombentry.rule[i].body then
	-- 		if bomb:HasTearFlags(bombentry.rule[i].includeflags)
	-- end

	if not bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
		local layer = sprite:GetLayer("body")

		if bomb.Variant ~= BombVariant.BOMB_TROLL and bomb.Variant ~= BombVariant.BOMB_SUPERTROLL then
			local path = string.sub(layer:GetSpritesheetPath(), 1, string.len(layer:GetSpritesheetPath())-4) .. "_gold.png"
			sprite:ReplaceSpritesheet(0, path, true)
		end

		local color = sprite:GetLayer("body"):GetColor()
		color:SetColorize(1, 1, 2.5, 2.5)
		color:SetTint(255/255, 255/255, 800/255, 1)
		color:SetOffset(-100/255, -100/255, -100/255)
		layer:SetColor(color)
	end

	local overlay = Sprite()
	overlay:Load("gfx/items/pick ups/bombs/thunder/spark" .. math.floor(bomb:GetScale() * 2) .. ".anm2", true)
	overlay:Play("Idle", true)
	overlay.Color = Color(1,1,1,1)
	data.ThunderBombsOverlay = overlay
end