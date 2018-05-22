class Dest_Vect

-- paths::dest_vect::const_iterator paths::dest_vect::find(const map_location &loc) const
-- {
-- step_compare = (a, b) ->
    -- return a.curr < b
--     const_iterator i = std::lower_bound(begin(), end(), loc, step_compare);
--     if (i != end() && i->curr != loc) return end();
--     return i;
-- }

-- void paths::dest_vect::insert(const map_location &loc)
-- {
--     iterator i = std::lower_bound(begin(), end(), loc, step_compare);
--     if (i != end() && i->curr == loc) return;
--     paths::step s { loc, map_location(), 0 };
--     std::vector<step>::insert(i, s);
-- }

    ----
    -- Returns the path going from the source point (included) to the
    -- destination point @a j (excluded).
    -- std::vector<map_location> paths::dest_vect::get_path(const const_iterator &j) const
    get_path: =>
--     std::vector<map_location> path;
        path = {}
--     if (!j->prev.valid()) {
--         path.push_back(j->curr);
--     } else {
--         const_iterator i = j;
--         do {
--             i = find(i->prev);
--             assert(i != end());
--             path.push_back(i->curr);
--         } while (i->prev.valid());
--     }
--     std::reverse(path.begin(), path.end());
--     return path;


-- bool paths::dest_vect::contains(const map_location &loc) const
-- {
--     return find(loc) != end();
-- }

return Dest_Vect
