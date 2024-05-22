local ThunderBombs = {}
local Helpers = include("lua.helpers.Helpers")

---@param bomb Entity
---@return boolean
local function IsThunderBomb(bomb)

	if not bomb then return false end
	if bomb.Type ~= EntityType.ENTITY_BOMB then return false end
	bomb = bomb:ToBomb()
	if BombFlagsAPI.HasCustomBombFlag(bomb, "THUNDER_BOMB") then return true end
	if bomb.Variant ~= BombVariant.BOMB_NORMAL and bomb.Variant ~= BombVariant.BOMB_GIGA and
	bomb.Variant ~= BombVariant.BOMB_ROCKET then return false end

	local player = Helpers.GetPlayerFromTear(bomb)
	if not player then return false end

	local isRandomNancyThunderBomb = false
	if player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) and not
	player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS)

		isRandomNancyThunderBomb = rng:RandomInt(100) < 7
	end

	if not player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS) and not isRandomNancyThunderBomb then return false end
	BombFlagsAPI.AddCustomBombFlag(bomb, "THUNDER_BOMB")
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

	if sprite:IsPlaying("Explode") then
		Game():GetRoom():DoLightningStrike()
		Game():MakeShockwave(bomb.Position, .035, .01, 10)

		local ring = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THIN_RED, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, bomb.Position, Vector.Zero, player):ToLaser()
		ring.Radius = 80 * bomb.RadiusMultiplier
		ring.CollisionDamage = bomb.ExplosionDamage / 2
		ring:SetTimeout(10)
		ring:SetOneHit(false)
		ring.Parent = bomb
		ring.Color = Color.LaserNumberOne
		Helpers.GetData(ring).FromThunderBomb = true
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, ThunderBombs.BombUpdate)


function ThunderBombs:HandleRingDamage(laser) --this exists because it doesnt properly hit everything inside of it
	local data = Helpers.GetData(laser)

	if data and data.FromThunderBomb == true then
		for i, enemy in ipairs(Isaac.FindInRadius(laser.Position, laser.Radius, EntityPartition.ENEMY)) do
			enemy:TakeDamage(0, DamageFlag.DAMAGE_LASER | DamageFlag.DAMAGE_EXPLOSION, EntityRef(laser), 0)
		end
	end

end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, ThunderBombs.HandleRingDamage)
--



---@param bomb EntityBomb
function ThunderBombs:EntityHit(entity, dmg, flags, source, countdown)
	source = source.Entity

	local data = Helpers.GetData(source)
	if IsThunderBomb(source) or data and data.FromThunderBomb == true then
		local lightning = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CHAIN_LIGHTNING, 0, entity.Position, Vector.Zero, bomb):ToEffect()
		lightning:SetDamageSource(EntityType.ENTITY_PLAYER)
		lightning.CollisionDamage = source.CollisionDamage
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ThunderBombs.EntityHit)


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
EdithCompliance:AddCallback(ModCallbacks.MC_POST_BOMB_RENDER, ThunderBombs.BombRender)


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
EdithCompliance:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, ThunderBombs.AddCharge, EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS)

---@param player EntityPlayer
function ThunderBombs:TryPlaceBomb(player)
	local data = Helpers.GetData(player)
	local OnlyStomps = TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "OnlyStomps")
	if (data.LockBombs or OnlyStomps == 2) and Helpers.IsPlayerEdith(player, true, false) then return end
	if not player:HasGoldenBomb() and player:GetNumBombs() == 0 and Helpers.CanMove(player) then
		local chargeRemove = nil
		local slot = 0
		for i = 0, 2 do
			local item = player:GetActiveItem(i)
			slot = i
			if item > 0 and ItemConfig.Config.IsValidCollectible(item) then
				local itemConf = Isaac.GetItemConfig():GetCollectible(item)
				local chargeType = itemConf.ChargeType
				if chargeType == 1 then
					if Helpers.GetCharge(player, i) >= itemConfig.MaxCharges then
						chargeRemove = itemConfig.MaxCharges
						break
					end
				end
				if chargeType == 2 then
					if Helpers.GetCharge(player, i) >= 1 then
						chargeRemove = 1
						break
					end
				end
			end
		end
		if chargeRemove then
			player:AddActiveCharge(chargeRemove, slot, true, false, true)
			local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, 0, BombFlagsAPI.GetCustomBombFlags(player), player.Position, Vector.Zero, player):ToBomb()
			bomb.TearFlags = player:GetBombFlags()
		end
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_PRE_PLAYER_USE_BOMB, ThunderBombs.TryPlaceBomb)


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

	BombFlagsAPI.HasCustomBombFlag(bomb, "THUNDER_BOMB")
end