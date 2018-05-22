Location = require"shared.Location"
dir = (...)\match"(.-)[^%.]+$"
find_routes = require"#{dir}find_routes"
Dest_Vect   = require"#{dir}Dest_Vect"

----
-- Object which contains all the possible locations a unit can move to,
-- with associated best routes to those locations.
class Paths
    ----
    -- Construct a list of paths for the specified unit.
    --
    -- This constructor is used for several purposes,
    -- including showing a unit's potential moves and
    -- generating currently possible paths.
    -- @todo I don't see the difference between "potential moves" and "possible paths".
    -- @param map terrain map
    -- @tparam Unit unit The unit whose moves and movement type will be used.
    -- @boolean force_ignore_zoc Set to true to completely ignore zones of control.
    -- @param allow_teleport   Set to true to consider teleportation abilities.
    -- @tparam Side viewing_side     Usually the current side, except for "show enemy moves", etc.
    -- @number additional_turns The number of turns to account for, in addition to the current.
    -- @boolean see_all          Set to true to remove unit visibility from consideration.
    -- @boolean ignore_units     Set to true if units should never obstruct paths (implies ignoring ZoC as well).
    new: (map, unit, unit_side, force_ignore_zoc, allow_teleport,
            viewing_side, additional_turns=0, see_all=false,
            ignore_units=false) =>
        @destinations = Dest_Vect!
        unless unit
            return nil

        loc = Location(unit.x, unit.y)
        -- costs = (terrain) -> unit\movement(terrain)
        costs = (terrain) -> unit.movement(terrain) or 1
        -- @todo
        -- slowed = unit\state("STATE_SLOWED")
        slowed = false
        assert(unit.moves, 'unit.moves ist nil')
        find_routes(map, loc, costs,
            slowed, unit.moves, unit.max_moves,
            additional_turns, @destinations, nil,
            if allow_teleport then unit else nil,
            if ignore_units then nil else unit_side,
            if force_ignore_zoc then nil else unit,
            if see_all then nil else viewing_side)


----
-- A refinement of paths for use when calculating vision.
class Vision_Paths extends Paths

    ----
    -- Constructs a list of vision paths for a unit.
    -- This is used to construct a list of hexes that the indicated unit can see.
    -- It differs from pathfinding in that it will only ever go out one turn,
    -- and that it will also collect a set of border hexes (the "one hex beyond"
    -- movement to which vision extends).
    -- @param viewer     The unit doing the viewing.
    -- @param loc        The location from which the viewing occurs
    --                   (does not have to be the unit's location).
    -- vision_path::vision_path(const unit& viewer, map_location const &loc,
    --                          const std::map<map_location, int>& jamming_map)
    --     : paths(), edges()
    -- {
    --     const int sight_range = viewer.vision();

    --     // The three nullptr parameters indicate (in order):
    --     // ignore units, ignore ZoC (no effect), and don't build a cost_map.
    --     team const& viewing_team = resources::gameboard->teams()[resources::screen->viewing_team()];
    --     find_routes(loc, viewer.movement_type().get_vision(),
    --                 viewer.get_state(unit::STATE_SLOWED), sight_range, sight_range,
    --                 0, destinations, &edges, &viewer, nullptr, nullptr, &viewing_team, &jamming_map, nullptr, true);
    -- }


    ----
    -- Construct a list of seen hexes for a unit.
    -- Constructs a list of vision paths for a unit.
    -- vision_path(const unit& viewer, map_location const &loc,
    --             const std::map<map_location, int>& jamming_map);
    -- vision_path(const movetype::terrain_costs & view_costs, bool slowed,
    --             int sight_range, const map_location & loc,
    --             const std::map<map_location, int>& jamming_map);

    -- This constructor is provided so that only the relevant portion of a unit's data is required to construct the vision paths.
    --  * @param view_costs   The vision costs of the unit doing the viewing.
    --  * @param slowed       Whether or not the unit is slowed.
    --  * @param sight_range  The vision() of the unit.
    --  * @param loc          The location from which the viewing occurs
    --  *                     (does not have to be the unit's location).
    --  */
    -- vision_path::vision_path(const movetype::terrain_costs & view_costs, bool slowed, int sight_range, const map_location & loc, const std::map<map_location, int>& jamming_map): paths(), edges()
    new: () =>
        -- The edges are the non-destination hexes
        -- bordering the destinations.
        -- @edges = Location_Set!

        -- viewing_team = resources.gameboard.teams()[resources.screen.viewing_team()]
        -- unit = resources.gameboard.units().find(loc)
        -- The three nullptr parameters indicate (in order):
        -- ignore units, ignore ZoC (no effect), and don't build a cost_map.
        -- find_routes(loc, view_costs, slowed, sight_range, sight_range, 0,
            -- destinations, edges, if unit.valid() then unit else nil, nil,
            -- nil, viewing_team, jamming_map, nil, true)


----
-- A refinement of paths for use when calculating jamming.
class Jamming_Paths extends Paths
    ----
    -- Constructs a list of jamming paths for a unit.
    -- Construct a list of jammed hexes for a unit.
    -- This is used to construct a list of hexes the indicated unit can jam.
    -- It differs from pathfinding by only ever going out one turn.
    -- @param jammer     The unit doing the jamming.
    -- @param loc        The location from which the jamming occurs
    --                   (does not have to be the unit's location).
    new: (jammer, loc) =>

        jamming_range = jammer.jamming
        -- The five nullptr parameters indicate (in order):
        -- no edges, no teleports, ignore units,
        -- ignore ZoC (no effect), and see all (no effect).
        find_routes(loc, jammer.movement_type().get_jamming(),
            jammer.get_state("STATE_SLOWED"), jamming_range,
            jamming_range, 0, @destinations, nil, nil, nil, nil, nil)


{
    :Paths
    :Vision_Paths
    :Jamming_Paths
}
