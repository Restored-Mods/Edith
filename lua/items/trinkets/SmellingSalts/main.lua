 local SmellingSalts = {}

function SmellingSalts:NPCUpdate(npc)
    if PlayerManager.AnyoneHasTrinket(EdithRestored.Enums.TrinketType.TRINKET_SMELLING_SALTS) and npc:IsVulnerableEnemy()
    and not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
        if npc:GetSlowingCountdown() > 0 or npc:GetFreezeCountdown() > 0 then
            Isaac.CreateTimer(function()
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
            end, math.max(npc:GetSlowingCountdown() + npc:GetFreezeCountdown(),60) + npc:GetWeaknessCountdown(), 1, false)
            
            npc:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
            npc:ClearEntityFlags(EntityFlag.FLAG_SLOW)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
            npc:AddWeakness(EntityRef(nil), math.max(npc:GetSlowingCountdown() + npc:GetFreezeCountdown(),60 ))
            npc:SetSlowingCountdown(0)
            npc:SetFreezeCountdown(0)
        end
      end
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, SmellingSalts.NPCUpdate)