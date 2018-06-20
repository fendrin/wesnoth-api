----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

--- A fancy name
-- @submodule wesnoth

--- Files
-- @section files



--- Replaces basic.dofile for loading files.
-- Loads the given filename (relative to the content directory)
-- and executes it in an unprotected environment
-- (that is, exceptions propagate to the caller).
-- @return Returns the values returned by the executed script.
-- @usage
-- wesnoth.dofile"~add-ons/MyCampaign/lua/scenario-utils.lua"
-- It may be helpful to put as many Lua code as possible in specific files instead of embedding it into WML files, so as to not confuse text editors. Then a scenario only needs to contain the following event:
-- [event]
--     name = preload
--     first_time_only = no
--     [lua]
--         code = << wesnoth.dofile "~add-ons/MyCampaign/lua/scenario-utils.lua" >>
--     [/lua]
-- [/event]
-- If the same files need to be loaded for all the scenarios, the [lua] tag above can be directly put inside the _main.cfg file (or equivalent file). The Lua code will then be executed at the start of each scenario.
-- If you pass additional arguments to dofile, they are forwarded to the script in the "..." variable.
dofile = (path) =>



--- Loads the given filename (relative to the content directory) and executes it in a protected environment. If the file has already been executed once, then compilation and execution are skipped and the value from its previous run is returned.
--     Select All
-- helper = wesnoth.require "lua/helper.lua"
-- This function is helpful in writing libraries of functions that can be accessed from various places. So the return value of the file is supposed to be a table containing the methods provided by the library. Such a library would look like:
--     Select All
-- local library = {}
-- function library.do_something(a) ... end
-- function library.go_somewhere(x, y) ... end
-- return library
-- It can also be helpful when writing unit types with events, since unit types are not necessarily available at preload time, hence preventing the usage of #wesnoth.dofile for precompiling code:
--     Expand
--     Select All
-- [unit_type]
--     id = phoenix
--     [event]
--         name = last breath
--         [lua]
--             code = << wesnoth.require("~add-ons/MyEra/lua/unit-utils.lua").resurrect(...) >>
--         [/lua]
--     [/event]
-- [/unit_type]
-- (Version 1.13.8 and later only)The ".lua" file extension is now added for you automatically, as is the "lua/" prefix. Both these substitutions only occur if the file without the substitutions does not exist. Taken together, this means that you can now write:
--     Select All
-- wesnoth.require "helper"
-- wesnoth.require "~add-ons/MyEra/lua/unit-utils"
require = (path) =>


--- Tests if a file exists.
-- Files are resolved in the same way as by dofile.
-- If you pass true as the second argument,
-- it returns true only if the file is a regular file — otherwise,
-- it returns true if the path is valid, whether it is a file,
-- directory, or some other type of object.
-- @function wesnoth.have_file
have_file = ( path, is_regular ) =>


--- Reads a file into a string.
-- If the path is a directory, this instead returns an array of the directory contents, with directories first, followed by files. The special key ndirs contains the number of directories.
-- @function wesnoth.read_file
read_file = (path) =>


{
    :dofile
    :require
    :have_file
    :read_file
}
