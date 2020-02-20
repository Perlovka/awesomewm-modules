
local ffi = require("ffi")

-- for command line testing with test-gm.lua
package.path = package.path .. ';/usr/share/awesome/lib/?.lua'
local dbg = require("gears.debug")

ffi.cdef[[
////    glib.h
typedef int             gint;
typedef char            gchar;
typedef gint            gboolean;
typedef unsigned int    guint32;
typedef guint32         GQuark;

typedef struct  {
  GQuark    domain;
  gint      code;
  gchar     *message;
} GError;

////    gio/gdesktopappinfo.h
typedef struct _GDesktopAppInfo     GDesktopAppInfo;
char *g_desktop_app_info_get_string (GDesktopAppInfo *info, const char *key);

////    GIO
typedef struct _GIcon GIcon;
gchar *g_icon_to_string (GIcon *icon);

////    gmenu-tree.h
typedef struct _GMenuTree        GMenuTree;
typedef struct GMenuTreeIter      GMenuTreeIter;
typedef struct GMenuTreeDirectory GMenuTreeDirectory;
typedef struct GMenuTreeEntry     GMenuTreeEntry;

typedef enum
{
  GMENU_TREE_ITEM_INVALID = 0,
  GMENU_TREE_ITEM_DIRECTORY,
  GMENU_TREE_ITEM_ENTRY,
  GMENU_TREE_ITEM_SEPARATOR,
  GMENU_TREE_ITEM_HEADER,
  GMENU_TREE_ITEM_ALIAS
} GMenuTreeItemType;

typedef enum
{
  GMENU_TREE_FLAGS_NONE                = 0,
  GMENU_TREE_FLAGS_INCLUDE_EXCLUDED    = 1 << 0,
  GMENU_TREE_FLAGS_INCLUDE_NODISPLAY   = 1 << 1,
  GMENU_TREE_FLAGS_INCLUDE_UNALLOCATED = 1 << 2,
  GMENU_TREE_FLAGS_SHOW_EMPTY          = 1 << 8,
  GMENU_TREE_FLAGS_SHOW_ALL_SEPARATORS = 1 << 9,
  GMENU_TREE_FLAGS_SORT_DISPLAY_NAME   = 1 << 16
} GMenuTreeFlags;

GMenuTree *gmenu_tree_new_for_path (const char *menu_path, GMenuTreeFlags  flags);
gboolean gmenu_tree_load_sync (GMenuTree  *tree, GError **error);
GMenuTreeDirectory *gmenu_tree_get_root_directory   (GMenuTree  *tree);

const char *gmenu_tree_directory_get_name       (GMenuTreeDirectory *directory);
GIcon      *gmenu_tree_directory_get_icon       (GMenuTreeDirectory *directory);
GMenuTreeIter      *gmenu_tree_directory_iter   (GMenuTreeDirectory *directory);
GMenuTreeItemType   gmenu_tree_iter_next            (GMenuTreeIter *iter);
GMenuTreeDirectory *gmenu_tree_iter_get_directory   (GMenuTreeIter *iter);
GMenuTreeEntry     *gmenu_tree_iter_get_entry       (GMenuTreeIter *iter);

GDesktopAppInfo *gmenu_tree_entry_get_app_info (GMenuTreeEntry *entry);
]]

local L = ffi.load("libgnome-menu-3.so")

local _M = {}

local function get_app_info(app_info, tag)
    local s = L.g_desktop_app_info_get_string(app_info, tag)
    if tag == "Terminal" then
        return (s ~= nil and ffi.string(s) == 'true') and true or false
    else
        return (s ~= nil) and ffi.string(s) or "Could not get "..tag
    end
end

local function parse_directory(directory, data)
    local iter = L.gmenu_tree_directory_iter(directory);
    if iter then
        local t = L.gmenu_tree_iter_next(iter)
        while t ~= L.GMENU_TREE_ITEM_INVALID do
            if t == L.GMENU_TREE_ITEM_DIRECTORY then
                local dir = L.gmenu_tree_iter_get_directory(iter)
                local name = L.gmenu_tree_directory_get_name(dir)
                local icon = L.gmenu_tree_directory_get_icon(dir)
                local item = {
                    Type = "submenu",
                    Name = (name ~= nil) and ffi.string(name) or "Undefined",
                    Icon = (icon ~= nil) and ffi.string(L.g_icon_to_string(icon)) or ""
                }
                if not data.Items then
                    data.Items = {}
                end
                table.insert(data.Items, item)
                parse_directory(dir, item )
            elseif t == L.GMENU_TREE_ITEM_ENTRY then
                local entry = L.gmenu_tree_iter_get_entry(iter)
                local app_info = L.gmenu_tree_entry_get_app_info(entry)

                if not data.Items then
                    data.Items = {}
                end

                table.insert(data.Items, {
                    Type = "app",
                    Name = get_app_info(app_info, "Name"),
                    Icon = get_app_info(app_info, "Icon"),
                    Exec = get_app_info(app_info, "Exec"),
                    Terminal = get_app_info(app_info, "Terminal")
                })
            elseif t == L.GMENU_TREE_ITEM_SEPARATOR then
                if not data.Items then
                    data.Items = {}
                end
                table.insert(data.Items, { Type = "separator" })
            else
--                dbg.dump(ffi.typeof(t))
            end
            t = L.gmenu_tree_iter_next(iter)
        end
    end
end

--- To show OnlyShowIn items, set XDG_CURRENT_DESKTOP environment variable
--  https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#key-onlyshowin
function _M.new_for_path(path, flags)
    local menu = { Type = "menu", Name = "Applications", Items = {} }

    if not path then
        return menu, "No file path is defined"
    end

    local tree = L.gmenu_tree_new_for_path(path, L.GMENU_TREE_FLAGS_SHOW_ALL_SEPARATORS+L.GMENU_TREE_FLAGS_INCLUDE_UNALLOCATED)
    local loaded = L.gmenu_tree_load_sync(tree, nil)
    -- TODO: get error message
     if loaded ~= 1 then
        return menu, "Failed to load menu for path: '" .. path .."'"
    end

    parse_directory(L.gmenu_tree_get_root_directory(tree), menu)

    return menu, nil
end

return _M
