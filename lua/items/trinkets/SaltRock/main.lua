local SaltRock = {}
local SaltCreepVar = EdithRestored.Enums.Entities.SALT_CREEP.Variant
local SaltCreepSubtype = EdithRestored.Enums.Entities.SALT_CREEP.SubType
local SaltQuantity = 4
local spawnDegree = 360 / SaltQuantity

local function ChangeToEdithTear(tear)
	tear:ChangeVariant(TearVariant.ROCK)
	tear.Color = Color(
		tear.Color.R + 0.8 + (tear.Parent.Color.R - 1), 
		tear.Color.G + 1 + (tear.Parent.Color.G - 1), 
		tear.Color.B + 1 + (tear.Parent.Color.B - 1), 
		tear.Color.A + (tear.Parent.Color.A - 1), 
		tear.Color.RO + tear.Parent.Color.RO, 
		tear.Color.GO + tear.Parent.Color.GO, 
		tear.Color.BO + tear.Parent.Color.BO
	)
end

---@param grid GridEntity
local function IsGridSaltRock(grid)
	return grid:GetSprite():GetLayer(0):GetSpritesheetPath() == "gfx/salt_rock.png"
end

---@param grid GridEntity
function SaltRock:Spawn(grid)
	local room = EdithRestored.Room()

	if not (PlayerManager.AnyoneHasTrinket(EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK) and room:IsFirstVisit()) then return end

	local rng = RNG()
	local desc = grid:GetSaveState()
	local seed = desc and desc.SpawnSeed or room:GetDecorationSeed()

	rng:SetSeed(seed, 35)

	if rng:RandomFloat() < 0.85 then return end
	grid:GetSprite():ReplaceSpritesheet(0, "gfx/salt_rock.png", true)

	for i = 1, SaltQuantity do
		local salt = Isaac.Spawn(EntityType.ENTITY_EFFECT, SaltCreepVar, SaltCreepSubtype, grid.Position + Vector.FromAngle(spawnDegree * i) * 10, Vector.Zero, nil):ToEffect()
		if not salt then return end

		for _ = 1, rng:RandomInt(2, 5) do
			Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 0, salt.Position, RandomVector() * rng:RandomFloat() * rng:RandomInt(6), nil):ToEffect()
		end
		salt:SetTimeout(999999999999)
		salt.Scale = (salt.Scale * 3)
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, SaltRock.Spawn, GridEntityType.GRID_ROCK)

---@param grid GridEntity
function SaltRock:OnKillSaltRock(grid)	
	if not IsGridSaltRock(grid) then return end
	local player = Isaac.GetPlayer() -- Honestly i can't think on a better approach
	local room = EdithRestored.Room()

	local rng = RNG()
	local desc = grid:GetSaveState()
	local seed = desc and desc.SpawnSeed or room:GetDecorationSeed()
	rng:SetSeed(seed, 35)

	for _ = 1, rng:RandomInt(5, 8) do
		local tear = player:FireTear(grid.Position, RandomVector():Resized(15))
		tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
        ChangeToEdithTear(tear)
    end

	SFXManager():Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, SaltRock.OnKillSaltRock, GridEntityType.GRID_ROCK)