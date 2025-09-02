local NuggetBombs = {}

---@param player EntityPlayer
---@param bombDamage number
---@param position Vector
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
---@param isScatterBomb boolean
---@return table?
function NuggetBombs:OnStompExplosion(player, bombDamage, position, radius, hasBombs, isGigaBomb, isScatterBomb)
	local flags = player:GetBombFlags()
	if isGigaBomb then
		flags = flags | TearFlags.TEAR_GIGA_BOMB
	end
	local spooter = FiendFolio:SpawnNuggetFam(position, flags, player, false, nil)

	if spooter then
		if isGigaBomb and not isScatterBomb then -- pls don't sue us FF team
			spooter:GetData().isUltraSpooter = true
			spooter:SetSize(20, spooter.SizeMulti, 12)
			local sprite = spooter:GetSprite()
			sprite:Load("gfx/familiar/nugget fly/ultra pooter.anm2", true)
			sprite:Play("Appear", true)
		elseif isScatterBomb then
			spooter:GetData().isBabySpooter = true
			--spooter.SpriteScale = Vector(0.5, 0.5)
			spooter:SetSize(spooter.Size * 0.5, spooter.SizeMulti * 0.5, 12)
			local sprite = spooter:GetSprite()
			sprite:Load("gfx/familiar/nugget fly/pooter_0.anm2", true)
			sprite:Play("Appear", true)
			--sprite:ReplaceSpritesheet(1, "gfx/familiar/babypooter_spawn.png")
			--sprite:LoadGraphics()
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	NuggetBombs.OnStompExplosion,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.NUGGET_BOMBS, PoolScatterBombs = true }
)

return NuggetBombs
