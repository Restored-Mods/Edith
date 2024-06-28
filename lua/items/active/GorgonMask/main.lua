local GorgonMask = {}
local Helpers = include("lua.helpers.Helpers")

local DIRECTION_VECTOR = {
	[Direction.NO_DIRECTION] = Vector(0, 1),	-- when you don't shoot or move, you default to HeadDown
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1)
}

function GorgonMask:UseMask(collectible, rng, player, flags, slot, vardata)
	local effects = player:GetEffects()
	if effects:HasNullEffect(EdithCompliance.Enums.NullItems.GORGON_MASK) then
		effects:RemoveNullEffect(EdithCompliance.Enums.NullItems.GORGON_MASK, 2)
		local canShoot = Helpers.GetEntityData(player).GorgonCouldShoot or true
		player:SetCanShoot(canShoot)
	else
		local count = flags & UseFlag.USE_CARBATTERY > 0 and 2 or 1
		effects:AddNullEffect(EdithCompliance.Enums.NullItems.GORGON_MASK, true, count)
		Helpers.GetEntityData(player).GorgonCouldShoot = player:CanShoot()
		player:SetCanShoot(false)
	end
	return true
end
EdithCompliance:AddCallback(ModCallbacks.MC_USE_ITEM, GorgonMask.UseMask, EdithCompliance.Enums.CollectibleType.COLLECTIBLE_GORGON_MASK)

function GorgonMask:GorgonMaskCheck(player)
	if not player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_GORGON_MASK) then
		local canShoot = Helpers.GetEntityData(player).GorgonCouldShoot or true
		player:GetEffects():RemoveNullEffect(EdithCompliance.Enums.NullItems.GORGON_MASK)
		player:SetCanShoot(canShoot)
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, GorgonMask.GorgonMaskCheck)

function GorgonMask:UpdateCanShootOnLoad()
	for _, player in ipairs(Helpers.GetPlayersByNullEffect(EdithCompliance.Enums.NullItems.GORGON_MASK)) do
		if player:GetEffects():HasNullEffect(EdithCompliance.Enums.NullItems.GORGON_MASK) then
			player:SetCanShoot(false)
		end
	end
end
EdithCompliance:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, GorgonMask.UpdateCanShootOnLoad)

function GorgonMask:MaskNpcUpdate(npc)
	if npc:IsActiveEnemy() == false then
		return
	end

	local room = Game():GetRoom()

	for _, player in ipairs(Helpers.GetPlayersByNullEffect(EdithCompliance.Enums.NullItems.GORGON_MASK)) do
		local count = player:GetEffects():GetNullEffectNum(EdithCompliance.Enums.NullItems.GORGON_MASK)
		local direction = DIRECTION_VECTOR[player:GetHeadDirection()]

		if room:CheckLine(player.Position, npc.Position, 3) then --check for obstructions

			if direction.X == 0 and math.abs(npc.Position.X - player.Position.X) <= 12 then --up/down

				if (player.Position * direction).Y > 0 and npc.Position.Y > player.Position.Y then --down
					npc:AddFreeze(EntityRef(player), 150 * count)

				elseif (player.Position * direction).Y < 0 and npc.Position.Y < player.Position.Y then --up
					npc:AddFreeze(EntityRef(player), 150 * count)
				end

			elseif direction.Y == 0 and math.abs(npc.Position.Y - player.Position.Y) <= 12 then --left/right

				if (player.Position * direction).X > 0 and npc.Position.X > player.Position.X then --right
					npc:AddFreeze(EntityRef(player), 90 * count)

				elseif (player.Position * direction).X < 0 and npc.Position.X < player.Position.X then --left
					npc:AddFreeze(EntityRef(player), 90 * count)
				end

			end
		end
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_NPC_UPDATE, GorgonMask.MaskNpcUpdate)