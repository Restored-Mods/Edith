local DarkMatter = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function DarkMatter:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_DARK_MATTER)
    local chance = 1 / (3 - Helpers.Clamp(player.Luck, 0, 20) * 0.1)
	if rng:RandomFloat() <= chance or isDollarBill or isFruitCake then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddFear(EntityRef(player), 150)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	DarkMatter.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_DARK_MATTER, Pool3DollarBill = true }
)

return DarkMatter