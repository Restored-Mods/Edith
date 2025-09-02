local SmashTrophy = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param force boolean
---@param isStompPool table
function SmashTrophy:OnStomp(player, stompDamage, bombLanding, force, isStompPool)
	for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
		FiendFolio:trySmashPush(enemy.Position - (enemy.Position - player.Position), enemy)
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	SmashTrophy.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.SMASH_TROPHY }
)

return SmashTrophy