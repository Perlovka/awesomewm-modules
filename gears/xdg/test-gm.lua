#! /usr/bin/env luajit

package.path = package.path .. ';/usr/share/awesome/lib/?.lua;/usr/share/awesome/lib/?/init.lua;'

--local gm = require("libgarcon")
local gm = require("libgnome-menu")

local lgi = require("lgi")
local Gtk = lgi.Gtk

local menu_file = os.getenv("HOME") .. "/.config/menus/awesome-applications.menu"
local dbg = require("gears.debug")

--local data, err = gm.new_for_path("/etc/xdg/menus/gnome-applications.menu")
--local data, err = gm.new_for_path("")

local data, err = gm.new_for_path(menu_file)

if not data then
    print(err)
    os.exit(1)
end

local function create_menu(data, mnu)
    if not data then return end

    local gtheme = Gtk.IconTheme.new()
    Gtk.IconTheme.set_custom_theme(gtheme, "ACYLS");

    for _,item in ipairs(data) do
            local icon = item.Icon or ""
            -- TODO: async icon lookup
            -- do not lookup absolute paths
            if not icon:find('^/') then
                -- use flags
                local iinfo = Gtk.IconTheme.lookup_icon(gtheme, item.Icon, 24, 0);
                if iinfo then
                    icon = Gtk.IconInfo.get_filename(iinfo)
                end
            end

        if (item.Type == "submenu") then
            local sub = {}
            create_menu(item.Items, sub)
            table.insert(mnu, { item.Name, sub, icon })
        elseif (item.Type == "separator") then
            table.insert(mnu, { "---" })
        else
            table.insert(mnu, { item.Name, item.Exec, icon })
        end
    end
end

local mnu = {}

--dbg.dump(data)

create_menu(data.Items, mnu)

dbg.dump(mnu)
