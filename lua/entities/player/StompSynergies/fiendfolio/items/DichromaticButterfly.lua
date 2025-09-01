local DichromaticButterfly = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function DichromaticButterfly:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.DICHROMATIC_BUTTERFLY)
	local randval = 30
	if player:HasTrinket(FiendFolio.ITEM.TRINKET.YIN_YANG_ORB) then
		randval = 20
	end
	local luck = math.max(math.min(math.floor(player.Luck), 7), -1)
	if rng:RandomInt(randval) < 5 + (luck * 2) then
		return { StompDamage = stompDamage * 1.25 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	DichromaticButterfly.OnStompModify,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.DICHROMATIC_BUTTERFLY }
)

return DichromaticButterfly