----
-- @submodule wesmere

----
-- @section Time

-- LuaWSL:Time
-- LuaWSL functions revolving around Time of Day schedule functionality, including time areas.

--areas = {}

-- {
--     ----
--     -- time_of_day table
--     -- @tfield string id string (as in [time])
--     -- @tfield number lawful_bonus integer (as in [time])
--     -- @tfield number bonus_modified integer (bonus change by units)
--     -- @tfield string image string (tod image in sidebar)
--     -- @tfield tstring name translatable string
--     -- @tfield number red
--     -- @tfield number green
--     -- @tfield number blue integers (color adjustment for this time)
--     -- @table time_of_day
--     time_of_day: {}

----
-- @function wesmere.get_time_of_day
-- @number[opt=turn_number] for_turn First parameter (optional) is the turn number for which to return the information, if unspecified: the current turn (turn_number).
-- @tparam[opt] {number,number,bool=false} Second argument is an optional table. If present, first and second fields must be valid on-map coordinates and all current time_areas in the scenario are taken into account (if a time area happens to contain the passed hex). If the table isn't present, the scenario main schedule is returned. The table has an optional third parameter (boolean). If true (default: false), time of day modifying units and terrain (such as Mages of Light or lava) are taken into account (if the passed hex happens to be affected). The units' placement being considered is always the current one.
-- @treturn time_of_day The function returns a time of day table.
-- @usage wesmere.get_time_of_day(2, { 37, 3, true })
--get_time_of_day = (for_turn=wesmere.current.turn_number, [ {x, y, [consider_illuminates]} ]) ->
get_time_of_day = (for_turn, more) =>
    assert(@, "Missing state argument")
    assert(@time, "GameState.time is nil")
    unless for_turn
        for_turn = @current.event_context.turn_number
    assert(for_turn)

    -- Think about empty time of day schedules.
    -- Some gameplay might simply not rely on this concept.
    if #@time == 0
        print #@time
        error "wesmere.get_time_of_day: schedule is empty"

    index = (for_turn % #@time) + 1
    assert(index <= #@time)

    return @time[index]

----
-- Creates a new time area.
-- @function wesmere.add_time_area
-- @tab cfg This takes a WSL table containing the same information normally used by the 'time_area' table.
-- @string|{string,..} cfg.id  an unique identifier assigned to a time_area. Optional, unless you want to remove the time_area later. Can be a comma-separated list when removing time_areas, see below.
-- @tab cfg.filter_location StandardLocationFilter: the locations to affect. note: only for [event][time_area]s - at scenario toplevel [time_area] does not support StandardLocationFilter, only location ranges
-- @tab cfg.time the new schedule. type: "TimeWSL"
-- @bool cfg.remove Indicates whether the specified time_area should be removed. Requires an identifier. If no identifier is used, however, all time_areas are removed.
-- @number cfg.current_time The time slot number (starting with one) active at the creation of the area.
add_time_area = (cfg) =>
    assert(@)
    assert(cfg)
    index = table.insert(@area, cfg)
    if id = cfg.id
        @area[id] = index

----
-- Removes a time area. This requires the time area to have been assigned an id at creation time.
-- @function wesmere.remove_time_area
-- @string id of the area to remove
-- @usage for id in *({'foo', 'bar', 'baz'})
--    wesmere.remove_time_area(id)
remove_time_area = (id) =>
    if index = @area[id]
        @area[index].disabled = true



{
    :areas
    :add_time_area
    :remove_time_area
    :get_time_of_day
}
