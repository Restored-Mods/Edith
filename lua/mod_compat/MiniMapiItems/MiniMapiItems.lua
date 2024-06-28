--MinimapAPI and Minimap Items Compatibility
if not MinimapAPI then return end

local Pickups = Sprite()
Pickups:Load("gfx/ui/minimapitems/pickups_edith_icons.anm2", true)
MinimapAPI:AddIcon("SoulOfEdithIcon", Pickups, "CustomIcons", 0)
MinimapAPI:AddPickup(EdithCompliance.Enums.Pickups.Cards.CARD_SOUL_EDITH, "SoulOfEdithIcon", 5, 300, EdithCompliance.Enums.Pickups.Cards.CARD_SOUL_EDITH, MinimapAPI.PickupNotCollected, "cards", 1000)
if not MiniMapiItemsAPI then return end

local Collectibles = Sprite()
Collectibles:Load("gfx/ui/minimapitems/collectibles_edith_icons.anm2", true)
for _,item in pairs(EdithCompliance.Enums.CollectibleType) do
    MiniMapiItemsAPI:AddCollectible(item, Collectibles, "CustomIcons", item - EdithCompliance.Enums.CollectibleType.COLLECTIBLE_BREATH_MINTS)
end