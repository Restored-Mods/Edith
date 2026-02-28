local Sodom = {}
local Helpers = EdithRestored.Helpers
local Enums = EdithRestored.Enums

local function SetOnFire(enemy, player, damage)
	if Helpers.IsEnemy(enemy) then
		damage = damage or 3.5
		enemy:AddBurn(EntityRef(player), 45, damage * 0.8)
		if type(EdithRestored:GetData(enemy).ExplodeInFlames) ~= "boolean" then
			EdithRestored:GetData(enemy).ExplodeInFlames = true
		end
	end
end

local function GetRandomPlayerWithSodom(players)
	players = players
		or Helpers.Filter(PlayerManager.GetPlayers(), function(_, player)
			return player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SODOM)
		end)
	if #players > 0 then
		return players[TSIL.Random.GetRandomInt(1, #players)]
	end
	return nil
end

local function SpawnSodomFlame(pos, vel, spawner, timeout)
	--
	local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, Enums.Entities.SODOM_FIRE.Variant, 0, pos, vel, spawner)
		:ToEffect()
	fire.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	fire.CollisionDamage = (spawner and spawner:ToPlayer()) and spawner:ToPlayer().Damage or 3.5
	fire.Velocity = vel
	fire:SetTimeout(timeout or 90)
end

---@param fire EntityEffect
function Sodom:FireDamage(fire)
	fire.Velocity = Helpers.Lerp(fire.Velocity, Vector.Zero, 0.07)
	local sprite = fire:GetSprite()
	if fire.Size <= 4 or fire.Timeout <= 0 then
		if sprite:IsFinished("Disappear") then
			fire:Remove()
			return
		end
		if not sprite:IsPlaying("Disappear") then
			fire.Velocity = Vector.Zero
			sprite:Play("Disappear", true)
		end
	else
		local capsule = fire:GetCollisionCapsule()
		for _, entity in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
			if Helpers.IsEnemy(entity, false, true) then
				if
					entity:TakeDamage(
						fire.CollisionDamage,
						DamageFlag.DAMAGE_FIRE | DamageFlag.DAMAGE_COUNTDOWN,
						EntityRef(fire),
						5
					)
				then
					local player = fire.SpawnerEntity and fire.SpawnerEntity:ToPlayer() or GetRandomPlayerWithSodom()
                    SetOnFire(entity, player or fire, fire.CollisionDamage)
					sprite.Scale:Resize(sprite.Scale:Length() - 0.3)
					fire.Size = fire.Size - 3
				end
			end
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Sodom.FireDamage, Enums.Entities.SODOM_FIRE.Variant)

---@param player EntityPlayer
function Sodom:DontLookBack(player)
	if player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SODOM) then
		local data = EdithRestored:GetData(player)
		data.SodomFireCountdown = data.SodomFireCountdown or 20
		data.SodomEdithResetPause = data.SodomEdithResetPause or 0
		if
			not Helpers.VectorEquals(player:GetMovementVector(), Vector.Zero)
			or Helpers.IsPureEdith(player)
				and data.EdithTargetMovementPosition
				and not Helpers.VectorEquals(player.Velocity, Vector.Zero)
		then
			data.SodomFireCountdown = data.SodomFireCountdown - 1
			data.SodomEdithResetPause = Helpers.IsPureEdith(player) and 10 or 0
			if data.SodomFireCountdown <= 0 then
				local vel = Helpers.IsPureEdith(player) and player.Velocity:Normalized() or player:GetMovementVector()
				SpawnSodomFlame(player.Position, vel * -1, player, 50)
				data.SodomFireCountdown = 20
			end
		elseif data.SodomEdithResetPause == 0 then
			data.SodomFireCountdown = 20
		else
			data.SodomEdithResetPause = math.max(data.SodomEdithResetPause - 1, 0)
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Sodom.DontLookBack)

---@param npc EntityNPC
function Sodom:NPCOnFireUpdate(npc)
	local data = EdithRestored:GetData(npc)
	data.ExplodeInFlames = data.ExplodeInFlames and npc:HasEntityFlags(EntityFlag.FLAG_BURN)
end
EdithRestored:AddCallback(ModCallbacks.MC_NPC_UPDATE, Sodom.NPCOnFireUpdate)

---@param ent Entity
function Sodom:SpreadFire(ent)
	local data = EdithRestored:GetData(ent)
	if data.ExplodeInFlames then
		for _, angle in ipairs({
			TSIL.Random.GetRandomInt(1, 120),
			TSIL.Random.GetRandomInt(121, 240),
			TSIL.Random.GetRandomInt(241, 360),
		}) do
			SpawnSodomFlame(ent.Position, Vector.FromAngle(angle):Resized(10), GetRandomPlayerWithSodom(), 90)
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Sodom.SpreadFire)
