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
						SubType = Isaac.GetEntitySubTypeByName("Salt Creep")
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
					EDITH = Isaac.GetPlayerTypeByName("C!Edith", false), 
					EDITH_B = Isaac.GetPlayerTypeByName("C!Edith", true)
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
	EDITH_HOOD = Isaac.GetCostumeIdByPath("gfx_cedith/characters/Character_001_C!Edith_Hood.anm2"),
	EDITH_B_HAIR = Isaac.GetCostumeIdByPath("gfx_cedith/characters/Character_001_Edith_b_Hood.anm2"),
}

Enums.PlayerSprites = {
	EDITH = "gfx_cedith/c!edith.anm2",
	EDITH_B = "gfx_cedith/c!edith_b.anm2"
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

Enums.Achievements = {}
Enums.Achievements.Characters = {
	EDITH =  Isaac.GetAchievementIdByName("Edith"),
	TAINTED =  Isaac.GetAchievementIdByName("Tainted Edith"),
}
Enums.Achievements.CompletionMarks = {
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
	LANDMINE =  Isaac.GetAchievementIdByName("Landmine"),

	-- Tainted Unlocks
	SOUL_EDITH =  Isaac.GetAchievementIdByName("Soul of Edith"),
	REV_PRUDENCE =  Isaac.GetAchievementIdByName("Reverse Prudence"),
}
Enums.Achievements.Misc = {
	SALT_ROCK = Isaac.GetAchievementIdByName("Salt Rock")
}
-- Challenges
Enums.Achievements.Challenges = {

}

Enums.Achievements.Marks = {
	ASide = {
		[CompletionType.MOMS_HEART] = Enums.Achievements.CompletionMarks.SALTY_BABY,
		[CompletionType.ISAAC] = Enums.Achievements.CompletionMarks.SALT_SHAKER,
		[CompletionType.SATAN] = Enums.Achievements.CompletionMarks.LANDMINE,
		[CompletionType.BOSS_RUSH] = Enums.Achievements.CompletionMarks.RED_HOOD,
		[CompletionType.BLUE_BABY] = Enums.Achievements.CompletionMarks.THUNDER_BOMBS,
		[CompletionType.LAMB] = Enums.Achievements.CompletionMarks.SMELLING_SALTS,
		[CompletionType.MEGA_SATAN] = Enums.Achievements.CompletionMarks.PAWN_BABY,
		[CompletionType.HUSH] = Enums.Achievements.CompletionMarks.BLASTING_BOOTS,
		[CompletionType.ULTRA_GREED] = Enums.Achievements.CompletionMarks.SALTY_BABY,
		[CompletionType.ULTRA_GREEDIER] = Enums.Achievements.CompletionMarks.GORGON_MASK,
		[CompletionType.DELIRIUM] = Enums.Achievements.CompletionMarks.LITHIUM,
		[CompletionType.MOTHER] = Enums.Achievements.CompletionMarks.SALTY_BABY,
		[CompletionType.BEAST] = Enums.Achievements.CompletionMarks.SODOM,
	}
}

EdithCompliance.Enums = Enums