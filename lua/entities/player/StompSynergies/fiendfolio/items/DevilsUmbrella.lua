local DevilsUmbrella = {}

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param force boolean
---@param isStompPool table
function DevilsUmbrella:OnStomp(player, stompDamage, bombLanding, force, isStompPool)
	local rng = player:GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.DEVILS_UMBRELLA)
	local data = EdithRestored:GetData(player)
	if rng:RandomInt(5) == 1 and data.PreJumpPosition then
		FiendFolio:firePiss(player, (player.Position - data.PreJumpPosition):Normalized())
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	DevilsUmbrella.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.DEVILS_UMBRELLA }
)

return DevilsUmbrella
