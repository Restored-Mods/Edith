if not Encyclopedia then
	return
end

local Wiki = require("lua.mod_compat.encyclopedia.wiki")

-- Items

--Breath Mints
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_PEPPERMINT,
	WikiDesc = Wiki.Peppermint,
})

--Salt Shaker
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_SALT_SHAKER,
	WikiDesc = Wiki.SaltShaker,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
	},
})

--Gorgon Mask
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_GORGON_MASK,
	WikiDesc = Wiki.GorgonMask,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		Encyclopedia.ItemPools.POOL_CURSE,
		Encyclopedia.ItemPools.POOL_GREED_CURSE,
	},
})

--Thunder Bombs
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS,
	WikiDesc = Wiki.ThunderBombs,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_SHOP,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		Encyclopedia.ItemPools.POOL_BOMB_BUM,
		Encyclopedia.ItemPools.POOL_BATTERY_BUM,
	},
})

--Lithium Salts
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LITHIUM,
	WikiDesc = Wiki.LithiumSalts,
	Pools = {
		Encyclopedia.ItemPools.POOL_CURSE,
		Encyclopedia.ItemPools.POOL_GREED_CURSE,
		Encyclopedia.ItemPools.POOL_SHOP,
		Encyclopedia.ItemPools.POOL_GREED_SHOP,
		Encyclopedia.ItemPools.POOL_DEMON_BEGGAR,
	},
})

--Blasting Boots
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS,
	WikiDesc = Wiki.BlastingBoots,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_SHOP,
		Encyclopedia.ItemPools.POOL_CRANE_GAME,
		Encyclopedia.ItemPools.POOL_BOMB_BUM,
	},
})

--Lot Baby
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LOT_BABY,
	WikiDesc = Wiki.LotBaby,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_SHOP,
		Encyclopedia.ItemPools.POOL_BABY_SHOP
	},
})

--Pawn Baby
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY,
	WikiDesc = Wiki.PawnBaby,
	Pools = {
		Encyclopedia.ItemPools.POOL_SHOP,
		Encyclopedia.ItemPools.POOL_GREED_SHOP,
		Encyclopedia.ItemPools.POOL_SECRET,
		Encyclopedia.ItemPools.POOL_GREED_SECRET,
		Encyclopedia.ItemPools.POOL_WOODEN_CHEST,
		Encyclopedia.ItemPools.POOL_BABY_SHOP
	},
})

--Salty Baby
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY,
	WikiDesc = Wiki.SaltyBaby,
	Pools = {
		Encyclopedia.ItemPools.POOL_SHOP,
		Encyclopedia.ItemPools.POOL_GREED_SHOP,
		Encyclopedia.ItemPools.POOL_GOLDEN_CHEST,
		Encyclopedia.ItemPools.POOL_BABY_SHOP
	},
})

--Sodom
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_SODOM,
	WikiDesc = Wiki.Sodom,
	Pools = {
		Encyclopedia.ItemPools.POOL_DEVIL,
		Encyclopedia.ItemPools.POOL_GREED_DEVIL
	},
})

--[[Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL,
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
	ID = EdithCompliance.Enums.TrinketType.TRINKET_PEPPER_GRINDER,
	WikiDesc = Wiki.PepperGrinder,
})

--Smelling Salts
Encyclopedia.AddTrinket({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.TrinketType.TRINKET_SMELLING_SALTS,
	WikiDesc = Wiki.SmellingSalts,
})

--Salt Rock
Encyclopedia.AddTrinket({
	ModName = "Compliance",
	Class = "Compliance",
	ID = EdithCompliance.Enums.TrinketType.TRINKET_SALT_ROCK,
	WikiDesc = Wiki.SaltRock,
})


-- Characters
Encyclopedia.AddCharacter({
    ModName = "Compliance",
    Name = "Edith",
    ID = EdithCompliance.Enums.PlayerType.EDITH,
	Sprite = Encyclopedia.RegisterSprite(EdithCompliance.path .. "content/gfx/characterportraits.anm2", "Edith", 0),
	WikiDesc = Wiki.Edith,
})

--[[Encyclopedia.AddCharacterTainted({
    ModName = "Compliance",
    Name = "Edith",
    Description = "The Effigy",
    ID = EdithCompliance.Enums.PlayerType.EDITH_B,
	Sprite = Encyclopedia.RegisterSprite(EdithCompliance.path .. "content/gfx/characterportraitsalt.anm2", "Edith", 0, EdithCompliance.path .. "content/gfx/charactermenu_edithb.png"),
	WikiDesc = Wiki.TaintedEdith,
})]]

EdithCompliance.Enums.Wiki = Wiki