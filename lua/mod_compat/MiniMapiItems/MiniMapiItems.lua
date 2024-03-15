--MinimapAPI and Minimap Items Compatibility
if not MinimapAPI then return end

local Pickups = Sprite()
Pickups:Load("gfx/ui/minimapitems/pickups_edith_icons.anm2", true)
MinimapAPI:AddIcon("SoulOfEdithIcon", Pickups, "CustomIcons", 0)
MinimapAPI:AddPickup(TC_SaltLady.Enums.Pickups.Cards.CARD_SOUL_EDITH, "SoulOfEdithIcon", 5, 300, TC_SaltLady.Enums.Pickups.Cards.CARD_SOUL_EDITH, MinimapAPI.PickupNotCollected, "cards", 1000)
if not MiniMapiItemsAPI then return end

local Collectibles = Sprite()
Collectibles:Load("gfx/ui/minimapitems/collectibles_edith_icons.anm2", true)
for _,item in pairs(TC_SaltLady.Enums.CollectibleType) do
    MiniMapiItemsAPI:AddCollectible(item, Collectibles, "CustomIcons", item - TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_PEPPERMINT)
end