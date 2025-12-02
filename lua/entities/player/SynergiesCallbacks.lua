EdithRestored.Synergies = {}
local Helpers = EdithRestored.Helpers

local conditions = {
	vanilla = function()
		return true
	end,
	fiendfolio = function()
		return FiendFolio ~= nil
	end,
}

local itemsSynergiesTable = {
	vanilla = {
		"Apple",
		"ALumpOfCoal",
		"BallOfTar",
		"BloodClot",
		"BobsCurse",
		"Brimstone",
		"ChemicalPeel",
		"CommonCold",
		"CompoundFracture",
		"CricketsBody",
		"DarkMatter",
		"DrFetus",
		"EightInchNails",
		"EpicFetus",
		"Euthanasia",
		"Explosivo",
		"EyeSore",
		"FireMind",
		"GhostBombs",
		"Glaucoma",
		"Godhead",
		"GodsFlesh",
		"Haemolacria",
		"HeadOfTheKeeper",
		--"HolyLight", Disabled since damage of light beam doesn't update
		"Ipecac",
		"IronBar",
		"JacobsLadder",
		"KnockoutDrops",
		"LittleHorn",
		"Lodestone",
		"MomsContacts",
		"MomsEyeshadow",
		"MomsKnife",
		"MomsPerfume",
		"MonstrosLung",
		"MrMega",
		"Mucormycosis",
		"MysteriousLiquid",
		"OcularRift",
		"Parasitoid",
		"Peeper",
		"Pisces",
		"Proptosis",
		"PupulaDuplex",
		"RottenTomato",
		"Scorpio",
		"SerpentsKiss",
		"SinusInfection",
		"SpiderBite",
		"Stye",
		"SulfuricAcid",
		"Technology",
		"TechX",
		"Terra",
		"TheMulligan",
		"TheParasite",
		"ToughLove",
		"Tropicamide",
		"Uranus",
	},
	fiendfolio = { 
		"BeeSkin",
		"BridgeBombs",
		"Crucifix",
		"DevilsUmbrella",
		"DichromaticButterfly",
		"EmojiGlasses",
		"HypnoRing",
		"ImpSoda",
		"LawnDarts",
		"LeftoverTakeout",
		"Musca",
		"NuggetBombs",
		"Pinhead",
		"PrankCookie",
		"RubberBullets",
		"SlippysGuts",
		"SmashTrophy",
		"Telebombs",
		"TimeItself",
		"ToyPiano",
	},
}

local trinketsSynergiesTable = {
	vanilla = {
		"Blister",
		"BlackTooth",
		"BlastingCap",
		"BobsBladder",
		"ChewedPen",
		"Jawbreaker",
		"NoseGoblin",
		"PinkyEye",
		"ShortFuse",
	},
	fiendfolio = {
		"FortuneWorm",
		"YingYangOrb",
	},
}

local function LoadScripts()
	Helpers.AddStompPool(CollectibleType.COLLECTIBLE_3_DOLLAR_BILL, true, "Pool3DollarBill", 3)
	Helpers.AddStompPool(CollectibleType.COLLECTIBLE_FRUIT_CAKE, true, "PoolFruitCake", 1)
	Helpers.AddStompPool(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE, true, "PoolPlaydoughCookie", 2, 0.5)
	if FiendFolio then
		Helpers.AddStompPool(FiendFolio.ITEM.COLLECTIBLE.EMOJI_GLASSES, true, "PoolFFEmojiGlases", 1, 0.5)
	end
	for t, tab in pairs(itemsSynergiesTable) do
		if conditions[t] and conditions[t]() then
			if not EdithRestored.Synergies[t] then
				EdithRestored.Synergies[t] = {}
			end
			if not EdithRestored.Synergies[t].Items then
				EdithRestored.Synergies[t].Items = {}
			end
			for _, item in pairs(tab) do
				if EdithRestored.Synergies[t].Items[item] == nil then
					EdithRestored.Synergies[t].Items[item] = include("lua.entities.player.StompSynergies." .. t .. ".items." .. item)
				end
			end
		end
	end

	for t, tab in pairs(trinketsSynergiesTable) do
		if conditions[t] and conditions[t]() then
			if not EdithRestored.Synergies[t] then
				EdithRestored.Synergies[t] = {}
			end
			if not EdithRestored.Synergies[t].Trinkets then
				EdithRestored.Synergies[t].Trinkets = {}
			end
			for _, trinket in pairs(tab) do
				if EdithRestored.Synergies[t].Trinkets[trinket] == nil then
					EdithRestored.Synergies[t].Trinkets[trinket] = include("lua.entities.player.StompSynergies." .. t .. ".trinkets." .. trinket)
				end
			end
		end
	end
end

LoadScripts()

EdithRestored:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
	LoadScripts()
end)

---@param player EntityPlayer
---@param config PassedJumpConfig
local function OnJump(_, player, config)
	EdithRestored:GetData(player).PreJumpPosition = player.Position
	for _, callback in ipairs(Isaac.GetCallbacks(EdithRestored.Enums.Callbacks.ON_EDITH_JUMPING)) do
		local params = callback.Param
		if
			params == nil
			or params.Item == nil and params.Trinket == nil
			or type(params.Item) == "number" and player:HasCollectible(callback.Param.Item)
			or type(params.Trinket) == "number" and player:HasTrinket(params.Trinket)
		then
			callback.Function(EdithRestored, player, config)
		end
	end
end
EdithRestored:AddCallback(
	JumpLib.Callbacks.POST_ENTITY_JUMP,
	OnJump,
	{ tag = "EdithJump", type = EntityType.ENTITY_PLAYER }
)

---@param player EntityPlayer
local function AfterJump(_, player)
	EdithRestored:GetData(player).PreJumpPosition = nil
end
EdithRestored:AddPriorityCallback(
	JumpLib.Callbacks.ENTITY_LAND,
	CallbackPriority.LATE + 100,
	AfterJump,
	{ type = EntityType.ENTITY_PLAYER }
)
