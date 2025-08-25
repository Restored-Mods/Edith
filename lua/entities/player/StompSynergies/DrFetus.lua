local DrFetus = {}
local game = EdithRestored.Game

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
function DrFetus:OnDrFetusStomp(player, bombLanding, isDollarBill, isFruitCake)
    if bombLanding then return end
    game:BombExplosionEffects(player.Position, player.Damage * 5, player.TearFlags, Color.Default, player, 1, true, false)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_LANDING,
	DrFetus.OnDrFetusStomp,
	CollectibleType.COLLECTIBLE_DR_FETUS
)