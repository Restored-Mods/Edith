local SoulOfEdith = {}
local Helpers = include("lua.helpers.Helpers")

---@param player EntityPlayer
local function JumpInit(player)
    local data = EdithRestored:GetData(player)
    data.StartPosition = data.StartPosition or player.Position
    if data.StoneJumps <= 0 then
        data.StoneJumps = nil
        player:GetSprite():Load(data.PrevAnimFile or "gfx/001.000_Player.anm2", true)
        player:GetSprite():Update()
        return
    end
    if data.StoneJumps > 1 then
        local ent = Helpers.GetNearestEnemy(player.Position, true)
        if ent == nil then
            local grids = {}
            for i = 0, EdithRestored.Room():GetGridSize() - 1 do
                local grid = EdithRestored.Room():GetGridEntity(i)
                if grid and (grid:GetType() == GridEntityType.GRID_ROCK or grid:GetType() == GridEntityType.GRID_ROCKB)
                and grid.State ~= 2 then
                    table.insert(grids, {Type = grid:GetType(), Position = grid.Position})
                end
            end
            local rocks = Helpers.Filter(grids, function(idx, grid) return grid.Type == GridEntityType.GRID_ROCKB end)
            if #rocks == 0 then
                rocks = Helpers.Filter(grids, function(idx, grid) return grid.Type == GridEntityType.GRID_ROCK end)
            end
            if #rocks == 0 then
                rocks = Helpers.Filter(Isaac.FindByType(EntityType.ENTITY_FIREPLACE), function(index, fire) return fire.Variant ~= 4 and fire:ToNPC().State ~= NpcState.STATE_IDLE end)
            end
            if #rocks == 0 then
                ent = player
            else
                table.sort(rocks, function(a, b) return player.Position:Distance(a.Position) < player.Position:Distance(b.Position) end)
                ent = rocks[1]
            end
        end
        data.TargetJumpPos = ent.Position
    else
        data.TargetJumpPos = data.StartPosition
        data.StartPosition = nil
    end
    player:PlayExtraAnimation("EdithJump")
end

---@param soe Card
---@param player EntityPlayer
---@param useflags integer | UseFlag
function SoulOfEdith:UseSoulEdith(soe, player, useflags)
    Helpers.PlaySND(EdithRestored.Enums.SFX.Cards.CARD_SOUL_EDITH)
    local data = EdithRestored:GetData(player)
    data.StoneJumps = 4
    local sprite = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
        player:SwapForgottenForm(true, false)
    end
    SFXManager():Play(SoundEffect.SOUND_STONE_IMPACT)
    data.PrevAnimFile = sprite:GetFilename()
    sprite:Load(EdithRestored.Enums.PlayerSprites.EDITH, true)
    sprite:Update()
    JumpInit(player)
    data.EdithTargetMovementPosition = nil
end
EdithRestored:AddCallback(ModCallbacks.MC_USE_CARD, SoulOfEdith.UseSoulEdith, EdithRestored.Enums.Pickups.Cards.CARD_SOUL_EDITH)

function SoulOfEdith:NoStatueDamage(entity, damage, flags, source, cd)
    if entity:ToPlayer() then
        local player = entity:ToPlayer()
        ---@cast player EntityPlayer
        local data = EdithRestored:GetData(player)
        if data.StoneJumps then
            return false
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SoulOfEdith.NoStatueDamage, EntityType.ENTITY_PLAYER)

function SoulOfEdith:Landing(player, jumpData, inPit)
	if not inPit then
        local data = EdithRestored:GetData(player)
        if data.StoneJumps then
            data.StoneJumps = math.max(data.StoneJumps - 1, 0)
            Helpers.Stomp(player, data.StoneJumps == 1)
            if data.StoneJumps == 0 then
                SFXManager():Play(SoundEffect.SOUND_STONE_IMPACT)
            end
            for _, pickup in ipairs(Isaac.FindInRadius(player.Position, 30, EntityPartition.PICKUP)) do
                pickup.Velocity = Vector.Zero
            end
            player.Velocity = Vector.Zero
            if data.EdithJumpTarget then
                data.EdithJumpTarget:Remove()
                data.EdithJumpTarget = nil
            end
            
            data.TargetJumpPos = nil
    
            for _, v in pairs(Isaac.FindInRadius(player.Position, 55, EntityPartition.BULLET)) do
                local projectile = v:ToProjectile() ---@cast projectile EntityProjectile
                local angle = ((player.Position - projectile.Position) * -1):GetAngleDegrees()
                projectile.Velocity = Vector.FromAngle(angle):Resized(10)
                projectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
                projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
            end
        end
	end
end
EdithRestored:AddCallback(JumpLib.Callbacks.ENTITY_LAND, SoulOfEdith.Landing, {tag = "SoulEdithJump", type = EntityType.ENTITY_PLAYER})

---@param player EntityPlayer
function SoulOfEdith:StatueJumping(player)
    local data = EdithRestored:GetData(player)
    if data.StoneJumps then
        local sprite = player:GetSprite()
        if JumpLib:CanJump(player) and not data.TargetJumpPos and player:IsExtraAnimationFinished() then
            JumpInit(player)
        end
        if sprite:GetAnimation() == "EdithJump" and sprite:GetFrame() < 17 then
            if sprite:GetFrame() == 5 then
                JumpLib:Jump(player, {
                    Height = 4,
                    Speed = 0.7,
                    Flags = JumpLib.Flags.NO_HURT_PITFALL | JumpLib.Flags.FAMILIAR_FOLLOW_ORBITALS | JumpLib.Flags.FAMILIAR_FOLLOW_TEARCOPYING,
                    Tags = {"SoulEdithJump"}
                })
            end
            if data.TargetJumpPos and sprite:GetFrame() > 5 then
                player.Velocity = (data.TargetJumpPos - player.Position):Normalized() * (data.TargetJumpPos - player.Position):Length() / 7
            end
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SoulOfEdith.StatueJumping)

function SoulOfEdith:NoStatueInput(entity, hook, button)
    if entity and entity:ToPlayer() then
        local player = entity:ToPlayer()
        local data = EdithRestored:GetData(player)
        if data.StoneJumps then
            if hook == InputHook.GET_ACTION_VALUE then
                return 0
            else
                return false
            end
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_INPUT_ACTION, SoulOfEdith.NoStatueInput)

