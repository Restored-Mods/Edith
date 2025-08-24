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
						Type = Isaac.GetEntityTypeByName("Restored Edith Target"),
						Variant = Isaac.GetEntityVariantByName("Restored Edith Target"),
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
									Type = Isaac.GetEntityTypeByName("​Salty Baby"),
									Variant = Isaac.GetEntityVariantByName("​Salty Baby"),
									SubType = 0
								},
					LOT_BABY = {
									Type = Isaac.GetEntityTypeByName("Lot Baby"),
									Variant = Isaac.GetEntityVariantByName("Lot Baby"),
									SubType = Isaac.GetEntitySubTypeByName("Lot Baby")
								},
					SALT_PAWNS = {
									Type = Isaac.GetEntityTypeByName("Salt Pawns"),
									Variant = Isaac.GetEntityVariantByName("Salt Pawns"),
									SubType = 0
								},
				}

Enums.PlayerType = 
				{
					EDITH = Isaac.GetPlayerTypeByName("Redith", false), 
					EDITH_B = Isaac.GetPlayerTypeByName("Redith", true)
				}

Enums.CollectibleType = 
					{
						COLLECTIBLE_PEPPERMINT = Isaac.GetItemIdByName("Peppermint"),
						COLLECTIBLE_LITHIUM = Isaac.GetItemIdByName("Lithium Salts"),
						COLLECTIBLE_SODOM = Isaac.GetItemIdByName("​Sodom"),
						COLLECTIBLE_BLASTING_BOOTS = Isaac.GetItemIdByName("Blasting Boots"),
						COLLECTIBLE_THUNDER_BOMBS = Isaac.GetItemIdByName("​Thunder Bombs"),
						COLLECTIBLE_LOT_BABY = Isaac.GetItemIdByName("Lot Baby"),
						COLLECTIBLE_SALTY_BABY = Isaac.GetItemIdByName("​Salty Baby"),
						COLLECTIBLE_SALT_PAWNS = Isaac.GetItemIdByName("Salt Pawns"),
						COLLECTIBLE_SALT_SHAKER = Isaac.GetItemIdByName("​Salt Shaker"),					
						COLLECTIBLE_GORGON_MASK = Isaac.GetItemIdByName("Gorgon Mask"),
						COLLECTIBLE_RED_HOOD = Isaac.GetItemIdByName("​Red Hood"),
						COLLECTIBLE_SHRAPNEL_BOMBS = Isaac.GetItemIdByName("Shrapnel Bombs"),
						--COLLECTIBLE_THE_CHISEL = Isaac.GetItemIdByName("The Chisel"),
					}

Enums.TrinketType =
					{
						--TRINKET_PEPPER_GRINDER = Isaac.GetTrinketIdByName("Pepper Grinder"),
						TRINKET_SALT_ROCK = Isaac.GetTrinketIdByName("Salt Rock"),
						TRINKET_SMELLING_SALTS = Isaac.GetTrinketIdByName("Smelling Salts"),
						TRINKET_CHUNK_OF_AMBER = Isaac.GetTrinketIdByName("Chunk of Amber"),
					}

Enums.NullItems = 
					{
						GORGON_MASK = Isaac.GetNullItemIdByName("Gorgon Mask Effect"),
						RED_HOOD = Isaac.GetNullItemIdByName("Red Hood Effect"),
						LITHIUM_POSITIVE = Isaac.GetNullItemIdByName("Lithium Positive Effect"),
						LITHIUM_NEGATIVE = Isaac.GetNullItemIdByName("Lithium Negative Effect"),
						LITHIUM_FALSEPHD = Isaac.GetNullItemIdByName("Lithium False PHD Effect"),
					}


Enums.Pickups = 
				{
					Cards  = 
							{
								--CARD_PRUDENCE = Isaac.GetCardIdByName("Prudence"),
								--CARD_REVERSE_PRUDENCE = Isaac.GetCardIdByName("Prudence?"),
								CARD_SOUL_EDITH = Isaac.GetCardIdByName("Soul of Edith"),
							},
					Pills  =
							{
								PILL_LITHIUM = Isaac.GetEntitySubTypeByName("Lithium Pill"),
								PILL_HORSE_LITHIUM = Isaac.GetEntitySubTypeByName("Horse Lithium Pill"),
							},
					PillEffects = {
								PILLEFFECT_LITHIUM = Isaac.GetPillEffectByName("Lithium");
					},
				}

Enums.SFX = 
				{
					Cards  = 
							{
								--CARD_PRUDENCE = Isaac.GetSoundIdByName("Prudence"),
								--CARD_REVERSE_PRUDENCE = Isaac.GetSoundIdByName("Reverse Prudence"),
								CARD_SOUL_EDITH = Isaac.GetSoundIdByName("Soul Of Edith"),
							},
					SaltShaker =
							{
								SHAKE = Isaac.GetSoundIdByName("Salt Shaker Use"),
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
				--CARD_PRUDENCE = "Prudence.png",
				--CARD_REVERSE_PRUDENCE = "PrudenceReverse.png",
				CARD_SOUL_EDITH = "SoulOfEdith.png",
			},
}

-- Costumes
Enums.Costumes = {
	EDITH_HOOD = Isaac.GetCostumeIdByPath("gfx/characters/Character_001_Redith_Hood.anm2"),
	EDITH_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/Character_001_Edith_b_Hood.anm2"),
}

Enums.PlayerSprites = {
	EDITH = "gfx/Redith.anm2",
	EDITH_B = "gfx/Redith_b.anm2"
}

Enums.Callbacks = {
	ON_EDITH_STOMP_EXPLOSION = "ON_EDITH_STOMP_EXPLOSION",
	DO_STOMP_EXPLOSION = "DO_STOMP_EXPLOSION",
	ON_EDITH_STOMP_LANDING_IFRAMES = "ON_EDITH_STOMP_LANDING_IFRAMES",
	ON_EDITH_JUMPING = "ON_EDITH_JUMPING",
	ON_EDITH_LANDING = "ON_EDITH_LANDING"
}

Enums.BombVariant = {
	BOMB_SHRAPNEL = Isaac.GetEntityVariantByName("Shrapnel Bomb")
}

Enums.RockVariant = {
	ROCK_SALT = 683
}

BombFlagsAPI.AddNewCustomBombFlag("THUNDER_BOMB", Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS)
BombFlagsAPI.AddNewCustomBombFlag("SHRAPNEL_BOMB", Enums.CollectibleType.COLLECTIBLE_SHRAPNEL_BOMBS)

Enums.Challenges = {
	ROCKET_LACES = Isaac.GetChallengeIdByName("Rocket Laces"),
}

Enums.Achievements = {}
Enums.Achievements.Characters = {
	EDITH =  Isaac.GetAchievementIdByName("Edith"),
	--TAINTED =  Isaac.GetAchievementIdByName("Tainted Edith"),
}
Enums.Achievements.CompletionMarks = {
	-- A-side Unlicks
	BLASTING_BOOTS =  Isaac.GetAchievementIdByName("Blasting Boots"),
	SALTY_BABY =  Isaac.GetAchievementIdByName("​Salty Baby"),
	SALT_SHAKER =  Isaac.GetAchievementIdByName("​Salt Shaker"),
	CHUNK_OF_AMBER =  Isaac.GetAchievementIdByName("Chunk of Amber"),
	THUNDER_BOMBS =  Isaac.GetAchievementIdByName("​Thunder Bombs"),
	SMELLING_SALTS =  Isaac.GetAchievementIdByName("Smelling Salts"),
	SALT_PAWNS =  Isaac.GetAchievementIdByName("Salt Pawns"),
	GORGON_MASK =  Isaac.GetAchievementIdByName("Gorgon Mask"),
	RED_HOOD =  Isaac.GetAchievementIdByName("​Red Hood"),
	LITHIUM =  Isaac.GetAchievementIdByName("Lithium Salts"),
	SHRAPNEL_BOMBS = Isaac.GetAchievementIdByName("Shrapnel Bombs"),
	SODOM =  Isaac.GetAchievementIdByName("​Sodom"),
	SALT_ROCK = Isaac.GetAchievementIdByName("Salt Rock"),
	SOUL_EDITH =  Isaac.GetAchievementIdByName("Soul of Edith"),
	
	PEPPERMINT =  Isaac.GetAchievementIdByName("Peppermint"),
	--REV_PRUDENCE =  Isaac.GetAchievementIdByName("Reverse Prudence"),
}
Enums.Achievements.Misc = {
	
}
-- Challenges
Enums.Achievements.Challenges = {

}

Enums.Achievements.Marks = {
	ASide = {
		[CompletionType.MOMS_HEART] = Enums.Achievements.CompletionMarks.SALTY_BABY,
		[CompletionType.ISAAC] = Enums.Achievements.CompletionMarks.SALT_SHAKER,
		[CompletionType.SATAN] = Enums.Achievements.CompletionMarks.CHUNK_OF_AMBER,
		[CompletionType.BOSS_RUSH] = Enums.Achievements.CompletionMarks.RED_HOOD,
		[CompletionType.BLUE_BABY] = Enums.Achievements.CompletionMarks.THUNDER_BOMBS,
		[CompletionType.LAMB] = Enums.Achievements.CompletionMarks.SMELLING_SALTS,
		[CompletionType.MEGA_SATAN] = Enums.Achievements.CompletionMarks.SALT_ROCK,
		[CompletionType.HUSH] = Enums.Achievements.CompletionMarks.BLASTING_BOOTS,
		[CompletionType.ULTRA_GREED] = Enums.Achievements.CompletionMarks.SALT_PAWNS,
		[CompletionType.ULTRA_GREEDIER] = Enums.Achievements.CompletionMarks.GORGON_MASK,
		[CompletionType.DELIRIUM] = Enums.Achievements.CompletionMarks.LITHIUM,
		[CompletionType.MOTHER] = Enums.Achievements.CompletionMarks.SHRAPNEL_BOMBS,
		[CompletionType.BEAST] = Enums.Achievements.CompletionMarks.SODOM,
	}
}

EdithRestored.Enums = Enums