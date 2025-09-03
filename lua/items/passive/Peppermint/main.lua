local Peppermint = {}
local Helpers = EdithRestored.Helpers

-- Hi here Kotry, here's Peppermint rework, right now its main functionality is done
-- Code formatted with https://codebeautify.org/lua-beautifier

--[[
	Known issues
	- Actually i haven't found any major issue, just lack of visual effect but i think it would be better if a spriter makes it so yeah, it's pretty much done
	- Ah yeah we need sound effect too
]]

-- Took from MeleeLib, for change tear Position when moving player's head
-- Conversions between directions to angle degrees
local DIRECTION_TO_DEGREES = {
	[Direction.NO_DIRECTION] = 0,
	[Direction.RIGHT] = 0,
	[Direction.DOWN] = 90,
	[Direction.LEFT] = 180,
	[Direction.UP] = 270,
}

-- Conversions between directions to vectors.
local DIRECTION_TO_VECTOR = {
	[Direction.NO_DIRECTION] = Vector(0, 0),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1),
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
}

-- Returns a vector representing the direction the player is aiming at.
---@param player EntityPlayer
---@return Vector
local function getAimDirection(player)
	if
		player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)
	then
		return player:GetAimDirection()
	end

	return DIRECTION_TO_VECTOR[player:GetHeadDirection()]
end

function Peppermint:RenderPepperMintCharge(player)
	local data = EdithRestored:GetData(player)
	local room = Game():GetRoom()

	if room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
		return
	end

	if not player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_PEPPERMINT) then
		return
	end

	if not data.PeppermintChargeBar then
		data.PeppermintChargeBar = Sprite("gfx/chargebar.anm2", true)
	end
	data.PeppermintChargeBar.Offset = Vector(-18 * player.SpriteScale.X, -20 * player.SpriteScale.Y)
	HudHelper.RenderChargeBar(
		data.PeppermintChargeBar,
		math.max(0, data.PeppermintCharge or 0),
		100,
		EdithRestored.Room():WorldToScreenPosition(player.Position)
	)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Peppermint.RenderPepperMintCharge, 0)

---@param player EntityPlayer
function Peppermint:AddPeppermintCharge(player)
	local data = EdithRestored:GetData(player)

	if not player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_PEPPERMINT) then
		return
	end

	if not data.PeppermintCharge then
		data.PeppermintCharge = 0
	end

	local shoot = {
		l = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
		r = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
		u = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
		d = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex),
	}

	local isShooting = (shoot.l or shoot.r or shoot.u or shoot.d)

	if isShooting == true then
		data.PeppermintCharge = math.min(100, data.PeppermintCharge + 1)
	else
		if data.PeppermintCharge >= 100 then
			local speed = getAimDirection(player):Resized(4)
			local pepperMintBreath = Isaac.Spawn(
				EntityType.ENTITY_EFFECT,
				EdithRestored.Enums.Entities.PEPPERMINT.Variant,
				0,
				player.Position + getAimDirection(player):Resized(20),
				speed,
				player
			):ToEffect()
			pepperMintBreath:SetTimeout(90)
		end
		data.PeppermintCharge = 0
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Peppermint.AddPeppermintCharge)

---@param cloud EntityEffect
function Peppermint:CloudUpdate(cloud)
	local player = Helpers.GetPlayerFromTear(cloud)
	if not player then
		cloud:Remove()
		return
	end
	if cloud.Timeout <= 0 then
		cloud:Remove()
	end
	--cloud.Position = player.Position + getAimDirection(player):Resized(20)
	cloud.Velocity = Helpers.Lerp(cloud.Velocity, Vector.Zero, 0.3, 0.2)
	if cloud.Timeout > 10 then
		local capsule = cloud:GetNullCapsule("cloud")
		for _, enemy in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
			-- Make sure it can be hurt.
			if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
				if enemy:GetDamageCountdown() == 0 then
					enemy:TakeDamage(player.Damage / 3, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(cloud), 10)
				end
			end
		end
	end
end
EdithRestored:AddCallback(
	ModCallbacks.MC_POST_EFFECT_UPDATE,
	Peppermint.CloudUpdate,
	EdithRestored.Enums.Entities.PEPPERMINT.Variant
)

function Peppermint:CloudDamage(ent, damage, flags, source, cd)
	if
		source
		and source.Entity
		and source.Entity.Type == EntityType.ENTITY_EFFECT
		and source.Entity.Variant == EdithRestored.Enums.Entities.PEPPERMINT.Variant
	then
		local cloud = source.Entity:ToEffect()
		if ent:HasMortalDamage() then
			ent:AddEntityFlags(EntityFlag.FLAG_ICE)
		else
			local slowColor = Color(0.7, 0.9, 1, 1, 0, 0, 0)
			if not ent:HasEntityFlags(EntityFlag.FLAG_SLOW) then
				ent:AddSlowing(EntityRef(cloud), 10, 0.5, slowColor)
			end
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, Peppermint.CloudDamage)

---@param cloud EntityEffect
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, cloud)
	cloud.Color = Color(0.14, 0.91, 1, math.min(1, cloud.Timeout / 30), 0, 0, 0)
	cloud:GetSprite().Offset = Vector(0, -10)
	if EdithRestored.DebugMode then
		local shape = cloud:GetDebugShape(true)
		local capsule = cloud:GetNullCapsule("cloud")
		shape:Circle(cloud.Position, capsule:GetF1())
	end
end, EdithRestored.Enums.Entities.PEPPERMINT.Variant)
