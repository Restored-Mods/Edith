local Godhead = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Godhead:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)

	local aura = player:FireTear(player.Position, Vector.Zero, false, true, false, player):ToTear()
	aura.TearFlags = BitSet128(0, 0)
	aura.Visible = true
	aura:AddTearFlags(TearFlags.TEAR_GLOW | TearFlags.TEAR_SPECTRAL)
	aura.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	aura.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	local height = aura.Height
	aura:SetColor(Color(1, 1, 1 ,0), 90, 0, false, false)
	Isaac.CreateTimer(function() aura.FallingSpeed = 0 aura.FallingAcceleration = 0 aura.Height = height aura:SetShadowSize(0) end, 1, 90, false)
	Isaac.CreateTimer(function() aura:Remove() end, 90, 1, false)
	
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Godhead.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_GODHEAD, PoolFruitCake = true }
)

return Godhead