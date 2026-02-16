---@type {funct: function, exists: fun(): boolean}[]
local modCompatibilities = {}

---Adds a function that will only run once when all mods are loaded.
---@param mod string | fun(): boolean Name of the global variable to check if the mod exists, or funtion that checks if it does.
---@param funct function
function EdithRestored:AddModCompat(mod, funct)
    local exists = mod
    if type(exists) == "string" then
        exists = function ()
            return _G[mod] ~= nil
        end
    end

    modCompatibilities[#modCompatibilities+1] = {
        funct = funct,
        exists = exists
    }
end

include("lua.mod_compat.eid.eid")
include("lua.mod_compat.fiendfolio.main")
include("lua.mod_compat.minimapapi.main")
include("lua.mod_compat.encyclopedia.encyclopedia")


local hasRunCompatibility = false
EdithRestored:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function ()
    if hasRunCompatibility then return end
    hasRunCompatibility = true

    for _, modCompat in ipairs(modCompatibilities) do
        if modCompat.exists() then
            modCompat.funct()
        end
    end
end)