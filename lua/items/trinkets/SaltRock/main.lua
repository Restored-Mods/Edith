local SaltRock = {}
local Helpers = include("lua.helpers.Helpers")
local SaltRockVariant = 683

---@param grid GridEntity
function SaltRock:Spawn(grid)
	local room = EdithRestored.Room()

	if not (PlayerManager.AnyoneHasTrinket(EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK) and room:IsFirstVisit()) then return end

	local rng = RNG()
	local desc = grid:GetSaveState()
	local seed = desc and desc.SpawnSeed or room:GetDecorationSeed()

	rng:SetSeed(seed, 35)

	if rng:RandomFloat() >= 0.9 then
		grid:SetVariant(SaltRockVariant)
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, SaltRock.Spawn, GridEntityType.GRID_ROCK)

function SaltRock:Render(rock, offset)
	if rock:GetVariant() == SaltRockVariant then
		rock:GetSprite():ReplaceSpritesheet(0, "gfx/salt_rock.png")
		rock:GetSprite():LoadGraphics()
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_ROCK_RENDER, SaltRock.Render, GridEntityType.GRID_ROCK)

local SaltCreepVar = EdithRestored.Enums.Entities.SALT_CREEP.Variant
local SaltCreepSubtype = EdithRestored.Enums.Entities.SALT_CREEP.SubType

local SaltQuantity = 10
local spawnDegree = 360 / SaltQuantity

---@param grid GridEntity
function SaltRock:OnKillSaltRock(grid, gridType, immediate)
	if grid:GetVariant() ~= SaltRockVariant then return end
	local room = EdithRestored.Room()
	local rng = RNG()
	local desc = grid:GetSaveState()
	local seed = desc and desc.SpawnSeed or room:GetDecorationSeed()
	rng:SetSeed(seed, 35)

	for i = 1, SaltQuantity do
        local salt = Isaac.Spawn(EntityType.ENTITY_EFFECT, SaltCreepVar, SaltCreepSubtype, grid.Position + Vector.FromAngle(spawnDegree * i) * 30, Vector.Zero, nil):ToEffect()
        if not salt then return end

        for _ = 1, rng:RandomInt(2, 5) do
            Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 0, salt.Position, RandomVector() * rng:RandomFloat() * rng:RandomInt(6), nil):ToEffect()
        end

        salt:SetTimeout(240)
    end

	SFXManager():Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, SaltRock.OnKillSaltRock, GridEntityType.GRID_ROCK)