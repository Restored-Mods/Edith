---CHALLENGE UNLOCKS-------------------------------------------------
local Helpers = include("lua.helpers.Helpers")

local marksA = {
	[CompletionType.MOMS_HEART] = EdithCompliance.Enums.Achievements.CompletionMarks.SALTY_BABY,
	[CompletionType.ISAAC] = EdithCompliance.Enums.Achievements.CompletionMarks.SALT_SHAKER,
	[CompletionType.SATAN] = EdithCompliance.Enums.Achievements.CompletionMarks.LANDMINE,
	[CompletionType.BOSS_RUSH] = EdithCompliance.Enums.Achievements.CompletionMarks.RED_HOOD,
	[CompletionType.BLUE_BABY] = EdithCompliance.Enums.Achievements.CompletionMarks.THUNDER_BOMBS,
	[CompletionType.LAMB] = EdithCompliance.Enums.Achievements.CompletionMarks.SMELLING_SALTS,
	[CompletionType.MEGA_SATAN] = EdithCompliance.Enums.Achievements.CompletionMarks.PAWN_BABY,
	[CompletionType.HUSH] = EdithCompliance.Enums.Achievements.CompletionMarks.BLASTING_BOOTS,
	--[CompletionType.ULTRA_GREED] = EdithCompliance.Enums.Achievements.CompletionMarks.,
	[CompletionType.ULTRA_GREEDIER] = EdithCompliance.Enums.Achievements.CompletionMarks.GORGON_MASK,
	[CompletionType.DELIRIUM] = EdithCompliance.Enums.Achievements.CompletionMarks.LITHIUM,
	--[CompletionType.MOTHER] = EdithCompliance.Enums.Achievements.CompletionMarks.,
	[CompletionType.BEAST] = EdithCompliance.Enums.Achievements.CompletionMarks.SODOM,
}

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

if not ImGui.ElementExists("tcMods") then
    ImGui.CreateMenu("tcMods", "TC Mods")
end

if not ImGui.ElementExists("edithCompliance") then
    ImGui.AddElement("tcMods", "edithCompliance", ImGuiElement.Menu, "Edith")
end

if ImGui.ElementExists("edithMenuUnlocks") then
    ImGui.RemoveElement("edithMenuUnlocks")
end

ImGui.AddElement("edithCompliance", "edithMenuUnlocks", ImGuiElement.MenuItem, "\u{f013} Unlocks")

if ImGui.ElementExists("edithWindowUnlocks") then
    ImGui.RemoveWindow("edithWindowUnlocks")
end

ImGui.CreateWindow("edithWindowUnlocks", "Edith Unlocks")

ImGui.LinkWindowToElement("edithWindowUnlocks", "edithMenuUnlocks")

local unlocksMarksA = {
	[CompletionType.MOMS_HEART] = "Mom's Heart",
	[CompletionType.ISAAC] = "Isaac",
	[CompletionType.SATAN] = "Satan",
	[CompletionType.BOSS_RUSH] = "Boss Rush",
	[CompletionType.BLUE_BABY] = "???",
	[CompletionType.LAMB] = "Lamb",
	[CompletionType.MEGA_SATAN] = "Mega Satan",
	[CompletionType.HUSH] = "Hush",
	[CompletionType.ULTRA_GREED] = "Ultra Greed",
	[CompletionType.ULTRA_GREEDIER] = "Ultra Greedier",
	[CompletionType.DELIRIUM] = "Delirium",
	[CompletionType.MOTHER] = "Mother",
	[CompletionType.BEAST] = "Beast",
}

ImGui.AddTabBar('edithWindowUnlocks', 'edithMarks')
ImGui.AddTab('edithMarks', 'edithUnlocksA', 'Edith')

for key, val in pairs(unlocksMarksA) do
	if ImGui.ElementExists("edithMark"..key) then
		ImGui.RemoveElement("edithMark"..key)
	end

	ImGui.AddCombobox("edithUnlocksA", "edithMark"..key, val, function(index, val)
		if index == 0 then
			Isaac.ExecuteCommand("lockachievement "..marksA[key])
		end
		Isaac.SetCompletionMark(EdithCompliance.Enums.PlayerType.EDITH, key, index)
		if index > 0 then
			if not Isaac.GetPersistentGameData():Unlocked(EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY) then
				Isaac.ExecuteCommand("achievement "..marksA[key])
			end
		end
	end, { 'None', 'Normal', 'Hard' }, 0, true)
	ImGui.AddCallback("edithMark"..key, ImGuiCallback.Render, function()
        ImGui.UpdateData("edithMark"..key, ImGuiData.Value, Isaac.GetCompletionMark(EdithCompliance.Enums.PlayerType.EDITH, key))
	end)
end

ImGui.AddCombobox("edithUnlocksA", "edithMarkAll", "All Marks", function(index, val)
	if index < 1 then
		Isaac.ExecuteCommand("lockachievement "..EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY)
	elseif not Isaac.GetPersistentGameData():Unlocked(EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY) then
		Isaac.ExecuteCommand("achievement "..EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY)
	end
end, { 'None', 'Unlocked' }, 0, true)