----
-- Copyright (C) 2014 - 2018 by David White <dave@whitevine.net>
-- SPDX-License-Identifier: GPL-2.0+

Set = require"shared.Set"
moon = require"moon"


----
-- @file
-- Handle movement types.

dir = (...)\match"(.-)[^%.]+$"
Terrain_Costs = require"#{dir}Terrain_Costs"

-- @todo
-- static lg::log_domain log_config("config");
-- #define ERR_CF LOG_STREAM(err, log_config)
-- #define WRN_CF LOG_STREAM(warn, log_config)


----
-- The basic "shape" of the unit - flying, small land, large land, etc.
-- This encompasses terrain costs, defenses, and resistances.
class Movetype

    ----
    -- @todo
    -- Magic value that signifies a hex is unreachable.
    -- The UNREACHABLE macro in the data tree should match this value.
    -- UNREACHABLE: 99

    -- @todo
    -- terrain_costs movement_;
    -- terrain_costs vision_;
    -- terrain_costs jamming_;
    -- terrain_defense defense_;
    -- resistances resist_;
    -- bool flying_;

    ----
    -- Default constructor
    -- @param cfg
    -- @param terrain_types
    new: (cfg, terrain_types) =>
        assert(cfg, "no cfg")
        assert(terrain_types, "no terrain_types")
        @terrain_types = terrain_types

        -- @todo clean up

        -- moon.p(cfg)
        assert(cfg.movement_costs, "No movement_costs provided.")

        -- This is not access before initialization;
        -- the address is merely stored at this point.
        -- @vision = Terrain_Costs(cfg.vision_costs, @movement, @jamming)
        -- @movement = Terrain_Costs(cfg.movement_costs, @vision)
        @movement = Terrain_Costs(cfg.movement_costs, terrain_types)
        -- movement_(cfg.child_or_empty("movement_costs"), nullptr, &vision_)
        -- @movement = Terrain_Costs(nil, @vision)
        -- jamming_(cfg.child_or_empty("jamming_costs"), &vision_, nullptr)
        -- @jamming  = Terrain_Costs(@vision, nil)
        -- jamming_(&vision_, nullptr),

        -- @defense = Defense(cfg.defense)
        -- @resist  = Resistances(cfg.resistance)

        @flying = cfg.flies or false

    -- /**
    --  * Copy constructor
    --  */
    -- movetype::movetype(const movetype & that) :
    --     movement_(that.movement_, nullptr, &vision_),    // This is not access before initialization; the address is merely stored at this point.
    --     vision_(that.vision_, &movement_, &jamming_), // This is not access before initialization; the address is merely stored at this point.
    --     jamming_(that.jamming_, &vision_, nullptr),
    --     defense_(that.defense_),
    --     resist_(that.resist_),
    --     flying_(that.flying_)


    ----
    -- Returns the cost to move through the indicated terrain.
    movement_cost: (terrain, slowed=false) =>
        return @movement\cost(terrain, slowed)


    ----
    -- Returns the cost to see through the indicated terrain.
    vision_cost: (terrain, slowed=false) =>
        return @vision\cost(terrain, slowed)


    ----
    -- Returns the cost to "jam" through the indicated terrain.
    jamming_cost: (terrain, slowed=false) =>
        return @jamming\cost(terrain, slowed)


    ----
    -- Returns the defensive value of the indicated terrain.
    defense_modifier: (terrain) =>
        return @defense\defense(terrain)


    ----
    -- Returns the resistance against the indicated attack.
    resistance_against: (attack) =>
        return @resist\resistance_against(attack)


    -- Returns the resistance against the indicated damage type.
    resistance_against: (damage_type) =>
        return @resist\resistance_against(damage_type)


    ----
    -- Returns a map from attack types to resistances.
    damage_table: =>
        return @resist.damage_table


    ----
    -- Returns whether or not there are any terrain caps
    -- with respect to a set of terrains.
    -- @param ts
    -- @return bool
    has_terrain_defense_caps: (ts) =>
        -- @todo where is the implementation?


    ----
    -- Returns whether or not there are any vision-specific costs.
    -- @return bool
    has_vision_data: =>
        return next(@vision) != nil


    ----
    -- Returns whether or not there are any jamming-specific costs.
    -- @return bool
    has_jamming_data: =>
        return next(@jamming) != nil


    ----
    -- Checks if we have a defense cap (nontrivial min value)
    -- for any of the given terrain types.
    -- @param ts todo
    has_terrain_defense_caps: (ts) =>
        for t in ts
            if @defense.capped(t)
                return true
        return false


    ----
    -- Merges the given config over the existing data.
    -- @param overwrite If @a overwrite is false, the new values will be added to the old. default is true
    merge: (new_cfg, overwrite=true) =>

        for child in *new_cfg.movement_costs
            @movement.merge(child, overwrite)

        for child in *new_cfg.vision_costs
            @vision.merge(child, overwrite)

        for child in *new_cfg.jamming_costs
            @jamming.merge(child, overwrite)

        for child in *new_cfg.defense
            @defense.merge(child, overwrite)

        for child in *new_cfg.resistance
            @resist.merge(child, overwrite)

        -- "flies" is used when WML defines a movetype.
        -- "flying" is used when WML defines a unit.
        -- It's easier to support both than to track which case we are in.
        -- @todo solve in the transcompiler
        if flies = new_cfg.flies
            @flying = flies
        if flying = new_cfg.flying
            @flying = flying


    ----
    -- The set of strings defining effects which apply to movetypes.
    -- The set of applicable effects for movement types
    effects: Set{"movement_costs", "vision_costs",
        "jamming_costs", "defense", "resistance"}


return Movetype
