--MinimapAPI and Minimap Items Compatibility
EdithRestored:AddModCompat("MinimapAPI", function()
	local Pickups = Sprite()
	Pickups:Load("gfx/ui/minimapitems/pickups_edith_icons.anm2", true)
	MinimapAPI:AddIcon("SoulOfEdithIcon", Pickups, "CustomIcons", 0)
	MinimapAPI:AddIcon("LithiumPillIcon", Pickups, "CustomIcons", 1)
	MinimapAPI:AddIcon("LithiumPillHorseIcon", Pickups, "CustomIcons", 2)
	MinimapAPI:AddPickup(
		"RuneSoulOfEdith",
		"SoulOfEdithIcon",
		5,
		300,
		EdithRestored.Enums.Pickups.Cards.CARD_SOUL_EDITH,
		MinimapAPI.PickupNotCollected,
		"runes",
		11050
	)
	MinimapAPI:AddPickup(
		"PillLithium",
		"LithiumPillIcon",
		5,
		70,
		EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM,
		MinimapAPI.PickupNotCollected,
		"pills",
		9001
	)
	MinimapAPI:AddPickup(
		"PillLithiumHorse",
		"LithiumPillHorseIcon",
		5,
		70,
		EdithRestored.Enums.Pickups.Pills.PILL_HORSE_LITHIUM,
		MinimapAPI.PickupNotCollected,
		"pills",
		9050
	)
end)
