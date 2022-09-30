#! /usr/bin/env luajit

package.path = package.path .. ';/usr/share/awesome/lib/?.lua;/usr/share/awesome/lib/?/init.lua;'

--local gm = require("libgarcon")
local gm = require("libgnome-menu")

local lgi = require("lgi")
local Gtk = lgi.Gtk
local Gio = lgi.Gio

local is_gtk4 = Gtk.version >= "4"

local menu_file = os.getenv("HOME") .. "/.config/menus/awesome-applications.menu"
local dump = require("gears.debug").dump



--local data, err = gm:new("/etc/xdg/menus/gnome-applications.menu")
local data, err = gm:new(menu_file, nil, function() print("z") end)

--print(menu_file)
--dump(data)

if not data then
    print(err)
    os.exit(1)
end

local function create_menu(data, mnu)
    if not data then return end

    local gtheme = Gtk.IconTheme.new()
    if not is_gtk4 then
        Gtk.IconTheme.set_custom_theme(gtheme, "ACYLS");
    else
        Gtk.IconTheme.set_theme_name(gtheme, "ACYLS");
    end

    for _,item in ipairs(data) do
--            dump(item)
            local icon_name = item.Icon or ""
            -- TODO: async icon lookup
            -- do not lookup absolute paths
            if not icon_name:find('^/') then
                print("Lookup", icon_name)
                -- use flags
                if not is_gtk4 then
                    local icon_info = Gtk.IconTheme.lookup_icon(gtheme, icon_name, 24, 0);
                    if icon_info then
                        icon_path = Gtk.IconInfo.get_filename(icon_info)
                    end
                else
                    icon = Gtk.IconTheme.lookup_icon(gtheme, icon_name, {}, 24, 1, 0, 0);
                    if icon then
                        icon_path = Gtk.IconPaintable.get_file(icon)
                        if icon_path then
                            icon_path = Gio.File.get_path(icon_path)
                        end
                    end
                end
            end

        if (item.Type == "submenu") then
            local sub = {}
--            dump(item.Items)
            create_menu(item.Items, sub)
            table.insert(mnu, { item.Name, sub, icon_path })
        elseif (item.Type == "separator") then
            table.insert(mnu, { "---" })
        else
            table.insert(mnu, { item.Name, item.Exec, icon_path })
        end
    end
end

local mnu = {}

create_menu(data.Items, mnu)

dump(mnu)
