## Installation

Clone repo somewhere:
```shell
cd /tmp
git clone https://github.com/Perlovka/awesomewm-modules.git

```
Copy files to the directory where awesome rc.lua is located:
```shell
cp -ar /tmp/awesomewm-modules/gears ~/.config/awesome/
```

## Documentation

### Modules

**[gears.filesystem.ls](gears/filesystem/ls.md)** &emsp;&emsp;List directory content

### Classes

**[gears.filesystem.inotifywatch](gears/filesystem/inotifywatch.md)** &emsp;Watch filesystem for changes

**[gears.xdg.icon_theme](gears/xdg/icon_theme.md)** &emsp;&emsp;&emsp;&emsp;&nbsp;Create XDG compliant icon theme using lgi.Gtk

**[gears.xdg.menu](gears/xdg/menu.md)** &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;Create dynamic [awful.menu](https://awesomewm.org/apidoc/popups_and_bars/awful.menu.html) from XDG .menu file using [libgnome-menu](https://github.com/GNOME/gnome-menus/tree/mainline/libmenu)
