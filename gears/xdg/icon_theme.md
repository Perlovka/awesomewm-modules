Class `gears.xdg.icon_theme`
============================

Exploring icon theme using [lgi.Gtk](https://github.com/pavouk/lgi/)

### Dependencies

Gtk+  
https://github.com/GNOME/gtk  

### Usage:

```lua
local icon_theme = require("gears.xdg.icon_theme")
local icon_theme_acyls = icon_theme:new("ACYLS", 24)
--- or
--  local icon_theme_acyls = require("gears.xdg.icon_theme"):new("ACYLS", 24)
--- or
--  local icon_theme_acyls = require("gears.xdg.icon_theme")("ACYLS", 24)

local icon_path = icon_theme_acyls:get_icon_path("folder")

```

[Constructors](#Constructors)
-----------------------

[:new (theme_name, icon_size)](#:new) &nbsp;&nbsp; Create new theme object  
[(theme_name, icon_size)](#new) &nbsp;&nbsp; Create new theme object

[Methods](#Methods)
-----------------------

[:get_icon_path (icon_name, fallback_icon_name)](#get_icon_path) &nbsp;&nbsp; Get icon path by icon name

## <a name="Constructors"></a>Constructors

#### <a name=":new"></a>**:new (theme_name, icon_size)**
#### <a name="new"></a>**(theme_name, icon_size)**
    Create new theme object
#### &nbsp;&nbsp;&nbsp; Parameters:
* &nbsp; *theme_name* (**string**)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Icon theme name
* &nbsp; *icon_size* (**string**)&nbsp;&nbsp;Preferred icon size

## <a name="Methods"></a>Methods

#### <a name="get_icon_path"></a>**:get_icon_path (icon_name, fallback_icon_name)**

    Get icon path by icon name

#### &nbsp;&nbsp;&nbsp; Parameters:

* &nbsp; *icon_name* (**string**)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Icon name
* &nbsp; *fallback_icon_name* (**string**)&nbsp;&nbsp;If icon not found, return path to icon with this name

#### &nbsp;&nbsp;&nbsp; Returns:

&nbsp;&nbsp;&nbsp; *icon_path* (**string**)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Icon file path or empty string, if no icon was found



