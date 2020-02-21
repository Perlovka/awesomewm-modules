Module `gears.xdg.menu`
============================

Create menu using [libgnome-menu](https://github.com/GNOME/gnome-menus/tree/mainline/libmenu) and [lgi.Gtk](https://github.com/pavouk/lgi/)

![](menu.png?raw=true)

### Dependencies

- [gnome-menus (libgnome-menu)](https://github.com/GNOME/gnome-menus)..
- [Gtk](https://github.com/GNOME/gtk)

### Usage:
- Copy content of **assets** directory to **$HOME/**
- To show *OnlyShowIn* items from other DE, set XDG_CURRENT_DESKTOP environment variable.  
  More info: [Desktop Entry specification](https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#key-onlyshowin)  
  For possible values see [Desktop Menu specification](https://specifications.freedesktop.org/menu-spec/menu-spec-latest.html#onlyshowin-registry)

```lua
local icon_theme = require("gears.xdg.icon_theme"):new("ACYLS", 24)
local xdg_menu = require("gears.xdg.menu")
local menu_file = os.getenv("HOME") .. "/.config/menus/awesome-applications.menu"
main_menu = xdg_menu.new_from_file(menu_file, env.terminal.." -e", icon_theme)

-- Create custom submenu
local awesome_menu = { "Awesome", {
    { "Edit config", "urxvt -e mc .config/awesome/ .config/awesome/themes/default/"},
    { "Restart", awesome.restart },
    { "Quit", function() awesome.quit() end}
    },
    beautiful.awesome_icon
}
main_menu:add(awesome_menu)

-- Create launcher
local l_main_menu = awful.widget.launcher({ image = beautiful.awesome_icon, menu = main_menu })
```
[Functions](#Functions)
-----------------------

[new_from_file (file, terminalcmd, icon_theme)](#new_from_file) &nbsp;&nbsp; Generate awful.menu from applications.menu file.

## <a name="Functions"></a>Functions

#### <a name="new_from_file"></a>**new_from_file (file, terminalcmd, icon_theme)**

Generate awful.menu from applications.menu file

#### &nbsp;&nbsp;&nbsp; Parameters:

* &nbsp; *file* (**string**) Path to applications.menu file. Required.
* &nbsp; *terminalcmd* (**string**) Terminal command to execute for terminal applications, e.g 'urxvt -e'.  
If set to *nil*, items with Terminal=true are excluded from menu.
* &nbsp; *icon_theme* (**object**) Icon theme object. If not set, generates menu without icons.

#### &nbsp;&nbsp;&nbsp; Returns:

&nbsp;&nbsp;&nbsp; [awful.menu](https://awesomewm.org/apidoc/popups_and_bars/awful.menu.html#Object_methods) instance (**object**).

