----
-- Copyright (C) 2003 by David White <dave@whitevine.net>
--               2005 - 2015 by Guillaume Melquiond <guillaume.melquiond@gmail.com>
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


bitwise = require"bit"
Location = require"utils.Location"
-- Location_Set = require"Location_Set"


log = loging"AStarSearch"
DBG_PF = log.debug
LOG_PF = log.info
-- ERR_PF = log.error

dir = (...)\match"(.-)[^%.]+$"
Heap = require"#{dir}.binary_heap"
import Plain_Route from require"#{dir}.route"

----
-- @return double
-- @param const map_location& src
-- @param const map_location& dst
heuristic = (src, dst) ->
    --  @todo move the heuristic function into the cost_calculator so we can use case-specific heuristic and clean the definition of these numbers

    -- We will mainly use the distances in hexes
    -- but we subtract a tiny bonus for shorter Euclidean distance
    -- based on how the path looks on the screen.

    -- 0.75 comes from the horizontal hex imbrication
    xdiff = (src.x - dst.x) * 0.75
    -- we must add 0.5 to the y coordinate when x is odd
    ydiff = (src.y - dst.y) + (bitwise.band(src.x, 1) -
        bitwise.band(dst.x, 1)) * 0.5

    -- we assume a map with a maximum diagonal of 300 (bigger than a 200x200)
    -- and we divide by 90000 * 10000 to avoid interfering with the defense subcost
    -- (see shortest_path_calculator.cost)
    -- NOTE: In theory, such heuristic is barely 'admissible' for A*,
    -- But not a problem for our current A* (we use heuristic only for speed)
    -- Plus, the euclidean fraction stay below the 1MP minimum and is also
    -- a good heuristic, so we still find the shortest path efficiently.
    return src\distance_between(dst) +
        (xdiff*xdiff + ydiff*ydiff) / 900000000.0


-- values 0 and 1 mean uninitialized
bad_search_counter = 0
-- The number of nodes already processed.
search_counter = bad_search_counter


class Node

    new: (s, curr, prev, dst, i, teleports) =>
        unless s
            @g = 1e25
            @h = 1e25
            @t = 1e25
            @curr = Location!
            @prev = Location!
            @["in"] = bad_search_counter
            return
        @g = s
        @h = heuristic(curr, dst)
        @t = @g + @h
        @curr = curr
        @prev = prev
        -- If equal to search_counter, the node is off the list.
        -- If equal to search_counter + 1, the node is on the list.
        -- Otherwise it is outdated.
        @["in"] = if i then search_counter + 1 else search_counter

        -- @todo
        -- if teleports and not teleports.empty!

        --     new_srch = 1.0 -- double

        --     sources = Location_Set!
        --     teleports.get_sources(sources)

        --     for src in *sources
        --         tmp_srch = heuristic(c, src)
        --         new_srch = tmp_srch if tmp_srch < new_srch

        --     for src in *sources
        --         tmp_srch = heuristic(c, src)
        --         new_srch = tmp_srch if tmp_srch < new_srch

        --         new_dsth = 1.0
        --         targets = Location_Set!
        --         teleports\get_targets(targets)

        --         for target in *targets
        --             tmp_dsth = heuristic(target, dst)
        --             new_dsth = tmp_dsth if tmp_dsth < new_dsth

        --     new_h = new_srch + new_dsth + 1.0
        --     if new_h < @h
        --         @h = new_h
        --         @t = @g + @h

    __lt: (other) =>
        return @t < other.t


class Comp
    new: (n) =>
        @nodes = n


    __call: (a, b) => -- bool operator()(int a, int b) const
        return @nodes[b] < @nodes[a]


class Indexer
    new: (w) =>
        assert(w)
        @w = w


    __call: (loc) => -- size_t operator()(const map_location& loc) const
        return loc.y * @w + loc.x


----
-- @return plain_route
-- @param Location src
-- @param Location dst
-- @param double stop_at
-- @param cost_calculator costCalculator
-- @param size_t parWidth
-- @param size_t parHeight
-- @param teleport_map teleports
-- @param bool border
a_star_search = (src, dst, stop_at, calc,
    width, height, teleports, border=false) ->
--(const map_location& src, const map_location& dst,
--                           double stop_at, const cost_calculator& calc,
--                           const size_t width, const size_t height,
--                           const teleport_map *teleports, bool border) {
-- a_star_search = (src, dst, stop_at, calc, width, height, teleports, border) ->
    -- PRE_CONDITIONS
    -- assert(src.valid(width, height, border))
    -- assert(dst.valid(width, height, border))

    unless calc
        calc = {
            cost: -> return 1
            getNoPathValue: -> return 9999999
        }
    assert(stop_at <= calc.getNoPathValue!)

    DBG_PF"A* search: #{src} -> #{dst}"

    if calc.cost(dst, 0) >= stop_at
        LOG_PF"aborted A* search because Start or Dest is invalid\n"
        locRoute = Plain_Route!
        locRoute.move_cost = calc.getNoPathValue!
        return locRoute

    -- increment search_counter but skip the range equivalent to uninitialized
    search_counter += 2
    -- if search_counter - bad_search_counter <= 1u
    if search_counter - bad_search_counter <= 1
        search_counter += 2

    -- this creates uninitialized nodes
    nodes = for i = 1, width * height
        Node!

    index = Indexer(width)
    node_comp = Comp(nodes)

    nodes[index(dst)].g = stop_at + 1
    nodes[index(src)] = Node(0, src, Location!, dst, true, teleports)

    pq = Heap(node_comp)  -- std::vector<int> pq;
    pq\insert(index(src)) -- pq.push_back(index(src));

    while not pq\empty!

        DBG_PF"Entries in PQ: #{#pq}"

        -- std::pop_heap(pq.begin(), pq.end(), node_comp);
        node = nodes[pq\pop!]

        -- require"moon".p node

        node["in"] = search_counter

        -- pq.pop_back();

        break if (node.t >= nodes[index(dst)].g)

        -- assert(false)

        -- locs = {} -- std::vector<map_location> locs(6);

        -- if teleports and not teleports.empty!

        --     allowed_teleports = Location_Set!
        --     teleports.get_adjacents(allowed_teleports, node.curr)
        --     -- locs.insert(locs.end(), allowed_teleports.begin(), allowed_teleports.end());
        --     for loc in *allowed_teleports
        --         table.insert(locs, loc)

        -- node.curr\get_adjacent_tiles(locs[1]) -- get_adjacent_tiles(n.curr, locs[1])

        node_loc = Location(node.curr)
        locs = node_loc\adjacents!

        for loc in *locs

            assert(false)

            continue unless loc.valid(width, height, border)
            continue if loc == node.curr
            next = nodes[index(loc)]


            thresh = if next.in - search_counter <= 1
                next.g
            else
                stop_at + 1
            -- cost() is always >= 1  (assumed and needed by the heuristic)
            continue if (node.g + 1 >= thresh)
            cost = node.g + calc.cost(loc, node.g)
            continue if (cost >= thresh)

            in_list = next.in == search_counter + 1

            next = Node(cost, loc, node.curr, dst, true, teleports)

            -- if in_list
              -- std::push_heap(pq.begin(), std::find(pq.begin(), pq.end(), static_cast<int>(index(loc))) + 1, node_comp);
                -- pq\insert(index(loc))
            -- else
                -- table.insert(pq, index[loc]) -- pq.push_back(index(loc));
                -- std::push_heap(pq.begin(), pq.end(), node_comp);

    route = Plain_Route!

    if (nodes[index(dst)].g <= stop_at)
        DBG_PF"found solution; calculating it..."
        -- route.move_cost = static_cast<int>(nodes[index(dst)].g);
        assert(route.move_cost)
        route.move_cost = nodes[index(dst)].g

        curr = nodes[index(dst)]
        -- for (node curr = nodes[index(dst)];
        -- curr.prev != map_location::null_location();
        -- curr = nodes[index(curr.prev)]) {
        --             route.steps.push_back(curr.curr); }
        while curr.prev.x != nil
            curr = nodes[index(curr.prev)]
            table.insert(route.steps, curr.curr)

        table.insert(route.steps, src) -- route.steps.push_back(src);
        -- std::reverse(route.steps.begin(), route.steps.end());
    else
        DBG_PF("aborted a* search")
        route.move_cost = calc.getNoPathValue!

    return route


return a_star_search
