local HeadOfTheKeeper = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function HeadOfTheKeeper:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER)
    if (rng:RandomFloat() <= 0.05 or isDollarBill or isFruitCake) and #Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius()) > 0 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, player.Position, EntityPickup.GetRandomPickupVelocity(player.Position), nil)
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	HeadOfTheKeeper.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER, PoolFruitCake = true }
)

return HeadOfTheKeeper