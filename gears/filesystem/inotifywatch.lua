--------------------------------------------------------------------------------
--- Watch filesystem for changes
--
-- @usage
--
--  -- Watch directory for created files, every 5 seconds:
--
--  local dbg = require("gears.debug")
--  local iw = require("gears.filesystem.inotifywatch")
--
--  local function process_event(e)
--      dbg.dump(e)
--  end
--
--  local iwatch = iw('/tmp/test', process_event, { 'IN_CREATE' }, 5)
--
--  iwatch:start()
--
-- @author Michael Perlov
-- @copyright 2018 Michael Perlov
-- @classmod gears.filesystem.inotifywatch
--------------------------------------------------------------------------------

local inotify = require("inotify")
local timer = require("gears.timer")
local protected_call = require("gears.protected_call")

local inotifywatch = {}

--- Event table, passed to callback function
-- @tfield number wd Watch descriptor.
-- @tfield string event Event name (e.g. IN_ATTRIB).
-- @tfield number mask Mask of an event.
-- @tfield string name Path of created file relative to the watched directory.
-- @tfield number cookie Unique cookie associating related events.
-- @table event

inotifywatch.masks = {}

for k,v in pairs(inotify) do
    if k:match("^IN_.*") then
        inotifywatch.masks[v] = k
    end
end

--- Create a new inotify watch object.
-- @tparam string path Path to file or directory to watch.
-- @tparam function callback Will be fired when inotify event is triggered
-- with the event table as argument
-- @tparam table events List of inotify events to watch. Default { 'IN_ATTRIB' }.
-- @tparam number interval Interval in seconds to check for new events.
-- Default 1.
-- @treturn inotifywatch object or nil, error when failed.
-- @function gears.filesystem.inotifywatch
function inotifywatch:new(path, callback, events, interval)
    local o = {}
    o.path = path
    o.callback = callback
    o.events = {}

    if events and next(events) ~= nil then
        for _,e in ipairs(events) do
            local mask = inotify[e]
            if mask then
                table.insert(o.events, mask)
            else
                return nil, 'No such event ' .. e
            end
        end
    else
        table.insert(o.events, inotify.IN_ATTRIB)
    end

    o.timer = timer({ timeout = interval or 1 })
    setmetatable(o, self)
    self.__index = self
    return o
end

--- Start watching inotify events.
-- @treturn true or nil, error when failed.
-- @function inotifywatch.start
function inotifywatch:start()
    local err, errno
    self.handle = inotify.init({ blocking = false })
    self.sd = { getfd = function () return self.handle:fileno() end }

    if self.wd then
        self.handle:rmwatch(self.wd)
    end

    self.wd, err, errno = self.handle:addwatch(self.path, unpack(self.events))

    if not self.wd then
        return nil, "Could not start inotify watch on " .. self.path .. ": " .. tostring(err)
    end

    if not self.timer._signals.timeout then
        self.timer:connect_signal("timeout", function() self:read_events() end)
    end
    self.timer:again()
end

--- Stop watching inotify events.
function inotifywatch:stop()
    if self.timer.started then
        self.timer:stop()
    end
    if self.handle then
        if self.wd then
            if self.handle:rmwatch(self.wd)
                then self.wd = nil
            end
        end
        self.handle:close()
    end
end

function inotifywatch:read_events()
    local events, err, errno = self.handle:read()

    if err then
        print("Error reading inotify events: " .. tostring(err))
    end

    if events then
        for i, event in ipairs(events) do
            event.event = self.masks[event.mask]
            protected_call(self.callback, event)
        end
    end
end

return setmetatable(inotifywatch, { __call = function(_, ...) return inotifywatch:new(...) end })
