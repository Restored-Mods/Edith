local MomsKnife = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function MomsKnife:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
    local weapon = player:GetWeapon(1)
    if weapon and weapon:GetWeaponType() == WeaponType.WEAPON_KNIFE and weapon:GetCharge() > 0 then
        local knife = player:GetActiveWeaponEntity():ToKnife()
        if knife then
            local enemy = Helpers.GetNearestEnemy(player.Position, Helpers.GetStompRadius())
            if enemy then
                local charge = weapon:GetCharge()
                weapon:SetCharge(0)
                knife.Rotation = (enemy.Position - player.Position):GetAngleDegrees()
                knife:Shoot(1, weapon:GetCharge())
            end
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	MomsKnife.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_MOMS_KNIFE }
)

return MomsKnife