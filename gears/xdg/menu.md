Module `gears.xdg.menu`
============================

Create dynamic [awful.menu](https://awesomewm.org/apidoc/popups_and_bars/awful.menu.html) from XDG .menu file using [libgnome-menu](https://github.com/GNOME/gnome-menus/tree/mainline/libmenu)

![](menu.png?raw=true)

### Dependencies

- [gnome-menus (libgnome-menu)](https://github.com/GNOME/gnome-menus)..

### Usage:
- Install gnome-menus package with your distribution package manager
- Copy content of **assets** directory to **$HOME/**
- To show *OnlyShowIn* items from other DE, set XDG_CURRENT_DESKTOP environment variable.  
  More info: [Desktop Entry specification](https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#key-onlyshowin)  
  For possible values see [Desktop Menu specification](https://specifications.freedesktop.org/menu-spec/menu-spec-latest.html#onlyshowin-registry)

```lua
local beautiful = require("beautiful")
local icon_theme = require("gears.xdg.icon_theme"){"ACYLS", 24}
local xdg_menu = require("gears.xdg.menu")
local menu_file = os.getenv("HOME") .. "/.config/menus/awesome-applications.menu"

-- Create custom submenu
local awesome_menu = { "Awesome", {
    { "Edit config", "urxvt -e mc .config/awesome/ .config/awesome/themes/default/"},
    { "Restart", awesome.restart },
    { "Quit", function() awesome.quit() end}
    },
    beautiful.awesome_icon
}

main_menu = xdg_menu:new(
    menu_file,
    "urxvt -e",
    icon_theme,
    awesome_menu
)

-- Create launcher
local l_main_menu = awful.widget.launcher({ image = beautiful.awesome_icon, menu = main_menu })
```

[Constructors](#Constructors)
-----------------------

[gears.xdg.menu:new(menu_file, terminal_cmd, icon_theme, bottom_submenu)](#new) &emsp;Create new menu object

## <a name="Constructors"></a>Constructors

#### <a name="new"></a>**gears.xdg.menu:new(file, terminalcmd, icon_theme, bottom_submenu)**

Create new menu object

#### &nbsp;&nbsp;&nbsp; Parameters:

* &nbsp; *menu_file* (**string**) Path to applications.menu file. Required.
* &nbsp; *terminal_cmd* (**string**) Terminal command to execute for terminal applications, e.g 'urxvt -e'.  
&ensp;If set to *nil*, items with Terminal=true are excluded from menu.
* &nbsp; *icon_theme* (**object**) Icon theme object.  
&ensp;If not set, generates menu without icons.
* &nbsp; *bottom_submenu* (**table**) [awful.menu](https://awesomewm.org/apidoc/popups_and_bars/awful.menu.html) menu entry table.

#### &nbsp;&nbsp;&nbsp; Returns:

&nbsp;&nbsp;&nbsp; [awful.menu](https://awesomewm.org/apidoc/popups_and_bars/awful.menu.html#Object_methods) instance (**object**).

