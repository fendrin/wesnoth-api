----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

---
-- @module helper

dir = (...)\match"(.-)[^%.]+$"
import get_unit from require"#{dir}.units"

----
-- Interrupts the current execution and displays a chat message that looks like a WML error.
-- @function helper.wml_error
-- @usage names = cfg.name or helper.wml_error("[clear_variable] missing required name= attribute.")
wml_error = (message) =>


----
-- Returns an iterator over sides that can be used in a for-in loop.
-- @function helper.all_sides
-- @usage for side in helper.all_sides() do side.gold = 200
all_sides = () =>


----
-- Displays a WML message box querying a choice from the user.
-- Attributes and options are taken from given tables (see [message]).
-- The index of the selected option is returned.
-- @function helper.get_user_choice
-- @usage result = helper.get_user_choice({ speaker: "narrator" }, { "Choice 1", "Choice 2" })
get_user_choice = (message_table, options) =>


----
-- Returns the distance between two tiles given by their coordinates.
-- @function helper.distance_between
-- @usage d = distance_between(x1, y1, x2, y2)
distance_between = (x1, x2, y1, y2) =>


----
-- If the third argument is true, tiles on the map border are also visited.
-- Returns an iterator on the (at most six) tiles around a given location that are on the map.
-- adjacent_tiles(x, y, [include_border])
-- @function helper.adjacent_tiles
-- @usage -- remove all the units next to the (a,b) tile
-- for x, y in helper.adjacent_tiles(a, b)
--     wesnoth.put_unit(x, y)
adjacent_tiles = (x, y, include_border) =>


----
--     helper.set_wml_tag_metatable{}
-- Sets the metable of a table so that it can be used to create subtags with less brackets. Returns the table. The fields of the table are simple wrappers around table constructors.
--     Select All
-- T = helper.set_wml_tag_metatable {}
-- W.event { name = "new turn", T.message { speaker = "narrator", message = "?" } }
set_wml_tag_metatable = =>


----
-- Modifies all the units satisfying the given filter (argument 1) with some WML attributes/objects (argument 2).
-- This is a Lua implementation of the MODIFY_UNIT macro.
-- @function helper.modify_unit
-- @usage helper.modify_unit({ id: "Delfador" }, { moves: 0 })
-- Note: This appears to be less powerful than the [modify_unit] tag and may be removed at some point in the future.
modify_unit = (filter, keys) =>


----
-- helper.move_unit_fake
-- Fakes the move of a unit satisfying the given filter (argument 1) to the given position (argument 2). This is a Lua implementation of the MOVE_UNIT macro.
--     Select All
-- helper.move_unit_fake({ id="Delfador" }, 14, 8)
move_unit_fake = (unit, destination) =>


----
-- @param path
move_unit = (path) =>
    mover = get_unit(@, path[1].x, path[1].y)
    assert(mover)
    return false unless mover
    -- assert false

    for step in *path

        @board.units\place_unit(mover, step.x, step.y)

        -- mover.x = step.x
        -- mover.y = step.y



----
-- (A shortcut to set_variable's rand= since math.rand is an OOS magnet and therefore disabled.) Pass a string like you would to set_variable's rand=.
-- @function helper.rand
-- @usage create a random unit at (1, 1) on side=1 :
-- wesnoth.put_unit(1, 1, { type: helper.rand("Dwarvish Fighter,Dwarvish Thunderer,Dwarvish Scout") })
rand = (spec) =>


----
-- Unlike other languages (Python, Perl, Javascript, ...), Lua does not include a round function. This helper function allows rounding numbers, following the "round half away from zero method", see Wikipedia [[1]]. Returns the number rounded to the nearest integer.
-- -- this number will be rounded up
-- helper.round(345.67) -- returns 346
-- -- this one will be rounded down
-- helper.round(543.21) -- returns 543
-- -- an integer stays integer
-- helper.round(123) -- returns 123
-- -- works also for negative numbers
-- helper.round(-369.84) -- returns -370
-- helper.round(-246.42) -- returns -246
-- @function helper.round
round = (n) =>


----
-- This function randomly sorts in place the elements of the table passed as argument, following the Fisher-Yates algorithm. It returns no value.
-- WARNING: this function uses Lua's math.random(), and so it is not MP-safe.
-- It is provided mainly for AI development, although it should work inside wesnoth.synchronize_choice() as well.
-- (Version 1.13.2 and later only) helper.shuffle(array, [random_function])
--     Select All
-- local locs = wesnoth.get_locations( { terrain="G*" } )
-- helper.shuffle( locs )
-- (Version 1.13.2 and later only) This function now uses the synced RNG by default and should not cause OOS anymore. It is also possible now to pass a different random generator as a second argument; a random generator is a function that takes two integers a and b and returns a random integer in the range [a,b]. For example, math.random can be passed to get the 1.12 behavior:
-- @function helper.shuffle
-- @usage
-- local locs = wesnoth.get_locations( { terrain: "G*" } )
-- helper.shuffle( locs, math.random )
shuffle = (array, random_function) =>


{
    :rand
    :round
    :shuffle
    :wml_error
    :all_sides
    :get_user_choice
    :distance_between
    :adjacent_tiles
    :modify_unit
    :move_unit
    :move_unit_fake
    :set_wml_tag_metatable
}
