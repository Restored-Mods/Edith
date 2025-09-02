local NuggetBombs = {}

---@param player EntityPlayer
---@param bombDamage number
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
function NuggetBombs:OnStompExplosion(player, bombDamage, radius, hasBombs, isGigaBomb)
	local flags = player:GetBombFlags()
	if isGigaBomb then
		flags = flags | TearFlags.TEAR_GIGA_BOMB
	end
	local spooter = FiendFolio:SpawnNuggetFam(player.Position, flags, player, false, nil)

	if spooter and isGigaBomb then -- pls don't sue us FF team
	  spooter:GetData().isUltraSpooter = true
	  spooter:SetSize(20, spooter.SizeMulti, 12)
	  local sprite = spooter:GetSprite()
	  sprite:Load("gfx/familiar/nugget fly/ultra pooter.anm2", true)
	  sprite:Play("Appear", true)
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	NuggetBombs.OnStompExplosion,
	{Item = FiendFolio.ITEM.COLLECTIBLE.NUGGET_BOMBS }
)

return NuggetBombs
