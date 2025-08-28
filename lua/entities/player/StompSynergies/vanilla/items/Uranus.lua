local Uranus = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
---@param forced boolean
function Uranus:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake, forced)
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
	{ Item = CollectibleType.COLLECTIBLE_URANUS, PoolFruitCake = true }
)

return Uranus