if not Encyclopedia then
	return
end

local Wiki = require("lua.mod_compat.encyclopedia.wiki")

-- Items

--Breath Mints
Encyclopedia.AddItem({
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_BREATH_MINTS,
	WikiDesc = Wiki.Peppermint,
})

--Salt Shaker
Encyclopedia.AddItem({
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALT_SHAKER,
	WikiDesc = Wiki.SaltShaker,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
	},
})

--Gorgon Mask
Encyclopedia.AddItem({
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_GORGON_MASK,
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
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS,
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
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_LITHIUM,
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
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS,
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
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_LOT_BABY,
	WikiDesc = Wiki.LotBaby,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_SHOP,
		Encyclopedia.ItemPools.POOL_BABY_SHOP
	},
})

--Pawn Baby
Encyclopedia.AddItem({
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY,
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
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY,
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
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_SODOM,
	WikiDesc = Wiki.Sodom,
	Pools = {
		Encyclopedia.ItemPools.POOL_DEVIL,
		Encyclopedia.ItemPools.POOL_GREED_DEVIL
	},
})

--[[Encyclopedia.AddItem({
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL,
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
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.TrinketType.TRINKET_PEPPER_GRINDER,
	WikiDesc = Wiki.PepperGrinder,
})

--Smelling Salts
Encyclopedia.AddTrinket({
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.TrinketType.TRINKET_SMELLING_SALTS,
	WikiDesc = Wiki.SmellingSalts,
})

--Salt Rock
Encyclopedia.AddTrinket({
	ModName = "RestoredEdith",
	Class = "RestoredEdith",
	ID = EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK,
	WikiDesc = Wiki.SaltRock,
})


-- Characters
Encyclopedia.AddCharacter({
    ModName = "RestoredEdith",
    Name = "Edith",
    ID = EdithRestored.Enums.PlayerType.EDITH,
	Sprite = Encyclopedia.RegisterSprite(EdithRestored.path .. "content/gfx/characterportraits.anm2", "Edith", 0),
	WikiDesc = Wiki.Edith,
})

--[[Encyclopedia.AddCharacterTainted({
    ModName = "RestoredEdith",
    Name = "Edith",
    Description = "The Effigy",
    ID = EdithRestored.Enums.PlayerType.EDITH_B,
	Sprite = Encyclopedia.RegisterSprite(EdithRestored.path .. "content/gfx/characterportraitsalt.anm2", "Edith", 0, EdithRestored.path .. "content/gfx/charactermenu_edithb.png"),
	WikiDesc = Wiki.TaintedEdith,
})]]

EdithRestored.Enums.Wiki = Wiki