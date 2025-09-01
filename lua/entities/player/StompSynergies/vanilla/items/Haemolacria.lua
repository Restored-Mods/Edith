local Haemolacria = {}

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
---@param forced boolean
function Haemolacria:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake, forced)
	local tear = player:FireTear(player.Position, Vector.Zero, false, true, false, player)
	tear.Height = -0.5
	tear.FallingAcceleration = 1
	tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Haemolacria.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_HAEMOLACRIA, PoolFruitCake = true }
)

return Haemolacria