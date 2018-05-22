resources = nil
find_routes = require"server.pathfind.find_routes"
Unit = require"Unit"



---
-- Structure which uses find_routes() to build a cost map
-- This maps each hex to a the movements a unit will need to reach
-- this hex.
-- Can be used commutative by calling add_unit() multiple times.
class Full_Cost_Map

    ----
    -- Constructs a cost-map. For a unit each hex is mapped to the cost the
    -- unit will need to reach this hex. Considers movement-loss caused by
    -- turn changes.
    -- Can also used with multiple units to accumulate their costs efficiently.
    -- Will also count how many units could reach a hex for easy normalization.
    -- @param u the unit
    -- @param force_ignore_zoc Set to true to completely ignore zones of control.
    -- @param allow_teleport   Set to true to consider teleportation abilities.
    -- @param viewing_team     Usually the current team, except for "show enemy moves", etc.
    -- @param see_all          Set to true to remove unit visibility from consideration.
    -- @param ignore_units     Set to true if units should never obstruct paths (implies ignoring ZoC as well).
    new: (u, force_ignore_zoc, allow_teleport, viewing_team, see_all=true, ignore_units=true) =>
        @force_ignore_zoc_ = force_ignore_zoc
        @allow_teleport_ = allow_teleport
        @viewing_team_ = viewing_team
        @see_all_ = see_all
        @ignore_units_ = ignore_units
        -- This is a vector of pairs
        -- Every hex has an entry.
        -- The first int is the accumulated cost for one or multiple units
        -- It is -1 when no unit can reach this hex.
        -- The second int is how many units can reach this hex.
        -- (For some units some hexes or even a whole regions are unreachable)
        -- To calculate a *average cost map* it is recommended to divide first/second.
        @cost_map = {} --std::vector<std::pair<int, int> >(map.w() * map.h(), std::make_pair(-1, 0));
        if u then @add_unit(u)


    ----
    -- Adds a units cost map to cost_map (increments the elements in cost_map)
    -- @param u a real existing unit on the map
    -- @param bool use_max_moves
    add_unit: (u, use_max_moves=true) =>
        teams = resources.gameboard.teams
        return nil if u.side < 1 or u.side > #teams --int(teams.size()))

        -- We don't need the destinations, but find_routes() wants to have this parameter
        dummy = nil -- Paths.dest_vect

        find_routes(u.get_location!, u.movement_type\get_movement!,
            u.get_state(Unit.STATE_SLOWED),
            if use_max_moves then u.total_movement else u.movement_left,
            u.total_movement(), 99, dummy, nil,
            if @allow_teleport_ then u else nil,
            if @ignore_units_ then nil else teams[u.side],
            if @force_ignore_zoc_ then nil else u,
            if @see_all_ then nil else @viewing_team_,
            nil, @cost_map)


    ----
    -- Adds a units cost map to cost_map (increments the elements in cost_map)
    -- This function can be used to generate a cost_map with a non existing unit.
    -- @param origin the location on the map from where the calculations shall start
    -- @param ut the unit type we are interested in
    -- @param side the side of the unit. Important for zocs.
    --
    -- void full_cost_map::add_unit(const map_location& origin, const unit_type* const ut, int side)
    -- void add_unit(const map_location& origin, const unit_type* const unit_type, int side);
    add_fake_unit: (origin, ut, side) =>
        return unless ut
        u = Unit(ut, side, false)
        u\set_location(origin)
        @add_unit(u)


    ----
    -- Accessor for the costs.
    -- @return the value of the cost_map at (x, y) or -1 if value is not set or (x, y) is invalid.
    get_cost_at: (x, y) => -- int full_cost_map::get_cost_at(int x, int y) const
        a,_ = @get_pair_at(x, y)
        return a


    ----
    -- Accessor for the cost/reach-amount pairs.
    -- Read comment in pathfind.hpp to cost_map.
    -- @return the entry of the cost_map at (x, y) or (-1, 0) if value is not set or (x, y) is invalid.
    get_pair_at: (x, y) => -- std::pair<int, int> full_cost_map::get_pair_at(int x, int y) const
        map = resources.gameboard.map
        assert(#@cost_map == map.w * map.h)

        if x < 0 or x >= map.w() or y < 0 or y >= map.h()
            return -1, 0 -- invalid

        return @cost_map[x + (y * map.w())]


    ----
    -- Accessor for the costs.
    --
    -- @return double The average cost of all added units for this hex or -1 if no unit can reach the hex.
    get_average_cost_at: (x, y) =>
        a,b = @get_pair_at(x, y)
        if b == 0
            return -1
        else
            return a / b -- return static_cast<double>(get_pair_at(x, y).first) / get_pair_at(x, y).second;
