local function InitSounds()
    if USoEI then
        for _,collectible in pairs(EdithCompliance.Enums.CollectibleType) do
            local collectibleConf = Isaac.GetItemConfig():GetCollectible(collectible)
            local sound = Isaac.GetSoundIdByName(collectibleConf.Name)
            if sound > 0 then
                USoEI.AddSoundToItem(collectible, sound)
            end
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, InitSounds)
