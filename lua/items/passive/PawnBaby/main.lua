local SaltPawns = {}
local Helpers = include("lua.helpers.Helpers")

local SaltPawnsDesc = Isaac.GetItemConfig():GetCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY)
local sfx = SFXManager()

local Settings = {
	Cooldown = 5,
	Damage = 10,
  Range = 60,
}

local States = {
	Idle = 0,
	Jump = 1,
	Moving = 2,
	Land = 3,
  Crumble = 4,
  Appear = 5
}

---@param player EntityPlayer
---@param cache CacheFlag | integer
function SaltPawns:Cache(player, cache)
    local numFamiliars = player:GetCollectibleNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY) + player:GetEffects():GetCollectibleEffectNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY)
	player:CheckFamiliar(EdithRestored.Enums.Familiars.PAWN_BABY.Variant, numFamiliars, player:GetCollectibleRNG(EdithRestored.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY), SaltPawnsDesc)
end
EdithRestored:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SaltPawns.Cache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
function SaltPawns:Init(familiar)
  local room = Game():GetRoom()
      local data = EdithRestored:GetData(familiar)
			familiar.Position = room:GetGridPosition(room:GetGridIndex(familiar:ToFamiliar().Player.Position))
      
      local door = SaltPawns.GetClosestDoor(familiar.Position)
      if door then
        data.Direction = door:ToDoor().Direction
      else
        data.Direction = 0
      end
      
      data.rng = RNG()
      data.rng:SetSeed(familiar.InitSeed)
      
			familiar.State = States.Idle
      familiar.FireCooldown = Settings.Cooldown
			familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			familiar.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, SaltPawns.Init, EdithRestored.Enums.Familiars.PAWN_BABY.Variant)


---@param familiar EntityFamiliar
function SaltPawns:Update(familiar)    
    local sprite = familiar:GetSprite()
    local player = familiar.Player
    local data = EdithRestored:GetData(familiar)
    local room = Game():GetRoom()
    local bff = familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    
    -- Cooldown
	if familiar.State == States.Idle then
		if not sprite:IsPlaying("Idle") then
			sprite:Play("Idle", true)
		end

		if familiar.FireCooldown <= 0 then
				familiar.State = States.Jump
		else
			familiar.FireCooldown = familiar.FireCooldown - 1
		end


	-- Jump
elseif familiar.State == States.Jump then
    local enemydetect = false
    if #Isaac.FindInRadius(familiar.Position + (Vector.FromAngle(data.Direction * 90 + 45) * 40 * math.sqrt(2)),35,EntityPartition.ENEMY) > 0 then
       familiar.TargetPosition = room:GetGridPosition(room:GetGridIndex(familiar.Position + (Vector.FromAngle(data.Direction * 90 + 45) * 21 * math.sqrt(2))))
       enemydetect = true
    elseif #Isaac.FindInRadius(familiar.Position + (Vector.FromAngle(data.Direction * 90 - 45) * 40 * math.sqrt(2)),35,EntityPartition.ENEMY) > 0 then
      familiar.TargetPosition = room:GetGridPosition(room:GetGridIndex(familiar.Position + (Vector.FromAngle(data.Direction * 90 - 45) * 21 * math.sqrt(2))))
      enemydetect = true
    end
    if (room:GetGridCollisionAtPos(familiar.TargetPosition) > 0 and enemydetect) or enemydetect == false then
      familiar.TargetPosition = room:GetGridPosition(room:GetGridIndex(familiar.Position + (Vector.FromAngle(data.Direction * 90) * 21)))
    end
    
    if room:GetGridCollisionAtPos(familiar.TargetPosition) > 0 then
      familiar.State = States.Crumble
    else
      if not sprite:IsPlaying("Jump") then
			sprite:Play("Jump", true)
		end

		if sprite:IsEventTriggered("Jump") then
			familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			familiar.GridCollisionClass = GridCollisionClass.COLLISION_NONE
			sfx:Play(SoundEffect.SOUND_SCAMPER, 0.9)

		elseif sprite:IsEventTriggered("Move") then
			familiar.State = States.Moving

			--entity.TargetPosition = room:GetGridPosition(room:GetGridIndex(entity.Position + ((entity.Target.Position - entity.Position):Normalized() * 40)))

			-- Get clamped angle to go in with BFFs extra steps
      end
    end

	-- Move
	elseif familiar.State == States.Moving then
		if not sprite:IsPlaying("Move") then
			sprite:Play("Move", true)
		end
		
		if familiar.Position:Distance(familiar.TargetPosition) > 2 and room:GetGridCollisionAtPos(familiar.TargetPosition) <= 0 then
			familiar.Position = (familiar.Position + (familiar.TargetPosition - familiar.Position) * 0.35)
    else
      familiar.State = States.Land
      familiar.Position = room:GetGridPosition(room:GetGridIndex(familiar.Position))
		end


	-- Land
	elseif familiar.State == States.Land then
		if not sprite:IsPlaying("Land") then
			sprite:Play("Land", true)
		end

		if sprite:IsEventTriggered("Land") then
			familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			familiar.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
			sfx:Play(SoundEffect.SOUND_FETUS_FEET, 1.2, 0, false, 0.8, 0)

			-- Stomp
			local range = Settings.Range

			if Sewn_API and Sewn_API:IsUltra(familiar:GetData()) then
				range = range * 1.5
			end

			for _,v in pairs(Isaac.GetRoomEntities()) do
				if v.Type > 9 and v.Type < 1000 and v.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE and v:IsActiveEnemy()
				and room:GetGridPosition(room:GetGridIndex(familiar.Position)):Distance(room:GetGridPosition(room:GetGridIndex(v.Position))) <= Settings.Range then
					local multiplier = 1
					if bff == true then
						multiplier = multiplier * Settings.BFFmultiplier
					end
					if room:GetGridPosition(room:GetGridIndex(v.Position)) == room:GetGridPosition(room:GetGridIndex(familiar.Position)) then
						multiplier = multiplier * Settings.SameSpaceMultiplier
					end

					local damage = Settings.Damage

					if Sewn_API then
						if Sewn_API:IsSuper(familiar:GetData()) then
							damage = damage * 1.25
						elseif Sewn_API:IsUltra(familiar:GetData()) then
							damage = damage * 1.5
						end
					end

					v:TakeDamage(damage * multiplier, DamageFlag.DAMAGE_CRUSH | DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(familiar), 0)
					if v:HasMortalDamage() then
						v:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
					end
				end
			end

		elseif sprite:IsEventTriggered("Move") then
			familiar.State = States.Idle
			familiar.FireCooldown = Settings.Cooldown
		end
  elseif familiar.State == States.Crumble then
    
    if sprite:IsFinished("Crumble") then
      local door = SaltPawns.GetRandomDoor(data.rng)
      if door then
        data.Direction = door:ToDoor().Direction
        familiar.Position = door.Position
      else
        data.Direction = data.rng:RandomInt(4)
        familiar.Position = Isaac.GetFreeNearPosition(player.Position,25)
      end
      
      familiar.State = States.Appear
    elseif not sprite:IsPlaying("Crumble") then
			sprite:Play("Crumble", true)
		end
    
  elseif familiar.State == States.Appear then
    if not sprite:IsPlaying("Appear") then
			sprite:Play("Appear", true)
		end
    
    if sprite:IsEventTriggered("Land") then
			familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			familiar.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
			sfx:Play(SoundEffect.SOUND_FETUS_FEET, 1.2, 0, false, 0.8, 0)

			-- Stomp
			local range = Settings.Range

			if Sewn_API and Sewn_API:IsUltra(familiar:GetData()) then
				range = range * 1.5
			end

			for _,v in pairs(Isaac.GetRoomEntities()) do
				if v.Type > 9 and v.Type < 1000 and v.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE and v:IsActiveEnemy()
				and room:GetGridPosition(room:GetGridIndex(familiar.Position)):Distance(room:GetGridPosition(room:GetGridIndex(v.Position))) <= Settings.Range then
					local multiplier = 1
					if bff == true then
						multiplier = multiplier * Settings.BFFmultiplier
					end
					if room:GetGridPosition(room:GetGridIndex(v.Position)) == room:GetGridPosition(room:GetGridIndex(familiar.Position)) then
						multiplier = multiplier * Settings.SameSpaceMultiplier
					end

					local damage = Settings.Damage

					if Sewn_API then
						if Sewn_API:IsSuper(familiar:GetData()) then
							damage = damage * 1.25
						elseif Sewn_API:IsUltra(familiar:GetData()) then
							damage = damage * 1.5
						end
					end

					v:TakeDamage(damage * multiplier, DamageFlag.DAMAGE_CRUSH | DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(familiar), 0)
					if v:HasMortalDamage() then
						v:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
					end
				end
			end

		elseif sprite:IsEventTriggered("Move") then
			familiar.State = States.Idle
			familiar.FireCooldown = Settings.Cooldown
		end
    
	end

end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SaltPawns.Update, EdithRestored.Enums.Familiars.PAWN_BABY.Variant)

function SaltPawns:NewRoom()
	for i, f in pairs(Isaac.GetRoomEntities()) do
		if f.Type == EntityType.ENTITY_FAMILIAR and f.Variant == EdithRestored.Enums.Familiars.PAWN_BABY.Variant then
			local room = Game():GetRoom()
      local data = EdithRestored:GetData(f)
			f.Position = room:GetGridPosition(room:GetGridIndex(f:ToFamiliar().Player.Position))
      
      local door = SaltPawns.GetClosestDoor(f.Position)
      if door then
        data.Direction = door:ToDoor().Direction
        f.Position = door.Position
      end
      
			f:ToFamiliar().State = States.Idle
			f:ToFamiliar().FireCooldown = 0
			f.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			f.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SaltPawns.NewRoom)

function SaltPawns.GetRandomDoor(rng)
  local room = Game():GetRoom()
  local doors = {}
  
  for i = 1, room:GetGridSize() do
			local Grid = room:GetGridEntity(i)
			if Grid ~= nil then
         if Grid:GetType() == GridEntityType.GRID_DOOR and Grid:GetVariant() ~= DoorVariant.DOOR_LOCKED_KEYFAMILIAR 
        and Grid:GetVariant() ~= DoorVariant.DOOR_HIDDEN and Grid:ToDoor().TargetRoomIndex >= 0 then
          table.insert(doors, Grid)
          
        end
    end
  end
  if #doors > 0 then
    return doors[1 + rng:RandomInt(#doors - 1)]
  else
    return nil
  end
end

function SaltPawns.GetClosestDoor(position)
  local room = Game():GetRoom()
      local Closestdoor
  
  for i = 1, room:GetGridSize() do
			local Grid = room:GetGridEntity(i)
			if Grid ~= nil then
        if Grid:GetType() == GridEntityType.GRID_DOOR and Grid:GetVariant() ~= DoorVariant.DOOR_LOCKED_KEYFAMILIAR 
        and Grid:GetVariant() ~= DoorVariant.DOOR_HIDDEN and Grid:ToDoor().TargetRoomIndex >= 0 then
          if Grid.Position:Distance(position) < 100 then
          if Closestdoor == nil then
         Closestdoor = Grid
      elseif Closestdoor ~= nil then
        if Closestdoor.Position:Distance(position) > Grid.Position:Distance(position) then
          Closestdoor = Grid
        end
        end
      end
      end
	end
end
if Closestdoor and Closestdoor:ToDoor() then
  return Closestdoor
else
  return nil
end
end

---@param familiar EntityFamiliar
---@param collider Entity
---@param low boolean
function SaltPawns:Colliding(familiar, collider, low)    
    if familiar.State ~= 0 then return end
    local sprite = familiar:GetSprite()
    local data = EdithRestored:GetData(familiar)
   
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, SaltPawns.Colliding, EdithRestored.Enums.Familiars.PAWN_BABY.Variant)