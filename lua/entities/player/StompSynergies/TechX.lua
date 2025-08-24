local TechX = {}

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
function TechX:OnTechXStomp(player, bombLanding, isDollarBill)
	local techLaser = player:FireTechXLaser(player.Position, Vector.Zero, 30, player, 1)
	techLaser:SetTimeout(30)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_LANDING,
	TechX.OnTechXStomp,
	CollectibleType.COLLECTIBLE_TECH_X
)
