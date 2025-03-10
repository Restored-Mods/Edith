local GorgonMask = {}
local Helpers = include("lua.helpers.Helpers")

GorgonMask.FREEZE_DURATION = 90
GorgonMask.FREEZE_SIZE = 12

---@param player EntityPlayer
function GorgonMask:GetData(player)
	---@class GorgonMaskData
	---@field CouldShoot boolean
	---@field Active boolean
	return Helpers.GetData(player)
end

---@param player EntityPlayer
function GorgonMask:UpdateCanShoot(player)
	local data = GorgonMask:GetData(player)

	if data.Active then
		player:SetCanShoot(false)
	elseif data.CouldShoot then
		player:SetCanShoot(true)
		data.CouldShoot = nil
	end
end

---@param player EntityPlayer
function GorgonMask:UseMask(_, _, player, flags)
	if flags & UseFlag.USE_CARBATTERY ~= 0 then return end

	local data = GorgonMask:GetData(player)

	if not data.Active then
		data.CouldShoot = player:CanShoot()
	end

	data.Active = not data.Active

	GorgonMask:UpdateCanShoot(player)

	return true
end
EdithRestored:AddCallback(ModCallbacks.MC_USE_ITEM, GorgonMask.UseMask, EdithRestored.Enums.CollectibleType.COLLECTIBLE_GORGON_MASK)

function GorgonMask:BlockShootDelayed(player)
	if not player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_GORGON_MASK)
	or not GorgonMask:GetData(player).Active then return end

	GorgonMask:UpdateCanShoot(player)
end
EdithRestored:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.LATE, GorgonMask.BlockShootDelayed)

---@param player EntityPlayer
function GorgonMask:PlayerEffectUpdate(player)
	if not player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_GORGON_MASK) then
		local data = GorgonMask:GetData(player)

		if data.Active then
			data.Active = false
			GorgonMask:UpdateCanShoot(player)
		end
	end

	local data = GorgonMask:GetData(player)
	if not data.Active then return end

	local room = Game():GetRoom()
	local direction = TSIL.Direction.DirectionToVector(player:GetHeadDirection())
	local count = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and 2 or 1
	local ref

	for _, npc in ipairs(Helpers.GetEnemies()) do
		if room:CheckLine(player.Position, npc.Position, 3) then
			if (direction.X == 0 and math.abs(npc.Position.X - player.Position.X) <= GorgonMask.FREEZE_SIZE and
			((player.Position * direction).Y > 0 and npc.Position.Y > player.Position.Y or -- Down
			(player.Position * direction).Y < 0 and npc.Position.Y < player.Position.Y) -- Up
		)
		or (direction.Y == 0 and math.abs(npc.Position.Y - player.Position.Y) <= GorgonMask.FREEZE_SIZE and
			((player.Position * direction).X > 0 and npc.Position.X > player.Position.X or -- Right
			(player.Position * direction).X < 0 and npc.Position.X < player.Position.X) -- Left
		) then
				ref = ref or EntityRef(player)
				npc:AddFreeze(ref, 90 * count)
			end
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, GorgonMask.PlayerEffectUpdate)