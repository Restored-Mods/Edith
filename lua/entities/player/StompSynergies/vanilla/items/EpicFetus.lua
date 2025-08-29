local EpicFetus = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function EpicFetus:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
	return { Radius = radius + 10, Knockback = knockback + 10 }
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	EpicFetus.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_EPIC_FETUS }
)

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function EpicFetus:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
	return { StompDamage = stompDamage * 3 }
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE + 30,
	EpicFetus.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_EPIC_FETUS }
)

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function EpicFetus:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
    if bombLanding or player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then return end
    EdithRestored.Game:BombExplosionEffects(player.Position, player.Damage * 5, player.TearFlags, Color.Default, player, 1, true, false)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	EpicFetus.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_EPIC_FETUS }
)

return EpicFetus