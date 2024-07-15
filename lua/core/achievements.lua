---CHALLENGE UNLOCKS-------------------------------------------------
local Helpers = include("lua.helpers.Helpers")
local marksA = EdithCompliance.Enums.Achievements.Marks.ASide

EdithCompliance:AddCallback(ModCallbacks.MC_PRE_RENDER_CUSTOM_CHARACTER_MENU, function(_, id, pos, sprite)
	if id == EdithCompliance.Enums.PlayerType.EDITH then
		local sprite = EntityConfig.GetPlayer(id):GetModdedMenuBackgroundSprite()
		local layerIcon = sprite:GetLayer(7)
		local layerName = sprite:GetLayer(8)
		if not Isaac.GetPersistentGameData():Unlocked(EdithCompliance.Enums.Achievements.CompletionMarks.SALT_SHAKER) then
			layerIcon:SetSize(Vector.Zero)
			layerName:SetSize(Vector.Zero)
		else
			layerIcon:SetSize(Vector.One)
			layerName:SetSize(Vector.One)
		end
	end
end)

for challenge, achievement in pairs(EdithCompliance.Enums.Challenges) do
	EdithCompliance:AddCallback(ModCallbacks.MC_POST_CHALLENGE_DONE, function(_ , id)	
		Helpers.UnlockAchievement(achievement)
	end, challenge)
end

EdithCompliance:AddCallback(ModCallbacks.MC_PRE_COMPLETION_EVENT, function(_, mark)	
	if PlayerManager.AnyoneIsPlayerType(EdithCompliance.Enums.PlayerType.EDITH) then
		if mark == CompletionType.ULTRA_GREEDIER and marksA[CompletionType.ULTRA_GREED] then -- make damn sure greedier unlocks greed too
			Helpers.UnlockAchievement(marksA[CompletionType.ULTRA_GREED])
		end
		if marksA[mark] then
			Helpers.UnlockAchievement(marksA[mark])
		end
		if Isaac.AllMarksFilled(EdithCompliance.Enums.PlayerType.EDITH) == 2 then
			Helpers.UnlockAchievement(EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY)
		end
	end
end)