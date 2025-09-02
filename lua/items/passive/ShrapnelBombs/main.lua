local ShrapnelBombs = {}
local Helpers = EdithRestored.Helpers

local directions = {
	0,
	90,
	180,
	270,
}

function ShrapnelBombs:BombInit(bomb)
	if EdithRestored:GetData(bomb).BombInit then
		return
	end
	local player = Helpers.GetPlayerFromTear(bomb)
	if player then
		local rng = bomb:GetDropRNG()

		local stoneChance = player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SHRAPNEL_BOMBS)
			and (not bomb.IsFetus or bomb.IsFetus and rng:RandomInt(100) < 20)

		local nancyChance = player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS)
			and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) < 10
			and not Helpers.IsItemDisabled(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SHRAPNEL_BOMBS)

		if stoneChance or nancyChance then
			BombFlagsAPI.AddCustomBombFlag(bomb, "SHRAPNEL_BOMB", EdithRestored.Enums.BombVariant.BOMB_SHRAPNEL)
		end
	end
end
--EdithRestored:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, ShrapnelBombs.BombInit)

---@param player EntityPlayer
---@param position Vector
---@param rng RNG
local function FireShrapnel(player, position, rng)
	for _ = 1, (12 + rng:RandomInt(5)) do
		local params = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 1, 1, nil)
		local tear = Isaac.Spawn(
			EntityType.ENTITY_TEAR,
			TearVariant.NAIL,
			0,
			position,
			Vector.FromAngle(rng:RandomInt(360)) * (15 + rng:RandomInt(8)),
			player
		):ToTear()
		tear.CollisionDamage = 1.5 + player.Damage
		tear.TearFlags = params.TearFlags
		if params.TearVariant ~= 0 and params.TearVariant ~= 1 then
			tear:ChangeVariant(params.TearVariant)
		end
		tear.Scale = 0.5
		tear:AddTearFlags(TearFlags.TEAR_PIERCING)
		EdithRestored:GetData(tear).Shrapnel = true
	end
end

function ShrapnelBombs:BombUpdate(bomb)
	local player = Helpers.GetPlayerFromTear(bomb)
	if not player then
		return
	end
	local data = EdithRestored:GetData(bomb)

	if bomb.FrameCount == 1 then
		ShrapnelBombs:BombInit(bomb)
		if bomb.Variant == EdithRestored.Enums.BombVariant.BOMB_SHRAPNEL then
			local sprite = bomb:GetSprite()
			local anim = sprite:GetAnimation()
			local file = sprite:GetFilename()
			sprite:Load("gfx/items/pick ups/bombs/shrapnel/shrapnel" .. file:sub(file:len() - 5), true)
			sprite:Play(anim, true)
		end
	end

	if BombFlagsAPI.HasCustomBombFlag(bomb, "SHRAPNEL_BOMB") then
		local sprite = bomb:GetSprite()
		local rng = RNG()
		rng:SetSeed(bomb.InitSeed)

		if sprite:IsPlaying("Explode") then
			FireShrapnel(player, bomb.Position, rng)
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, ShrapnelBombs.BombUpdate)

function ShrapnelBombs:TearCollision(tear, colider, low)
	if EdithRestored:GetData(tear).Shrapnel and colider:IsVulnerableEnemy() then
		if not colider:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
			colider:AddBleeding(EntityRef(tear.SpawnerEntity), 300)
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, ShrapnelBombs.TearCollision, TearVariant.NAIL)

---@param player EntityPlayer
function ShrapnelBombs:EdithStompShrapnelBomb(player, damage, radius, hasBombs)
	FireShrapnel(player, player.Position, player:GetCollectibleRNG(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SHRAPNEL_BOMBS))
end
EdithRestored:AddCallback(EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION, ShrapnelBombs.EdithStompShrapnelBomb, {Item = EdithRestored.Enums.CollectibleType.COLLECTIBLE_SHRAPNEL_BOMBS })