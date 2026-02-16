EdithRestored:AddModCompat("FiendFolio", function ()
    local referenceItems = { --Code refferenced from https://steamcommunity.com/sharedfiles/filedetails/?id=3281491787&searchtext=d.edith--
        Passives = {
            { ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_RED_HOOD,    Reference = "Little Red Riding Hood" },
            { ID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS,    Reference = "Team Fortress 2" },
        },
        Trinkets = {
            { ID = EdithRestored.Enums.TrinketType.TRINKET_CHUNK_OF_AMBER,         Reference = "Four Souls" },
        },
    }
    for i = 1, #referenceItems.Passives do
        table.insert(FiendFolio.ReferenceItems.Passives, referenceItems.Passives[i])
    end
    for i = 1, #referenceItems.Trinkets do
        table.insert(FiendFolio.ReferenceItems.Trinkets, referenceItems.Trinkets[i])
    end
    FiendFolio:AddStackableItems({
			EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY,
			EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALT_PAWNS,
		})
    local golemTrinkets = {
        [EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK] = 0,
        [EdithRestored.Enums.TrinketType.TRINKET_CHUNK_OF_AMBER] = 0,
    }
    for id, rarity in pairs(golemTrinkets) do
        --FiendFolio.ITEM.ROCK[data.Name] = id
        FiendFolio.RockTrinkets[id] = rarity
    end
end)