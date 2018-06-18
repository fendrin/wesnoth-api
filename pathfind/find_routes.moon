Location = require"Location"
Location_Set = require"Location_Set"
-- VALIDATE = -> "whatever"
-- moon = require"moon"

log = (require"log")"FindRoutes"

-- import enemy_zoc from require"server.wesnoth.pathfind.pathfind"
dir = (...)\match"(.-)[^%.]+$"
import Findroute_Node, Findroute_Comp, Findroute_Indexer from require"#{dir}.find_routes_assets"
Heap = require"#{dir}.binary_heap"


-- Since this is called so often, keep memory reserved for the node list.
nodes = {}
node_comp = Findroute_Comp(nodes)
search_counter = 0
----
-- Creates a list of routes that a unit can traverse from the provided location.
-- (This is called when creating pathfind.Paths and descendant classes.)
-- @param[in]  map
-- @param[in]  origin        The location at which to begin the routes.
-- @param[in]  costs         The costs to use for route finding.
-- @param[in]  slowed        Whether or not to use the slowed costs.
-- @param[in]  moves_left    The number of movement points left for the current turn.
-- @param[in]  max_moves     The number of movement points in each future turn.
-- @param[in]  turns_left    The number of future turns of movement to calculate.
-- @param[out] destinations  The traversable routes.
-- @param[out] edges         The hexes (possibly off-map) adjacent to those in
--                            destinations. (It is permissible for this to contain
--                            some hexes that are also in destinations.)
-- @param[in]  teleporter    If not nullptr, teleportation will be considered, using
--                           this unit's abilities.
-- @param[in]  current_team  If not nullptr, enemies of this team can obstruct routes
--                           both by occupying hexes and by exerting zones of control.
--                           In addition, the presence of units can affect
--                           teleportation options.
-- @param[in]  skirmisher    If not nullptr, use this to determine where ZoC can and
--                           cannot be ignored (due to this unit having or not
--                           having the skirmisher ability).
--                           If nullptr, then ignore all zones of control.
--                           (No effect if current_team is nullptr).
-- @param[in]  viewing_team  If not nullptr, use this team's vision when detecting
--                           enemy units and teleport destinations.
--                           If nullptr, then "see all".
--                           (No effect if teleporter and current_team are both nullptr.)
-- @param[in]  jamming_map   The relevant "jamming" of the costs being used
--                           (currently only used with vision costs).
-- @param[out] full_cost_map If not nullptr, build a cost_map instead of destinations.
--                           Destinations is ignored.
--                           full_cost_map is a vector of pairs. The first entry is the
--                           cost itself, the second how many units already visited this hex
-- @param[in]  check_vision  If true, use vision check for teleports, that is, ignore
--                           units potentially blocking the teleport exit
find_routes = (map, origin, costs, slowed, moves_left, max_moves, turns_left,
    destinations, edges, teleporter, current_team, skirmisher, viewing_team,
    jamming_map=nil, full_cost_map=nil, check_vision=false) ->

    assert(moves_left, 'no moves_left arg')

    log.debug"The unit has #{moves_left} moves left."

    see_all = viewing_team == nil

    -- @todo
    -- When see_all is true, the viewing team never matters, but we still
    -- need to supply one to some functions.
    -- assert(viewing_team, "No viewing_team provided.")

    -- @todo teleport is currently not supported
    -- Build a teleport map, if needed.
    teleports = if teleporter
        get_teleport_locations(teleporter,
            viewing_team, see_all, current_team == nil, check_vision)
    -- else
        -- Teleport_Map!


    -- Incrementing search_counter means we ignore results from earlier searches.
    search_counter += 1

    -- @todo check if lua numbers do cycle
    -- Whenever the counter cycles, trash the contents of nodes and restart at 1.
    -- if search_counter == 0
    --     nodes = {} -- nodes.resize(0);
    --     search_counter = 1

    -- nodes.resize(map.w() * map.h()); -- Initialize the nodes for this search.
    index = Findroute_Indexer(map.width, map.height)

    assert(index\on_board(origin))

    -- Check if full_cost_map has the correct size.
    -- If not, ignore it. If yes, initialize the start position.
    -- if full_cost_map
    --     if #full_cost_map != map.w * map.h --static_cast<unsigned>(map.w() * map.h())
    --         full_cost_map = nil
    --     elseif full_cost_map[index(origin)].second == 0
    --         full_cost_map[index(origin)].first = 0
    --         full_cost_map[index(origin)].second += 1

    -- Used to optimize the final collection of routes.
    xmin = origin.x
    xmax = origin.x
    ymin = origin.y
    ymax = origin.y

    -- Record the starting location.
    nodes[index(origin.x, origin.y)] = Findroute_Node(moves_left, turns_left,
        nil, search_counter)

    hexes_to_process = Heap(node_comp)
    -- Begin the search at the starting location.
    hexes_to_process\insert(index(origin.x, origin.y))

    adj_locs = origin\adjacents!

    cur_hex = Location(1,1)
    while #hexes_to_process != 0

        -- Process the hex closest to the origin.
        -- Remove from the heap.
        cur_index = hexes_to_process\pop!
        assert(cur_index)
        cur_x, cur_y = index(cur_index)
        assert(cur_hex)
        cur_hex.x = cur_x
        cur_hex.y = cur_y
        current = nodes[cur_index]
        assert(current)

        unless index\on_board(cur_hex)
            continue
        -- if current.x < 1
        --     continue
        -- if current.y < 1
        --     continue
        -- if current.x

        -- Get the locations adjacent to current.
        cur_hex\adjacents(adj_locs)

        -- Sort adjacents by on-boardness
        -- auto off_board_it = std::partition(adj_locs.begin(), adj_locs.end(), [&index](map_location loc){
        --     return index.on_board(loc);
        -- });



        -- Store off-board edges if needed
        -- if edges
            -- table.insert()
        --     edges->insert(off_board_it, adj_locs.end());

        -- // Remove off-board map locations
        -- adj_locs.erase(off_board_it, adj_locs.end());

        if teleporter
            allowed_teleports = Location_Set!
            teleports.get_adjacents(allowed_teleports, cur_hex)
            -- @todo
            -- adj_locs.insert(adj_locs.end(), allowed_teleports.begin(), allowed_teleports.end());

        for key, loc in pairs adj_locs

            continue unless index\on_board(loc)

            continue if key == "WEST" or key == "EAST"
            -- Get the node associated with this location.
            next_hex = loc
            assert(next_hex, "no next_hex")
            next_index = index(next_hex.x, next_hex.y)
            assert(next_index, "no next_index")
            next = nodes[next_index]
            unless next
                nodes[next_index] = Findroute_Node!
            next = nodes[next_index]
            assert(next, "no next, next_index is: #{next_index}")

            -- Skip nodes we have already collected.
            -- (Since no previously checked routes were longer
            --  than the current one,
            --  the current route cannot be shorter.)
            -- (Significant difference from classic Dijkstra:
            --  we have vertex weights, not edge weights.)
            continue if next.search_num == search_counter

            -- If we go to next, it will be from current.
            next.prev = cur_hex

            -- @todo
            -- Calculate the cost of entering next_hex.
            -- cost = costs.cost(map[next_hex], slowed)

            -- assert(false)
            -- cost = costs(terrain, slowed)
            -- assert(map, 'no map')
            -- assert(map[next_hex.x], 'no row')
            continue unless (map[next_hex.x])
            continue unless (map[next_hex.x][next_hex.y])
            terrain = map[next_hex.x][next_hex.y]

            -- @TODO shouldn't slowed be handled by the unit's cost method?
            cost = costs(terrain, slowed)
            -- log.debug"Movecosts for #{terrain} is #{cost}."

            -- @todo
            -- if jamming_map
            --     jam_it = jamming_map.find(next_hex)
            --     if jam_it
            --         cost += jam_it.second

            -- Calculate movement remaining after entering next_hex.
            -- print current.moves_left .. " current moves left"
            next.moves_left = current.moves_left - cost
            next.turns_left = current.turns_left
            if next.moves_left < 0
                -- print next.moves_left .. " next moves left"
                -- Have to delay until the next turn.
                next.turns_left -= 1
                next.moves_left = max_moves - cost
            if next.moves_left < 0 or next.turns_left < 0
                -- print"next.moves_left is #{next.moves_left}"
                -- print"next.turns_left is #{next.turns_left}"
                -- Either can never enter this hex or out of turns.
                -- if edges
                    -- edges.insert(next_hex)
                continue

            -- if current_team
            --     -- Account for enemy units.
            --     v = resources.gameboard\get_visible_unit(next_hex, viewing_team, see_all)
            --     if v and current_team\is_enemy(v.side())
            --         -- Cannot enter enemy hexes.
            --         if edges
            --             edges.insert(next_hex)
            --         continue

            --     if skirmisher and next.moves_left > 0 and
            --         enemy_zoc(current_team, next_hex, viewing_team, see_all) and
            --         not skirmisher\get_ability_bool("skirmisher", next_hex, resources.gameboard)
            --         next.moves_left = 0

            -- Update full_cost_map
            if full_cost_map
                if full_cost_map[next_index].second == 0
                    full_cost_map[next_index].first = 0
                summed_cost = (turns_left - next.turns_left + 1) *
                    max_moves - next.moves_left
                full_cost_map[next_index].first += summed_cost
                full_cost_map[next_index].second += 1

            -- Mark next as being collected.
            next.search_num = search_counter

            -- Add this node to the heap.
            assert next_index
            -- print nodes[next_index]
            hexes_to_process\insert(next_index)

            -- Bookkeeping (for later).
            if next_hex.x < xmin
                xmin = next_hex.x
            elseif xmax < next_hex.x
                xmax = next_hex.x
            if next_hex.y < ymin
                ymin = next_hex.y
            elseif ymax < next_hex.y
                ymax = next_hex.y
        -- /for (adjs)
    -- /while (hexes_to_process)

    -- Currently the only caller who uses full_cost_map doesn't need the
    -- destinations. We can skip this part.
    return if full_cost_map

    -- Build the routes for every map_location that we reached.
    -- The ordering must be compatible with Location.__le.
    for x = xmin, xmax
        for y = ymin, ymax
            node = nodes[index(x,y)]

            continue unless node
            if node.search_num == search_counter
                step = { {x:x,y:y}, node.prev,
                    node.moves_left + node.turns_left*max_moves }
                table.insert(destinations, step)

    return

return find_routes
