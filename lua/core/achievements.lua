---CHALLENGE UNLOCKS-------------------------------------------------
local Helpers = EdithRestored.Helpers
local marksA = EdithRestored.Enums.Achievements.Marks.ASide

EdithRestored:AddCallback(ModCallbacks.MC_PRE_RENDER_CUSTOM_CHARACTER_MENU, function(_, id, pos, sprite)
	if id == EdithRestored.Enums.PlayerType.EDITH then
		local sprite = EntityConfig.GetPlayer(id):GetModdedMenuBackgroundSprite()
		local layerIcon = sprite:GetLayer(7)
		local layerName = sprite:GetLayer(8)
		if not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.SALT_SHAKER) then
			layerIcon:SetSize(Vector.Zero)
			layerName:SetSize(Vector.Zero)
		else
			layerIcon:SetSize(Vector.One)
			layerName:SetSize(Vector.One)
		end
	end
end)

local function UnlockEdith(doUnlock, force)
	if doUnlock then
		local pgd = Isaac.GetPersistentGameData()
		if pgd:IsBossKilled(BossType.BEAST) and not pgd:Unlocked(EdithRestored.Enums.Achievements.Characters.EDITH) then
			Helpers.UnlockAchievement(EdithRestored.Enums.Achievements.Characters.EDITH, force)
		end
	end
end

EdithRestored:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, function(_, slot, selected, raw)
	UnlockEdith(selected, true)
end)

EdithRestored:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, load)
	UnlockEdith(true, true)
end)

for challenge, achievement in pairs(EdithRestored.Enums.Challenges) do
	EdithRestored:AddCallback(ModCallbacks.MC_POST_CHALLENGE_DONE, function(_ , id)	
		Helpers.UnlockAchievement(achievement)
	end, challenge)
end

EdithRestored:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, function(_, mark)	
	if PlayerManager.AnyoneIsPlayerType(EdithRestored.Enums.PlayerType.EDITH) then
		if mark == CompletionType.ULTRA_GREEDIER and marksA[CompletionType.ULTRA_GREED] then -- make damn sure greedier unlocks greed too
			Helpers.UnlockAchievement(marksA[CompletionType.ULTRA_GREED])
		end
		if marksA[mark] then
			Helpers.UnlockAchievement(marksA[mark])
		end
		if Isaac.AllMarksFilled(EdithRestored.Enums.PlayerType.EDITH) == 2 then
			Helpers.UnlockAchievement(EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH)
		end
	end
	if mark == CompletionType.BEAST then
		Helpers.UnlockAchievement(EdithRestored.Enums.Achievements.Characters.EDITH)
	end
end)

EdithRestored:AddCallback(ModCallbacks.MC_GET_CARD, function(_, rng, card, playing, runes, onlyrunes)
    if card == EdithRestored.Enums.Pickups.Cards.CARD_SOUL_EDITH and not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH) then
        return 0
    end
end)

local TEdithAch = Isaac.GetAchievementIdByName("Tainted Edith (Restored Edith)")

EdithRestored:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function (_, command, args)
	if not (command == "achievement" and args == tostring(TEdithAch)) then return end
	print("Tainted Edith isn't available yet, please wait for a future update")
	print("Reverting Tainted Edith unlock")

	Isaac.ExecuteCommand("lockachievement " .. tostring(TEdithAch))
end)