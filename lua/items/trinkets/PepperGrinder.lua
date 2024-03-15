local PepperGrinder = {}
local Helpers = include("lua.helpers.Helpers")

function PepperGrinder:OnKillPG(entity)
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Game():GetPlayer(i)
		local dataP = Helpers.GetEntityData(player)
		local goldenbox = player:GetTrinketMultiplier(TC_SaltLady.Enums.TrinketType.TRINKET_PEPPER_GRINDER)
		if player:HasTrinket(TC_SaltLady.Enums.TrinketType.TRINKET_PEPPER_GRINDER) then
			local rngGrinder = TSIL.Random.GetRandomInt(1,100)
			if (goldenbox > 2 or goldenbox > 4) and rngGrinder <= 75 		-- Golden Trinket + Mom's Box
			or goldenbox > 1 and goldenbox < 3 and rngGrinder <= 50			-- Golden Trinket or Mom's Box
			or goldenbox < 2 and rngGrinder <= 25 then						-- Normal Trinket
				dataP.CreepNum = 5
			end
			if dataP.CreepNum > 0 then
				Game():SpawnParticles(entity.Position, EffectVariant.POOF02, 1, 0, Color(0, 0, 0, 1, 0.25, 0.25, 0.25), 1, 0)
			end
		end
	end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PepperGrinder.OnKillPG)

function PepperGrinder:CreepSpawning(player)
	local dataP = Helpers.GetEntityData(player)
	if player:HasTrinket(TC_SaltLady.Enums.TrinketType.TRINKET_PEPPER_GRINDER) then
		if dataP.CreepNum == nil then
			dataP.CreepNum = 0
		end
		if dataP.CreepNum > 0 then
			dataP.CreepNum = dataP.CreepNum - 1
		end
		if dataP.CreepNum < 0 then
			dataP.CreepNum = 0
		end
		for _, entity in pairs(Isaac.FindInRadius(player.Position, 999)) do -- What is actually spawning the Pepper
			if entity:IsDead() and dataP.CreepNum > 0 then
				local creep = Isaac.Spawn(1000, 53, 0, entity.Position, Vector(TSIL.Random.GetRandomInt(1, 4) - 2, TSIL.Random.GetRandomInt(1, 4) - 2), player)
				local sprite = creep:GetSprite()
				sprite:Load("gfx/1000.092_creep (powder).anm2", true)
				sprite:ReplaceSpritesheet(0, "gfx/effects/effect_blackpowder.png")
				local rngSprite = TSIL.Random.GetRandomInt(0, 5)
				if rngSprite == 0 then
					sprite:Play("SmallBlood01", true)
				elseif rngSprite == 1 then
					sprite:Play("SmallBlood02", true)
				elseif rngSprite == 2 then
					sprite:Play("SmallBlood03", true)
				elseif rngSprite == 3 then
					sprite:Play("SmallBlood04", true)
				elseif rngSprite == 4 then
					sprite:Play("SmallBlood05", true)
				else
					sprite:Play("SmallBlood06", true)
				end
				creep.CollisionDamage = 0.4
			end
		end
	end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PepperGrinder.CreepSpawning)