local Wiki = {
	-- Items
	Peppermint = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Spawns a freezing breath cloud for 3 seconds after releasing shoot button with full charge."},
			{str = "If enemy stays in cloud for too long, it will freeze to death."},
		},
		--[[{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "Placeholder text"},
		},]]
	},
	SaltShaker = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "On use spawns a ring of salt creep near Isaac."},
			{str = "Touching creep enemies get scared."},
		},
		--[[{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "Placeholder text"},
		},]]
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Salt Shaker was one of the few items not imported into Repentance, alongside Book Of Despair, Bowl of Tears, Donkey Jawbone, Knife Piece 3, Menorah, and Voodoo Pin."},
		},
	},
	GorgonMask = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "On use puts on/off Gorgon mask."},
			{str = "Looking at enemies when mask is on freezes them."},
			{str = "Isaac can't shoot while mask is on."},
		},
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Gorgon Mask is based on head of Medusa, Greek mythological character."},
		},
	},
	ThunderBombs = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Fully recharges active items."},
			{str = "When Isaac has no bombs, one can be placed at the cost of a charge."},
			{str = "Bombs make electricity that spreads to nearby enemies and does half bomb's damage."},
		},
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Thunder bombs was an unused idea from Antibirth, it only existed in concept art."},
		},
	},
	LithiumSalts = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Using pills lowers damage and tear rate but increases invincibility time on damage taken."},
		},
		{ -- Synergies
			{ str = "Synergies", fsize = 2, clr = 3, halign = 0 },
			{ str = "Horse Pills - effect is doubled." },
		},
		--[[{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = ""},
		},]]
	},
	BlastingBoots = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Gives explosion immunity."},
			{str = "Explosion launches Isaac in the air."},
		},
		{ -- Synergies
			{ str = "Synergies", fsize = 2, clr = 3, halign = 0 },
			{ str = "Edith - on landing procs Edith's stomp effect." },
		},
		{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "When Isaac launched, he can go over pits and and rocks."},
			{str = "Falling into pit brings you back to nearest solid ground."},
			{str = "Falling into pit as Edith makes you land like you would do a stomp jump."},
		},
		--[[{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = ""},
		},]]
	},
	LotBaby = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Familiar that mimics Isaac's movement on a 0.66 second delay."},
			{str = "Shoots only tears with basic damage and tear rate of Isaac."},
		},
		{ -- Synergies
			{ str = "Synergies", fsize = 2, clr = 3, halign = 0 },
			{ str = "BFFS! - damage is doubled." },
		},
		{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "When playing as Edith, gives +1 damage."},
		},
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Lot Baby is based on Eidth's husband Lot in Bible."},
			{str = "Originally was supposed to be a co-op baby, but because of modding API limitations and true co-op being in the Repentance, it was made as familiar."},
		},
	},
	PawnBaby = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Familiar like Brother Bobby that has 20% chance to shoot fear tears."},
			{str = "Nearby enemies has chance to get stomped."},
		},
		{ -- Synergies
			{ str = "Synergies", fsize = 2, clr = 3, halign = 0 },
			{ str = "BFFS! - damage is doubled." },
		},
		{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "Stomping kills regular enemies and deals 20% maximum boss health damage."},
		},
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Originally was supposed to be a co-op baby, but because of modding API limitations and true co-op being in the Repentance, it was made as familiar."},
		},
	},
	SaltyBaby = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Familiar that shoots salt creep circle."},
			{str = "Nearby enemies get fear effect near salt creep."},
		},
		{ -- Synergies
			{ str = "Synergies", fsize = 2, clr = 3, halign = 0 },
			{ str = "BFFS! - salt creep size increased by 30%." },
		},
		{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "Effect is similar to Salt Shaker."},
		},
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Originally was supposed to be a co-op baby, but because of modding API limitations and true co-op being in the Repentance, it was made as familiar."},
		},
	},
	Sodom = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Freezes enemeis in large radius."},
		},
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Sodom is a biblical city alongside Gomorrah that was destroyed by God for their wickedness."},
			{str = "Item icon references city's destruction by 'sulfur and fire'."},
		},
	},
	--[[TheChisel = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "When used as Tainted Edith, it will spawn on top of her and fall down, removing 1 stage of tranforming into a pepper statue."},
			{str = "After she's freed from being a statue, she will have a black powder-like effect for a short time."},
			{str = "This powder only deals contact damage, similar to creep."},
		},
		{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "When used when not being peppered or as a character that is not Tainted Edith, it will fall down and scrape flesh off of the side of your face, giving a tears and damage up for the room and dealing half a heart of damage."},
			{str = "- The room will darken for a short period of time when this happens."}
		},
	},]]

	-- Trinkets
	--Pepper Grinder
	PepperGrinder = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Each time you kill an enemy, there's a 33% chance they will explode into pepper powder, which will leave a stain of black powder-like creep on the ground."},
			{str = "It will slowly slide away from the killed enemy and fade away, dealing contact damage."},
			{str = "The pepper creep does 0.4 damage per tick."},
		},
		{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "Kills can be stacked and cause even more pepper powder to be produced."},
		},
	},
	--Smelling Salts
	SmellingSalts = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Ignores fatal damage after whitch trinket is destroyed."},
		},
	},
	--Salt Rock
	SaltRock = {
		{ -- Effect
			{str = "Effect", fsize = 2, clr = 3, halign = 0},
			{str = "Entering new room has 10% to make rock a salt rock."},
			{str = "Destroing spawns mini Edith statue."},
			{str = "Statue jumps on enemies. If no enemy left, on random rock/poop."},
		},
	},
	-- Characters
	Edith = {
		{ -- Start Data
			{str = "Start Data", fsize = 2, clr = 3, halign = 0},
			{str = "Items:"},
			{str = "- Salt Shaker (after unlocking)"},
			{str = "Stats:"},
			{str = "- HP: 3 Soul Hearts"},
			{str = "- Speed: 1.00"},
			{str = "- Tear rate: 2.73"},
			{str = "- Damage: 3.85"},
			{str = "- Range: 6.05"},
			{str = "- Shot speed: 1.00"},
			{str = "- Luck: 0.00"},
		},
		{ -- Traits
			{str = "Traits", fsize = 2, clr = 3, halign = 0},
			{str = "Edith cannot gain red heart containers. If an item would grant her a red heart container (including an empty one), it adds a soul heart instead."},
			{str = "Edith cannot walk around freely, and instead slides in cardinal direction."},
			{str = "When Edith stands still a charge bar appears. Moving will stop it charging."},
			{str = "Pressing the bomb key (E by default) will create a target radical that can be moved with shooting buttons."},
			{str = "Pressing it again will make Edith jump to that position, damaging enemies and destroing rocks on landing."},
			{str = "Pressing the drop key (ctrl by default) will switch to/from bomb landing."},
			{str = "If player has any bombs or golden bomb, explosion will happen on landing, damaging only enemies."},
		},
		{ -- Birthright
			{str = "Birthright", fsize = 2, clr = 3, halign = 0},
			{str = "Charging jump is faster and moving doesn't stop it."},
		},
		{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "Damage from landing is affected by Edith's damage."},
			{str = "Bomb landing has the same effects as bomb items effects."},
		},
		--[[{ -- Interactions
			{str = "Interactions", fsize = 2, clr = 3, halign = 0},
			{str = "Using Dark Arts will create a line between Edith and her Salt Shaker."},
		},]]
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Edith was unused and unfinished character in Antibirth mod, that eventually became Tainted Forgotten."},
		},
	},
	--[[TaintedEdith = {
		{ -- Start Data
			{str = "Start Data", fsize = 2, clr = 3, halign = 0},
			{str = "Items:"},
			{str = "- The Chisel"},
			{str = "Stats:"},
			{str = "- HP: 3 Black Hearts"},
			{str = "- Speed: 0.90"},
			{str = "- Tear rate: 2.73"},
			{str = "- Damage: 3.50"},
			{str = "- Range: 6.50"},
			{str = "- Shot speed: 1.00"},
			{str = "- Luck: 0.00"},
		},
		{ -- Traits
			{str = "Traits", fsize = 2, clr = 3, halign = 0},
			{str = "Tainted Edith cannot gain red heart containers. If an item would grant her a red heart container (including an empty one), it adds a black heart instead."},
			{str = "Unlike Edith, Tainted Edith can walk around freely."},
			{str = "When she is near an enemy, Tainted Edith will slowly become a statue of pepper. For each stage of pepper, she will lose 0.15 speed and gain 0.25 damage."},
			{str = "Once Tainted Edith becomes a full statue of pepper, she can no longer move. Using her pocket active item ''The Chisel'' will remove one stage of pepper and being freed from the statue will make her produce a trail of damaging pepper for 5 seconds."},
			{str = "If The Chisel is used when no pepper is present, she will instead scrape flesh off of the side of her face, giving a tears and damage up for the room and dealing half a heart of damage."},
		},
		{ -- Birthright
			{str = "Birthright", fsize = 2, clr = 3, halign = 0},
			{str = "All enemies that get near Tainted Edith will become slowed."},
			{str = "The size of the slowing radius depends on how peppered you are, getting larger if you are more peppered and smaller if less peppered."},
		},
		{ -- Notes
			{str = "Notes", fsize = 2, clr = 3, halign = 0},
			{str = "Tainted Edith is at a much higher risk of taking damage than most characters. Staying near enemies for too long can cause you to be unable to get away from them and you should be trying to use The Chisel frequently."},
			{str = "The best way to play as Tainted Edith is to balance the usage of The Chisel and be aware of your surrounding area, since at any time you can forget to use The Chisel and you can be turned into a statue."},
		},
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Tainted Edith's mechanic and design spanned over about 3 months and changed pretty drastically. She was originally going to look and work completely differently but we instead decided on a new concept and ran with it."},
			{str = "- She overall took another 3 months to code. Thanks Akad, anchikai., and BrakeDude!"},
		},
	},]]
}

return Wiki