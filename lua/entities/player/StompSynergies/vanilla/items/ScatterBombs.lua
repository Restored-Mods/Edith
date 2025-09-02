local ScatterBombs = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombDamage number
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
function ScatterBombs:OnStompExplosion(player, bombDamage, radius, hasBombs, isGigaBomb)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SCATTER_BOMBS)
	for i = 1, rng:RandomInt(4, 5) do
		local flags = player:GetBombFlags()
		if isGigaBomb then
			flags = flags | TearFlags.TEAR_GIGA_BOMB
		end
		Isaac.CreateTimer(function()
			local explosionPosition = Vector.FromAngle(rng:RandomInt(1, 360))
				:Resized(TSIL.Random.GetRandomFloat(0.1, radius * 1.5, rng))
			EdithRestored.Game:BombExplosionEffects(
				player.Position + explosionPosition,
				bombDamage / 2,
				player:GetBombFlags(),
				Color.Default,
				player,
				0.5,
				true,
				false
			)
			if FiendFolio then
				if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.SLIPPYS_GUTS) then
					local cloud = Isaac.Spawn(
						FiendFolio.FF.SlippyFart.ID,
						FiendFolio.FF.SlippyFart.Var,
						FiendFolio.FF.SlippyFart.Sub,
						explosion.Position,
						Vector.Zero,
						player
					)
					SFXManager():Play(FiendFolio.Sounds.FartFrog1, 0.2, 0, false, math.random(80, 120) / 100)

					cloud:GetData().RadiusMult = 0.5
					cloud.SpriteScale = Vector(0.5, 0.5)
				end
				if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.NUGGET_BOMBS) then -- FF Synergy
					local spooter =
						FiendFolio:SpawnNuggetFam(player.Position + explosionPosition, flags, player, false, nil)
					if spooter and not isGigaBomb then
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
		end, rng:RandomInt(5, 10), 1, false)
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	ScatterBombs.OnStompExplosion,
	{ Item = CollectibleType.COLLECTIBLE_SCATTER_BOMBS }
)

return ScatterBombs
