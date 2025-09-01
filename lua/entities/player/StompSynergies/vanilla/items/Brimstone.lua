local Brimstone = {}

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function Brimstone:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	player:FireBrimstoneBall(player.Position, Vector.Zero, Vector.Zero)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Brimstone.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_BRIMSTONE }
)

return Brimstone