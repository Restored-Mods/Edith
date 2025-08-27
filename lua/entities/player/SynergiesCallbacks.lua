local Synergies = {}

Synergies.Items = {}
Synergies.Trinkets = {}

local itemsSynergiesTable = {
	"Apple",
	"BallOfTar",
	"BloodClot",
	"Brimstone",
	"ChemicalPeel",
	"CommonCold",
	"CompoundFracture",
	"DarkMatter",
	"DrFetus",
	"EightInchNails",
	"Euthanasia",
	"EyeSore",
	"FireMind",
	"Glaucoma",
	"GodsFlesh",
	"HeadOfTheKeeper",
	--"HolyLight", Disabled since damage of light beam doesn't update
	"Ipecac",
	"IronBar",
	"KnockoutDrops",
	"LittleHorn",
	"Lodestone",
	"MomsContacts",
	"MomsEyeshadow",
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
	"SinusInfection",
	"SpiderBite",
	"Stye",
	"SulfuricAcid",
	"Technology",
	"TechX",
	"Terra",
	"TheMulligan",
	"ToughLove",
	"Tropicamide",
}

local trinketsSynergiesTable = {
	"Blister",
	"BlackTooth",
	"ChewedPen",
	"Jawbreaker",
	"NoseGoblin",
	"PinkyEye",
}

for _, item in pairs(itemsSynergiesTable) do
	Synergies.Items[item] = include("lua.entities.player.StompSynergies.items." .. item)
end

for _, trinket in pairs(trinketsSynergiesTable) do
	Synergies.Trinkets[trinket] = include("lua.entities.player.StompSynergies.trinkets." .. trinket)
end

---@param player EntityPlayer
local function OnJump(_, player)
	for _, callback in ipairs(Isaac.GetCallbacks(EdithRestored.Enums.Callbacks.ON_EDITH_JUMPING)) do
		local params = callback.Param
		if params == nil or params.Item == nil and params.Trinket == nil
		or params.Item ~= nil and player:HasCollectible(callback.Param.Item)
		or params.Trinket ~= nil and player:HasTrinket(params.Trinket) then
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