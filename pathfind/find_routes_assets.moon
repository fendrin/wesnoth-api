-- Location = require"shared.Location"
-- moon = require"moon"

----
-- A function object for comparing indices.
class Findroute_Comp

    ----
    -- Constructor:
    -- findroute_comp(const std::vector<findroute_node>& n)
    new: (nodes) =>
        @nodes = nodes -- const std::vector<findroute_node>& nodes;


    ----
    -- Binary predicate evaluating the order of its arguments:
    -- @return bool
    -- operator()(int l, int r) const {
    -- __call: (r, l) =>
    __call: (r, l) =>
        assert r
        assert l
        return @nodes[r] < @nodes[l]


----
-- Nodes used by find_routes().
-- These store the information necessary for extending the path
-- and for tracing the route back to the source.
class Findroute_Node
    -- int moves_left, turns_left;
    -- map_location prev;
    -- search_num is used to detect which nodes have been collected
    -- in the current search. (More than just a boolean value so
    -- that nodes can be stored between searches.)
    -- unsigned search_num;

    ----
    -- Constructors.
    -- findroute_node(int moves, int turns, const map_location &prev_loc, unsigned search_count)
    -- findroute_node()
    new: (moves, turns, prev_loc, search_count) =>
        unless moves
            @moves_left = 0
            @turns_left = 0
            @prev = nil -- Location!
            @search_num = 0
        else
            @moves_left = moves
            @turns_left = turns
            @prev = prev_loc
            @search_num = search_count


    ----
    -- Compare these nodes based on movement consumed.
    -- bool operator<(const findroute_node& o) const
    -- @return bool
    __lt: (o) =>
        return @turns_left > o.turns_left or
            (@turns_left == o.turns_left and @moves_left > o.moves_left)


    __tostring: =>
        return "i am a node with prev #{@prev}"

----
-- Converts map locations to and from integer indices.
class Findroute_Indexer
    -- int w, h; // Width and height of the map.


    -- Constructor:
    -- findroute_indexer(int a, int b) : w(a), h(b) { }
    new: (w, h) =>
        @width = w
        @height = h


    -- Convert to an index: (throws on out of bounds)
    -- unsigned operator()(int x, int y) const
    -- Convert to an location:
    -- map_location operator()(unsigned index) const
    __call: (x, y) =>

        unless y
            return math.floor(x % @width), math.floor(x / @width)

        return x + y*@width
        -- @todo
        -- VALIDATE(@on_board(x,y), "Pathfind: Location not on board")


    -- Check if location is on board
    -- inline bool on_board(const map_location& loc) const
    -- inline bool on_board(int x, int y) const
    on_board: (loc_or_x, y) =>
        local x
        unless y
            x = loc_or_x.x
            y = loc_or_x.y
        else
            x = loc_or_x

        return (x > 0) and (x <= @width) and (y > 0) and (y <= @height)

{
    :Findroute_Node
    :Findroute_Indexer
    :Findroute_Comp
}
