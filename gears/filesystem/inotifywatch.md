Class `gears.filesystem.inotifywatch`
=====================================

Watch filesystem for changes

### Dependencies

Linotify should be installed on your system
https://github.com/hoelzro/linotify

Use your system package manager or luarocks to install.

#### Gentoo

Can be installed from overlay:  https://github.com/Perlovka/portage-overlay/tree/master/dev-lua/lua-inotify

#### Luarocks install:

```shell
root@localhost # luarocks install inotify

```

### Usage:
```lua
-- Watch directory for created files, every 5 seconds:

local dbg = require("gears.debug")
local iw = require("gears.filesystem.inotifywatch")

local function process_event(e)
    dbg.dump(e)
end

local iwatch = iw('/tmp/test', process_event, { 'IN_CREATE' }, 5)

iwatch:start()
```

[Functions](#Functions)
-----------------------

**[gears.filesystem.inotifywatch (path, callback, events, interval)](#inotifywatch)** &nbsp;&nbsp; Create a new inotify watch object.

[Tables](#Tables)
-----------------

**[gears.filesystem.inotifywatch.event](#inotifywatch.event)** &nbsp;&nbsp; Event table, passed to callback function

[Methods](#Methods)
-------------------

**[gears.filesystem.inotifywatch:start ()](#inotifywatch.start)** &nbsp;&nbsp; Start watching inotify events.

**[gears.filesystem.inotifywatch:stop ()](#inotifywatch.stop)** &nbsp;&nbsp; Stop watching inotify events.


## <a name="Functions"></a>Functions

#### <a name="inotifywatch"></a>**gears.filesystem.inotifywatch (path, callback, events, interval)**

Create a new inotify watch object.

#### &nbsp;&nbsp;&nbsp; Parameters:

* &nbsp; *path* (**string**) Path to file or directory to watch.
* &nbsp; *callback* (**function**) Will be fired when inotify event is triggered with the event table as argument
* &nbsp; *events* (**table**) List of inotify events to watch. Default { 'IN\_ATTRIB' }.
* &nbsp; *interval* (**number**) Interval in seconds to check for new events. Default 1.

#### &nbsp;&nbsp;&nbsp; Returns:

&nbsp;&nbsp;&nbsp; [inotifywatch](#) (**object**) or nil, error when failed.

## <a name="Tables"></a>Tables

#### <a name="inotifywatch.event"></a>**gears.filesystem.inotifywatch.event**

Event table, passed to callback function

#### &nbsp;&nbsp;&nbsp; Fields:

* &nbsp; *wd* (**number**) Watch descriptor.
* &nbsp; *event* (**string**) Event name (e.g. IN\_ATTRIB).
* &nbsp; *mask* (**number**) Mask of an event.
* &nbsp; *name* (**string**) Path of created file relative to the watched directory.
* &nbsp; *cookie* (**number**) Unique cookie associating related events.

## <a name="Methods"></a>Methods

#### <a name="inotifywatch.start"></a>**gears.filesystem.inotifywatch:start ()**

 Start watching inotify events.

#### &nbsp;&nbsp;&nbsp; Returns:

&nbsp;&nbsp;&nbsp; **true** or **nil, error** when failed.

#### <a name="inotifywatch.stop"></a>**gears.filesystem.inotifywatch:stop ()**
 Stop watching inotify events.
