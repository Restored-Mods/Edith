local LeftoverTakeout = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function LeftoverTakeout:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	--Fortune Stuff
	if FiendFolio.FortuneTearCooldown <= 0 then
		local baseFortuneOdds = 0
		if player:HasTrinket(FiendFolio.ITEM.TRINKET.FORTUNE_WORM) or player:HasTrinket(FiendFolio.ITEM.ROCK.FORTUNE_WORM_FOSSIL) then
			local fortuneWormOdds = player:GetPlayerType() == FiendFolio.PLAYER.FIEND and 5 or 1
			fortuneWormOdds = fortuneWormOdds * (player:GetTrinketMultiplier(FiendFolio.ITEM.TRINKET.FORTUNE_WORM) + FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.FORTUNE_WORM_FOSSIL))
			baseFortuneOdds = baseFortuneOdds + fortuneWormOdds
		end
		if FiendFolio.GreatFortune then
			baseFortuneOdds = baseFortuneOdds + 3
		end
		if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.LEFTOVER_TAKEOUT) then
			baseFortuneOdds = baseFortuneOdds + 17
		end

		if baseFortuneOdds > 0 then
			local freq = math.min(math.max(math.floor(22 - baseFortuneOdds - player.Luck), 3), 25)
			if math.random(freq) == 1 then
				Isaac.CreateTimer(function()
				FiendFolio:ShowFortune(false, true)
				FiendFolio.FortuneTearCooldown = 20
				end, 1, 1, true)
				return { StompDamage = stompDamage * 1.05 }
			end
		end
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	LeftoverTakeout.OnStompModify,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.LEFTOVER_TAKEOUT }
)

return LeftoverTakeout