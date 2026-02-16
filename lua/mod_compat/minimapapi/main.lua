--MinimapAPI and Minimap Items Compatibility
EdithRestored:AddModCompat("MinimapAPI", function()
	local Pickups = Sprite()
	Pickups:Load("gfx/ui/minimapitems/pickups_edith_icons.anm2", true)
	MinimapAPI:AddIcon("SoulOfEdithIcon", Pickups, "CustomIcons", 0)
	MinimapAPI:AddPickup(
		EdithRestored.Enums.Pickups.Cards.CARD_SOUL_EDITH,
		"SoulOfEdithIcon",
		5,
		300,
		EdithRestored.Enums.Pickups.Cards.CARD_SOUL_EDITH,
		MinimapAPI.PickupNotCollected,
		"runes",
		11050
	)
end)
