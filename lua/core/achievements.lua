---CHALLENGE UNLOCKS-------------------------------------------------
local Helpers = EdithRestored.Helpers
local marksA = EdithRestored.Enums.Achievements.Marks.ASide
local marksB = EdithRestored.Enums.Achievements.Marks.BSide
local pgd = Isaac.GetPersistentGameData()

local function AreMarksCompleted(...)
	for _, mark in ipairs({...}) do

	end
	return true
end

local achievementRequirements = {
	[1] = {
		Cond = function(compType)
			return pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.BLASTING_BOOTS)
			and not pgd:Unlocked(EdithRestored.Enums.Achievements.Misc.ROCKET_LACES)
		end,
		Achievement = EdithRestored.Enums.Achievements.Misc.ROCKET_LACES,
	},
	[2] = {
		Cond = function(compType)
			Isaac.GetCompletionMarks()
			return PlayerManager.AnyoneIsPlayerType(EdithRestored.Enums.PlayerType.EDITH_B)
			and not pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH)
		end,
		Achievement = EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH
	}
}

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
		if pgd:IsBossKilled(BossType.BEAST) and not pgd:Unlocked(EdithRestored.Enums.Achievements.Characters.EDITH) then
			Helpers.UnlockAchievement(EdithRestored.Enums.Achievements.Characters.EDITH, force)
		end
	end
end

EdithRestored:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, function(_, slot, selected, raw)
	UnlockEdith(selected, true)
	for _, ach in ipairs(achievementRequirements) do
		if ach.Cond() then
			Isaac.ExecuteCommand("achievement "..ach.Achievement)
		end
	end
end)

EdithRestored:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, load)
	UnlockEdith(true, true)
	for _, ach in ipairs(achievementRequirements) do
		if ach.Cond() then
			Helpers.UnlockAchievement(ach.Achievement)
		end
	end
end)

for challenge, achievement in pairs(EdithRestored.Enums.Challenges) do
	EdithRestored:AddCallback(ModCallbacks.MC_POST_CHALLENGE_DONE, function(_, id)
		Helpers.UnlockAchievement(achievement)
	end, achievement)
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
			Helpers.UnlockAchievement(EdithRestored.Enums.Achievements.CompletionMarks.PRUDENCE)
		end
	end
	if PlayerManager.AnyoneIsPlayerType(EdithRestored.Enums.PlayerType.EDITH_B) then
		if marksB[mark] then
			Helpers.UnlockAchievement(marksB[mark])
		end
	end
	if mark == CompletionType.BEAST then
		Helpers.UnlockAchievement(EdithRestored.Enums.Achievements.Characters.EDITH)
	end
	for _, ach in ipairs(achievementRequirements) do
		if ach.Cond(mark) then
			Helpers.UnlockAchievement(ach.Achievement)
		end
	end
end)

EdithRestored:AddCallback(ModCallbacks.MC_GET_CARD, function(_, rng, card, playing, runes, onlyrunes)
	if
		card == EdithRestored.Enums.Pickups.Cards.CARD_SOUL_EDITH
		and not pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH)
		or card == EdithRestored.Enums.Pickups.Cards.CARD_PRUDENCE and not pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.PRUDENCE)
		or card == EdithRestored.Enums.Pickups.Cards.CARD_REVERSE_PRUDENCE and not pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.REV_PRUDENCE)
	then
		return 0
	end
end)