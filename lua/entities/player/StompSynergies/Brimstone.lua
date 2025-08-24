local Brimstone = {}

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
function Brimstone:OnBrimStomp(player, bombLanding, isDollarBill)
	player:FireBrimstoneBall(player.Position, Vector.Zero, Vector.Zero)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_LANDING,
	Brimstone.OnBrimStomp,
	CollectibleType.COLLECTIBLE_BRIMSTONE
)