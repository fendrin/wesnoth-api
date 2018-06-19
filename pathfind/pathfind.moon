----
-- Copyright (C) 2003 - 2018 by David White <dave@whitevine.net>
-- Part of the Battle for Wesnoth Project http://www.wesnoth.org/
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY.
--
-- See the COPYING file for more details.

----
-- @file
-- This module contains various pathfinding functions and utilities.

-- static lg::log_domain log_engine("engine");
-- #define ERR_PF LOG_STREAM(err, log_engine)

movetype = {
    UNREACHABLE: 999
}


Location     = require"utils.Location"
Location_Set = require"utils.Location_Set"

resources = {
    gameboard: {}
}


----
-- Function that will find a location on the board that is as near
-- to @a loc as possible, but which is unoccupied by any units.
-- If no valid location can be found, it will return a null location.
-- If @a pass_check is provided, the found location must have a terrain
-- that this unit can enter.
-- If @a shroud_check is provided, only locations not covered by this
-- team's shroud will be considered.
--
-- Function that will find a location on the board that is as near
-- to @a loc as possible, but which is unoccupied by any units.
-- @return map_location
-- @param map_location loc
-- @param VACANT_TILE_TYPE vacancy
-- @param Unit pass_check
-- @param const team* shroud_check
-- @param const game_board* board
find_vacant_tile = (loc, vacancy="VACANT_ANY", pass_check, shroud_check, board) ->

	unless board
		board = resources.gameboard
		assert(board)

	map   = board.map
	units = board.units

    return Location! unless map.on_board(loc)

	do_shroud = shroud_check and shroud_check.uses_shroud!

    pending_tiles_to_check = Location_Set!
    tiles_checked = Location_Set!
	pending_tiles_to_check.insert(loc)
    -- Iterate out 50 hexes from loc
	for distance = 0, 50
		return Location! if pending_tiles_to_check.empty!

        -- Copy over the hexes to check and clear the old set
        tiles_checking = Location_Set!
        tiles_checking\swap(pending_tiles_to_check)
        -- Iterate over all the hexes we need to check
		for l in *tiles_checking
            -- Skip shrouded locations.
			continue if do_shroud and shroud_check.shrouded(l)

            -- If this area is not a castle but should, skip it.
			continue if vacancy == "VACANT_CASTLE" and not map.is_castle(l)
			pass_check_and_unreachable = pass_check and
				pass_check.movement_cost(map[l]) == movetype.UNREACHABLE
            -- If the unit can't reach the tile and we have searched
            -- an area of at least radius 10 (arbitrary), skip the tile.
            -- Neccessary for cases such as an unreachable
            -- starting hex surrounded by 6 other unreachable hexes, in which case
            -- the algorithm would not even search distance==1
            -- even if there's a reachable hex for distance==2.
			continue if pass_check_and_unreachable and distance > 10
            -- If the hex is empty and we do either no pass check or the hex is reachable,
            -- return it.
			return l if (not units.find(l) and not pass_check_and_unreachable)
            adjs = {}-- map_location adjs[6];
            l\get_adjacent_tiles(adjs) -- get_adjacent_tiles(l,adjs);
			for l2 in *adjs
				continue unless map.on_board(l2)
                -- Add the tile to be checked if it hasn't already been and
                -- isn't being checked.
				if not tiles_checked.find(l2) and not tiles_checking.find(l2)
					pending_tiles_to_check.insert(l2)

		tiles_checked.swap(tiles_checking)

	return Location!


-- Wrapper for find_vacant_tile() when looking for a vacant castle tile
-- near a leader.
-- @return map_location
----
-- Wrapper for find_vacant_tile() when looking for a vacant castle tile
-- near a leader.
-- If no valid location can be found, it will return a null location.
--
-- map_location find_vacant_castle(const unit & leader)
find_vacant_castle = (leader) ->
	return find_vacant_tile(leader.get_location!, "VACANT_CASTLE",
        nil, resources.gameboard.get_team(leader.side!))


----
-- Determines if a given location is in an enemy zone of control.
--
-- @param team current_team  The moving team (only ZoC of enemies of this team are considered).
-- @param Location loc       The location to check.
-- @param team viewing_team  Only units visible to this team are considered.
-- @param bool see_all       If true, all units are considered (and viewing_team is ignored).
-- @return bool true iff a visible enemy exerts zone of control over loc.
--
-- bool enemy_zoc(team const &current_team, map_location const &loc, team const &viewing_team, bool see_all)
enemy_zoc = (current_team, loc, viewing_team, see_all=false) ->
    -- Check the adjacent tiles.
    locs = loc\get_adjacent_tiles!
    for location in locs
		u = resources.gameboard.get_visible_unit(location, viewing_team, see_all)
		if u and current_team.is_enemy(u.side) and u.emits_zoc!
			return true
	return false -- No adjacent tiles had an enemy exerting ZoC over loc.

    -- class Step
        -- map_location curr, prev;
        -- int move_left;

    -- -- Ordered vector of possible destinations.
    -- class Dest_Vect -- : std::vector<step>
    --     find: (location) =>
    --     contains: (location) =>
    --     insert: (loc) =>
    --     -- std::vector<map_location> get_path(const const_iterator &) const;
    --     get_path: (const_iterator) =>


{
    :enemy_zoc
    :find_vacant_castle
    :find_vacant_tile
}
