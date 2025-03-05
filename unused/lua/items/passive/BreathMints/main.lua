local Peppermint = {}
local Helpers = include("lua.helpers.Helpers")

-- Hi here Kotry, here's Peppermint rework, right now its main functionality is done
-- Code formatted with https://codebeautify.org/lua-beautifier

--[[
	Known issues
	- Actually i haven't found any major issue, just lack of visual effect but i think it would be better if a spriter makes it so yeah, it's pretty much done
	- Ah yeah we need sound effect too
]]

-- Took from MeleeLib, for change tear Position when moving player's head
-- Conversions between directions to angle degrees
local DIRECTION_TO_DEGREES = {
    [Direction.NO_DIRECTION] = 0,
    [Direction.RIGHT] = 0,
    [Direction.DOWN] = 90,
    [Direction.LEFT] = 180,
    [Direction.UP] = 270
}

-- Conversions between directions to vectors.
local DIRECTION_TO_VECTOR = {
    [Direction.NO_DIRECTION] = Vector(0, 0),
    [Direction.RIGHT] = Vector(1, 0),
    [Direction.DOWN] = Vector(0, 1),
    [Direction.LEFT] = Vector(-1, 0),
    [Direction.UP] = Vector(0, -1)
}

-- Returns a vector representing the direction the player is aiming at.
---@param player EntityPlayer
---@return Vector
local function getAimDirection(player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) or
        player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) or
        player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) or
        player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) or
        player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)
    then
        return player:GetAimDirection()
    end

    return DIRECTION_TO_VECTOR[player:GetHeadDirection()]
end

function Peppermint:RenderPepperMintCharge()
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local data = Helpers.GetData(player)
        local room = Game():GetRoom()

        if room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
            return
        end

        if not player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_BREATH_MINTS) then
            return
        end

        if not data.PepperMintChargeBar then
            if data.PeppermintCharge and data.PeppermintCharge > 0 then
                data.PepperMintChargeBar = Sprite()
                data.PepperMintChargeBar:Load("gfx/chargebar.anm2", true) -- Maybe a custom chargebar for Peppermint like Revelation one?
            end
        end

        -- if not Game():IsPaused() then
        local update = true -- yeah here i just copypasted Edith's chargebar manager,
        if data.PepperMintChargeBar ~= nil then
            data.PepperMintChargeBar.PlaybackSpeed = 0.5
            if not data.PepperMintChargeBar:IsPlaying("Disappear") then
                if
                    (data.PeppermintCharge * 100) < (100) and
                        not (data.PepperMintChargeBar:GetAnimation():sub(-(#"Charged")) == "Charged")
                 then
                    data.PepperMintChargeBar:SetFrame("Charging", math.ceil((data.PeppermintCharge * 100)))
                    update = false
                else
                    if data.PepperMintChargeBar:GetAnimation() == "Charging" then
                        data.PepperMintChargeBar:Play("StartCharged", true)
                    elseif
                        data.PepperMintChargeBar:IsFinished("StartCharged") and
                            not data.PepperMintChargeBar:IsPlaying("Charged")
                     then
                        data.PepperMintChargeBar:Play("Charged", true)
                    end
                end
            end
            if (data.PeppermintCharge == 0) and (data.PepperMintChargeBar:GetAnimation():find("Charg", 1, true)) then
                data.PepperMintChargeBar:Play("Disappear", false)
            end
            if update then
                data.PepperMintChargeBar:Update()
            end
            data.PepperMintChargeBar.Offset = Vector(0, -40)
            data.PepperMintChargeBar:Render(Isaac.WorldToScreen(player.Position), Vector.Zero, Vector.Zero)
            if data.PepperMintChargeBar:IsFinished("Disappear") then
                data.PepperMintChargeBar = nil
            end
        end
        -- end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_RENDER, Peppermint.RenderPepperMintCharge)

function Peppermint:AddPeppermintCharge(player)
    local data = Helpers.GetData(player)

    if not player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_BREATH_MINTS) then
        return
    end

    if not data.PeppermintCharge then
        data.PeppermintCharge = 0
    end

    local shoot = {
        l = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
        r = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
        u = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
        d = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
    }

    local isShooting = (shoot.l or shoot.r or shoot.u or shoot.d)

    if isShooting == true then
        data.PeppermintCharge = math.min(1,data.PeppermintCharge + 0.01)
    else
        if data.PeppermintCharge >= 1 then
            local speed = getAimDirection(player):Resized(4)
            local pepperMintBreath = 
                Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EdithRestored.Enums.Entities.PEPPERMINT.Variant,
                0,
                player.Position + getAimDirection(player):Resized(20),
                speed,
                player
            ):ToEffect()
            pepperMintBreath:SetTimeout(90)
        end
        data.PeppermintCharge = 0
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Peppermint.AddPeppermintCharge)


---@param cloud EntityEffect
function Peppermint:CloudUpdate(cloud)
    local player = Helpers.GetPlayerFromTear(cloud)
    if not player then cloud:Remove() return end
    if cloud.Timeout <= 0 then cloud:Remove() end
    --cloud.Position = player.Position + getAimDirection(player):Resized(20)
    cloud.Velocity = Helpers.Lerp(cloud.Velocity, Vector.Zero, 0.3, 0.2)
    for _, enemies in pairs(Helpers.GetEnemies()) do
        if (enemies.Position - cloud.Position):Length() <= 30 then
            if cloud.FrameCount % 15 == 0 then -- Breath ticks, if right now it does a total of 30 damage for all breath duration
                enemies:TakeDamage(player.Damage / 3, 0, EntityRef(cloud), 15)
            end
        end
    end
    
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Peppermint.CloudUpdate, EdithRestored.Enums.Entities.PEPPERMINT.Variant)

function Peppermint:CloudDamage(ent, damage, flags, source, cd)
    if source and source.Entity and source.Entity.Type == EntityType.ENTITY_EFFECT and source.Entity.Variant == EdithRestored.Enums.Entities.PEPPERMINT.Variant then
        local cloud = source.Entity:ToEffect()
        if ent:HasMortalDamage() then
            ent:AddEntityFlags(EntityFlag.FLAG_ICE)
        else
            local slowColor = Color(0.7, 0.9, 1, 1, 0, 0, 0)
            if not ent:HasEntityFlags(EntityFlag.FLAG_SLOW) then
                ent:AddSlowing(EntityRef(player), 10, 0.5, slowColor)
            end
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, Peppermint.CloudDamage)

EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, cloud)
    cloud.Color = Color(0.14, 0.91, 1, math.min(1, cloud.Timeout / 30), 0, 0, 0)
    cloud:GetSprite().Offset = Vector(0,-10)
end, EdithRestored.Enums.Entities.PEPPERMINT.Variant)
