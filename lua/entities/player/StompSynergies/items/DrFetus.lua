local DrFetus = {}

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function DrFetus:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
    if bombLanding then return end
    EdithRestored.Game:BombExplosionEffects(player.Position, player.Damage * 5, player.TearFlags, Color.Default, player, 1, true, false)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	DrFetus.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_DR_FETUS }
)

return DrFetus