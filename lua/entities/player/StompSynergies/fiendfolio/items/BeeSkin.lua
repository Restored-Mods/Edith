local BeeSkin = {}

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param force boolean
---@param isStompPool table
function BeeSkin:OnStomp(player, stompDamage, bombLanding, force, isStompPool)
	local pdata = player:GetData()
	pdata.BeeSkinAngle = (pdata.BeeSkinAngle or -110) + 20
	local vel = Vector.FromAngle(pdata.BeeSkinAngle) * 8 * player.ShotSpeed
	local numberOfBees = player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.BEE_SKIN)
	local numshots = math.min(2 + numberOfBees, 8)

	local tear = player:FireTear(player.Position, Vector.Zero, true, true, false, player, 1)
	tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	local fallingspeed = tear.FallingSpeed
	local height = tear.Height
	local fallingaccel = tear.FallingAcceleration
	local scale = tear.Scale * 0.8
	local flags = tear.TearFlags
	tear:Remove()
	for i = 1, numshots do
		local shotvel = vel:Rotated((360 / numshots) * i) + player.Velocity
		local beeskintear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0,player.Position, shotvel, player):ToTear()
		beeskintear.FallingSpeed = fallingspeed
		beeskintear.Height = height
		beeskintear.FallingAcceleration = fallingaccel
		beeskintear.TearFlags = flags
		beeskintear.CollisionDamage = stompDamage * 0.3
		beeskintear.Parent = player
		beeskintear.Scale = scale
		beeskintear.CanTriggerStreakEnd = false
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	BeeSkin.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.BEE_SKIN }
)

return BeeSkin