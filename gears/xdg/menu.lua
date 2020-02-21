---------------------------------------------------------------------------
--- Menu generation module using Freedesktop specifications
--
-- @author Michael Perlov
-- @copyright 2020 Michael Perlov
-- @module gears.xdg.menu
---------------------------------------------------------------------------

local gm = require("gears.xdg.libgnome-menu")
local awful_menu = require("awful.menu")

local dbg = require("gears.debug")

local menu = {}

--- Create table, that can be used to generate awful.menu
local function parse_menu(data, mnu, terminalcmd, icon_theme)
    if not data then return end

    for _,item in ipairs(data) do
        local icon = nil

        if icon_theme then
            icon = item.Icon or "application-default-icon"
            -- do not lookup absolute paths
            if not icon:find('^/') then
                -- TODO: async icon lookup
                icon = icon_theme:get_icon_path(icon, "application-default-icon")
            end
        end

        if item.Type == "submenu" then
            local sub = {}
            parse_menu(item.Items, sub, terminalcmd, icon_theme)
            table.insert(mnu, { item.Name, sub, icon })
        elseif (item.Type == "separator") then
            table.insert(mnu, { "---" })
        else
            -- substitute/drop some Exec special codes
            -- http://standards.freedesktop.org/desktop-entry-spec/1.1/ar01s06.html
            local command = item.Exec:gsub('%%[fikuFU]', '')
            command = command:gsub('%%c', item.Name)
            if item.Terminal then
                -- if not terminal cmd defined, skip item
                if terminalcmd then
                    command = terminalcmd .. " " .. command
                    table.insert(mnu, { item.Name, command, icon })
                end
            else
                table.insert(mnu, { item.Name, command, icon })
            end
        end
    end
end

--- Create awful.menu from applications.menu file.
-- @param file Path to applications.menu file.
-- @param terminalcmd Terminal command to execute for terminal applications, e.g 'urxvt -e'.
-- @param icon_theme icon_theme object
-- @return awful.menu instance.
-- @staticfct gears.xdg.menu.new_from_file
function menu.new_from_file(file, terminalcmd, icon_theme)

    local tree, err = gm.new_for_path(file)
    local aw_menu = awful_menu()

    if err then
        dbg.dump(err)
        return aw_menu
    end

    local data = {}
    parse_menu(tree.Items, data, terminalcmd, icon_theme)

    for name,item in pairs(data) do
        aw_menu:add(item)
    end

    return aw_menu
end

return menu
