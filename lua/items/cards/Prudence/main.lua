local Cards = {}

EdithRestored.HiddenItemManager:HideCostumes("Prudence")

function Cards:UsePrudence(prud, player, useflags)
    EdithRestored.HiddenItemManager:AddForRoom(player, CollectibleType.COLLECTIBLE_GUPPYS_EYE, -1, 1, "Prudence")
end
EdithRestored:AddCallback(ModCallbacks.MC_USE_CARD, Cards.UsePrudence, EdithRestored.Enums.Pickups.Cards.CARD_PRUDENCE)