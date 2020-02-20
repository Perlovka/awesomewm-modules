---------------------------------------------------------------------------
--- Icon theme module
--
-- @author Michael Perlov
-- @copyright 2020 Michael Perlov
-- @module gears.xdg.icon_theme
---------------------------------------------------------------------------

local Gtk = require("lgi").Gtk
local dbg = require("gears.debug")

local icon_theme = {}

--- Create new theme object
--  @param  theme_name  Theme name
--  @param  icon_size   Preferred icon size
--  @return icon_theme object
function icon_theme:new(theme_name, icon_size)
    local theme = {}
    setmetatable(theme, self)
    self.__index = self

    theme.name = theme_name or nil
    theme.icon_size = icon_size or 24

    if theme_name then
        theme.gtk_theme = Gtk.IconTheme.new()
        Gtk.IconTheme.set_custom_theme(theme.gtk_theme, theme_name);
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
    return ""
end

return setmetatable(icon_theme, { __call = function(_, ...) return icon_theme:new(...) end })
