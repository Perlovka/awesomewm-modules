---------------------------------------------------------------------------
--- Menu generation module using Freedesktop specifications
--
-- @author Michael Perlov
-- @copyright 2020 Michael Perlov
-- @module gears.xdg.menu
---------------------------------------------------------------------------

local gm = require("gears.xdg.libgnome-menu")
local Gtk = require("lgi").Gtk
local awful_menu = require("awful.menu")

local dbg = require("gears.debug")

local menu = {}

--- Create table, that can be used to generate awful.menu
local function parse_menu(data, mnu, terminalcmd, gtk_theme, icon_size)
    if not data then return end

    for _,item in ipairs(data) do
        local icon = item.Icon or ""
        -- TODO: async icon lookup
        -- do not lookup absolute paths
        if not icon:find('^/') then
            -- use flags
            local icon_info = Gtk.IconTheme.lookup_icon(gtk_theme, item.Icon, icon_size, 0);
            -- fallback icon
            if not icon_info then
                icon_info = Gtk.IconTheme.lookup_icon(gtk_theme, "application-default-icon", icon_size, 0)
            end
            if icon_info then
                icon = Gtk.IconInfo.get_filename(icon_info)
            end
        end

        if item.Type == "submenu" then
            local sub = {}
            parse_menu(item.Items, sub, terminalcmd, gtk_theme, icon_size)
            table.insert(mnu, { item.Name, sub, icon })
        elseif (item.Type == "separator") then
            table.insert(mnu, { "---" })
        else
            -- Substitute/drop some Exec special codes
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
-- @param icon_theme Icon theme name. If not set, beautiful.icon_theme or
--  default Gtk theme will be used.
-- @param icon_size Preferred icon size. Default 24.
-- @return awful.menu instance.
-- @staticfct gears.xdg.menu.new_from_file
function menu.new_from_file(file, terminalcmd, icon_theme, icon_size)

    local tree, err = gm.new_for_path(file)
    local aw_menu = awful_menu()

    if err then
        dbg.dump(err)
        return aw_menu
    end

    local icon_theme = icon_theme or nil
    local icon_size = icon_size or 24
    local gtk_theme

    if not icon_theme then
        local beautiful = require("beautiful")
        icon_theme = beautiful.icon_theme or nil
    end

    if icon_theme then
        gtk_theme = Gtk.IconTheme.new()
        Gtk.IconTheme.set_custom_theme(gtk_theme, icon_theme);
    else
        gtk_theme = Gtk.IconTheme.get_default()
    end

    local data = {}
    parse_menu(tree.Items, data, terminalcmd, gtk_theme, icon_size)

    for name,item in pairs(data) do
        aw_menu:add(item)
    end

    return aw_menu
end

return menu
