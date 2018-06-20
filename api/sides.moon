----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

---
-- @submodule wesnoth

dir = (...)\match"(.-)[^%.]+$"

log = (require'utils.log')"sides"

Set      = require"utils.Set"
Location = require"utils.Location"

-- import wml_error from require"helper"
helper = require"#{dir}.helper"

-- LuaWSL:Sides
-- This page describes the LuaWSL functions and helpers for handling sides and villages.

----
-- This is not a function but a table indexed by side numbers.
-- Its elements are proxy tables with these fields:
-- The metatable of these proxy tables appears as "side".
-- @usage side = wesnoth.sides[1]
-- side.gold += 50
-- wesnoth.message(string.format("%d sides", #wesnoth.sides))
-- @table wesnoth.sides
-- @number side the side number
-- @number gold
-- @number village_gold
-- @number base_income integers (read/write)
-- @number total_income integer (read only)
-- @tfield tstring objectives
-- @tfield tstring user_team_name translatable strings (read/write)
-- @bool objectives_changed (read/write)
-- @string team_name: string (read/write)
-- @string controller: string (read/write) possible values: human, network, ai, network_ai, null, idle. note: In networked multiplayer, the controller attribute is ambiguous. Be very careful or you have OOS errors. A local human should always be "human", a local ai should always be "ai", a remote human should always be "network". and a remote ai should always be "network_ai". An empty side should be null on all clients. An idle side should appear similarly as a "human" side for all sides that don't own the idle side, i.e. as "network". These values may be checked using lua, or the :controller command in game. This value can only be set to 'human', 'ai' or 'null'.
-- @bool fog (read)
-- @bool shroud (read)
-- @bool hidden (read/write)
-- @string name (read)
-- @string color (read/write)
-- @tparam {string,...} recruit (read/write)
-- @bool scroll_to_leader (read/write)
-- @string village_support (read/write)
-- @string flag (read)
-- @string flag_icon (read)
-- @string defeat_condition (read/write) See description at SideWSL, ScenarioWSL#Scenario_End_Conditions
-- @bool lost (read/write) If lost=true this side will be removed from the persitent list at the end of the scenario. This key can also be used to stop the engine from removing a side by setting it to false. Writing this key only works in a victory/defeat event.
-- @tab __cfg WSL table (dump)


--- Gives ownership of the village at the given location to the given side (or remove ownership if none).
-- Ownership is also removed if nil or 0 is passed for the third parameter,
-- but no capture events are fired in this case.
-- @function wesnoth.set_village_owner
-- @number x
-- @number y
-- @number[opt=0] side
-- @bool[opt=false] fire_events An optional 4th parameter can be passed determining whether to fire any capture events.
-- @treturn number|bool side number of the former owner
-- @usage wesnoth.set_village_owner(12, 15, 1)
set_village_owner = (x, y, side=0, fire_events=false) =>
    assert(@)

	new_side = side

	loc = Location(x,y)

    -- return false unless @Board.is_village(@Board.map[loc.x][loc.y])

    -- old_side = @Board.village[x][y]

    -- if (new_side == old_side or new_side < 0 or
    --     new_side > #@Board.sides or
    --     @Board.team_is_defeated(@Board.sides[new_side]))
    --         return false

    -- if old_side
    --     @sides[old_side].lose_village(loc)

    -- -- if new_side
    -- --     @sides[new_side].get_village(loc, old_side, (fire_events ? &gamedata() : NULL) )

    -- if new_side
    --     @Board.village[x][y] = new_side
    -- else @Board.village[x][y] = false

    -- return old_side


--- Returns true if sideA is enemy of sideB, false otherwise.
-- @number sideA
-- @number sideB
-- @treturn bool
-- @usage enemy_flag = wesnoth.is_enemy(1, 3)
is_enemy = (sideA, sideB) =>

    with helper
        unless sideA or type(sideA) != "number"
            .wml_error("wesnoth.is_enemy: sideA not a number")
        unless sideB or type(sideB) != "number"
            .wml_error("wesnoth.is_enemy: sideB not a number")
        if sideA < 1 or sideA > #@sides
            .wml_error("wesnoth.is_enemy: sideA not valid")
        if sideB < 1 or sideB > #@sides
            .wml_error("wesnoth.is_enemy: sideB not valid")

    -- We're not enemy of ourselves
    return false if sideA == sideB
    teamsA = Set(@sides[sideA].team_name)
    teamsB = Set(@sides[sideB].team_name)
    -- We're friendly with any side we share a team with
    return (teamsA * teamsB)\isempty!


local match_side
----
-- Returns a table array containing tables for these sides matching the passed StandardSideFilter.
-- @function wesnoth.get_sides
-- @tab filter StandardSideFilter
-- @treturn {Side,...} Array containing the matching sides.
-- @usage
-- -- set gold to 0 for all sides with a leader
-- sides = wesnoth.get_sides
--     has_unit:
--         can_recruit: true
-- for side in *sides
--     side.gold = 0
get_sides = (filter) =>
    assert(@, "no self in 'get_sides'")
    assert(filter, "no filter in 'get_sides'")
    if side = filter.side
        if match_side(@, side, filter)
            return {@board.sides[side]}
        else return {}

    -- @todo check for filter.side and preselect
    return for s in *@board.sides
        if match_side(s, filter)
            side
        else continue


----
-- Matches a side against a given StandardSideFilter.
-- @function wesnoth.match_side
-- @number side
-- @tab filter
-- @usage wesnoth.message(tostring(wesnoth.match_side(1, { has_unit: { type: "Troll" } } )))
match_side = (side, filter) =>
    assert(side)
    assert(filter, "match_side: Missing 'filter' argument.")

    if true return true

    ----
    --
    --
    check_side_number = (side_number, range) ->


    return false if filter.side_in and not check_side_number(side, filter.side_in)

    return false if filter.side and not check_side_number(side, filter.side)

    --- @todo
    -- if (!side_string_.empty()) {
    --     if (!check_side_number(t,side_string_)) {
    --         return false;
    --     }
    -- }

    -- config::attribute_value cfg_team_name = cfg_["team_name"];
    -- if (!cfg_team_name.blank()) {
    --     const std::string& that_team_name = cfg_team_name;
    --     const std::string& this_team_name = t.team_name();
    --     if(std::find(this_team_name.begin(), this_team_name.end(), ',') == this_team_name.end()) {
    --         if(this_team_name != that_team_name) return false;
    --     }
    --     else {
    --         const std::vector<std::string>& these_team_names = utils::split(this_team_name);
    --         bool search_futile = true;
    --         BOOST_FOREACH(const std::string& this_single_team_name, these_team_names) {
    --             if(this_single_team_name == that_team_name) {
    --                 search_futile = false;
    --                 break;
    --             }
    --         }
    --         if(search_futile) return false;
    --     }
    -- }
    if that_team_name = filter.team_name
        this_team_name = side.team_name
        return false if (Set(that_team_name) * Set(this_team_name)).is_empty!

    -- Allow filtering on units
    -- if(cfg_.has_child("has_unit")) {
    --     const vconfig & ufilt_cfg = cfg_.child("has_unit");
    --     if (!ufilter_)
    --         ufilter_.reset(new unit_filter(ufilt_cfg, fc_, flat_));
    --     bool found = false;
    --     BOOST_FOREACH(const unit &u, fc_->get_disp_context().units()) {
    --         if (u.side() != t.side()) continue;
    --         if (ufilter_->matches(u)) {
    --             found = true;
    --             break;
    --     if(!found && ufilt_cfg["search_recall_list"].to_bool(false)) {
    --         BOOST_FOREACH(const unit_const_ptr & u, t.recall_list()) {
    --             scoped_recall_unit this_unit("this_unit", t.save_id(),t.recall_list().find_index(u->id()));
    --             if(ufilter_->matches(*u)) {
    --                 found = true;
    --                 break;
    --     if (!found) {
    --         return false;
    if unit_filter = filter.has_unit
        found = false
        for map_unit in *@units
            continue if map_unit.side != side.side
            if map_unit\matches(unit_filter)
                found = true
                break
        unless found and filter.search_recall_list
            for recall_unit in *side.recall_list
                if recall_unit\matches(unit_filter)
                    found = true
                    break
        return false unless found

    -- const vconfig& enemy_of = cfg_.child("enemy_of");
    -- if(!enemy_of.null()) {
    --     if (!enemy_filter_)
    --         enemy_filter_.reset(new side_filter(enemy_of, fc_));
    --     const std::vector<int>& teams = enemy_filter_->get_teams();
    --     if(teams.empty()) return false;
    --     BOOST_FOREACH(const int side, teams) {
    --         if(!(fc_->get_disp_context().teams())[side - 1].is_enemy(t.side()))
    --             return false;
    if enemy_of = filter.enemy_of
        enemies = get_sides(@, enemy_of)
        return false if #sides == 0
        for enemy in enemies
            return false if wesnoth.is_enemy(@, side, enemy)

    -- const vconfig& allied_with = cfg_.child("allied_with");
    -- if(!allied_with.null()) {
    --     if (!allied_filter_)
    --         allied_filter_.reset(new side_filter(allied_with, fc_));
    --     const std::vector<int>& teams = allied_filter_->get_teams();
    --     if(teams.empty()) return false;
    --     BOOST_FOREACH(const int side, teams) {
    --         if((fc_->get_disp_context().teams())[side - 1].is_enemy(t.side()))
    --             return false;
    if allied_filter = filter.allied_with
        allies = wesnoth.get_sides(allied_filter)
        return false if #allies == 0
        for ally in allies
            return false if ally.is_enemy(side.side)

    -- const vconfig& has_enemy = cfg_.child("has_enemy");
    -- if(!has_enemy.null()) {
    --     if (!has_enemy_filter_)
    --         has_enemy_filter_.reset(new side_filter(has_enemy, fc_));
    --     const std::vector<int>& teams = has_enemy_filter_->get_teams();
    --     bool found = false;
    --     BOOST_FOREACH(const int side, teams) {
    --         if((fc_->get_disp_context().teams())[side - 1].is_enemy(t.side()))
    --             found = true;
    --             break;
    --     if (!found) return false;
    if enemy_filter = filter.has_enemy
        enemies = wesnoth.get_sides(enemy_filter)
        found = false
        for enemy in *enemies
            if wesnoth.is_enemy(side, enemy)
                found = true
                break
        return false unless found

    -- const vconfig& has_ally = cfg_.child("has_ally");
    -- if(!has_ally.null()) {
    --     if (!has_ally_filter_)
    --         has_ally_filter_.reset(new side_filter(has_ally, fc_));
    --     const std::vector<int>& teams = has_ally_filter_->get_teams();
    --     bool found = false;
    --     BOOST_FOREACH(const int side, teams) {
    --         if(!(fc_->get_disp_context().teams())[side - 1].is_enemy(t.side()))
    --             found = true;
    --             break;
    --     if (!found) return false;
    if ally_filter = filter.has_ally
        allies = get_sides(ally_filter)
        found = false
        for ally in *allies
            unless is_enemy(side, ally)
                found = true
                break
        return false unless found

    -- const config::attribute_value cfg_controller = cfg_["controller"];
    -- if (!cfg_controller.blank())
    --     if (network::nconnections() > 0 && synced_context::is_synced()) {
    --         ERR_NG << "ignoring controller= in SSF due to danger of OOS errors" << std::endl;
    --     else {
    --         bool found = false;
    --         BOOST_FOREACH(const std::string& controller, utils::split(cfg_controller))
    --             if(t.controller().to_string() == controller) found = true;
    --         if(!found) return false;
    if controller = filter.controller
        found = false
        for each in *controller
            if each == side.controller
                found = true
                break
        return false unless found

    return true


----
-- Returns the starting location of the given side.
-- @function wesnoth.get_starting_location
-- @usage loc = wesnoth.get_starting_location(1)
-- wesnoth.message "side 1 starts at (#{loc[1]}, #{loc[2]})"
get_starting_location = (side) =>
    -- return @sides[side].starting_location
    log.debug"get_starting_location for #{side}"
    return @board.map.starting_location[side]


----
-- Stub text
-- @function wesnoth.get_village_owner
-- @number x
-- @number y
-- @treturn number the side that owns the village at the given location.
-- @usage owned_by_side_1 = wesnoth.get_village_owner(12, 15) == 1
get_village_owner = (x, y) =>
    assert(@)
    -- @todo rename to get_tile_owner to make it less wesnoth specific
    return @Board.owner[x][y]


----
-- @number side
-- Changes the visual identification of a side.
-- Pass an empty string if you only want to change one of these two attributes.
-- (Version 1.13.7 and later only)
-- @function wesnoth.set_side_id
set_side_id = (side, color, flag) =>


----
-- Shrouds the specified hexes.
-- (Version 1.13.7 and later only)
-- You can pass a shroud_data string (which will be merged with existing shroud), a list of specific locations (where each location is a two-element list of x and y coordinates), or the special string "all" to shroud all hexes.
-- @function wesnoth.place_shroud
place_shroud = (side, shroud) =>


----
-- (Version 1.13.7 and later only)
-- Unshrouds the specified hexes. Hexes are specified as with place_shroud, except that a shroud_data string will not work.
-- @function wesnoth.remove_shroud
remove_shroud = (side, shroud) =>


----
-- (Version 1.13.7 and later only)
-- Tests if the given location is under fog from the point of view of the given side.
-- @function wesnoth.is_fogged
is_fogged = (side, location) =>


----
-- (Version 1.13.7 and later only)
-- @function wesnoth.is_shrouded
is_shrouded = (side, location) =>




{
    -- :sides
    :is_fogged
    :is_shrouded
    :place_shroud
    :remove_shroud
    :set_side_id
    :get_sides
    :get_village_owner
    :set_village_owner
    :is_enemy
    :match_side
    :get_starting_location
    -- :all_teams
}
