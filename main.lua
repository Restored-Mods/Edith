
EdithCompliance = RegisterMod("Edith", 1)

local LOCAL_TSIL = require("lua.extraLibs.loi.TSIL")
LOCAL_TSIL.Init("lua.extraLibs.loi")
include("lua.extraLibs.APIs.custom_bomb_flags")

require("lua.extraLibs.jumplib").Init()

--core
include("lua.core.enums")
include("lua.core.globals")
require("lua.core.achievements")
include("lua.core.save_manager")
include("lua.core.dss.deadseascrolls")
include("lua.core.BlockDisabledItems")

--entities
include("lua.entities.player.main")
include("lua.entities.clots.main")

--items
--active
--include("lua.items.active.TheChisel.main")
include("lua.items.active.GorgonMask.main")
include("lua.items.active.SaltShaker.main")

--passive
include("lua.items.passive.BreathMints.main")
include("lua.items.passive.Lithium.main")
include("lua.items.passive.Sodom.main")
include("lua.items.passive.BlastingBoots.main")
include("lua.items.passive.LotBaby.main")
include("lua.items.passive.SaltyBaby.main")
include("lua.items.passive.PawnBaby.main")
include("lua.items.passive.ThunderBombs.main")
include("lua.items.passive.Landmine.main")

include("lua.items.passive.RedHood.main")

-- trinkets
include("lua.items.trinkets.PepperGrinder.main")
include("lua.items.trinkets.SaltRock.main")
include("lua.items.trinkets.SmellingSalts.main")

-- pickups
include("lua.items.pickups.cards")

--mod compatibility
include("lua.mod_compat.eid.eid")
include("lua.mod_compat.encyclopedia.encyclopedia")
include("lua.mod_compat.MiniMapiItems.MiniMapiItems")

--misc
include("lua.items.funny")

if StageAPI and StageAPI.Loaded then
    StageAPI.AddPlayerGraphicsInfo(EdithCompliance.Enums.PlayerType.EDITH, {
        Name = "gfx_cedith/ui/boss/playername_Edith.png",
        Portrait = "gfx_cedith/ui/boss/playerportrait_Edith_A.png",
        NoShake = false
    })

    --[[StageAPI.AddPlayerGraphicsInfo(EdithCompliance.Enums.PlayerType.EDITH_B, {
        Name = "gfx_cedith/ui/boss/playername_Edith.png",
        Portrait = "gfx_cedith/ui/boss/playerportrait_Edith_B.png",
        NoShake = false
    })]]
end

print("TC Edith mod loaded'")
