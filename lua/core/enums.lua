local Enums = {}

Enums.MouseClick = {LEFT = 0, RIGHT = 1, WHEEL = 2, BACK = 3, FORWARD = 4}

Enums.Entities = {
					FALLING_CHISEL = 
					{
						Type = Isaac.GetEntityTypeByName("The Chisel"), 
						Variant = Isaac.GetEntityVariantByName("The Chisel"),
						SubType = 0
					},
					SALT_STATUE = 
					{
						Type = Isaac.GetEntityTypeByName("Salt Statue"), 
						Variant = Isaac.GetEntityVariantByName("Salt Statue"),
						SubType = 0
					},
					SALT_STATUE_MINI = 
					{
						Type = Isaac.GetEntityTypeByName("Mini Salt Statue"), 
						Variant = Isaac.GetEntityVariantByName("Mini Salt Statue"),
						SubType = 0
					},
					EDITH_TARGET =
					{
						Type = Isaac.GetEntityTypeByName("Edith Target (TC)"),
						Variant = Isaac.GetEntityVariantByName("Edith Target (TC)"),
						SubType = 0
					},
					SALT_CREEP =
					{
						Type = Isaac.GetEntityTypeByName("Salt Creep"),
						Variant = Isaac.GetEntityVariantByName("Salt Creep"),
						SubType = 0
					},
					PEPPERMINT =
					{
						Type = Isaac.GetEntityTypeByName("Peppermint Cloud"),
						Variant = Isaac.GetEntityVariantByName("Peppermint Cloud"),
						SubType = 0
					},
					CUSTOM_DUST_CLOUD =
					{
						Type = Isaac.GetEntityTypeByName("Custom Dust Cloud"),
						Variant = Isaac.GetEntityVariantByName("Custom Dust Cloud")
					},
					WEREWOLF_SWIPE = {
						Type = Isaac.GetEntityTypeByName("Werewolf Swipe"),
						Variant = Isaac.GetEntityVariantByName("Werewolf Swipe"),
						SubType = 0
					},
					MOON_PHASE = {
						Type = Isaac.GetEntityTypeByName("Moon Phases"),
						Variant = Isaac.GetEntityVariantByName("Moon Phases"),
						SubType = 0
					}
				}

Enums.Familiars = 
				{
					SALTY_BABY =
								{
									Type = Isaac.GetEntityTypeByName("Salty Baby"),
									Variant = Isaac.GetEntityVariantByName("Salty Baby"),
									SubType = 0
								},
					LOT_BABY = {
									Type = Isaac.GetEntityTypeByName("Lot Baby"),
									Variant = Isaac.GetEntityVariantByName("Lot Baby"),
									SubType = Isaac.GetEntitySubTypeByName("Lot Baby")
								},
					PAWN_BABY = {
									Type = Isaac.GetEntityTypeByName("Pawn Baby"),
									Variant = Isaac.GetEntityVariantByName("Pawn Baby"),
									SubType = 0
								},
				}

Enums.PlayerType = 
				{
					EDITH = Isaac.GetPlayerTypeByName("Edith", false), 
					EDITH_B = Isaac.GetPlayerTypeByName("Edith", true)
				}

Enums.CollectibleType = 
					{
						COLLECTIBLE_BREATH_MINTS = Isaac.GetItemIdByName("Breath Mints"),
						COLLECTIBLE_LITHIUM = Isaac.GetItemIdByName("Lithium Salts"),
						COLLECTIBLE_SODOM = Isaac.GetItemIdByName("Sodom"),
						COLLECTIBLE_BLASTING_BOOTS = Isaac.GetItemIdByName("Blasting Boots"),
						COLLECTIBLE_THUNDER_BOMBS = Isaac.GetItemIdByName("Thunder Bombs"),
						COLLECTIBLE_LOT_BABY = Isaac.GetItemIdByName("Lot Baby"),
						COLLECTIBLE_SALTY_BABY = Isaac.GetItemIdByName("Salty Baby"),
						COLLECTIBLE_PAWN_BABY = Isaac.GetItemIdByName("Pawn Baby"),
						COLLECTIBLE_SALT_SHAKER = Isaac.GetItemIdByName("Salt Shaker"),					
						COLLECTIBLE_GORGON_MASK = Isaac.GetItemIdByName("Gorgon Mask"),
						COLLECTIBLE_RED_HOOD = Isaac.GetItemIdByName("Red Hood"),
						COLLECTIBLE_LANDMINE = Isaac.GetItemIdByName("Landmine"),
						--COLLECTIBLE_THE_CHISEL = Isaac.GetItemIdByName("The Chisel"),
					}

Enums.TrinketType =
					{
						TRINKET_PEPPER_GRINDER = Isaac.GetTrinketIdByName("Pepper Grinder"),
						TRINKET_SALT_ROCK = Isaac.GetTrinketIdByName("Salt Rock"),
						TRINKET_SMELLING_SALTS = Isaac.GetTrinketIdByName("Smelling Salts"),
					}

Enums.NullItems = 
					{
						GORGON_MASK = Isaac.GetNullItemIdByName("Gorgon Mask Effect"),
						RED_HOOD = Isaac.GetNullItemIdByName("Red Hood Effect"),
					}


Enums.Pickups = 
				{
					Cards  = 
							{
								CARD_PRUDENCE = Isaac.GetCardIdByName("Prudence"),
								CARD_REVERSE_PRUDENCE = Isaac.GetCardIdByName("Prudence?"),
								CARD_SOUL_EDITH = Isaac.GetCardIdByName("Soul of Edith"),
							},
				}

Enums.SFX = 
				{
					Cards  = 
							{
								CARD_PRUDENCE = Isaac.GetSoundIdByName("Prudence"),
								CARD_REVERSE_PRUDENCE = Isaac.GetSoundIdByName("Reverse Prudence"),
								CARD_SOUL_EDITH = Isaac.GetSoundIdByName("Soul Of Edith"),
							},
					SaltShaker =
							{
								SHAKE = Isaac.GetSoundIdByName("Salt Shaker"),
							},
					Edith = 
							{
								ROCK_SLIDE = Isaac.GetSoundIdByName("RockSlide"),
								WATER_STOMP = Isaac.GetSoundIdByName("stompOnWater"),
							},
				}

Enums.GFX = 
{
	Cards 	=
			{
				CARD_PRUDENCE = "Prudence.png",
				CARD_REVERSE_PRUDENCE = "PrudenceReverse.png",
				CARD_SOUL_EDITH = "SoulOfEdith.png",
			},
}

-- Costumes
Enums.Costumes = {
	EDITH_HOOD = Isaac.GetCostumeIdByPath("gfx/characters/Character_001_Edith_Hood.anm2"),
	EDITH_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/Character_001_Edith_b_Hood.anm2"),
}

Enums.Callbacks = {
	ON_EDITH_STOMP_EXPLOSION = "ON_EDITH_STOMP_EXPLOSION",
	ON_EDITH_STOMP_EXPLOSION_EFFECT = "ON_EDITH_STOMP_EXPLOSION_EFFECT"
}

Enums.BombVariant = {
	LANDMINE = Isaac.GetEntityVariantByName("Landmine"),
}

BombFlagsAPI.AddNewCustomBombFlag("THUNDER_BOMB", Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS)

Enums.Challenges = {

}

EdithCompliance.Enums = Enums

local function InitAchievements()
	if not EdithCompliance.Enums.Achievements then
		EdithCompliance.Enums.Achievements = {}
		EdithCompliance.Enums.Achievements.Characters = {
			EDITH =  Isaac.GetAchievementIdByName("Edith"),
			TAINTED =  Isaac.GetAchievementIdByName("Tainted Edith"),
		}
		EdithCompliance.Enums.Achievements.CompletionMarks = {
			-- A-side Unlicks
			BLASTING_BOOTS =  Isaac.GetAchievementIdByName("Blasting Boots"),
			SALTY_BABY =  Isaac.GetAchievementIdByName("Salty Baby"),
			SALT_SHAKER =  Isaac.GetAchievementIdByName("Salt Shaker"),
			THUNDER_BOMBS =  Isaac.GetAchievementIdByName("Thunder Bombs"),
			SMELLING_SALTS =  Isaac.GetAchievementIdByName("Smelling Salts"),
			PAWN_BABY =  Isaac.GetAchievementIdByName("Pawn Baby"),
			GORGON_MASK =  Isaac.GetAchievementIdByName("Gorgon Mask"),
			RED_HOOD =  Isaac.GetAchievementIdByName("Red Hood"),
			LITHIUM =  Isaac.GetAchievementIdByName("Lithium Salts"),
			SODOM =  Isaac.GetAchievementIdByName("Sodom"),
			LOT_BABY =  Isaac.GetAchievementIdByName("Lot Baby"),

			-- Tainted Unlocks
			SOUL_EDITH =  Isaac.GetAchievementIdByName("Soul of Edith"),
			REV_PRUDENCE =  Isaac.GetAchievementIdByName("Reverse Prudence"),
		}
		EdithCompliance.Enums.Achievements.Misc = {
			SALT_ROCK = Isaac.GetAchievementIdByName("Salt Rock")
		}
		-- Challenges
		EdithCompliance.Enums.Achievements.Challenges = {

		}
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function() EdithCompliance:RemoveCallback(ModCallbacks.MC_MAIN_MENU_RENDER, InitAchievements) InitAchievements() end)
EdithCompliance:AddCallback(ModCallbacks.MC_POST_RENDER, function()  EdithCompliance:RemoveCallback(ModCallbacks.MC_POST_RENDER, InitAchievements) InitAchievements() end)
InitAchievements()