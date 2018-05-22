-- /*
--    Copyright (C) 2010 - 2017 by Fabian Mueller <fabianmueller5@gmx.de>
--    Part of the Battle for Wesnoth Project http://www.wesnoth.org/
--
--    This program is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License version 2
--    or at your option any later version.
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY.
--
--    See the COPYING file for more details.
-- */

-- static lg::log_domain log_engine("engine");
-- #define ERR_PF LOG_STREAM(err, log_engine)
-- typedef std::pair<std::set<map_location>, std::set<map_location> >
--         teleport_pair;

reversed_suffix = "-__REVERSED__"
class Manager

    -- private:
    --     std::vector<teleport_group> tunnels_;
    --     int id_;
    new: (cfg) => -- manager(const config &cfg);
-- manager::manager(const config &cfg) : tunnels_(), id_(cfg["next_teleport_group_id"].to_int(0)) {
--     const int tunnel_count = cfg.child_count("tunnel");
--     for(int i = 0; i < tunnel_count; ++i) {
--         const config& t = cfg.child("tunnel", i);
--         if(!t["saved"].to_bool()) {
--             lg::wml_error() << "Do not use [tunnel] directly in a [scenario]. Use it in an [event] or [abilities] tag.\n";
--             continue;
--         }
--         const teleport_group tunnel(t);
--         this->add(tunnel);
--     }
-- }


    ----
    -- @param group        teleport_group to be added
    -- void add(const teleport_group &group);
    add: (group) =>
        table.insert(@tunnels_, group)


    ----
    -- * @param id        id of the teleport_group that is to be removed by the method
    -- void remove(const std::string &id);
    remove: (id) =>
        -- std::vector<teleport_group>::iterator t = tunnels_.begin();
        -- for(;t != tunnels_.end();) {
        for i, tunnel in ipairs @tunnels_
            if tunnel.get_teleport_id! == id or
                tunnel.get_teleport_id! == id .. reversed_suffix
                table.remove(@tunnels_, i)


    ----
    -- @return    all registered teleport groups on the game field
    -- const std::vector<teleport_group>& get() const;
    get: =>
        return @tunnels_

    -- /** Inherited from savegame_config. */
    -- config to_config() const;

    ----
    -- @returns the next free unique id for a teleport group
    -- std::string next_unique_id();
    next_unique_id: =>
        @id_ += 1
        return tostring(@id_)

-- config manager::to_config() const {
--     config store;

--     std::vector<teleport_group>::const_iterator tunnel = tunnels_.begin();
--     for(; tunnel != tunnels_.end(); ++tunnel) {
--         store.add_child("tunnel", tunnel->to_config());
--     }
--     store["next_teleport_group_id"] = std::to_string(id_);

--     return store;
-- }
