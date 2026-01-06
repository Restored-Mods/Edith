local BlockDisabledItems = {}


function BlockDisabledItems:OnGameStart(isContinue)
    if isContinue then return end

    local itemPool = Game():GetItemPool()

    for indexItem, disabledItem in ipairs(EdithRestored:GetDefaultFileSave("DisabledItems")) do
        if EdithRestored.Enums.CollectibleType[indexItem] then
            itemPool:RemoveCollectible(EdithRestored.Enums.CollectibleType[indexItem])
        end
    end
    for indexItem, disabledItem in ipairs(EdithRestored:GetDefaultFileSave("DisabledTrinkets")) do
        if EdithRestored.Enums.TrinketType[indexItem] then
            itemPool:RemoveTrinket(EdithRestored.Enums.TrinketType[indexItem])
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, BlockDisabledItems.OnGameStart)

local isDisablingItem = false

function BlockDisabledItems:PostGetCollectible(selectedItem, poolType, decrease, seed)
    if isDisablingItem then return end

    local isDisabledItem = false

    for indexItem, disabledItem in ipairs(EdithRestored:GetDefaultFileSave("DisabledItems")) do
        if selectedItem == EdithRestored.Enums.CollectibleType[indexItem] then
            isDisabledItem = true
            break
        end
    end

    if not isDisabledItem then return end

    local itemPool = Game():GetItemPool()

    local rng = RNG()
    rng:SetSeed(seed, 35)

    isDisablingItem = true
    local newItem = itemPool:GetCollectible(poolType, decrease, rng:Next() * 1000)
    isDisablingItem = false

    return newItem
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, BlockDisabledItems.PostGetCollectible)

function BlockDisabledItems:GetTrinket(selectedTrinket, rng)
    if isDisablingItem then return end

    local isDisabledItem = false

    for indexItem, disabledItem in ipairs(EdithRestored:GetDefaultFileSave("DisabledTrinkets")) do
        if selectedTrinket == EdithRestored.Enums.TrinketType[indexItem] then
            isDisabledItem = true
            break
        end
    end

    if not isDisabledItem then return end

    local itemPool = Game():GetItemPool()

    isDisablingItem = true
    local newItem = itemPool:GetTrinket(true)
    isDisablingItem = false

    return newItem
end
EdithRestored:AddCallback(ModCallbacks.MC_GET_TRINKET, BlockDisabledItems.GetTrinket)

local firstBlacklistTrinket = EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK
local lastBlacklistTrinket = EdithRestored.Enums.TrinketType.TRINKET_PEPPER_GRINDER

---@param trinket EntityPickup
function BlockDisabledItems:RerollDisabledTrinkets(trinket)
    if trinket.SubType >= firstBlacklistTrinket and trinket.SubType <= lastBlacklistTrinket then
        for disabledIndex, disabledItem in pairs(EdithRestored:GetDefaultFileSave("DisabledTrinkets")) do
            if trinket.SubType == EdithRestored.Enums.TrinketType[disabledIndex] then
                if trinket:GetSprite():IsPlaying("Appear") or trinket:IsShopItem() then
                    trinket:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, true, true)
                else
                    trinket:Remove()
                end
                break
            end
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, BlockDisabledItems.RerollDisabledTrinkets, PickupVariant.PICKUP_TRINKET)