if not Encyclopedia then
	return
end

local Wiki = require("lua.mod_compat.encyclopedia.wiki")

-- Items
--Salt shaker
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_SALT_SHAKER,
	WikiDesc = Wiki.SaltShaker,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
	},
})

--[[Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL,
	WikiDesc = Wiki.TheChisel,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_SHOP,
	},
})]]

-- Trinkets
--Pepper grinder
Encyclopedia.AddTrinket({
	ModName = "Compliance",
	Class = "Compliance",
	ID = TC_SaltLady.Enums.TrinketType.TRINKET_PEPPER_GRINDER,
	WikiDesc = Wiki.PepperGrinder,
})

-- Characters
Encyclopedia.AddCharacter({
    ModName = "Compliance",
    Name = "Edith",
    ID = TC_SaltLady.Enums.PlayerType.EDITH,
	Sprite = Encyclopedia.RegisterSprite(TC_SaltLady.path .. "content/gfx/characterportraits.anm2", "Edith", 0),
	WikiDesc = Wiki.Edith,
})

--[[Encyclopedia.AddCharacterTainted({
    ModName = "Compliance",
    Name = "Edith",
    Description = "The Effigy",
    ID = TC_SaltLady.Enums.PlayerType.EDITH_B,
	Sprite = Encyclopedia.RegisterSprite(TC_SaltLady.path .. "content/gfx/characterportraitsalt.anm2", "Edith", 0, TC_SaltLady.path .. "content/gfx/charactermenu_edithb.png"),
	WikiDesc = Wiki.TaintedEdith,
})]]

TC_SaltLady.Enums.Wiki = Wiki