local Chisel = {}
local Helpers = include("lua.helpers.Helpers")

function Chisel:UseTheChisel(_, _, player)
	local ChiselSelection
	local data = Helpers.GetEntityData(player)
	local rng = player:GetCollectibleRNG(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL)
	Helpers.ChangePepperValue(player)
	local entities = Isaac.FindInRadius(player.Position, 99999, EntityPartition.ENEMY)
	local enemies = {}
		for _,ent in ipairs(entities) do
			if ent:IsActiveEnemy() and ent:IsVulnerableEnemy() then
				table.insert(enemies,ent)
			end
		end
	if #enemies > 0 and data.Pepper == 0 then
		local randomIndex = rng:RandomInt(#enemies) + 1
		local chosenEnemy = enemies[randomIndex]
		ChiselSelection = chosenEnemy
	else
		ChiselSelection = player
	end
	-- falling chisel stuff
	local chisel = Isaac.Spawn(EdithCompliance.Enums.Entities.FALLING_CHISEL.Type,EdithCompliance.Enums.Entities.FALLING_CHISEL.Variant,0,player.Position,Vector.Zero,player)
	Helpers.GetData(chisel).ChiselSelection = ChiselSelection
	local sprite = chisel:GetSprite()
	sprite:Load("gfx/chisel.anm2", true)
	sprite:Play("Firing", true)
	SFXManager():Play(SoundEffect.SOUND_SCYTHE_BREAK)
	
	Helpers.ChangeSprite(player,false)
	return true
end
EdithCompliance:AddCallback(ModCallbacks.MC_USE_ITEM, Chisel.UseTheChisel, EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL)

function Chisel:PepperLevel(player)
	if Helpers.IsPlayerEdith(player,false,true) then
		local data = Helpers.GetData(player)
		if not data.PepperTimer then
			data.PepperTimer = 60
		end
		if Helpers.IsEdithNearEnemy(player) then
			if data.PepperTimer > 0 then
				data.PepperTimer = data.PepperTimer - 1
			else
				data.PepperTimer = 60
				Helpers.ChangePepperValue(player, 1)
				SFXManager():Play(SoundEffect.SOUND_STONE_IMPACT)
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:AddCacheFlags(CacheFlag.CACHE_SPEED)
				player:EvaluateItems()
				Helpers.ChangeSprite(player,false)
			end
		else
			data.PepperTimer = 60
		end
		
		-- Pepper creep handling
		if data.CreepTimer == nil then
			data.CreepTimer = 0
		end
		data.CreepTimer = data.CreepTimer - 1
		if data.CreepTimer < 0 then
			data.CreepTimer = 0
		end
		if data.CreepTimer > 0 then
			 if Game():GetFrameCount()%5 == 0 then
				local creep = Isaac.Spawn(1000, 53, 0, player.Position, Vector(0,0), nil):ToEffect()
				local sprite = creep:GetSprite()
				sprite:Load("gfx/1000.092_creep (powder).anm2", true)
				sprite:ReplaceSpritesheet(0, "gfx/effect_blackpowder.png")
				local rng = player:GetCollectibleRNG(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL)
				local rngSprite = rng:RandomInt(6)+1
					sprite:Play("SmallBlood0"..rngSprite, true)
				creep.CollisionDamage = 0.4
			end
		end
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Chisel.PepperLevel)

function Chisel:Chisel_CacheEval(player, cacheFlag)
	local data = Helpers.GetEntityData(player)
	local sprite = player:GetSprite()
	if Helpers.IsPlayerEdith(player, false, true) then
		Helpers.ChangePepperValue(player)
		Helpers.ChangeSprite(player)
		-- Pepper Stats
		if cacheFlag  == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 0.25 * data.Pepper
		end
		if cacheFlag  == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.15 * data.Pepper
		end
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Chisel.Chisel_CacheEval)

function Chisel:HasBirthright(player)
	local data = Helpers.GetEntityData(player)
	if Helpers.IsPlayerEdith(player, false, true) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		for _, enemiesBR in pairs(Isaac.FindInRadius(player.Position, 20*data.Pepper)) do
			if enemiesBR:IsVulnerableEnemy() and enemiesBR:IsActiveEnemy() and data.Pepper < 5 and EntityRef(enemiesBR).IsCharmed == false then
				enemiesBR:AddSlowing(EntityRef(player), 1, 0.5, Color.Default)
			end
		end
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Chisel.HasBirthright)

function Chisel:ChiselAnm(chisel)
	if chisel.SpawnerType == EntityType.ENTITY_PLAYER then
		local player = chisel.SpawnerEntity:ToPlayer()
		local data = Helpers.GetData(chisel)
		local dataP = Helpers.GetEntityData(player)
		local rng = player:GetCollectibleRNG(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL)

		chisel.Position = data.ChiselSelection.Position
		local sprite = chisel:GetSprite()
		if sprite:IsEventTriggered("ChiselHurt") then
			if GetPtrHash(data.ChiselSelection) == GetPtrHash(player) then
				---@cast player EntityPlayer
				Helpers.ChangePepperValue(player)
				if dataP.Pepper == 0 and player:GetDamageCooldown() == 0 then
					player:TakeDamage(1, 0, EntityRef(nil), 1)
					SFXManager():Play(SoundEffect.SOUND_PESTILENCE_HEAD_EXPLODE)
					Game():SpawnParticles(player.Position, EffectVariant.BLOOD_PARTICLE, 50, 1, Color.Default)
					Game():Darken(1, 150)
					player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_CHEMICAL_PEEL, true)
					player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_SAD_ONION, false)
				elseif dataP.Pepper > 0 then		-- If you are peppered
					SFXManager():Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, 1, 0)
					Game():SpawnParticles(player.Position, EffectVariant.TOOTH_PARTICLE, 15, 1, Color(0.25, 0.25, 0.25, 1, 0, 0, 0))
					Helpers.ChangePepperValue(player, -1)
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					player:AddCacheFlags(CacheFlag.CACHE_SPEED)
					player:EvaluateItems()
				end
			-- Fall on an ememy instead
			elseif GetPtrHash(data.ChiselSelection) ~= GetPtrHash(player) then
				data.ChiselSelection:TakeDamage(rng:RandomInt(5)+1, 0, EntityRef(player), 1)
				if not data.ChiselSelection:IsDead() then
					if data.ChiselSelection:HasMortalDamage() then
						SFXManager():Play(SoundEffect.SOUND_PESTILENCE_HEAD_EXPLODE)
						Game():SpawnParticles(data.ChiselSelection.Position, EffectVariant.BLOOD_PARTICLE, 50, 1, Color.Default)
						Game():Darken(1, 150)
					else
						Game():SpawnParticles(data.ChiselSelection.Position, EffectVariant.BLOOD_PARTICLE, 10, 1.3, Color.Default)
						SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
					end
				end
			end
		end
		if sprite:IsFinished("Firing") and GetPtrHash(data.ChiselSelection) == GetPtrHash(player) then
			-- Pepper creep timing
			if Helpers.IsPlayerEdith(player,false,true) then
				if dataP.PrevPepper > 0 then
					Helpers.GetData(player).CreepTimer = (dataP.Pepper + 1) * 40 - 10--150
				end
				Helpers.ChangeSprite(player)
			end
			chisel:Remove()
		end
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Chisel.ChiselAnm, EdithCompliance.Enums.Entities.FALLING_CHISEL.Variant)

function Chisel:TEdithPepperBlock(player, damage, flags, source, cd)
	local dataP = Helpers.GetEntityData(player)
	if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) and not player:HasCollectible(CollectibleType.COLLECTIBLE_ISAACS_HEART)
	and TSIL.Random.GetRandomInt(1, 100) <= dataP.Pepper * 12 then
		return false
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, Chisel.TEdithPepperBlock, EdithCompliance.Enums.PlayerType.EDITH_B)

function Chisel:PreProjectileCollision(projectile, collider, low)
	if collider and collider:ToPlayer() then
		local player = collider:ToPlayer()
		if Helpers.IsPlayerEdith(player, false, true) then
			local dataP = Helpers.GetEntityData(player)
			if TSIL.Random.GetRandomInt(1, 100) <= dataP.Pepper * 12 then			
				projectile.Velocity = projectile.Velocity * -1
				projectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
				projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
				SFXManager():Play(SoundEffect.SOUND_BEEP, 1, 0, false, TSIL.Random.GetRandomFloat(0.8, 1.2))
			end
		end
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, Chisel.PreProjectileCollision)

function Chisel:TMinidith(familiar)
	local player = familiar.Parent or familiar.SpawnerEntity
	if player then
		if player:ToPlayer() then
			if Helpers.IsPlayerEdith(player:ToPlayer(), false, true) then
				local dataP = Helpers.GetEntityData(player)
				local sprite = EntityFamiliar:GetSprite()
				sprite:Load("gfx/minidith.anm2", true)
				local miniPeppersaac = dataP.Pepper
				if miniPeppersaac > 4 then
					miniPeppersaac = 4
				end
				sprite:ReplaceSpritesheet(0, "gfx/familiar/familiar_minisaac_edith"..miniPeppersaac..".png")
				sprite:ReplaceSpritesheet(1, "gfx/familiar/familiar_minisaac_edith"..miniPeppersaac..".png")
				sprite:LoadGraphics()
				--print("stage "..miniPeppersaac)
			end
		end
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Chisel.TMinidith, FamiliarVariant.MINISAAC)