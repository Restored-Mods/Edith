
EdithCompliance = RegisterMod("Edith", 1)

--Functions that will be called when starting run
EdithCompliance.CallOnStart = {}

local LOCAL_TSIL = require("lua.extraLibs.loi.TSIL")
LOCAL_TSIL.Init("lua.extraLibs.loi")

--core
include("lua.core.enums")
include("lua.core.globals")
include("lua.core.achievements")
include("lua.core.save_manager")
include("lua.core.dss.deadseascrolls")
include("lua.core.BlockDisabledItems")

--entities
include("lua.entities.player")
include("lua.entities.clots")
include("lua.entities.unlock")

--items
--active
--include("lua.items.active.TheChisel")
include("lua.items.active.GorgonMask")
include("lua.items.active.SaltShaker")

--passive
include("lua.items.passive.Peppermint")
include("lua.items.passive.Lithium")
include("lua.items.passive.Sodom")
include("lua.items.passive.BlastingBoots")
include("lua.items.passive.LotBaby")
include("lua.items.passive.SaltyBaby")
include("lua.items.passive.PawnBaby")
include("lua.items.passive.ThunderBombs")
include("lua.items.passive.Landmine")

--include("lua.items.passive.RedHood")
include("lua.items.passive.NewRedHood")

-- trinkets
include("lua.items.trinkets.PepperGrinder")
include("lua.items.trinkets.SaltRock")
include("lua.items.trinkets.SmellingSalts")

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
        Name = "gfx/ui/boss/playername_Edith.png",
        Portrait = "gfx/ui/boss/playerportrait_Edith_A.png",
        NoShake = false
    })

    --[[StageAPI.AddPlayerGraphicsInfo(EdithCompliance.Enums.PlayerType.EDITH_B, {
        Name = "gfx/ui/boss/playername_Edith.png",
        Portrait = "gfx/ui/boss/playerportrait_Edith_B.png",
        NoShake = false
    })]]
end

print("TC Edith mod loaded'")
