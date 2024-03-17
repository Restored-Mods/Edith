local Cards = {}
local Helpers = include("lua.helpers.Helpers")

function Cards:UsePrudence(prud, player, useflags)
    EdithCompliance.HiddenItemManager:AddForRoom(player, CollectibleType.COLLECTIBLE_GUPPYS_EYE, -1, 1, "Prudence")    
end
EdithCompliance:AddCallback(ModCallbacks.MC_USE_CARD, Cards.UsePrudence, EdithCompliance.Enums.Pickups.Cards.CARD_PRUDENCE)

function Cards:PrudenceHideEye()
    EdithCompliance.HiddenItemManager:HideCostumes("Prudence")
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_UPDATE, Cards.PrudenceHideEye)

function Cards:UseReversePrudence(revPrud, player, useflags)
    --ItemOverlay.Show(Isaac.GetGiantBookIdByName("Reverse Prudence"), 0 , player)
    Helpers.PlaySND(EdithCompliance.Enums.SFX.Cards.CARD_REVERSE_PRUDENCE)
    local slot = Isaac.Spawn(EntityType.ENTITY_SLOT,16,0,Game():GetRoom():FindFreePickupSpawnPosition(player.Position,40,true),Vector.Zero,nil)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, slot.Position, Vector.Zero, nil)
    SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND,1,0)
end
EdithCompliance:AddCallback(ModCallbacks.MC_USE_CARD, Cards.UseReversePrudence, EdithCompliance.Enums.Pickups.Cards.CARD_REVERSE_PRUDENCE)

function Cards:UseSoulEdith(soe, player, useflags)
    local statue = Isaac.Spawn(1000, EdithCompliance.Enums.Entities.SALT_STATUE.Variant, 0, player.Position, Vector(0, 0), player):ToEffect()
    Helpers.PlaySND(EdithCompliance.Enums.SFX.Cards.CARD_SOUL_EDITH)
    local data = Helpers.GetData(statue)
    data.firstpos = player.Position
    player.Visible = false
    player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    SFXManager():Play(SoundEffect.SOUND_STONE_IMPACT)
    player.ControlsEnabled = false
end
EdithCompliance:AddCallback(ModCallbacks.MC_USE_CARD, Cards.UseSoulEdith, EdithCompliance.Enums.Pickups.Cards.CARD_SOUL_EDITH)

function Cards:Statue(Statue)
    if Statue.SpawnerType == EntityType.ENTITY_PLAYER then
        local room = Game():GetRoom()
        local player = Statue.SpawnerEntity:ToPlayer()
        local data = Helpers.GetData(Statue)
        player.Position = Statue.Position
        local sprite = Statue:GetSprite()
        if data.jumps == nil then
            sprite:Play("JumpUp")
            data.jumps = 6
        end
        if sprite:IsEventTriggered("Slam") then
            for _, entity in pairs(Isaac.FindInRadius(player.Position, 50)) do
                if
                    entity.Type >= 10 and entity.Type <= 999 and entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and
                        EntityRef(entity).IsCharmed == false
                 then
                    entity:TakeDamage(30, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_CRUSH, EntityRef(Statue), 0)
                end
                for i = 0, (room:GetGridSize()) do
                    local gent = room:GetGridEntity(i)
                    if
                        gent and
                            (gent:GetType() > 1 and gent:GetType() < 3 or gent:GetType() == 12 or gent:GetType() == 14 or
                                gent:GetType() == 22 or
                                gent:GetType() > 24)
                     then
                        if (Statue.Position - gent.Position):Length() <= 80 then
                            gent:Destroy()
                        end
                    end
                end
                SFXManager():Play(SoundEffect.SOUND_STONE_IMPACT)
                Game():SpawnParticles(
                    player.Position,
                    EffectVariant.TOOTH_PARTICLE,
                    15,
                    1,
                    Color(1, 1, 1, 1, 0, 0, 0)
                )
                Game():ShakeScreen(10)
            end
        end
        if sprite:IsFinished("JumpDown") then
            data.jumps = data.jumps - 1
            if data.jumps == 0 then
                player.Visible = true
                player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                player.ControlsEnabled = true
                Statue:Remove()
                SFXManager():Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND)
            else
                sprite:Play("JumpUp")
            end
        end
        if sprite:IsFinished("JumpUp") then
            sprite:Play("JumpDown")
            if data.jumps > 1 then
                for i = 0, (room:GetGridSize()) do
                    local gent = room:GetGridEntity(i)
                    if
                        gent and
                            (gent:GetType() > 1 and gent:GetType() < 3 or gent:GetType() == 12 or gent:GetType() == 14 or
                                gent:GetType() == 22 or
                                gent:GetType() > 24) and
                            gent.State < 2
                     then
                        Statue.Position = gent.Position
                    end
                end
                for _, entity in pairs(Isaac.GetRoomEntities()) do
                    if
                        entity.Type >= 10 and entity.Type <= 999 and entity:IsVulnerableEnemy() and
                            entity:IsActiveEnemy() and
                            EntityRef(entity).IsCharmed == false
                     then
                        Statue.Position = entity.Position
                    end
                end
            else
                Statue.Position = data.firstpos
            end
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Cards.Statue, EdithCompliance.Enums.Entities.SALT_STATUE.Variant)
