local BlastBoots = {}
local Helpers = include("lua.helpers.Helpers")

function BlastBoots:OnBombDamage(e, amount, flags, source, countdown)
	if e and e:ToPlayer() then
        local player = e:ToPlayer()
        if not player:HasCollectible(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS) then
            return
        end
        local data = Helpers.GetData(player)
		if flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION then
            data.PushedByBombInTheAir = 1
			return false
		end
        if data.JumpCounter > 0 then
            return false
        end
	end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BlastBoots.OnBombDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
function BlastBoots:Hop(player)
    local data = Helpers.GetData(player)
        
    if not data.JumpCounter then
        data.JumpCounter = 0
    end
    if not data.PushedByBombInTheAir then
        data.PushedByBombInTheAir = 0
    end
    if not data.LandingFromBomb then
        data.LandingFromBomb = 0
    end
    local sprite = player:GetSprite()
    local room = Game():GetRoom()   
    if data.PushedByBombInTheAir > 0 or data.LandingFromBomb > 0 then
        player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        player.PositionOffset = Vector(player.PositionOffset.X, -(data.JumpCounter * 5))
        data.JumpCounter = data.JumpCounter + data.PushedByBombInTheAir - data.LandingFromBomb
        if data.JumpCounter >= 10 and data.PushedByBombInTheAir > 0 then
            data.PushedByBombInTheAir = 0
            data.LandingFromBomb = 0.01
        elseif data.LandingFromBomb > 0 then
            data.LandingFromBomb = Helpers.Lerp(data.LandingFromBomb,1,0.5,0.2)
        end
        if data.JumpCounter <= 0 and data.LandingFromBomb then
            data.JumpCounter = 0
            data.LandingFromBomb = 0
            for i = 0, room:GetGridSize() do
                local grid = room:GetGridEntity(i)
                if grid then
                    if grid:GetType() == GridEntityType.GRID_PIT and grid.Desc.State ~= 1 
                    and grid.CollisionClass == GridCollisionClass.COLLISION_PIT and not player.CanFly 
                    and (player.Position - grid.Position):Length() <= 30 then
                        if Helpers.IsPlayerEdith(player, true, false) then
                            data.PitFallJump = true
                            player:StopExtraAnimation()
                            player:PlayExtraAnimation("EdithTrapdoorFall")
                        else
                            data.BlastingBootsFallJump = player.ControlsEnabled
                            player:PlayExtraAnimation("FallIn")
                        end
                        return
                    end
                end
            end
            Helpers.Stomp(player)
            player.GridCollisionClass = player.CanFly and EntityGridCollisionClass.GRIDCOLL_WALLS or EntityGridCollisionClass.GRIDCOLL_GROUND
            player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end
    elseif data.JumpCounter ~= 0 then
        data.JumpCounter = 0
    end
    if data.BlastingBootsFallJump ~= nil then
        player.Velocity = Vector.Zero
        player.ControlsEnabled = false
        if sprite:IsEventTriggered("Poof") then
            data.LandingFromBomb = 15
            data.JumpCounter = 100
            player.Position = Isaac.GetFreeNearPosition(player.Position, 1)
            player.ControlsEnabled = data.BlastingBootsFallJump
            data.BlastingBootsFallJump = nil
        end
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BlastBoots.Hop)

function BlastBoots:NewRoom()
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Helpers.GetData(player)
		if data.BlastingBootsFallJump ~= nil then
			player.GridCollisionClass = player.CanFly and EntityGridCollisionClass.GRIDCOLL_WALLS or EntityGridCollisionClass.GRIDCOLL_GROUND
            player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			player.ControlsEnabled = data.BlastingBootsFallJump
			data.BlastingBootsFallJump = nil
            data.PushedByBombInTheAir = 0
			data.LandingFromBomb = 0
            data.JumpCounter = -1
		end
	end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BlastBoots.NewRoom)