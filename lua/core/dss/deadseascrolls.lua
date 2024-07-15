local DSSModName = "Dead Sea Scrolls (Edith Compliance)"

local DSSCoreVersion = 7

local modMenuName = "Edith (Compliance)"
-- Those functions were taken from Balance Mod, just to make things easier 
	local BREAK_LINE = {str = "", fsize = 1, nosel = true}

	local function GenerateTooltip(str)
		local endTable = {}
		local currentString = ""
		for w in str:gmatch("%S+") do
			local newString = currentString .. w .. " "
			if newString:len() >= 15 then
				table.insert(endTable, currentString)
				currentString = ""
			end

			currentString = currentString .. w .. " "
		end

		table.insert(endTable, currentString)
		return {strset = endTable}
	end
-- Thanks to catinsurance for those functions

-- Every MenuProvider function below must have its own implementation in your mod, in order to handle menu save data.
local MenuProvider = {}

function MenuProvider.SaveSaveData()
    TSIL.SaveManager.SaveToDisk()
end

local function GetDSSOptions()
    return TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "DSS")
end

function MenuProvider.GetPaletteSetting()
    return GetDSSOptions().MenuPalette or {}
end

function MenuProvider.SavePaletteSetting(var)
    GetDSSOptions().MenuPalette = var
end

function MenuProvider.GetGamepadToggleSetting()
    return  GetDSSOptions().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    GetDSSOptions().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return  GetDSSOptions().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    GetDSSOptions().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return  GetDSSOptions().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    GetDSSOptions().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return GetDSSOptions().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    GetDSSOptions().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return GetDSSOptions().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    GetDSSOptions().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return GetDSSOptions().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    GetDSSOptions().MenusPoppedUp = var
end

local DSSInitializerFunction = include("lua.core.dss.dssmenucore")

-- This function returns a table that some useful functions and defaults are stored on
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

local function InitDisableMenu()

    local itemTogglesMenu = {}
    local orderedItems = {}
    itemTogglesMenu = {
        {str = 'choose what items', fsize = 2, nosel = true},
        {str = 'show up', fsize = 2, nosel = true},
        {str = '', fsize = 2, nosel = true},
    }

    local itemConfig = Isaac.GetItemConfig()
    ---@type ItemConfigItem[]
    for _, collectible in pairs(EdithCompliance.Enums.CollectibleType) do
        local collectibleConf = itemConfig:GetCollectible(collectible)
        orderedItems[#orderedItems+1] = collectibleConf
    end
    table.sort(orderedItems, function (a, b)
        return a.Name < b.Name
    end)

    local function SplitStr(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
    end

    local function GetItemsEnum(id)
        for enum, collectible in pairs(EdithCompliance.Enums.CollectibleType) do
            if id == collectible then
                return enum
            end
        end
        return ""
    end

    for _, collectible in pairs(orderedItems) do
        local split = SplitStr(string.lower(collectible.Name))

        local tooltipStr = {"enable", ""}
        for _, word in ipairs(split) do
            if tooltipStr[#tooltipStr]:len() + word:len() > 15 then
                tooltipStr[#tooltipStr] = tooltipStr[#tooltipStr]:sub(0, tooltipStr[#tooltipStr]:len()-1)
                tooltipStr[#tooltipStr+1] = word .. " "
            else
                tooltipStr[#tooltipStr] = tooltipStr[#tooltipStr] .. word .. " "
            end
        end
        tooltipStr[#tooltipStr] = tooltipStr[#tooltipStr]:sub(0, tooltipStr[#tooltipStr]:len()-1)

        local itemSprite = Sprite()
        itemSprite:Load("gfx/ui/dss_item.anm2", false)
        itemSprite:ReplaceSpritesheet(0, collectible.GfxFileName)
        itemSprite:LoadGraphics()
        itemSprite:SetFrame("Idle", 0)

        local collectibleOption = {
            str = string.lower(collectible.Name),

            -- The "choices" tag on a button allows you to create a multiple-choice setting
            choices = {'enabled', 'disabled'},
            -- The "setting" tag determines the default setting, by list index. EG "1" here will result in the default setting being "choice a"
            setting = 1,

            -- "variable" is used as a key to story your setting; just set it to something unique for each setting!
            variable = 'ToggleItem' .. collectible.Name,

            -- When the menu is opened, "load" will be called on all settings-buttons
            -- The "load" function for a button should return what its current setting should be
            -- This generally means looking at your mod's save data, and returning whatever setting you have stored
            load = function()
                if not TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "DisabledItems") then
                    TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "DisabledItems", {})
                end

                for _, disabledItem in ipairs(TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "DisabledItems")) do
                    if disabledItem == GetItemsEnum(collectible.ID) then
                        return 2
                    end
                end
                return 1
            end,

            -- When the menu is closed, "store" will be called on all settings-buttons
            -- The "store" function for a button should save the button's setting (passed in as the first argument) to save data!
            store = function(var)
                if not TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "DisabledItems") then
                    TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "DisabledItems", {})
                end
                local disabledItems = TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "DisabledItems")
                for index, disabledItem in ipairs(disabledItems) do
                    if disabledItem == GetItemsEnum(collectible.ID) then
                        if var == 1 then
                            table.remove(disabledItems, index)
                        end
                        break
                    end
                end

                if var == 2 then
                    table.insert(disabledItems, GetItemsEnum(collectible.ID))
                end
                local elemName = string.gsub(collectible.Name, " ", "").."BlackList"
                TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "DisabledItems", disabledItems)
            end,

            -- A simple way to define tooltips is using the "strset" tag, where each string in the table is another line of the tooltip
            tooltip = {
                buttons = {
                    {spr = {
                        sprite = itemSprite,
                        centerx = 16,
                        centery = 16,
                        width = 32,
                        height = 32,
                        float = {1, 6},
                        shadow = true,
                        nosel = true
                    }},
                    {strset = tooltipStr},
                }
            }
        }

        itemTogglesMenu[#itemTogglesMenu+1] = collectibleOption
    end
    
    return itemTogglesMenu
end

local function InitTargetColorMenu()

    local targetColorMenu = {
        {
            str = 'red',

            -- If "min" and "max" are set without "slider", you've got yourself a number option!
            -- It will allow you to scroll through the entire range of numbers from "min" to "max", incrementing by "increment"
            min = 0,
            max = 255,
            increment = 1,

            -- You can also specify a prefix or suffix that will be applied to the number, which is especially useful for percentages!
            --pref = 'hi! ',
            setting = 155,

            variable = "TargetColorRed",

            load = function()
                return TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "TargetColor").R or 155
            end,
            store = function(newOption)
                TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "TargetColor").R = newOption
            end,

            tooltip = GenerateTooltip('color red value'),
        },
        {
            str = 'green',

            -- If "min" and "max" are set without "slider", you've got yourself a number option!
            -- It will allow you to scroll through the entire range of numbers from "min" to "max", incrementing by "increment"
            min = 0,
            max = 255,
            increment = 1,

            -- You can also specify a prefix or suffix that will be applied to the number, which is especially useful for percentages!
            --pref = 'hi! ',
            setting = 155,

            variable = "TargetColorGreen",

            load = function()
                return TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "TargetColor").G or 0
            end,
            store = function(newOption)
                TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "TargetColor").G = newOption
            end,

            tooltip = GenerateTooltip('color green value'),
        },
        {
            str = 'blue',

            -- If "min" and "max" are set without "slider", you've got yourself a number option!
            -- It will allow you to scroll through the entire range of numbers from "min" to "max", incrementing by "increment"
            min = 0,
            max = 255,
            increment = 1,

            -- You can also specify a prefix or suffix that will be applied to the number, which is especially useful for percentages!
            --pref = 'hi! ',
            setting = 155,

            variable = "TargetColorBlue",

            load = function()
                return TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "TargetColor").B or 0
            end,
            store = function(newOption)
                TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "TargetColor").B = newOption
            end,

            tooltip = GenerateTooltip('color blue value'),
        },
    }
    return targetColorMenu
end

-- Creating a menu like any other DSS menu is a simple process.
-- You need a "Directory", which defines all of the pages ("items") that can be accessed on your menu, and a "DirectoryKey", which defines the state of the menu.
local edithdirectory = {
    -- The keys in this table are used to determine button destinations.
    main = {
        -- "title" is the big line of text that shows up at the top of the page!
        title = 'edith compliance',

        -- "buttons" is a list of objects that will be displayed on this page. The meat of the menu!
        buttons = {
            -- The simplest button has just a "str" tag, which just displays a line of text.
            
            -- The "action" tag can do one of three pre-defined actions:
            --- "resume" closes the menu, like the resume game button on the pause menu. Generally a good idea to have a button for this on your main page!
            --- "back" backs out to the previous menu item, as if you had sent the menu back input
            --- "openmenu" opens a different dss menu, using the "menu" tag of the button as the name
            {str = 'resume game', action = 'resume'},

            -- The "dest" option, if specified, means that pressing the button will send you to that page of your menu.
            -- If using the "openmenu" action, "dest" will pick which item of that menu you are sent to.
            {str = 'settings', dest = 'settings'},

            {str = 'item toggles', dest = 'items'},
            -- A few default buttons are provided in the table returned from DSSInitializerFunction.
            -- They're buttons that handle generic menu features, like changelogs, palette, and the menu opening keybind
            -- They'll only be visible in your menu if your menu is the only mod menu active; otherwise, they'll show up in the outermost Dead Sea Scrolls menu that lets you pick which mod menu to open.
            -- This one leads to the changelogs menu, which contains changelogs defined by all mods.
            dssmod.changelogsButton,

        },

        -- A tooltip can be set either on an item or a button, and will display in the corner of the menu while a button is selected or the item is visible with no tooltip selected from a button.
        -- The object returned from DSSInitializerFunction contains a default tooltip that describes how to open the menu, at "menuOpenToolTip"
        -- It's generally a good idea to use that one as a default!
        tooltip = dssmod.menuOpenToolTip
    },
    items = {
        title = 'item toggles',

        buttons = InitDisableMenu()
    },
    targetcolor = {
        title = 'target color',
        buttons = InitTargetColorMenu()
    },
    settings = {
        title = 'settings',
        buttons = {
            {str = '', nosel = true},
            {
                strset = {'slide', 'on hold button'},
                choices = {'enable', 'disable'},
                setting = 1,
                variable = 'AllowHolding',

                load = function ()
                    return TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "AllowHolding") or 2
                end,

                store = function(newOption)
                    TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "AllowHolding", newOption)
                end,

                tooltip = GenerateTooltip('enable or disable the sliding on holding a movement button')
            },
            {
                str = '',
                fsize = 2,
                nosel = true
            },
            {
                strset = {'bombs', 'for edith'},
                choices = {'enable', 'disable'},
                setting = 1,
                variable = 'OnlyStomps',

                load = function ()
                    return TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "OnlyStomps") or 1
                end,

                store = function(newOption)
                    TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "OnlyStomps", newOption)
                end,

                tooltip = GenerateTooltip('enable or disable placing bombs when playing as edith')
            },
            {
                str = '',
                fsize = 2,
                nosel = true
            },
			{str = 'target color', dest = 'targetcolor', tooltip = GenerateTooltip('edith target color customization')},
            {
                str = '',
                fsize = 2,
                nosel = true
            },
            {
                strset = {'always show', 'moon phase'},
                choices = {'enable', 'disable'},
                setting = 1,
                variable = 'AwaysShowMoonPhase',

                load = function ()
                    return TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "AlwaysShowMoonPhase") or 2
                end,

                store = function(newOption)
                    TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "AlwaysShowMoonPhase", newOption)
                end,

                tooltip = GenerateTooltip('enable always showing moon phase')
            },
            {
                str = '',
                fsize = 2,
                nosel = true
            },
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton,
        }
    },
}

local edithdirectorykey = {
    Item = edithdirectory.main, -- This is the initial item of the menu, generally you want to set it to your main item
    Main = 'main', -- The main item of the menu is the item that gets opened first when opening your mod's menu.

    -- These are default state variables for the menu; they're important to have in here, but you don't need to change them at all.
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

--#region AgentCucco pause manager for DSS

local OldTimer
local OldTimerBossRush
local OldTimerHush
local OverwrittenPause = false
local AddedPauseCallback = false
local function OverridePause(self, player, hook, action)
	if not AddedPauseCallback then return nil end

	if OverwrittenPause then
		OverwrittenPause = false
		AddedPauseCallback = false
		return
	end

	if action == ButtonAction.ACTION_SHOOTRIGHT then
		OverwrittenPause = true
		for _, ember in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.FALLING_EMBER, -1)) do
			if ember:Exists() then
				ember:Remove()
			end
		end
		if REPENTANCE then
			for _, rain in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.RAIN_DROP, -1)) do
				if rain:Exists() then
					rain:Remove()
				end
			end
		end
		return true
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_INPUT_ACTION, OverridePause, InputHook.IS_ACTION_PRESSED)

local function FreezeGame(unfreeze)
	if unfreeze then
		OldTimer = nil
        OldTimerBossRush = nil
        OldTimerHush = nil
        if not AddedPauseCallback then
			AddedPauseCallback = true
		end
	else
		if not OldTimer then
			OldTimer = Game().TimeCounter
		end
        if not OldTimerBossRush then
            OldTimerBossRush = Game().BossRushParTime
		end
        if not OldTimerHush then
			OldTimerHush = Game().BlueWombParTime
		end
		
        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, UseFlag.USE_NOANIM)
		
		Game().TimeCounter = OldTimer
		Game().BossRushParTime = OldTimerBossRush
		Game().BlueWombParTime = OldTimerHush
	end
end

local function RunEdithDSSMenu(tbl)
    FreezeGame()
    dssmod.runMenu(tbl)
end

local function CloseEdithDSSMenu(tbl, fullClose, noAnimate)
    FreezeGame(true)
    dssmod.closeMenu(tbl, fullClose, noAnimate)
end

include("lua.core.dss.imgui")

--#endregion
DeadSeaScrollsMenu.AddMenu(modMenuName, {
    -- The Run, Close, and Open functions define the core loop of your menu
    -- Once your menu is opened, all the work is shifted off to your mod running these functions, so each mod can have its own independently functioning menu.
    -- The DSSInitializerFunction returns a table with defaults defined for each function, as "runMenu", "openMenu", and "closeMenu"
    -- Using these defaults will get you the same menu you see in Bertran and most other mods that use DSS
    -- But, if you did want a completely custom menu, this would be the way to do it!
    
    -- This function runs every render frame while your menu is open, it handles everything! Drawing, inputs, etc.
    Run = RunEdithDSSMenu,
    -- This function runs when the menu is opened, and generally initializes the menu.
    Open = dssmod.openMenu,
    -- This function runs when the menu is closed, and generally handles storing of save data / general shut down.
    Close = CloseEdithDSSMenu,

    Directory = edithdirectory,
    DirectoryKey = edithdirectorykey
})

-- There are a lot more features that DSS supports not covered here, like sprite insertion and scroller menus, that you'll have to look at other mods for reference to use.
-- But, this should be everything you need to create a simple menu for configuration or other simple use cases!