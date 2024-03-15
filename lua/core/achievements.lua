---CHALLENGE UNLOCKS-------------------------------------------------
local Helpers = include("lua.helpers.Helpers")

TC_SaltLady:AddCallback(ModCallbacks.MC_PRE_RENDER_CUSTOM_CHARACTER_MENU, function(_, id, pos, sprite)
	if id == TC_SaltLady.Enums.PlayerType.EDITH then
		local sprite = EntityConfig.GetPlayer(id):GetModdedMenuBackgroundSprite()
		local layerIcon = sprite:GetLayer(7)
		local layerName = sprite:GetLayer(8)
		if not Isaac.GetPersistentGameData():Unlocked(TC_SaltLady.Enums.Achievements.CompletionMarks.SALT_SHAKER) then
			layerIcon:SetSize(Vector.Zero)
			layerName:SetSize(Vector.Zero)
		else
			layerIcon:SetSize(Vector.One)
			layerName:SetSize(Vector.One)
		end
	end
end)

for challenge, achievement in pairs(TC_SaltLady.Enums.Challenges) do
	TC_SaltLady:AddCallback(ModCallbacks.MC_POST_CHALLENGE_DONE, function(_ , id)	
		Helpers.UnlockAchievement(achievement)
	end, challenge)
end

TC_SaltLady:AddCallback(ModCallbacks.MC_PRE_COMPLETION_EVENT, function(_, mark)	
	if PlayerManager.AnyoneIsPlayerType(TC_SaltLady.Enums.PlayerType.EDITH) then
		local marksA = {
			[CompletionType.MOMS_HEART] = TC_SaltLady.Enums.Achievements.CompletionMarks.SALTY_BABY,
			[CompletionType.ISAAC] = TC_SaltLady.Enums.Achievements.CompletionMarks.SALT_SHAKER,
			--[CompletionType.SATAN] = TC_SaltLady.Enums.Achievements.CompletionMarks.,
			[CompletionType.BOSS_RUSH] = TC_SaltLady.Enums.Achievements.CompletionMarks.RED_HOOD,
			[CompletionType.BLUE_BABY] = TC_SaltLady.Enums.Achievements.CompletionMarks.THUNDER_BOMBS,
			[CompletionType.LAMB] = TC_SaltLady.Enums.Achievements.CompletionMarks.SMELLING_SALTS,
			[CompletionType.MEGA_SATAN] = TC_SaltLady.Enums.Achievements.CompletionMarks.PAWN_BABY,
			[CompletionType.HUSH] = TC_SaltLady.Enums.Achievements.CompletionMarks.BLASTING_BOOTS,
			--[CompletionType.ULTRA_GREED] = TC_SaltLady.Enums.Achievements.CompletionMarks.,
			[CompletionType.ULTRA_GREEDIER] = TC_SaltLady.Enums.Achievements.CompletionMarks.GORGON_MASK,
			[CompletionType.DELIRIUM] = TC_SaltLady.Enums.Achievements.CompletionMarks.LITHIUM,
			--[CompletionType.MOTHER] = TC_SaltLady.Enums.Achievements.CompletionMarks.,
			[CompletionType.BEAST] = TC_SaltLady.Enums.Achievements.CompletionMarks.SODOM,
		}
		if mark == CompletionType.ULTRA_GREEDIER then -- make damn sure greedier unlocks greed too
			Helpers.UnlockAchievement(marksA[CompletionType.ULTRA_GREED])
		end
		if marksA[mark] then
			Helpers.UnlockAchievement(marksA[mark])
		end
		if Isaac.AllMarksFilled(TC_SaltLady.Enums.PlayerType.EDITH) == 2 then
			Helpers.UnlockAchievement(TC_SaltLady.Enums.Achievements.CompletionMarks.LOT_BABY)
		end
	end
end)