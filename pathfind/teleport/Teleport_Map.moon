
 class Teleport_Map
-- public:
--     /*
--      * @param teleport_groups
--      * @param u
--      * @param viewing_team
--      * @param see_all
--      * @param ignore_units
--      * @param check_vision
--      */
--     teleport_map(
--               const std::vector<teleport_group>& teleport_groups
--             , const unit& u
--             , const team &viewing_team
--             , const bool see_all
--             , const bool ignore_units
--             , const bool check_vision);

--     /*
--      * Constructs an empty teleport map.
--      */
--     teleport_map() :
--         teleport_map_(), sources_(), targets_() {}

--     /*
--      * @param adjacents        used to return the adjacent hexes
--      * @param loc            the map location for which we want to know the adjacent hexes
--      */
--     void get_adjacents(std::set<map_location>& adjacents, map_location loc) const;
--     /*
--      * @param sources    used to return the locations that are an entrance of the tunnel
--      */
--     void get_sources(std::set<map_location>& sources) const;
--     /*
--      * @param targets    used to return the locations that are an exit of the tunnel
--      */
--     void get_targets(std::set<map_location>& targets) const;

--     /*
--      * @returns whether the teleport_map does contain any defined tunnel
--      */
--     bool empty() const {
--         return sources_.empty();
--     }

-- private:
--     std::map<map_location, std::set<std::string> > teleport_map_;
--     std::map<std::string, std::set<map_location> > sources_;
--     std::map<std::string, std::set<map_location> > targets_;
-- };

-- /*
--  * @param u                    The unit that is processed by pathfinding
--  * @param viewing_team        The team the player belongs to
--  * @param see_all            Whether the teleport can be seen below shroud
--  * @param ignore_units        Whether to ignore zoc and blocking by units
--  * @param check_vision        Whether to check vision as opposed to movement range
--  * @returns a teleport_map
--  */
-- const teleport_map get_teleport_locations(const unit &u, const team &viewing_team,
--         bool see_all = false, bool ignore_units = false, bool check_vision = false);

-- teleport_map::teleport_map(
--           const std::vector<teleport_group>& groups
--         , const unit& unit
--         , const team &viewing_team
--         , const bool see_all
--         , const bool ignore_units
--         , const bool check_vision)
--     : teleport_map_()
--     , sources_()
--     , targets_()
-- {

--     for (const teleport_group& group : groups) {

--         teleport_pair locations;

--         if (check_vision && !group.allow_vision()) {
--             continue;
--         }

--         group.get_teleport_pair(locations, unit, ignore_units);
--         if (!see_all && !group.always_visible() && viewing_team.is_enemy(unit.side())) {
--             teleport_pair filter_locs;
--             for (const map_location &loc : locations.first) {
--                 if(!viewing_team.fogged(loc))
--                     filter_locs.first.insert(loc);
--             }
--             for (const map_location &loc : locations.second) {
--                 if(!viewing_team.fogged(loc))
--                     filter_locs.second.insert(loc);
--             }
--             locations.first.swap(filter_locs.first);
--             locations.second.swap(filter_locs.second);
--         }

--         if (!group.pass_allied_units() && !ignore_units && !check_vision) {
--             std::set<map_location>::iterator loc = locations.second.begin();
--             while(loc != locations.second.end()) {
--                 unit_map::iterator u;
--                 if (see_all) {
--                     u = resources::gameboard->units().find(*loc);
--                 } else {
--                     u = resources::gameboard->find_visible_unit(*loc, viewing_team);
--                 }
--                 if (u != resources::gameboard->units().end()) {
--                     loc = locations.second.erase(loc);
--                 } else {
--                     ++loc;
--                 }
--             }
--         }

--         std::string teleport_id = group.get_teleport_id();
--         std::set<map_location>::iterator source_it = locations.first.begin();
--         for (; source_it != locations.first.end(); ++source_it ) {
--             if(teleport_map_.count(*source_it) == 0) {
--                 std::set<std::string> id_set;
--                 id_set.insert(teleport_id);
--                 teleport_map_.emplace(*source_it, id_set);
--             } else {
--                 (teleport_map_.find(*source_it)->second).insert(teleport_id);
--             }
--         }
--         sources_.emplace(teleport_id, locations.first);
--         targets_.emplace(teleport_id, locations.second);
--     }
-- }

-- void teleport_map::get_adjacents(std::set<map_location>& adjacents, map_location loc) const {

--     if (teleport_map_.count(loc) == 0) {
--         return;
--     } else {
--         const std::set<std::string>& keyset = (teleport_map_.find(loc)->second);
--         for(std::set<std::string>::const_iterator it = keyset.begin(); it != keyset.end(); ++it) {

--             const std::set<map_location>& target = targets_.find(*it)->second;
--             adjacents.insert(target.begin(), target.end());
--         }
--     }
-- }

-- void teleport_map::get_sources(std::set<map_location>& sources) const {

--     std::map<std::string, std::set<map_location> >::const_iterator it;
--     for(it = sources_.begin(); it != sources_.end(); ++it) {
--         sources.insert(it->second.begin(), it->second.end());
--     }
-- }

-- void teleport_map::get_targets(std::set<map_location>& targets) const {

--     std::map<std::string, std::set<map_location> >::const_iterator it;
--     for(it = targets_.begin(); it != targets_.end(); ++it) {
--         targets.insert(it->second.begin(), it->second.end());
--     }
-- }


-- const teleport_map get_teleport_locations(const unit &u,
--     const team &viewing_team,
--     bool see_all, bool ignore_units, bool check_vision)
-- {
--     std::vector<teleport_group> groups;

--     if (u.get_ability_bool("teleport", *resources::gameboard)) {
--         for (const unit_ability & teleport : u.get_abilities("teleport")) {
--             const int tunnel_count = (teleport.first)->child_count("tunnel");
--             for(int i = 0; i < tunnel_count; ++i) {
--                 config teleport_group_cfg = (teleport.first)->child("tunnel", i);
--                 groups.emplace_back(vconfig(teleport_group_cfg, true), false);
--             }
--         }
--     }

--     const std::vector<teleport_group>& global_groups = resources::tunnels->get();
--     groups.insert(groups.end(), global_groups.begin(), global_groups.end());

--     return teleport_map(groups, u, viewing_team, see_all, ignore_units, check_vision);
-- }

