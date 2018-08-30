--------------------------------------------------------------------------------
--- List directory content
--
-- @usage
--
--  -- List directory, recursive:
--
--  local ls = require("gears.filesystem.ls")
--
--  ls('/tmp', function(result) dbg.dump(result) end, true)
--
-- @author Michael Perlov
-- @copyright 2018 Michael Perlov
-- @module gears.filesystem.ls
--------------------------------------------------------------------------------
local Gio = require("lgi").Gio
local gdebug = require("gears.debug")
local gfs = require("gears.filesystem")

local ls = {}

local protected_call = require("gears.protected_call")
local do_protected_call, call_callback
do
    -- Lua 5.1 cannot yield across a protected call. Instead of hardcoding a
    -- check, we check for this problem: The following coroutine yields true on
    -- success (so resume() returns true, true). On failure, pcall returns
    -- false and a message, so resume() returns true, false, message.
    local _, has_yieldable_pcall = coroutine.resume(coroutine.create(function()
        return pcall(coroutine.yield, true)
    end))
    if has_yieldable_pcall then
        do_protected_call = protected_call.call
        call_callback = function(callback, ...)
            return callback(...)
        end
    else
        do_protected_call = function(f, ...)
            return f(...)
        end
        call_callback = protected_call.call
    end
end

--- List directory content.
-- @tparam string directory The directory path.
-- @tparam function callback Will be fired when directory was parsed
-- with the resulting list of files as argument.
-- @tparam boolean recursive Work recursively. Default false.
-- @function gears.filesystem.ls
function ls.ls(directory, callback, recursive)

    local function enumerator(gfile, result)
        local enum, err = gfile:async_enumerate_children("standard::name,standard::type,access::can-read",
                                       Gio.FileQueryInfoFlags.NONE)
        if not enum then
            gdebug.print_error(err)
            return
        end

        while true do
            local list, err = enum:async_next_files(100)
            if err then
                gdebug.print_error(err)
                return
            end
            for _, gfileinfo in ipairs(list) do
                local file_child = enum:get_child(gfileinfo)
                local file_type = gfileinfo:get_file_type()
                local readable = gfileinfo:get_attribute_boolean("access::can-read")
                if file_type == 'REGULAR' and readable then
                    local path = file_child:get_path()
                    if path then
                        table.insert(result, path)
                    end
                elseif file_type == 'DIRECTORY' and recursive then
                    enumerator(file_child, result)
                end
            end
            if #list == 0 then
                break
            end
        end
        enum:async_close()
    end

    Gio.Async.start(do_protected_call)(function()
        local result = {}
        enumerator(Gio.File.new_for_path(directory), result)
        call_callback(callback, result)
    end)
end

return setmetatable(ls, { __call = function(_,...) ls.ls(...) end})
