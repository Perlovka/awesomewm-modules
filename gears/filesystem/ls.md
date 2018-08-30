Module `gears.filesystem.ls`
============================

List directory content

### Usage:
```lua
-- List directory, recursive:

local ls = require("gears.filesystem.ls")

ls('/tmp', function(result) dbg.dump(result) end, true)
```
[Functions](#Functions)
-----------------------

[gears.filesystem.ls (directory, callback, recursive)](#gears.filesystem.ls) &nbsp;&nbsp; List directory content.
  
## <a name="Functions"></a>Functions

**gears.filesystem.ls (directory, callback, recursive)**

List directory content.

#### Parameters:

* &nbsp;&nbsp; *directory* (**string**) The directory path.
* &nbsp;&nbsp; *callback* (**function**) Will be fired when directory was parsed with the resulting list of files as argument.
* &nbsp;&nbsp; *recursive* (**boolean**) Work recursively. Default false.
