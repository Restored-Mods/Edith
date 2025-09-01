local TechX = {}

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function TechX:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	local techLaser = player:FireTechXLaser(player.Position, Vector.Zero, 30, player, 1)
	techLaser:SetTimeout(30)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	TechX.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_TECH_X }
)

return TechX