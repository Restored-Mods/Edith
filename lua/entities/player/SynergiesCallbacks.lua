local Synergies = {}

local synergiesTable = {
	"BallOfTar",
	"Brimstone",
    "CommonCold",
    "DarkMatter",
    "DrFetus",
    "FireMind",
    --"HolyLight",
    "Ipecac",
    "IronBar",
    "MomsContacts",
    "MomsEyeshadow",
	"MomsPerfume",
	"MonstrosLung",
	"MysteriousLiquid",
    "Scorpio",
    "SpiderBite",
    "Technology",
	"TechX",
}

for _, item in pairs(synergiesTable) do
	include("lua.entities.player.StompSynergies." .. item)
end

---@param player EntityPlayer
---@param inPit boolean
function Synergies:OnStomp(player, _, inPit)
	if inPit then
		return
	end
	local dollarBillEffect = 0
	for _, callback in ipairs(Isaac.GetCallbacks(EdithRestored.Enums.Callbacks.ON_EDITH_LANDING)) do
		if
			callback.Param == nil
			or (
					callback.Param ~= nil
					and (
						player:HasCollectible(callback.Param)
						or player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_3_DOLLAR_BILL):RandomInt(1, 10) == 1
                        and player:HasCollectible(CollectibleType.COLLECTIBLE_3_DOLLAR_BILL)
                        and dollarBillEffect < 3
					)
				)
		then
            local isDollarBill = callback.Param ~= nil and not player:HasCollectible(callback.Param) and dollarBillEffect < 3
			if isDollarBill then
				dollarBillEffect = dollarBillEffect + 1
			end
			callback.Function(EdithRestored, player, EdithRestored:GetData(player).BombStomp, isDollarBill)
		end
	end
end
EdithRestored:AddCallback(
	JumpLib.Callbacks.ENTITY_LAND,
	Synergies.OnStomp,
	{ tag = "EdithJump", type = EntityType.ENTITY_PLAYER }
)

---@param player EntityPlayer
function Synergies:OnJump(player)
	for _, callback in ipairs(Isaac.GetCallbacks(EdithRestored.Enums.Callbacks.ON_EDITH_JUMPING)) do
		if callback.Param == nil or player:HasCollectible(callback.Param) then
			callback.Function(EdithRestored, player)
		end
	end
end
EdithRestored:AddCallback(
	JumpLib.Callbacks.POST_ENTITY_JUMP,
	Synergies.OnJump,
	{ tag = "EdithJump", type = EntityType.ENTITY_PLAYER }
)
