local Synergies = {}

local synergiesTable = {
	"BallOfTar",
	"Brimstone",
	"CommonCold",
	"CompoundFracture",
	"DarkMatter",
	"DrFetus",
	"FireMind",
	"Glaucoma",
	"GodsFlesh",
	"HeadOfTheKeeper",
	--"HolyLight", Disabled since damage of light beam doesn't update
	"Ipecac",
	"IronBar",
	"MomsContacts",
	"MomsEyeshadow",
	"MomsPerfume",
	"MonstrosLung",
	"MysteriousLiquid",
	"Scorpio",
	"SinusInfection",
	"SpiderBite",
	"Technology",
	"TechX",
	"TheMulligan",
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
	local fruitCakeEffect = 0
	for _, callback in ipairs(Isaac.GetCallbacks(EdithRestored.Enums.Callbacks.ON_EDITH_LANDING)) do
		local params = callback.Param
		local isTbl = type(params) == "table"
		local item = isTbl and type(params.Item) == "number" and params.Item or type(params) == "number" and params
		local isDollarBill = isTbl
			and params.Pool3DollarBill
			and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_3_DOLLAR_BILL):RandomInt(1, 4) == 1
			and player:HasCollectible(CollectibleType.COLLECTIBLE_3_DOLLAR_BILL)
		local isFruitCake = isTbl
			and params.PoolFruitCake
			and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_FRUIT_CAKE):RandomInt(1, 4) == 1
			and player:HasCollectible(CollectibleType.COLLECTIBLE_FRUIT_CAKE)
		if
			params == nil
			or item == nil
			or player:HasCollectible(item)
			or isDollarBill and dollarBillEffect < 3
			or isFruitCake and fruitCakeEffect < 1
		then
			if item ~= nil and not player:HasCollectible(item) then
				if isDollarBill and dollarBillEffect < 3 and isFruitCake and fruitCakeEffect < 1 then
					local weight = WeightedOutcomePicker()
					weight:AddOutcomeWeight(1, 50)
					weight:AddOutcomeWeight(2, 50)
					if weight:PickOutcome(player:GetCollectibleRNG(item)) == 1 then
						dollarBillEffect = dollarBillEffect + 1
						isFruitCake = false
					else
						fruitCakeEffect = fruitCakeEffect + 1
						isDollarBill = false
					end
				elseif isDollarBill and dollarBillEffect < 3 then
					dollarBillEffect = dollarBillEffect + 1
				elseif isFruitCake and fruitCakeEffect < 1 then
					fruitCakeEffect = fruitCakeEffect + 1
				end
			end
			callback.Function(EdithRestored, player, EdithRestored:GetData(player).BombStomp, isDollarBill, isFruitCake)
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
