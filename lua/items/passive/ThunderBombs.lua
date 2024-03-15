local ThunderBombs = {}
local Helpers = include("lua.helpers.Helpers")

---@param bomb Entity
---@return boolean
local function IsThunderBomb(bomb)

	local data = Helpers.GetData(bomb)
	if data and data.IsThunderBomb == true then return true end

	if not bomb then return false end
	if bomb.Type ~= EntityType.ENTITY_BOMB then return false end
	bomb = bomb:ToBomb()
	if bomb.Variant ~= BombVariant.BOMB_NORMAL and bomb.Variant ~= BombVariant.BOMB_GIGA and
	bomb.Variant ~= BombVariant.BOMB_ROCKET then return false end

	local player = Helpers.GetPlayerFromTear(bomb)
	if not player then return false end

	local isRandomNancyThunderBomb = false
	if player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) and not
	player:HasCollectible(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS)

		isRandomNancyThunderBomb = rng:RandomInt(100) < 7
	end

	if not player:HasCollectible(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS) and not isRandomNancyThunderBomb then return false end

	return true
end



---@param bomb EntityBomb
function ThunderBombs:BombUpdate(bomb)

	if not IsThunderBomb(bomb) then return end

	local player = Helpers.GetPlayerFromTear(bomb)
	local data = Helpers.GetData(bomb)
	local sprite = bomb:GetSprite()

	if data.IsBlankBombInstaDetonating then
		return
	end

	--put explosion logic here, use the repentogon hit list function to know which enemies to spawn the chain lightning effect on
	if sprite:IsPlaying("Explode") then
		-- Game():GetRoom():DoLightningStrike()
	end

end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, ThunderBombs.BombUpdate)


---@param bomb EntityBomb
function ThunderBombs:BombRender(bomb)

	if not IsThunderBomb(bomb) then return end

	local data = Helpers.GetData(bomb)

	if data.ThunderBombsOverlay then
		if bomb.FrameCount % 2 == 0 and not Game():IsPaused() then
			data.ThunderBombsOverlay:Update()
		end

		data.ThunderBombsOverlay:Render(Isaac.WorldToScreen(bomb.Position + bomb.PositionOffset))

	else
		ThunderBombs:ReplaceCostume(bomb)
	end

end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_BOMB_RENDER, ThunderBombs.BombRender)

---@param collectible CollectibleType | integer
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param VarData integer
---@param player EntityPlayer
function ThunderBombs:AddCharge(collectible, charge, firstTime, slot, VarData, player)
	if firstTime then
		for i = 0,2 do
			local item = player:GetActiveItem(i)
			local itemConf = Isaac.GetItemConfig():GetCollectible(item)
			if itemConf and itemConf.ChargeType ~= 2 then
				player:FullCharge(i)
			end
		end
	end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, ThunderBombs.AddCharge, TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS)

---@param bomb EntityBomb
function ThunderBombs:ReplaceCostume(bomb)
	local sprite = bomb:GetSprite()
	local data = Helpers.GetData(bomb)

	-- local bombentry = XMLData.GetEntryById(XMLNode.BOMBCOSTUME, 1)

	-- for i=1, #bombentry.rule do
	-- 	if bombentry.rule[i].body then
	-- 		if bomb:HasTearFlags(bombentry.rule[i].includeflags)
	-- end

	if not bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
		local layer = sprite:GetLayer("body")

		local path = string.sub(layer:GetSpritesheetPath(), 1, string.len(layer:GetSpritesheetPath())-4) .. "_gold.png"
		sprite:ReplaceSpritesheet(0, path, true)

		local color = sprite:GetLayer("body"):GetColor()
		color:SetColorize(1, 1, 2.5, 2.5)
		color:SetTint(255/255, 255/255, 800/255, 1)
		color:SetOffset(-100/255, -100/255, -100/255)
		layer:SetColor(color)
	end

	local overlay = Sprite()
	overlay:Load("gfx/items/pick ups/bombs/spark" .. math.floor(bomb:GetScale() * 2) .. ".anm2", true)
	overlay:Play("Idle", true)
	overlay.Color = Color(1,1,1,1)
	data.ThunderBombsOverlay = overlay

	data.IsThunderBomb = true
end