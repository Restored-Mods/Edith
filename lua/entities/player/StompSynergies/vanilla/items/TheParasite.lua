local TheParasite = {}

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
---@param force boolean
function TheParasite:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake, force)
    local data = EdithRestored:GetData(player)
	if data.PreJumpPosition then
		local vec = player.Position - data.PreJumpPosition
		local dir = vec:GetAngleDegrees()
		for i = -90, 90, 180 do
			local tear = player:FireTear(player.Position, Vector.FromAngle(dir + i):Resized(10 * player.ShotSpeed), false, true, false, player, 0.5)
			tear:ChangeVariant(TearVariant.BLUE)
			tear:ClearTearFlags(TearFlags.TEAR_SPLIT)
			tear.Size = tear.Size * 0.5
			tear.SizeMulti = tear.SizeMulti * 0.8
			tear.Height = tear.Height / 2
			if tear.CollisionDamage < 1 then
				tear:Remove()
			end
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	TheParasite.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_PARASITE, PoolFruitCake = true }
)

return TheParasite