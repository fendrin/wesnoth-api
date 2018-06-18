-- dir = (...)\match"(.-)[^%.]+$"
pathfind = require"pathfind"

----
-- This page describes the LuaWSL functions and helpers for finding paths.
-- @submodule wesmere

Loc = require "Location"

---
--
-- @section Pathfinder

----
-- Returns the shortest path from one location to another.
-- The source location is given either by coordinates as two arguments x and y; there must be a unit at the source location when using the standard path calculator. The source location can also be given by a unit as a single argument (as returned by the functions from LuaWSL:Units). The second location is given by its coordinates.
-- @function wesmere.find_path
-- @number x1
-- @number y1
-- @number x2
-- @number y2
-- @tparam tab|func path_options The last argument is an optional table that can be used to parametrize the pathfinder.
-- @number path_options.max_cost if set, the pathfinder will ignore paths longer than its value
-- @bool path_options.ignore_units if set, the path will go through units and ignore zones of control
-- @bool path_options.ignore_teleport if set, the teleport ability of the unit is ignored
-- @number path_options.viewing_side if set to a valid side number, fog and shroud for this side will be taken into account; if set to an invalid number (e.g. 0), fog and shroud will be ignored; if left unset, the viewing side will be the unit side
-- @treturn {Location,...} The path is returned as a table of coordinate pairs. It contains both the source and destination tile if a path was found.
-- @treturn number The total cost of the path is also available as a second return value, if needed.
-- @usage -- Display some items along the path from (x1,y1) to (x2,y2).
-- u = wesmere.get_units({ x: x1, y: y1 })[1]
-- path, cost = wesmere.find_path(u, x2, y2, { ignore_units: true, viewing_side: 0 })
-- if cost > u.moves then
--     wesmere.message("That's too far!")
-- else
--     for i, loc in ipairs(path) do
--         wesmere.fire("item", { x: loc[1], y: loc[2], image: "items/buckler.png" })
-- @usage Instead of a parameter table, a cost function can be passed to the pathfinder. It will be called for all the tiles the computed path may possibly go through. It receives three arguments. The first two are the coordinates of the tile, the last one is the current cost for reaching that tile. The function should return a floating-point value that is the cost for entering the given tile. This cost should be greater or equal to one.
-- Count how many turns it would take, assuming the worst case (3 movement points per tile)
-- max_moves = wesmere.get_units({ x = x1, y = y1 })[1].max_moves
-- path, cost = wesmere.find_path(x1, y2, x2, y2,
--     (x, y, current_cost) ->
--         local remaining_moves = max_moves - (current_cost % max_moves)
--         if remaining_moves < 3 then current_cost = current_cost + remaining_moves
--         return current_cost + 3
--     )
-- wesmere.message(string.format("It would take %d turns.", math.ceil(cost / 3)))
-- @usage wesmere.find_path = (x1, y1, x2, y2, [path_options | cost_function]) ->
find_path = (x1, y1, x2, y2, path_options_or_cost_function) =>
    -- int arg = 1;
    src = Loc!
    dst = Loc! -- map_location src, dst;
    local u -- const unit* u = nullptr;


    src.x = x1
    src.y = y1
    dst.x = x2
    dst.y = y2

    -- if (lua_isuserdata(L, arg))
    -- {
    --     u = &luaW_checkunit(L, arg);
    --     src = u->get_location();
    --     ++arg;
    -- }
    -- else
    -- {
    --     src = luaW_checklocation(L, arg);
    --     unit_map::const_unit_iterator ui = units().find(src);
    --     if (ui.valid()) {
    --         u = ui.get_shared_ptr().get();
    --     }
    --     ++arg;
    -- }

    -- dst = luaW_checklocation(L, arg);
    -- ++arg;

    -- if (!board().map().on_board(src))
    --     return luaL_argerror(L, 1, "invalid location");
    -- if (!board().map().on_board(dst))
    --     return luaL_argerror(L, arg - 2, "invalid location");

	map = @board.map
	viewing_side = 0
	ignore_units = false
    see_all = false
    ignore_teleport = false
	stop_at = 10000
    local calc -- std::unique_ptr<pathfind::cost_calculator> calc;

    -- if (lua_istable(L, arg))
    -- {
    --     lua_pushstring(L, "ignore_units");
    --     lua_rawget(L, arg);
    --     ignore_units = luaW_toboolean(L, -1);
    --     lua_pop(L, 1);

    --     lua_pushstring(L, "ignore_teleport");
    --     lua_rawget(L, arg);
    --     ignore_teleport = luaW_toboolean(L, -1);
    --     lua_pop(L, 1);

    --     lua_pushstring(L, "max_cost");
    --     lua_rawget(L, arg);
    --     if (!lua_isnil(L, -1))
    --         stop_at = luaL_checknumber(L, -1);
    --     lua_pop(L, 1);

    --     lua_pushstring(L, "viewing_side");
    --     lua_rawget(L, arg);
    --     if (!lua_isnil(L, -1)) {
    --         int i = luaL_checkinteger(L, -1);
    --         if (i >= 1 && i <= int(teams().size())) viewing_side = i;
    --         else see_all = true;
    --     }
    --     lua_pop(L, 1);
    -- }
    -- else if (lua_isfunction(L, arg))
    -- {
    --     calc.reset(new lua_pathfind_cost_calculator(L, arg));
    -- }

    -- pathfind::teleport_map teleport_locations;

    -- if (!calc) {
    --     if (!u) return luaL_argerror(L, 1, "unit not found");

    --     const team& viewing_team = viewing_side
    --         ? board().get_team(viewing_side)
    --         : board().get_team(u->side());

    --     if (!ignore_teleport) {
    --         teleport_locations = pathfind::get_teleport_locations(
    --             *u, viewing_team, see_all, ignore_units);
    --     }
    --     calc.reset(new pathfind::shortest_path_calculator(*u, viewing_team,
    --         teams(), map, ignore_units, false, see_all));
    -- }

    -- pathfind::plain_route res = pathfind::a_star_search(src, dst, stop_at, *calc, map.w(), map.h(), &teleport_locations);
    res = pathfind.a_star_search(src, dst, stop_at, calc,
        map.width, map.height)

    -- int nb = res.steps.size();
    -- lua_createtable(L, nb, 0);
    -- for (int i = 0; i < nb; ++i)
    -- {
    --     lua_createtable(L, 2, 0);
    --     lua_pushinteger(L, res.steps[i].wml_x());
    --     lua_rawseti(L, -2, 1);
    --     lua_pushinteger(L, res.steps[i].wml_y());
    --     lua_rawseti(L, -2, 2);
    --     lua_rawseti(L, -2, i + 1);
    -- }
    -- lua_pushinteger(L, res.move_cost);
    -- return 2;
    return res


-- @todo


----
-- Returns the two coordinates of an empty tile the closest to the tile passed by coordinates.
-- @number x
-- @number y
-- @tparam[opt] Unit unit An optional unit (either a WSL table or a proxy object) can be passed as a third argument; if so, the returned tile has terrain which is passable for the passed unit.
-- @usage function teleport(src_x, src_y, dst_x, dst_y)
-- u = wesmere.get_units({x: src_x, y: src_y })[1]
-- ut = u.__cfg
-- dst_x, dst_y = wesmere.find_vacant_tile(dst_x, dst_y, u)
-- wesmere.put_unit(src_x, src_y)
-- wesmere.put_unit(dst_x, dst_y, ut)
find_vacant_tile = (x, y, unit) ->
    loc = Loc(x,y)
    --- @todo do the real implementation.
    return loc.x, loc.y

--    while not found
--    for loc\adjacent_tiles(false)
-- map_location find_vacant_tile(const map_location& loc, VACANT_TILE_TYPE vacancy,
--                               const unit* pass_check, const team* shroud_check, const game_board* board)
-- {
--     if (!board) {
--         board = resources::gameboard;
--         assert(board);
--     }
--     const gamemap & map = board->map();
--     const unit_map & units = board->units();

--     if (!map.on_board(loc)) return map_location();

--     const bool do_shroud = shroud_check  &&  shroud_check->uses_shroud();
--     std::set<map_location> pending_tiles_to_check, tiles_checked;
--     pending_tiles_to_check.insert(loc);
--     // Iterate out 50 hexes from loc
--     for (int distance = 0; distance < 50; ++distance) {
--         if (pending_tiles_to_check.empty())
--             return map_location();
--         //Copy over the hexes to check and clear the old set
--         std::set<map_location> tiles_checking;
--         tiles_checking.swap(pending_tiles_to_check);
--         //Iterate over all the hexes we need to check
--         BOOST_FOREACH(const map_location &loc, tiles_checking)
--         {
--             // Skip shrouded locations.
--             if ( do_shroud  &&  shroud_check->shrouded(loc) )
--                 continue;
--             //If this area is not a castle but should, skip it.
--             if ( vacancy == VACANT_CASTLE  &&  !map.is_castle(loc) ) continue;
--             const bool pass_check_and_unreachable = pass_check
--                 && pass_check->movement_cost(map[loc]) == movetype::UNREACHABLE;
--             //If the unit can't reach the tile and we have searched
--             //an area of at least radius 10 (arbitrary), skip the tile.
--             //Neccessary for cases such as an unreachable
--             //starting hex surrounded by 6 other unreachable hexes, in which case
--             //the algorithm would not even search distance==1
--             //even if there's a reachable hex for distance==2.
--             if (pass_check_and_unreachable && distance > 10) continue;
--             //If the hex is empty and we do either no pass check or the hex is reachable, return it.
--             if (units.find(loc) == units.end() && !pass_check_and_unreachable) return loc;
--             map_location adjs[6];
--             get_adjacent_tiles(loc,adjs);
--             BOOST_FOREACH(const map_location &loc, adjs)
--             {
--                 if (!map.on_board(loc)) continue;
--                 // Add the tile to be checked if it hasn't already been and
--                 // isn't being checked.
--                 if (tiles_checked.find(loc) == tiles_checked.end() &&
--                     tiles_checking.find(loc) == tiles_checking.end())
--                 {
--                     pending_tiles_to_check.insert(loc);
--                 }
--             }
--         }
--         tiles_checked.swap(tiles_checking);
--     }
--     return map_location();
-- }


----
-- Returns all the locations reachable by a unit.
-- @function wesmere.find_reach
-- @tparam Unit|Location unit The unit is given either by its two coordinates or by a proxy object.
-- @tab[opt] path_options The last argument is an optional table that can be used to parametrize the pathfinder.
-- @number path_options.additional_turns if set to an integer n, the pathfinder will consider tiles that can be reached in n+1 turns
-- @bool path_options.ignore_units if set, the paths will go through units and ignore zones of control
-- @bool path_options.ignore_teleport if set, the teleport ability of the unit is ignored
-- @number path_options.viewing_side: if set to a valid side number, fog and shroud for this side will be taken into account; if set to an invalid number (e.g. 0), fog and shroud will be ignored; if left unset, the viewing side will be the unit side
-- @return The locations are stored as triples in an array. The first two elements of a triple are the coordinates of a reachable tile, the third one is the number of movement points left when reaching the tile.
-- @usage -- overlay the number of turns needed to reach each tile
-- t = wesmere.find_reach(u, { additional_turns: 8 })
-- m = u.max_moves
-- for l in *t
--    wesmere.fire("label", { x: l[1], y: l[2], text: math.ceil(9 - l[3]/m) })
find_reach = (unit, path_options) =>

    -- local u

    -- if (lua_isuserdata(L, arg))
    -- {
    --     u = &luaW_checkunit(L, arg);
    --     ++arg;
    -- }
    -- else
    -- {
    --     map_location src = luaW_checklocation(L, arg);
    --     unit_map::const_unit_iterator ui = units().find(src);
    --     if (!ui.valid())
    --         return luaL_argerror(L, 1, "unit not found");
    --     u = ui.get_shared_ptr().get();
    --     ++arg;
    -- }

    -- viewing_side = 0
    -- ignore_units = false
    -- see_all = false
    -- ignore_teleport = false
    -- additional_turns = 0

	viewing_side_num = 1
	ignore_units = true
    see_all = true
    ignore_teleport = true
	additional_turns = 0

    -- if (lua_istable(L, arg))
    -- {
    --     lua_pushstring(L, "ignore_units");
    --     lua_rawget(L, arg);
    --     ignore_units = luaW_toboolean(L, -1);
    --     lua_pop(L, 1);

    --     lua_pushstring(L, "ignore_teleport");
    --     lua_rawget(L, arg);
    --     ignore_teleport = luaW_toboolean(L, -1);
    --     lua_pop(L, 1);

    --     lua_pushstring(L, "additional_turns");
    --     lua_rawget(L, arg);
    --     additional_turns = lua_tointeger(L, -1);
    --     lua_pop(L, 1);

    --     lua_pushstring(L, "viewing_side");
    --     lua_rawget(L, arg);
    --     if (!lua_isnil(L, -1)) {
    --         int i = luaL_checkinteger(L, -1);
    --         if (i >= 1 && i <= int(teams().size())) viewing_side = i;
    --         else see_all = true;
    --     }
    --     lua_pop(L, 1);
    -- }

    -- viewing_side = if viewing_side_num > 0
    --     @board.sides[viewing_side_num]
    -- else
    --     @board.sides[unit.side]

	res = pathfind.Paths(@board.map, unit, @board.sides[unit.side],
        ignore_units, not ignore_teleport,
		viewing_side, additional_turns, see_all, ignore_units)

    -- nb = #res.destinations
    -- lua_createtable(L, nb, 0);
    -- for (int i = 0; i < nb; ++i)
    -- {
        -- pathfind::paths::step &s = res.destinations[i];
        -- lua_createtable(L, 2, 0);
        -- lua_pushinteger(L, s.curr.wml_x());
        -- lua_rawseti(L, -2, 1);
        -- lua_pushinteger(L, s.curr.wml_y());
        -- lua_rawseti(L, -2, 2);
        -- lua_pushinteger(L, s.move_left);
        -- lua_rawseti(L, -2, 3);
        -- lua_rawseti(L, -2, i + 1);
    -- }

    return res.destinations




----
-- Builds a cost map for one, multiple units or unit types.
--
-- In a cost map each hex is mapped to two values: a) The summed cost to reach this hex for all input units b) A value which indicates how many units can reach this hex The caller can divide a) with b) to get a average cost to reach this hex for the input units. The costs will consider movement lost during turn changes. (So with simple calculus it is possible to get the turns to reach a hex)
-- wesmere.find_cost_map
--
-- Input arguments:
-- @tparam Unit|Location|StandardUnitFilter unit
-- @tparam Location|{thing,...} another_unit unit location|(optional) A array of triples (coordinates + unit type as string)
-- @tab options
-- @bool options.ignore_units
-- @bool options.ignore_teleport
-- @number options.viewing_side
-- @bool options.debug
-- @bool options.use_max_moves
-- @tparam StandardLocationFilter filter
-- @return A array of quadruples (coordinates + a summed cost + reach count)
-- @usage
-- 1 + 2. A units location
-- OR 1. A unit
-- OR 1. A unit filter
-- 2.
-- 3. (optional) A table with options:
-- 4. (optional) A Standard Location Filter.
-- If the array of unit types is given the units will be added to the first parameter. Use a empty filter or a invalid location to only add unit types.
find_cost_map = (unit, another_unit, options, filter) ->



-- A location set can be build by calling location.set.of_pairs(retval).

----
-- Returns the distance between two tiles given by their coordinates.
-- @number x1
-- @number x2
-- @number y1
-- @number y2
-- @usage d = distance_between(x1, y1, x2, y2)
distance_between = (x1, x2, y1, y2) ->
    return Loc(x1,x2) - Loc(y1,y2)

----
-- Returns an iterator on the (at most six) tiles around a given location that are on the map. If the third argument is true, tiles on the map border are also visited.
-- @number x
-- @number y
-- @bool[opt] include_border
-- @usage -- remove all the units next to the (a,b) tile
-- for x, y in helper.adjacent_tiles(a, b) do
--     wesmere.put_unit(x, y)
adjacent_tiles = (x, y, include_border) ->
    return Loc(x,y)\adjacent_tiles(include_border)


{
    :find_path
    :find_vacant_tile
    :find_reach
    :find_cost_map
    :distance_between
    :adjacent_tiles
}
