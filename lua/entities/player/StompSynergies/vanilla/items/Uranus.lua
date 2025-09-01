local Uranus = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function Uranus:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
		if not enemy:IsDead() and not enemy:HasEntityFlags(EntityFlag.FLAG_ICE) then
			enemy:AddEntityFlags(EntityFlag.FLAG_ICE)
			Isaac.CreateTimer(function() 
				if not enemy:IsDead() then
					enemy:ClearEntityFlags(EntityFlag.FLAG_ICE)
				end
			end, 2, 1, false)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Uranus.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_URANUS, PoolFruitCake = true, PoolPlaydoughCookie = true }
)

return Uranus