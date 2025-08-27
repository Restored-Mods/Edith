local TechX = {}

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function TechX:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
	local techLaser = player:FireTechXLaser(player.Position, Vector.Zero, 30, player, 1)
	techLaser:SetTimeout(30)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	TechX.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_TECH_X }
)

return TechX