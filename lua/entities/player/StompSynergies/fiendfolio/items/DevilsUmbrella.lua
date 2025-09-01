local DevilsUmbrella = {}

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
---@param force boolean
function DevilsUmbrella:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake, force)
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
