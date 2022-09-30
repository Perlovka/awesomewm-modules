---------------------------------------------------------------------------
--- Icon theme module
--
-- @author Michael Perlov
-- @copyright 2022 Michael Perlov
-- @module gears.xdg.icon_theme
---------------------------------------------------------------------------

local Gtk = require("lgi").Gtk
local Gio = require("lgi").Gio

local icon_theme = {}
local is_gtk4 = Gtk.version >= "4"

--- Create new theme object
--  @param  theme_name  Theme name
--  @param  icon_size   Preferred icon size
--  @return icon_theme object
function icon_theme:new(args)
    local theme = {}
    setmetatable(theme, self)
    self.__index = self

    theme.name = args[1] or args.name or nil
    theme.icon_size = args[2] or args.icon_size or 24

    if theme.name then
        theme.gtk_theme = Gtk.IconTheme.new()
        if not is_gtk4 then
            Gtk.IconTheme.set_custom_theme(theme.gtk_theme, theme.name);
        else
            Gtk.IconTheme.set_theme_name(theme.gtk_theme, theme.name);
        end
    else
        theme.gtk_theme = Gtk.IconTheme.get_default()
    end

    return theme
end

--- Get icon file path by icon name
--  @param  icon_name           Icon name
--  @param  fallback_icon_name  If icon not found return path to icon with this name
--  @return icon file path or empty string if icon not found
function icon_theme:get_icon_path(icon_name, fallback_icon_name)
    local icon_path

    if not is_gtk4 then
        -- TODO: use flags
        local icon_info = Gtk.IconTheme.lookup_icon(self.gtk_theme, icon_name, self.icon_size, 0);
        -- fallback
        if not icon_info and fallback_icon_name then
            icon_info = Gtk.IconTheme.lookup_icon(self.gtk_theme, fallback_icon_name, self.icon_size, 0)
        end
        if icon_info then
            icon_path = Gtk.IconInfo.get_filename(icon_info)
            if icon_path then
                return icon_path
            end
        end
    else
        -- TODO: use flags
        local icon = Gtk.IconTheme.lookup_icon(self.gtk_theme, icon_name, {}, self.icon_size, 1, 0, 0);
        -- fallback
        if not icon and fallback_icon_name then
            icon = Gtk.IconTheme.lookup_icon(self.gtk_theme, fallback_icon_name, {}, self.icon_size, 1, 0, 0);
        end
        if icon then
            icon_path = Gtk.IconPaintable.get_file(icon)
            if icon_path then
                return Gio.File.get_path(icon_path)
            end
        end
    end

    return "/usr/share/icons/Adwaita/24x24/status/image-loading.png"
end

return setmetatable(icon_theme, { __call = icon_theme.new })
