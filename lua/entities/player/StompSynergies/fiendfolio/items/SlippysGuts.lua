local SlippysGuts = {}

---@param player EntityPlayer
---@param bombDamage number
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
function SlippysGuts:OnStompExposion(player, bombDamage, radius, hasBombs, isGigaBomb)
	local cloud = Isaac.Spawn(
		FiendFolio.FF.SlippyFart.ID,
		FiendFolio.FF.SlippyFart.Var,
		FiendFolio.FF.SlippyFart.Sub,
		player.Position,
		Vector.Zero,
		player
	)
	SFXManager():Play(FiendFolio.Sounds.FartFrog1, 0.2, 0, false, math.random(80, 120) / 100)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	SlippysGuts.OnStompExposion,
	FiendFolio.ITEM.COLLECTIBLE.SLIPPYS_GUTS
)

return SlippysGuts
