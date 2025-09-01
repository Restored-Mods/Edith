local CricketsBody = {}

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function CricketsBody:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
	local tear = player:FireTear(player.Position, Vector.Zero, false, true, false, player):ToTear()
	tear.Height = -0.2
	tear.FallingAcceleration = 0
	tear.EntityCollisionClass =EntityCollisionClass.ENTCOLL_NONE
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	CricketsBody.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_CRICKETS_BODY, PoolFruitCake = true, Pool3DollarBill = true }
)

return CricketsBody