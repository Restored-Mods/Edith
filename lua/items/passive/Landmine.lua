local Landmine = {}
local Helpers = require("lua.helpers.Helpers")

---@param bomb EntityBomb
function Landmine:BombInit(bomb)
	local player = Helpers.GetPlayerFromTear(bomb)
	if player then
		local data = Helpers.GetData(bomb)
		if player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LANDMINE) then
			if (bomb.Variant > BombVariant.BOMB_SUPERTROLL or bomb.Variant < BombVariant.BOMB_TROLL) then
                bomb.Variant = EdithCompliance.Enums.BombVariant.LANDMINE
			end
		end
        if bomb.Variant == EdithCompliance.Enums.BombVariant.LANDMINE then
            data.ActivationTimer = 30
        end
	end
    print(bomb:GetExplosionCountdown())
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, Landmine.BombInit)

---@param bomb EntityBomb
function Landmine:BombUpdate(bomb)
	local data = Helpers.GetData(bomb)
	
	data.ActivationTimer = data.ActivationTimer and math.max(data.ActivationTimer - 1, 0) or 30
	bomb:SetExplosionCountdown(47)
    bomb.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    if data.ActivationTimer <= 0 then
        local entityTable = Helpers.MergeTables(Helpers.GetEnemies(true), Helpers.GetPlayers(true), Isaac.FindByType(EntityType.ENTITY_TEAR),
        Isaac.FindByType(EntityType.ENTITY_LASER), Isaac.FindByType(EntityType.ENTITY_PROJECTILE), Isaac.FindByType(EntityType.ENTITY_KNIFE))
        for _, entity in ipairs(entityTable) do
            if entity:Exists() then
                if bomb.Position:Distance(entity.Position) <= 30 then
                    bomb:SetExplosionCountdown(0)
                    break
                end
            end
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, Landmine.BombUpdate, EdithCompliance.Enums.BombVariant.LANDMINE)

---@param bomb EntityBomb
function Landmine:BombCollision(bomb, collider)
	local data = Helpers.GetData(bomb)
    if data.ActivationTimer <= 0 then
        if Helpers.IsEnemy(collider, collider) or collider.Type == EntityType.ENTITY_PLAYER and collider.Variant == 0 or
        collider.Type == EntityType.ENTITY_TEAR or collider.Type == EntityType.ENTITY_PROJECTILE or collider.Type == EntityType.ENTITY_LASER
        or collider.Type == EntityType.ENTITY_KNIFE then
            bomb:SetExplosionCountdown(0)
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, Landmine.BombCollision, EdithCompliance.Enums.BombVariant.LANDMINE)