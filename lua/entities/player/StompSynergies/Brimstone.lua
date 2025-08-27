local Brimstone = {}

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Brimstone:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
	player:FireBrimstoneBall(player.Position, Vector.Zero, Vector.Zero)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Brimstone.OnStomp,
	CollectibleType.COLLECTIBLE_BRIMSTONE
)

return Brimstone