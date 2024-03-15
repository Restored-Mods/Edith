local SmellingSalts = {}

function SmellingSalts:KeeperDamage(entity, damage, flags, source, cd)
    if entity and entity:ToPlayer() then
        local player = entity:ToPlayer()
        ---@cast player EntityPlayer
        if flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE then
            local normalHP = player:GetHearts() + player:GetSoulHearts() + player:GetEternalHearts() - player:GetRottenHearts()
            local boneHp = player:GetBoneHearts()
            if (normalHP == 0 and boneHp < 2 or boneHp == 0 and normalHP <= damage) and player:HasTrinket(TC_SaltLady.Enums.TrinketType.TRINKET_SMELLING_SALTS) then
                player:TryRemoveTrinket(TC_SaltLady.Enums.TrinketType.TRINKET_SMELLING_SALTS)
                return {Damage = 0, DamageFlags = flags, DamageCountdown = cd}
            end
        end
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SmellingSalts.KeeperDamage, EntityType.ENTITY_PLAYER)

