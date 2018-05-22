-- typedef std::shared_ptr<terrain_type_data> ter_data_cache;

----
-- Copyright (C) 2014 - 2018 by Chris Beck <render787@gmail.com>
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


-- import terrain_type, create_terrain_maps from require'terrain'
t_translation = require"wesnoth.terrain.translation"
Terrain_Type  = require"wesnoth.terrain.Terrain_Type"

create_terrain_maps = require'wesnoth.terrain.create_terrain_maps'

class Terrain_Type_Data

    -- local create_terrain_maps
    ----
    -- @param game_config
    new: (game_config) =>
        -- t_translation::ter_list
        @terrainList = {}
        -- map terrain_code -> terrain_type
        @tcodeToTerrain = {}
        -- @todo
        -- @initialized = false
        @initialized = true
        @game_config = game_config

        -- moon = require'moon'
        -- moon.p(game_config)

        -- @todo not done here in upstream
        -- create_terrain_maps(@game_config.terrain_type,
        --     @terrainList, @tcodeToTerrain)
        create_terrain_maps(game_config,
            @terrainList, @tcodeToTerrain)


    -- @return {t_translation}
    list: =>
        unless @initialized
            create_terrain_maps(@game_config.terrain_type,
                @terrainList, @tcodeToTerrain)
            @initialized = true

        return @terrainList


    ----
    -- @todo do we need to give away the map?
    -- @return std::map<t_translation::terrain_code, terrain_type>
    map: =>
        unless @initialized
            create_terrain_maps(@game_config.terrain_type, @terrainList, @tcodeToTerrain)
            @initialized = true

        return @tcodeToTerrain


    default_terrain = Terrain_Type!
    ----
    -- Get the corresponding terrain_type information object
    -- for a given type of terrain.
    -- @tparam terrain_code terrain
    get_terrain_info: (terrain) =>
        -- @todo
        terrain_type = @tcodeToTerrain[terrain]
        -- assert(terrain.base, "no base")
        -- terrain_type = @tcodeToTerrain[terrain.base]
        -- moon = require'moon'
        -- moon.p(@tcodeToTerrain)
        -- moon.p(terrain)
        assert(terrain_type, "'#{terrain}' not found in tcodeToTerrain")
        return terrain_type or default_terrain


    ----
    -- The name of the terrain is the terrain itself,
    -- The underlying terrain is the name of the terrain for game-logic purposes.
    -- I.e. if the terrain is simply an alias, the underlying terrain name
    -- is the name of the terrain that it's aliased to.
    -- @tparam terrain_code terrain
    underlying_mvt_terrain: (terrain) =>
        if terrain_type = @tcodeToTerrain[terrain]
            moon = require"moon"
            moon.p(terrain_type)
            return terrain_type.mvt_type
        else
            return {terrain}


    ----
    -- @todo
    underlying_def_terrain: (terrain) =>
        if terrain_type = @tcodeToTerrain[terrain]
            return terrain_type.def_type
        else
            return {terrain}


    ----
    -- @todo
    underlying_union_terrain: (terrain) =>
        if terrain_type = @tcodeToTerrain[terrain]
            return terrain_type.union_type
        else
            return {terrain}


    ----
    -- Get a formatted terrain name -- terrain (underlying, terrains)
    -- @tparam terrain_code terrain
    -- @return string
    get_terrain_string: (terrain) =>
        str = @get_terrain_info(terrain).description
        str ..= @get_underlying_terrain_string(terrain)
        return str


    ----
    -- @return std::string
    -- @tparam terrain_code terrain
    get_terrain_editor_string: (terrain) =>
        str  = @get_terrain_info(terrain).editor_name()
        desc = @get_terrain_info(terrain).description()

        unless str == desc
            str ..= "/"
            str ..= desc

        str ..= @get_underlying_terrain_string(terrain)
        return str


    ----
    -- @return string
    -- @tparam terrain_code terrain
    get_underlying_terrain_string: (terrain) =>
        str = ''

        underlying = @underlying_union_terrain(terrain)
        assert(#underlying == 0)

        if #underlying > 1 or underlying[1] != terrain
            str ..= " ("
            i = underlying[1]
            str ..= @get_terrain_info(i).name
            -- while (++i != underlying.end()) {
            while i != nil
                str ..= ", " .. @get_terrain_info(i).name
            str ..= ")"

        return str


    ----
    -- @return bool
    -- @tparam terrain_code terrain
    is_village: (terrain) =>
		return @get_terrain_info(terrain).is_village!

    ----
    -- @return int
    -- @tparam terrain_code terrain
    gives_healing: (terrain) =>
		return @get_terrain_info(terrain).gives_healing!

    ----
    -- @return bool
    -- @tparam terrain_code terrain
    is_castle: (terrain) =>
        return @get_terrain_info(terrain).is_castle!


    ----
    -- @return bool
    -- @tparam terrain_code terrain
    is_keep: (terrain) =>
        return @get_terrain_info(terrain).is_keep!


    ----
    -- Tries to find out if "terrain" can be created
    -- by combining two existing terrains
    -- Will add the resulting terrain to the terrain list if successful
    -- @return bool
    -- @tparam t_translation::terrain_code terrain
    try_merge_terrains = (terrain) =>

        unless @tcodeToTerrain[terrain]
            base = @tcodeToTerrain[t_translation.terrain_code(
                terrain.base, t_translation.NO_LAYER)]
            overlay = @tcodeToTerrain[t_translation.terrain_code(
                t_translation.NO_LAYER, terrain.overlay)]

            return false if (base == nil) or (overlay == nil)

            new_terrain = Terrain_Type(base, overlay)

            table.insert(@terrainList, new_terrain.number)
            @tcodeToTerrain[new_terrain.number] = new_terrain
            return true

        return true -- Terrain already exists, nothing to do


    ----
    -- Tries to merge old and new terrain using the merge_settings config
    -- Relevant parameters are "layer" and "replace_conflicting"
    -- "layer" specifies the layer that should be replaced
    -- (base or overlay, default is both).
    -- If "replace_conflicting" is true the new terrain will replace
    -- the old one if merging failed.
    -- (using the default base if new terrain is an overlay terrain)
    -- Will return the resulting terrain or NONE_TERRAIN if merging failed.
    -- @param old_t
    -- @param new_t
    -- @param mode one of "BASE", "OVERLAY" or "BOTH"
    -- @param replace_if_failed (false)
    -- @return terrain_code
    merge_terrains: (old_t, new_t, mode, replace_if_failed=false) =>
        result = t_translation.NONE_TERRAIN

        if mode == "OVERLAY"
            t = t_translation.terrain_code(old_t.base, new_t.overlay)
            if try_merge_terrains(t)
                result = t
        elseif mode == "BASE"
            t = t_translation.terrain_code(new_t.base, old_t.overlay)
            if try_merge_terrains(t)
                result = t
        elseif mode == "BOTH" and new_t.base != t_translation.NO_LAYER
            -- We need to merge here, too,
            -- because the dest terrain might be a combined one.
            if try_merge_terrains(new_t)
                result = new_t
        -- if merging of overlay and base failed,
        -- and replace_if_failed is set,
        -- replace the terrain with the complete new terrain (if given)
        -- or with (default base)^(new overlay)
        if result == t_translation.NONE_TERRAIN and replace_if_failed and
                @tcodeToTerrain.count(new_t) > 0
            if new_t.base != t_translation.NO_LAYER
                -- Same as above
                if try_merge_terrains(new_t)
                    result = new_t
            elseif @get_terrain_info(new_t).default_base() !=
                    t_translation.NONE_TERRAIN
                result = @get_terrain_info(new_t).terrain_with_default_base()

        return result
