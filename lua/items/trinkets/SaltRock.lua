local SaltRock = {}
local Helpers = include("lua.helpers.Helpers")

function SaltRock:MiniStatue(Statue)
	local room = Game():GetRoom()
	local data = Helpers.GetData(Statue)
	local sprite = Statue:GetSprite()
	if data.jumps == nil then
		sprite:Play("JumpUp")
		data.jumps = 1
	end
	if sprite:IsEventTriggered("Slam") then
		for _, entity in pairs(Helpers.GetEnemies()) do
			if entity.Position:Distance(Statue.Position) <= 30 then
				entity:TakeDamage(15, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_CRUSH, EntityRef(Statue), 0)
			end
		end
		local grid = room:GetGridEntityFromPos(Statue.Position)
		if grid and (grid:IsBreakableRock() or grid:ToPoop())then
			grid:Destroy()
		end
		SFXManager():Play(SoundEffect.SOUND_STONE_IMPACT)
		Game():SpawnParticles(Statue.Position, EffectVariant.TOOTH_PARTICLE, 7, 1, Color(1, 1, 1, 1, 0, 0, 0))
		Game():ShakeScreen(5)
	end
	if sprite:IsFinished("JumpDown") then
		data.jumps = data.jumps - 1
		sprite:Play("JumpUp")
	end
	if sprite:IsFinished("JumpUp") then
		sprite:Play("JumpDown")
		if data.jumps > 0 then
			local gridTablePositions = {}
			for i = 0, (room:GetGridSize()) do
				local gent = room:GetGridEntity(i)
				if gent and (gent:IsBreakableRock() or gent:ToPoop()) and gent.State < 2 then
					table.insert(gridTablePositions, gent.Position)
				end
			end
			if #gridTablePositions > 0 then
				Statue.Position = gridTablePositions[TSIL.Random.GetRandomInt(1, #gridTablePositions)]
			end
			local enemyTablePositions = {}
			for _, entity in pairs(Helpers.GetEnemies()) do
				table.insert(enemyTablePositions, entity.Position)
			end
			if #enemyTablePositions > 0 then
				Statue.Position = enemyTablePositions[TSIL.Random.GetRandomInt(1, #enemyTablePositions)]
			end
		else
			Statue:Remove()
		end
	end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SaltRock.MiniStatue, TC_SaltLady.Enums.Entities.SALT_STATUE_MINI.Variant)

function SaltRock:Spawn(grid)
	local room = Game():GetRoom()
	if PlayerManager.AnyoneHasTrinket(TC_SaltLady.Enums.TrinketType.TRINKET_SALT_ROCK) and room:IsFirstVisit()
	and Isaac.GetPersistentGameData():Unlocked(TC_SaltLady.Enums.Achievements.Characters.EDITH) then
		local rng = RNG()
		local desc = grid:GetSaveState()
		if desc then
			rng:SetSeed(desc.SpawnSeed, 35)
		else
			rng:SetSeed(room:GetDecorationSeed(), 35)
		end
		if rng:RandomFloat() >= 0.9 then
			grid:SetVariant(683)
		end
	end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, SaltRock.Spawn, GridEntityType.GRID_ROCK)

function SaltRock:Render(rock, offset)
	if rock:GetVariant() == 683 then
		rock:GetSprite():ReplaceSpritesheet(0, "gfx/salt_rock.png")
		rock:GetSprite():LoadGraphics()
	end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_ROCK_RENDER, SaltRock.Render, GridEntityType.GRID_ROCK)

function SaltRock:OnKillSaltRock(grid, gridType, immediate)
	if grid:GetVariant() ~= 683 or not Isaac.GetPersistentGameData():Unlocked(TC_SaltLady.Enums.Achievements.Characters.EDITH) then return end
	Isaac.Spawn(1000, TC_SaltLady.Enums.Entities.SALT_STATUE_MINI.Variant, 0, grid.Position, Vector(0, 0), nil):ToEffect()
	SFXManager():Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND)
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, SaltRock.OnKillSaltRock, GridEntityType.GRID_ROCK)