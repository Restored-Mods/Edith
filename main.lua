EdithRestored = RegisterMod("Edith", 1)

local LOCAL_TSIL = require("lua.extraLibs.loi.TSIL")
LOCAL_TSIL.Init("lua.extraLibs.loi")
include("lua.extraLibs.APIs.custom_bomb_flags")

require("lua.extraLibs.jumplib").Init()
include("lua.extraLibs.hud_helper")

EdithRestored.SaveManager = include("lua.core.save_manager")
EdithRestored.SaveManager.Init(EdithRestored)
include("lua.core.saving_system")

--core
include("lua.core.enums")
include("lua.core.globals")
include("lua.core.achievements")
include("lua.core.dss.deadseascrolls")
include("lua.core.dss.imgui")
include("lua.core.BlockDisabledItems")

--entities
include("lua.entities.player.main")
include("lua.entities.clots.main")

--items
--active
include("lua.items.active.GorgonMask.main")
include("lua.items.active.SaltShaker.main")

--passive
include("lua.items.passive.Lithium.main")
include("lua.items.passive.Sodom.main")
include("lua.items.passive.BlastingBoots.main")
include("lua.items.passive.SaltyBaby.main")
include("lua.items.passive.SaltPawns.main")
include("lua.items.passive.ThunderBombs.main")

include("lua.items.passive.RedHood.main")
include("lua.items.passive.ShrapnelBombs.main")

-- trinkets
--include("lua.items.trinkets.PepperGrinder.main")
include("lua.items.trinkets.SaltRock.main")
include("lua.items.trinkets.SmellingSalts.main")
include("lua.items.trinkets.ChunkOfAmber.main")

-- cards
include("lua.items.cards.SoulOfEdith.main")

--mod compatibility
include("lua.mod_compat.eid.eid")
include("lua.mod_compat.encyclopedia.encyclopedia")
include("lua.mod_compat.MiniMapiItems.MiniMapiItems")
include("lua.mod_compat.fiendfolio.main")

--misc
include("lua.items.funny")

--stomp synergies
include("lua.entities.player.SynergiesCallbacks")

if StageAPI and StageAPI.Loaded then
    StageAPI.AddPlayerGraphicsInfo(EdithRestored.Enums.PlayerType.EDITH, {
        Name = "gfx/ui/boss/playername_Edith.png",
        Portrait = "gfx/ui/boss/playerportrait_Edith_A.png",
        NoShake = false
    })

    --[[StageAPI.AddPlayerGraphicsInfo(EdithRestored.Enums.PlayerType.EDITH_B, {
        Name = "gfx/ui/boss/playername_Edith.png",
        Portrait = "gfx/ui/boss/playerportrait_Edith_B.png",
        NoShake = false
    })]]
end

EdithRestored:Log("Edith Restored loaded.")
