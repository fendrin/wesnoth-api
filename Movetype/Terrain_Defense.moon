----
-- Copyright (C) 2014 - 2018 by David White <dave@whitevine.net>
-- SPDX-License-Identifier: GPL-2.0+

import Terrain_Info, Parameters from require"Terrain_Info"

----
-- Converts config defense values to a "max" value.
config_to_max = (value) ->
    return if value < 0 then -value else value

----
-- Converts config defense values to a "min" value.
config_to_min = (value) ->
    return if value < 0 then -value else 0


----
-- Stores a set of defense levels.
class Terrain_Defense

    -- static const terrain_info::parameters params_min_;
    -- const movetype::terrain_info::parameters
    --     movetype::terrain_defense::params_min_(0, 100, config_to_min, false, true);
    params_min: Parameters(0, 100, config_to_min, false, true)

    -- const movetype::terrain_info::parameters
    --     movetype::terrain_defense::params_max_(0, 100, config_to_max, false, false);
    -- static const terrain_info::parameters params_max_;
    params_max: Parameters(0, 100, config_to_max, false, false)

    -- There will be duplication of the config here, but it is a small
    -- config, and the duplication allows greater code sharing.
    -- terrain_info min_;
    -- terrain_info max_;

    -- terrain_defense() : min_(params_min_), max_(params_max_) {}
    -- explicit terrain_defense(const config & cfg) :
    -- min_(cfg, params_min_), max_(cfg, params_max_)
    new: (cfg) =>
        if cfg
            @max = Terrain_Info(cfg, @params_max)
            @min = Terrain_Info(cfg, @params_min)
        else
            @max = Terrain_Info(@params_max)
            @min = Terrain_Info(@params_min)

    ----
    -- Returns the defense associated with the given terrain.
    -- int defense(const t_translation::terrain_code & terrain) const
    defense: (terrain) =>
        return math.max(@min.value(terrain), @max.value(terrain))

    ----
    -- Returns whether there is a defense cap associated to this terrain.
    -- bool capped(const t_translation::terrain_code & terrain) const
    capped: (terrain) =>
        return @min.value(terrain) != 0

    ----
    -- Merges the given config over the existing costs.
    -- (Not overwriting implies adding.)
    -- void merge(const config & new_data, bool overwrite)
    merge: (new_data, overwrite) =>
        @min.merge(new_data, overwrite)
        @max.merge(new_data, overwrite)

    ----
    -- Writes our data to a config, as a child if @a child_name is specified.
    -- (No child is created if there is no data.)
    -- void write(config & cfg, const std::string & child_name="") const
    write: (cfg, child_name="") =>
        @max.write(cfg, child_name, false)
