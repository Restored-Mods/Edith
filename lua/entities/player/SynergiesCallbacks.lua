local Synergies = {}

Synergies.Items = {}
Synergies.Trinkets = {}

local itemsSynergiesTable = {
	vanilla = {
		"Apple",
		"ALumpOfCoal",
		"BallOfTar",
		"BloodClot",
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
		"Glaucoma",
		"Godhead",
		"GodsFlesh",
		"Haemolacria",
		"HeadOfTheKeeper",
		--"HolyLight", Disabled since damage of light beam doesn't update
		"Ipecac",
		"IronBar",
		"KnockoutDrops",
		"LittleHorn",
		"Lodestone",
		"MomsContacts",
		"MomsEyeshadow",
		--"MomsKnife",
		"MomsPerfume",
		"MonstrosLung",
		"MrMega",
		"Mucormycosis",
		"MysteriousLiquid",
		"OcularRift",
		"Parasitoid",
		"Peeper",
		"Pisces",
		"PlaydoughCookie",
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
}

local trinketsSynergiesTable = {
	vanilla = {
		"Blister",
		"BlackTooth",
		"ChewedPen",
		"Jawbreaker",
		"NoseGoblin",
		"PinkyEye",
	},
}

for t, tab in pairs(itemsSynergiesTable) do
	for _, item in pairs(tab) do
		Synergies.Items[item] = include("lua.entities.player.StompSynergies." .. t .. ".items." .. item)
	end
end

for t, tab in pairs(trinketsSynergiesTable) do
	for _, trinket in pairs(tab) do
		Synergies.Trinkets[trinket] = include("lua.entities.player.StompSynergies." .. t .. ".trinkets." .. trinket)
	end
end

---@param player EntityPlayer
local function OnJump(_, player)
	for _, callback in ipairs(Isaac.GetCallbacks(EdithRestored.Enums.Callbacks.ON_EDITH_JUMPING)) do
		local params = callback.Param
		if
			params == nil
			or params.Item == nil and params.Trinket == nil
			or type(params.Item) == "number" and player:HasCollectible(callback.Param.Item)
			or type(params.Trinket) == "number" and player:HasTrinket(params.Trinket)
		then
			callback.Function(EdithRestored, player)
		end
	end
end
EdithRestored:AddCallback(
	JumpLib.Callbacks.POST_ENTITY_JUMP,
	OnJump,
	{ tag = "EdithJump", type = EntityType.ENTITY_PLAYER }
)

EdithRestored.Synergies = Synergies
