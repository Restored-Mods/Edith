local Synergies = {}

local synergiesTable = {
	"Apple",
	"BallOfTar",
	"BloodClot",
	"Brimstone",
	"ChemicalPeel",
	"CommonCold",
	"CompoundFracture",
	"DarkMatter",
	"DrFetus",
	"Euthanasia",
	"EyeSore",
	"FireMind",
	"Glaucoma",
	"GodsFlesh",
	"HeadOfTheKeeper",
	--"HolyLight", Disabled since damage of light beam doesn't update
	"Ipecac",
	"IronBar",
	"LittleHorn",
	"MomsContacts",
	"MomsEyeshadow",
	"MomsPerfume",
	"MonstrosLung",
	"MrMega",
	"Mucormycosis",
	"MysteriousLiquid",
	"Parasitoid",
	"Peeper",
	"PlaydoughCookie",
	"PupulaDuplex",
	"RottenTomato",
	"Scorpio",
	"SinusInfection",
	"SpiderBite",
	"SulfuricAcid",
	"Technology",
	"TechX",
	"Terra",
	"TheMulligan",
	"ToughLove",
}

for _, item in pairs(synergiesTable) do
	Synergies[item] = include("lua.entities.player.StompSynergies." .. item)
end

---@param player EntityPlayer
local function OnJump(_, player)
	for _, callback in ipairs(Isaac.GetCallbacks(EdithRestored.Enums.Callbacks.ON_EDITH_JUMPING)) do
		if callback.Param == nil or player:HasCollectible(callback.Param) then
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