local Musca = {}

---@param player EntityPlayer
---@param bombDamage number
---@param position Vector
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
---@param isScatterBomb boolean
---@return table?
function Musca:OnStompExplosion(player, bombDamage, position, radius, hasBombs, isGigaBomb, isScatterBomb)
	local flies = #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY)
	local rng = player:GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.MUSCA)

	local randAngle = math.random(360)
	local angles = {Vector.FromAngle(randAngle)}

	angles = {Vector.FromAngle(randAngle), Vector.FromAngle(randAngle + 120), Vector.FromAngle(randAngle + 240)}

	for _, angle in ipairs(angles) do
		if flies >= 6 then
			break
		end
		local subt = rng:RandomInt(5) + 1
		local locust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subt, position, angle:Resized(10), player):ToFamiliar()
		locust.Player = player
		locust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		locust:Update()
		flies = flies + 1
	end

end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	Musca.OnStompExplosion,
	{Item = FiendFolio.ITEM.COLLECTIBLE.MUSCA, PoolScatterBombs = true }
)

return Musca
