local Helpers = {}

local turretList = {{831,10,-1}, {835,10,-1}, {887,-1,-1}, {951,-1,-1}, {815,-1,-1}, {306,-1,-1}, {837,-1,-1}, {42,-1,-1}, {201,-1,-1}, 
{202,-1,-1}, {203,-1,-1}, {235,-1,-1}, {236,-1,-1}, {804,-1,-1}, {809,-1,-1}, {68,-1,-1}, {864,-1,-1}, {44,-1,-1}, {218,-1,-1}, {877,-1,-1},
{893,-1,-1}, {915,-1,-1}, {291,-1,-1}, {295,-1,-1}, {404,-1,-1}, {409,-1,-1}, {903,-1,-1}, {293,-1,-1}, {964,-1,-1},}


local function RemoveStoreCreditFromPlayer(player) -- Partially from FF
	local t0 = player:GetTrinket(0)
	local t1 = player:GetTrinket(1)
	
	if t0 & TrinketType.TRINKET_ID_MASK == TrinketType.TRINKET_STORE_CREDIT then
		player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
		return
	elseif t1 & TrinketType.TRINKET_ID_MASK == TrinketType.TRINKET_STORE_CREDIT then
		player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
		return
	end
	player:TryRemoveSmeltedTrinket(TrinketType.TRINKET_STORE_CREDIT)
end

local function TryRemoveStoreCredit(player)
	if Game():GetRoom():GetType() == RoomType.ROOM_SHOP then
		if player:HasTrinket(TrinketType.TRINKET_STORE_CREDIT) then
			RemoveStoreCreditFromPlayer(player)
		else
			for _,player in ipairs(Helpers.Filter(Helpers.GetPlayers(), function(_, player) return player:HasTrinket(TrinketType.TRINKET_STORE_CREDIT) end)) do
				RemoveStoreCreditFromPlayer(player)
				return
			end
		end
	end
end

function Helpers.HereticBattle(enemy)
	local room = Game():GetRoom()
	if room:GetType() == RoomType.ROOM_BOSS and room:GetBossID() == 81 and enemy.Type == EntityType.ENTITY_EXORCIST then
		return true
	end
	return false
end


function Helpers.IsTurret(enemy)
	for _,e in ipairs(turretList) do
		if e[1] == enemy.Type and (e[2] == -1 or e[2] == enemy.Variant) and (e[3] == -1 or e[3] == enemy.SubType) then
			return true
		end
	end
	return false
end

function Helpers.IsLost(player)
    return player:GetHealthType() == HealthType.NO_HEALTH and player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B
end

function Helpers.IsGhost(player)
    return player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) or Helpers.IsLost(player)
end

function Helpers.CanCollectCustomShopPickup(player, pickup)
	if pickup:IsShopItem() and (pickup.Price > 0 and player:GetNumCoins() < pickup.Price or not player:IsExtraAnimationFinished())
	or pickup.Wait > 0 then
		return false
	end
	return true
end

function Helpers.CollectCustomPickup(player,pickup)
	if not Helpers.CanCollectCustomShopPickup(player, pickup) then
		return pickup:IsShopItem()
	end
	if not pickup:IsShopItem() then
		pickup:GetSprite():Play("Collect")
		pickup:Die()
	else
		if pickup.Price >= 0 or pickup.Price == PickupPrice.PRICE_FREE or pickup.Price == PickupPrice.PRICE_SPIKES then
			if pickup.Price == PickupPrice.PRICE_SPIKES and not Helpers.IsGhost(player) then
				local tookDamage = player:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				if not tookDamage then
					return pickup:IsShopItem()
				end
			end
			if pickup.Price >= 0 then
				player:AddCoins(-pickup.Price)
			end
			CustomHealthAPI.Library.TriggerRestock(pickup)
			TryRemoveStoreCredit(player)
			pickup:Remove()
			player:AnimatePickup(pickup:GetSprite(), true)
		end
	end
	if pickup.OptionsPickupIndex ~= 0 then
		local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
		for _, entity in ipairs(pickups) do
			if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
			(entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
			then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
				entity:Remove()
			end
		end
	end
	return nil
end
	
---@param enemy Entity
---@param allEnemies boolean?
---@return boolean
function Helpers.IsEnemy(enemy, allEnemies)
	allEnemies = allEnemies or false
	return enemy and (enemy:IsVulnerableEnemy() or allEnemies) and enemy:IsActiveEnemy() and enemy:IsEnemy()
	and not EntityRef(enemy).IsFriendly
end

---@param allEnemies boolean | nil
---@param noBosses boolean | nil
---@return EntityNPC[]
function Helpers.GetEnemies(allEnemies, noBosses)
	local enemies = {}
	for _,enemy in ipairs(Isaac.GetRoomEntities()) do
		enemy = enemy:ToNPC()
		if Helpers.IsEnemy(enemy, allEnemies) then
			if not enemy:IsBoss() or (enemy:IsBoss() and not noBosses) then
				if enemy.Type == EntityType.ENTITY_ETERNALFLY then
					enemy:Morph(EntityType.ENTITY_ATTACKFLY,0,0,-1)
				end
				if not Helpers.HereticBattle(enemy) and not Helpers.IsTurret(enemy) and enemy.Type ~= EntityType.ENTITY_BLOOD_PUPPY then
					table.insert(enemies,enemy)
				end
			end
		end
	end
	return enemies
end


function Helpers.Lerp(a, b, t, speed)
	speed = speed or 1
	return a + (b-a) * speed * t
end

function Helpers.Sign(x)
	return x >= 0 and 1 or -1
end

function Helpers.IsMenuing()
	if ModConfigMenu and ModConfigMenu.IsVisible or DeadSeaScrollsMenu and DeadSeaScrollsMenu.OpenedMenu then return true end
	return false
end

function Helpers.InBoilerMirrorWorld()
	return FFGRACE and FFGRACE:IsBoilerMirrorWorld()
end

function Helpers.InMirrorWorld()
	return Game():GetRoom():IsMirrorWorld() or Helpers.InBoilerMirrorWorld()
end

---@param player EntityPlayer
function Helpers.CanMove(player, allowJump)
	local controlsEnabled = player.ControlsEnabled

	local isDead = player:IsDead()

	local isPlayingForbiddenExtraAnimation = false
	local forbiddenExtraAnimations = {
		"Appear",
		"Death",
		"TeleportUp",
		"TeleportDown",
		"Trapdoor",
		"MinecartEnter",
		"Jump",
		"LostDeath",
		"FallIn",
		"HoleDeath",
		"JumpOut",
		"LightTravel",
		"LeapUp",
		"SuperLeapUp",
		"LeapDown",
		"SuperLeapDown",
		"ForgottenDeath",
		"DeathTeleport",
		"EdithJump"
	}
	local playerSpr = player:GetSprite()
	for _, anim in ipairs(forbiddenExtraAnimations) do
		if playerSpr:IsPlaying(anim) and (anim ~= "Jump" or anim == "Jump" and not allowJump) then
			isPlayingForbiddenExtraAnimation = true
			break
		end
	end

	return controlsEnabled and not isDead and not isPlayingForbiddenExtraAnimation
end

function Helpers.CantMove(player)
	return not (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) or player:IsCoopGhost() or player:HasCurseMistEffect())
end

function Helpers.IsPlayerType(player, type)
	return player:GetPlayerType() == type
end

function Helpers.GetPlayerIndex(player)
    local id = 1
	if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
		id = 2
	end
	return player:GetCollectibleRNG(id):GetSeed()
end

function Helpers.GetEntityData(entity)
	if entity then
		if entity:ToPlayer() then
			local player = entity:ToPlayer()
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
				player = player:GetOtherTwin()
			end
			if not player then return {} end
			local index = tostring(Helpers.GetPlayerIndex(player))
			local data = TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "PlayerData")
			if not data[index] then
				data[index] = {}
			end
			if not data[index].BethsHeartIdentifier then
				data[index].BethsHeartIdentifier = tonumber(index)
			end
			if not data[index].Pepper then
				data[index].Pepper = 0
			end
			if not data[index].PrevPepper then
				data[index].PrevPepper = data[index].Pepper
			end
			if not data[index].LithiumUses then
				data[index].LithiumUses = 0
			end
			return data[index]
		elseif entity:ToFamiliar() then
			local index = tostring(entity:ToFamiliar().InitSeed)
			local data = TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "FamiliarData")
			if not data[index] then
				data[index] = {}
			end
			return data[index]
		end
	end
	return nil
end

function Helpers.RemoveEntityData(entity)
	if entity then
		local index
		if entity:ToPlayer() then
			local player = entity:ToPlayer()
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
				player = player:GetOtherTwin()
			end
			if not player then return end
			index = tostring(Helpers.GetPlayerIndex(player))
			local data = TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "PlayerData")
			data[index] = nil
		elseif entity:ToFamiliar() then
			index = tostring(entity:ToFamiliar().InitSeed)
			local data = TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "FamiliarData")
			data[index] = nil
		end
	end
end

function Helpers.GetBombExplosionRadius(bomb)
	local damage = bomb.ExplosionDamage
	local radiusMult = bomb.RadiusMultiplier
	local radius

	if damage >= 175.0 then
		radius = 105.0
	else
		if damage <= 140.0 then
			radius = 75.0
		else
			radius = 90.0
		end
	end

	return radius * radiusMult
end


function Helpers.GetBombRadiusFromDamage(damage,isBomber)
	if 300 <= damage then
		return 300.0
	elseif isBomber then
		return 155.0
	elseif 175.0 <= damage then
		return 105.0
	else
		if damage <= 140.0 then
			return 75.0
		else
			return 90.0
		end
	end
end

function Helpers.IsPlayerEdith(player, includeNormal, includeTainted)
	if includeNormal == nil then includeNormal = true end
	if includeTainted == nil then includeTainted = true end
	if player and ((Helpers.IsPlayerType(player,EdithCompliance.Enums.PlayerType.EDITH) and includeNormal) or Helpers.IsPlayerType(player,EdithCompliance.Enums.PlayerType.EDITH_B) and includeTainted) then
		return true
	end
	return false
end

--self explanatory
function Helpers.GetCharge(player,slot)
	return player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
end

function Helpers.BatteryChargeMult(player)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 2 or 1
end

function Helpers.GetUnchargedSlot(player,slot)
	local charge = Helpers.GetCharge(player, slot)
	local battery = Helpers.BatteryChargeMult(player)
	local item = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(slot))
	if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
		if charge < item.MaxCharges then
			return slot
		end
	elseif player:GetActiveItem(slot) > 0 and charge < item.MaxCharges * battery and player:GetActiveItem(slot) ~= CollectibleType.COLLECTIBLE_ERASER then
		return slot
	elseif slot < ActiveSlot.SLOT_POCKET then
		slot = Helpers.GetUnchargedSlot(player,slot + 1)
		return slot
	end
	return nil
end

function Helpers.OverCharge(player,slot,item)
	local effect = Isaac.Spawn(1000,49,1,player.Position+Vector(0,1),Vector.Zero,nil)
	effect:GetSprite().Offset = Vector(0,-22)
end

function Helpers.GetNearestEnemy(_pos)
	local distance = 9999999
	local closestPos = nil
	local enemies = Isaac.GetRoomEntities()
	for i=1, #enemies do
		local enemy = enemies[i]:ToNPC()
		if (enemy) and (enemy:IsVulnerableEnemy()) and (not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)) then
			if (_pos - enemy.Position):Length() < distance then
				closestPos = enemy
				distance = (_pos - enemy.Position):Length()
			end
		end
	end
	if distance == 9999999 then
		return Game():GetNearestPlayer(_pos)
	else
		return closestPos
	end
end

function Helpers.VecToDir(_vec)
	local angle = _vec:GetAngleDegrees()
	if (angle < 45 and angle >= -45) then
		return Direction.RIGHT
	elseif (angle < -45 and angle >= -135) then
		return Direction.UP
	elseif (angle > 45 and angle <= 135) then
		return Direction.DOWN
	end
	return Direction.LEFT
end

function Helpers.IsEdithNearEnemy(player) -- Enemy detection
	local data = Helpers.GetEntityData(player)
	for _, enemies in pairs(Isaac.FindInRadius(player.Position, 95)) do
		if enemies:IsVulnerableEnemy() and enemies:IsActiveEnemy() and data.Pepper < 5 and EntityRef(enemies).IsCharmed == false then
			return true
		end
	end
	return false
end

function Helpers.ChangePepperValue(player, amount)
	amount = amount or 0
	local data = Helpers.GetEntityData(player)
	if not data.Pepper then
		data.Pepper = 0
	end
	data.Pepper = math.max(0, math.min(5, data.Pepper + amount))
end

function Helpers.ChangeSprite(player, loading)
	local data = Helpers.GetEntityData(player)
	local sprite = player:GetSprite()
	if Helpers.IsPlayerEdith(player, true, false) then
		if sprite:GetFilename() ~= "gfx/edith.anm2" and not player:IsCoopGhost() then
			sprite:Load("gfx/edith.anm2", true)
			sprite:Update()
		end
		local changeCostume = data.MistCurse
		local human = ""
		if player:HasCurseMistEffect() and not data.MistCurse then
			data.MistCurse = true
		elseif not player:HasCurseMistEffect() and data.MistCurse then
			data.MistCurse = nil
			
		end
		if data.MistCurse then
			human = "_Human"
		end
		
		if changeCostume ~= data.MistCurse then
			for i=0,14 do
				if i ~= 13 then
					sprite:ReplaceSpritesheet(i,"gfx/characters/costumes/Character_001_Edith"..human..".png")
				end
			end
			local hoodSprite = "gfx/characters/costumes/Character_001_Edith_Hood"..human..".png"
			player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(EdithCompliance.Enums.Costumes.EDITH_HOOD), hoodSprite, 5)
			sprite:LoadGraphics()
		end
	elseif Helpers.IsPlayerEdith(player, false, true) then
		if sprite:GetFilename() ~= "gfx/edith_b.anm2" and not player:IsCoopGhost() then
			sprite:Load("gfx/edith_b.anm2", true)
			sprite:Update()
		end
		Helpers.ChangePepperValue(player)
		if data.Pepper == 0 then
			sprite:ReplaceSpritesheet(1, "gfx/characters/costumes/tedith_phase1.png")
			sprite:LoadGraphics()
		end
		if data.Pepper < 6 and (data.Pepper ~= data.PrevPepper or loading) then
			local hairSprite = "gfx/characters/costumes/tedithhair_phase"
			if data.Pepper < 3 then
				hairSprite = hairSprite.."1"
			else
				hairSprite = hairSprite..tostring(data.Pepper + 1)
			end
				--spritesheet stuff
			for i=0,14 do
				if i ~= 13 then
					sprite:ReplaceSpritesheet(i, "gfx/characters/costumes/tedith_phase"..(data.Pepper+1)..".png")
				end
			end
			sprite:LoadGraphics()
			hairSprite = hairSprite..".png"
			player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(EdithCompliance.Enums.Costumes.EDITH_B_HAIR), hairSprite, 5)
			data.PrevPepper = data.Pepper
		end
	elseif sprite:GetFilename() == "gfx/edith.anm2" or sprite:GetFilename() == "gfx/edith_b.anm2" then
		sprite:Load("gfx/001.000.player.anm2", true)
		sprite:Update()
	end
end

function Helpers.magicchalk_3f(player)
	local magicchalk = Isaac.GetItemIdByName("Magic Chalk")
	return magicchalk ~= -1 and player:HasCollectible(magicchalk)
end

function Helpers.Shuffle(list)
	local size, shuffled  = #list, list
    for i = size, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
    return shuffled
end

function Helpers.GetMaxCollectibleID()
    return Isaac.GetItemConfig():GetCollectibles().Size -1
end

function Helpers.GetMaxTrinketID()
    return Isaac.GetItemConfig():GetTrinkets().Size -1
end

function Helpers.tearsUp(firedelay, val)
    local currentTears = Helpers.ToTearsPerSecond(firedelay)
    local newTears = currentTears + val
    return math.max((30 / newTears) - 1, -0.75)
end

function Helpers.GetTrueRange(player)
    return player.Range / 40.0
end

function Helpers.rangeUp(range, val)
    local currentRange = range / 40.0
    local newRange = currentRange + val
    return math.max(1.0,newRange) * 40.0
end

function Helpers.PlaySND(sound, alwaysSfx)
	if (Options.AnnouncerVoiceMode == 2 or Options.AnnouncerVoiceMode == 0 and TSIL.Random.GetRandomInt(0, 3) == 0 or alwaysSfx) then
		SFXManager():Play(sound,1,0)
	end
end

function Helpers.GridAlignPosition(pos)
	local x = pos.X
	local y = pos.Y

	x = 40 * math.floor(x/40 + 0.5)
	y = 40 * math.floor(y/40 + 0.5)

	return Vector(x, y)
end

---@param enemy Entity
---@return boolean
function Helpers.IsTargetableEnemy(enemy)
    return enemy:IsEnemy() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and
    not (enemy:IsBoss() or enemy.Type == EntityType.ENTITY_FIREPLACE or
    (enemy.Type == EntityType.ENTITY_EVIS and enemy.Variant == 10))
end


---@param player EntityPlayer
function Helpers.DoesPlayerHaveRightAmountOfPickups(player)
    local has7Coins = player:GetNumCoins() % 10 == 7
    local has7Keys = player:GetNumKeys() % 10 == 7
    local has7Bombs = player:GetNumBombs() % 10 == 7
    local has7Poops = player:GetPoopMana() % 10 == 7

    return has7Bombs or has7Coins or has7Keys or has7Poops
end


---@param player EntityPlayer
function Helpers.GetLuckySevenTearChance(player)
    local has7Coins = player:GetNumCoins() % 10 == 7
    local has7Keys = player:GetNumKeys() % 10 == 7
    local has7Bombs = player:GetNumBombs() % 10 == 7
    local has7Poops = player:GetPoopMana() % 10 == 7

    local chance = 0

    if has7Coins then chance = chance + 2 end
    if has7Keys then chance = chance + 2 end
    if has7Bombs then chance = chance + 2 end
    if has7Poops then chance = chance + 2 end

    chance = math.max(0, math.min(15, chance + player.Luck))

    local mult = player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) and 3 or 1

    return chance * mult
end


---@param v1 Vector
---@param v2 Vector
---@return number
local function ScalarProduct(v1, v2)
    return v1.X * v2.X + v1.Y * v2.Y
end


---@param laser EntityLaser
---@param entity Entity
function Helpers.DoesLaserHitEntity(laser, entity)
    local targetSamples = {
        entity.Position,
        entity.Position + Vector(entity.Size * entity.SizeMulti.X, 0),
        entity.Position + Vector(-entity.Size * entity.SizeMulti.X, 0),
        entity.Position + Vector(0, entity.Size * entity.SizeMulti.Y),
        entity.Position + Vector(0, -entity.Size * entity.SizeMulti.Y),
    }
    ---@type VectorList
    ---@diagnostic disable-next-line: assign-type-mismatch
    local samplePoints = laser:GetSamples()
    local laserSize = laser.Size

    --From https://math.stackexchange.com/questions/190111/how-to-check-if-a-point-is-inside-a-rectangle
    for i = 0, samplePoints.Size-2, 1 do
        local point1 = samplePoints:Get(i)
        local point2 = samplePoints:Get(i+1)

        local side = (point1 - point2):Rotated(90):Resized(laserSize)

        local cornerA = point1 + side
        local cornerB = point2 + side
        local cornerD = point1 - side

        for _, targetPos in ipairs(targetSamples) do
            local AM = targetPos - cornerA
            local AB = cornerB - cornerA
            local AD = cornerD - cornerA
    
            local AMpAB = ScalarProduct(AM, AB)
            local ABpAB = ScalarProduct(AB, AB)
            local AMpAD = ScalarProduct(AM, AD)
            local ADpAD = ScalarProduct(AD, AD)
    
            if 0 < AMpAB and AMpAB < ABpAB and 0 < AMpAD and AMpAD < ADpAD then
                return true
            end
        end
    end
end

function Helpers.InBlastingBootsState(player)
	local data = Helpers.GetData(player)
	return data.JumpCounter and data.JumpCounter > 0
end

-----------------------------------
--Helper Functions (thanks piber)--
-----------------------------------

function Helpers.GetPlayers(ignoreCoopBabies)
	return Helpers.Filter(PlayerManager.GetPlayers(), function(_, player)
		return player.Variant == 0 or ignoreCoopBabies == false
	end)
end

function Helpers.GetPlayerFromTear(tear)
	for i=1, 2 do
		local check = nil
		if i == 1 then
			check = tear.Parent
		elseif i == 2 then
			check = tear.SpawnerEntity
		end
		if check then
			if check.Type == EntityType.ENTITY_PLAYER then
				return Helpers.GetPtrHashEntity(check):ToPlayer()
			elseif check.Type == EntityType.ENTITY_FAMILIAR and check.Variant == FamiliarVariant.INCUBUS then
				local data = Helpers.GetData(tear)
				data.IsIncubusTear = true
				return check:ToFamiliar().Player:ToPlayer()
			end
		end
	end
	return nil
end

function Helpers.GetPtrHashEntity(entity)
	if entity then
		if entity.Entity then
			entity = entity.Entity
		end
		for _, matchEntity in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType, false, false)) do
			if GetPtrHash(entity) == GetPtrHash(matchEntity) then
				return matchEntity
			end
		end
	end
	return nil
end


---@param entity Entity
---@return table | nil?
function Helpers.GetData(entity)
	if entity and entity.GetData then
		local data = entity:GetData()
		if not data.EdithCompliance then
			data.EdithCompliance = {}
		end
		return data.EdithCompliance
	end
	return nil
end

function Helpers.Contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

--ripairs stuff from revel
function ripairs_it(t,i)
	i=i-1
	local v=t[i]
	if v==nil then return v end
	return i,v
end
function ripairs(t)
	return ripairs_it, t, #t+1
end

--- Executes a function for each key-value pair of a table
function Helpers.ForEach(toIterate, funct)
	for index, value in pairs(toIterate) do
		funct(index, value)
	end
end

--filters a table given a predicate
function Helpers.Filter(toFilter, predicate)
	local filtered = {}

	for index, value in pairs(toFilter) do
		if predicate(index, value) then
			filtered[#filtered+1] = value
		end
	end

	return filtered
end

--returns a list of all players that have a certain item
function Helpers.GetPlayersByCollectible(collectibleId)
	local players = Helpers.GetPlayers()

	return Helpers.Filter(players, function(_, player)
		return player:HasCollectible(collectibleId)
	end)
end

--returns a list of all players that have a certain item effect (useful for actives)
function Helpers.GetPlayersWithCollectibleEffect(collectibleId)
	local players = Helpers.GetPlayers()

	return Helpers.Filter(players, function(_, player)
		return player:GetEffects():HasCollectibleEffect(collectibleId)
	end)
end

--returns a list of all players that have a certain item effect (useful for actives)
function Helpers.GetPlayersByNullEffect(nullItemId)
	local players = Helpers.GetPlayers()

	return Helpers.Filter(players, function(_, player)
		return player:GetEffects():HasNullEffect(nullItemId)
	end)
end

--returns a list of all players of certain type
function Helpers.GetPlayersByType(playerType)
	local players = Helpers.GetPlayers()
	if not playerType or type(playerType) ~= "number" or playerType < 0 then return players end

	return Helpers.Filter(players, function(_, player)
		return player:GetPlayerType() == playerType
	end)
end

function Helpers.UnlockAchievement(achievement, force) -- from Community Remix
	if not force then
		if not Game():AchievementUnlocksDisallowed() then
			if not Isaac.GetPersistentGameData():Unlocked(achievement) then
				Isaac.GetPersistentGameData():TryUnlock(achievement)
			end
		end
	else
		Isaac.GetPersistentGameData():TryUnlock(achievement)
	end
end


local function destroyRocksAndStuff(e, radius)
    local room = Game():GetRoom()
    radius = radius or 10
    for i = 0, (room:GetGridSize()) do
		local gent = room:GetGridEntity(i)
        if room:GetGridEntity(i) then
			if (e.Position - gent.Position):Length() <= radius then
				if (gent.Desc.Type ~= 16) then
					gent:Destroy()
				else
					if gent.Desc.Variant ~= 1 or gent.Desc.State ~= 1 then
						gent:Destroy()
					end
				end
            end
        end
    end
end

---@param radius number
---@param damage number
---@param bombDamage number
---@param knockback number
---@param player EntityPlayer
local function NewStompFunction(radius, damage, bombDamage, knockback, player) -- well its name is clear
	local enemiesInRadius = Helpers.Filter(Helpers.GetEnemies(), function(_, enemy) return enemy.Position:Distance(player.Position) <= radius end)
	for _,enemy in pairs(enemiesInRadius) do
		--enemy.Velocity = (enemy.Position - player.Position):Resized(knockback)
		enemy:AddKnockback(EntityRef(player), (enemy.Position - player.Position):Resized(knockback), 5, Helpers.IsPlayerEdith(player, true, false) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT))
	end
	Game():BombDamage(player.Position, damage, radius, true, player, TearFlags.TEAR_NORMAL, DamageFlag.DAMAGE_CRUSH | DamageFlag.DAMAGE_EXPLOSION, false)

	local bombEffectTriggered = bombDamage > 0

	if not bombEffectTriggered and Helpers.GetData(player).BombStomp then
		local callbacks = Isaac.GetCallbacks(EdithCompliance.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION_EFFECT)
		for _,callback in ipairs(callbacks) do
			if callback.Param == nil or callback.Param ~= nil and player:HasCollectible(callback.Param) then
				local ret = callback.Function(callback.Mod, player)
				if ret == true then
					bombEffectTriggered = true
					bombDamage = player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) and 185 or 100
					break
				end
			end
		end
	end

	if bombEffectTriggered then
		Game():BombExplosionEffects(player.Position, bombDamage, player:GetBombFlags(), Color.Default, player)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOBS_CURSE) then
			local poisonCloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect()
			poisonCloud:SetTimeout(150)
		end
				
		if player:HasCollectible(CollectibleType.COLLECTIBLE_SCATTER_BOMBS) then
			for _, enemies in pairs(enemiesInRadius) do
				Game():BombExplosionEffects(enemies.Position, bombDamage, 0, Color.Default, player, 0.5, true, player, 0)
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_BOMBS) then
			local ghost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, player.Position, Vector.Zero, player):ToEffect()
			ghost:SetTimeout(300)
			SFXManager():Play(SoundEffect.SOUND_FLOATY_BABY_ROAR, 1, 0, false, 1.75, 0)
		end
		if player:HasTrinket(TrinketType.TRINKET_BOBS_BLADDER) then
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, player.Position, Vector.Zero, player):ToEffect()
			creep.Timeout = 60
		end
		local callbacks = Isaac.GetCallbacks(EdithCompliance.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION)
		for _,callback in ipairs(callbacks) do
			if callback.Param == nil or callback.Param ~= nil and player:HasCollectible(callback.Param) then
				callback.Function(callback.Mod, player, bombDamage, radius)
			end
		end
	end

end

function Helpers.Stomp(player)
	local data = Helpers.GetData(player)
	if data.justStomped then return end
	local room = Game():GetRoom()
	local bdType = room:GetBackdropType()
	local chap4 = (bdType == 10 or bdType == 11 or bdType == 12 or bdType == 13 or bdType == 34 or bdType == 43 or bdType == 44)
	local level = Game():GetLevel():GetStage()
	
	local stompDamage = (1 + (level * 6 / 1.4) + player.Damage * 2.5)
	local bombDamage = 0
	local radius = 35
	local knockbackFormula = 15 * ((Helpers.IsPlayerEdith(player, true, false) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) and 2 or 1)

	-- reflecting tears stuff
	for _, projectile in pairs(Isaac.FindInRadius(player.Position, radius + 20, EntityPartition.BULLET)) do
		local projectileData = Helpers.GetData(projectile)
		projectileData.WasProjectileReflectedBy = player
	end
	-- reflecting tears stuff end

	-- yeah the en of that stuff
	if data.BombStomp ~= nil then
		if player:GetNumBombs() > 0 or player:HasGoldenBomb() then
		-- Check if edith has a golden bomb cause well using a golden bomb doesn't substract your bomb count
			if not player:HasGoldenBomb() then
				player:AddBombs(-1)
			end
			bombDamage = 100
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then -- Mr. Mega
				stompDamage = stompDamage * 1.15
				bombDamage = 185
				radius = radius * 1.3
			end
		end
	end
	NewStompFunction(radius, stompDamage, bombDamage, knockbackFormula, player)
	
	Game():ShakeScreen(10)
	
	if chap4 then	
		SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1, 0)
	else
		SFXManager():Play(SoundEffect.SOUND_STONE_IMPACT, 1, 0)
	end
	
	for i = 1, TSIL.Random.GetRandomInt(6, 9) do
		local randRockVel = Vector(TSIL.Random.GetRandomInt(-3, 3), TSIL.Random.GetRandomInt(-3, 3))
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, player.Position, randRockVel, nil)
	end
	if room:HasWater() then
		-- if not chap4 then
			local splashpitch = 0.9 + (TSIL.Random.GetRandomFloat(0, 1) / 10)
			local waterSplash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position + Vector(0, 2), Vector.Zero, player):ToEffect()
			waterSplash.SpriteScale = waterSplash.SpriteScale * 0.65
			SFXManager():Play(EdithCompliance.Enums.SFX.Edith.WATER_STOMP, 1, 0, false, splashpitch, 0)
		-- end
	else
		local poof
		if not chap4 then
			poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player):ToEffect()
		else
			poof = Isaac.Spawn(1000, 16, 3, player.Position, Vector.Zero, nil):ToEffect()
			if bdType == 13 then
				poof.Color = Color(0, 0, 0, 1, 0.3, 0.4, 0.6)
			elseif bdType == 34 then
				poof.Color = Color(0, 0, 0, 1, 0.62, 0.65, 0.62)
			elseif bdType == 43 then
				poof.Color = Color(0, 0, 0, 1, 0.55, 0.57, 0.55)
			end
		end
		poof.SpriteScale = poof.SpriteScale * 0.5
		poof:GetSprite().PlaybackSpeed = 2
	end
end

---@param x number
---@return number
function Helpers.EaseOutBack(x)
    local c1 = 1.70158
	local c3 = c1 + 1

	return 1 + c3 * (x - 1)^3 + c1 * (x - 1)^2
end

---@param player EntityPlayer
---@return boolean
function Helpers.IsPlayingExtraAnimation(player)
    local sprite = player:GetSprite()
    local anim = sprite:GetAnimation()

    local normalAnims = {
        ["WalkUp"] = true,
        ["WalkDown"] = true,
        ["WalkLeft"] = true,
        ["WalkRight"] = true
    }

    return not normalAnims[anim]
end


---@param num number
---@param dp integer
---@return number
function Helpers.Round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end


---By catinsurance
---@param maxFireDelay number
---@return number
function Helpers.ToTearsPerSecond(maxFireDelay)
    return 30 / (maxFireDelay + 1)
end


---By catinsurance
---@param tearsPerSecond number
---@return number
function Helpers.ToMaxFireDelay(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

---@param ... table[]
---@return table
function Helpers.MergeTables(...)
	local tables = {...}
	local t = tables[1]
	table.remove(tables, 1)
	for i, tab in ipairs(tables) do
		for _,v in pairs(tab) do
			table.insert(t, v)
		end
	end
	return t
end

---@param ... table[]
---@return table
function Helpers.MergeiTables(...)
	local tables = table.unpack(...)
    local t1 = tables[1]
    table.remove(tables, 1)
	for _,tab in ipairs(tables) do
        for _,v in ipairs(tab) do
            table.insert(t1, v)
        end
	end
	return t1
end

--#region bless Fiend Folio (you read that right)
local function runUpdates(tab) --This is from Fiend Folio
    for i = #tab, 1, -1 do
        local f = tab[i]
        f.Delay = f.Delay - 1
        if f.Delay <= 0 then
            f.Func()
            table.remove(tab, i)
        end
    end
end

local delayedFuncs = {}
function Helpers.scheduleForUpdate(foo, delay, callback)
    callback = callback or ModCallbacks.MC_POST_UPDATE
    if not delayedFuncs[callback] then
        delayedFuncs[callback] = {}
        EdithCompliance:AddCallback(callback, function()
            runUpdates(delayedFuncs[callback])
        end)
    end

    table.insert(delayedFuncs[callback], { Func = foo, Delay = delay })
end
--#endregion

---@param item CollectibleType | integer
---@return boolean
function Helpers.IsItemDisabled(item)
	for _, disabledItem in ipairs(TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "DisabledItems")) do
        if item == disabledItem then
            return true
        end
    end
	return false
end

EdithCompliance.Helpers = Helpers

return Helpers