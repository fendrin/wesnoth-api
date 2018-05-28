----
-- Copyright (C) 2014 - 2018 by David White <dave@whitevine.net>
-- SPDX-License-Identifier: GPL-2.0+

-- local ERR_CF
t_translation = require"wesnoth.terrain.translation"

----
-- The terrain-based data.
class Terrain_Data

    ----
    -- Constructor.
    new: (cfg, params, terrain_types) =>
        assert(cfg, "no cfg")
        assert(params, 'params is nil')
        assert(terrain_types)
        @cfg    = cfg
        @params = params
        @cache  = {}
        @tdata  = terrain_types


    ----
    -- Clears the cached data (presumably our fallback has changed).
    -- @param[in] cascade Cache clearing will be cascaded into this terrain_info
    clear_cache: (cascade) =>
        @cache = {} -- @cache.clear!
        -- Cascade the clear to whichever terrain_info falls back on us.
        if cascade
            cascade.clear_cache!


    ----
    -- Tests if merging @a new_values would result in changes.
    -- This allows the shared data to actually work,
    -- as otherwise each unit created via WML (including unstored units)
    -- would "overwrite" its movement data with
    -- a usually identical copy and thus break the sharing.
    -- @return bool
    -- @tparam config new_values
    -- @tparam bool overwrite
    config_has_changes: (new_values, overwrite) =>
        if overwrite
            for key, value in pairs new_values
                if value != @cfg[key]
                    return true
        else
            for _, value in pairs new_values
                if value != 0
                    return true
        -- If we make it here, new_values has no changes for us.
        return false


    ----
    -- Tests for no data in this object.
    -- @return bool Returns whether or not our data is empty.
    empty: => return next(@cfg) == nil


    ----
    -- Merges the given config over the existing costs.
    -- @param[in] new_values  The new values.
    -- @param[in] overwrite   If true, the new values overwrite the old.
    --                        If false, the new values are added to the old.
    -- @param[in] cascade     Cache clearing will be cascaded into this terrain_info.
    merge: (new_values, overwrite, cascade) =>

        if overwrite
            -- We do not support child tags here,
            -- so do not copy any that might be in the input.
            -- (If in the future we need to support child tags,
            -- change "merge_attributes" to "merge_with".)
            for key, value in pairs new_values
                @cfg[key] = value
        else
            for key, value in pairs new_values
                dest = @cfg[key]
                old  = if dest then tonumber(dest) else
                    @params.max_value

                -- The new value is the absolute value of the old plus the
                -- provided value, capped between minimum and maximum, then
                -- given the sign of the old value.
                -- (Think defenses for why we might have negative values.)
                value = math.abs(old) +
                    if value then tonumber(value) else 0
                value = math.max(@params.min_value, math.min(value,
                    @params.max_value))
                if old < 0
                    value = -value

                dest = value

        -- The new data has invalidated the cache.
        @clear_cache(cascade)


    local calc_value
    ----
    -- Returns the value associated with the given terrain (possibly cached).
    -- @param[in]  terrain        The terrain whose value is requested.
    -- @param[in]  fallback       Consulted if we are missing data.
    -- @param[in]  recurse_count  Detects (probable) infinite recursion.
    -- @return number
    -- int movetype::terrain_info::data::value(
    --     const t_translation::terrain_code & terrain,
    --     const terrain_info * fallback,
    --     unsigned recurse_count) const
    value = (terrain, fallback, recurse_count) =>
        -- moon = require'moon'
        -- moon.p(@)
        assert(terrain, 'no terrain arg')

        print"was asked for #{terrain}, recursion step is #{recurse_count}"

        -- Check the cache.
        unless @cache[terrain]
            -- The cache did not have an entry for this terrain,
            -- so calculate the value.
            @cache[terrain] = calc_value(@, terrain, fallback, recurse_count)

        return @cache[terrain]


    ----
    -- Calculates the value associated with the given terrain.
    -- This is separate from value() to separate the calculating of the
    -- value from the caching of it.
    -- @param[in]  terrain        The terrain whose value is requested.
    -- @param[in]  fallback       Consulted if we are missing data.
    -- @param[in]  recurse_count  Detects (probable) infinite recursion.
    -- int movetype::terrain_info::data::calc_value(
    --     const t_translation::terrain_code & terrain,
    --     const terrain_info * fallback,
    --     unsigned recurse_count) const
    calc_value = (terrain, fallback, recurse_count) =>

        print"#{terrain} is not in cache, calculating..."

        -- Infinite recursion detection:
        if recurse_count > 100
            -- @todo
            assert(false, "to many recursion steps")
            -- ERR_CF("infinite terrain_info recursion on " ..
            --     (if @params.use_move then "movement" else "defense") ..
            --     ": " .. t_translation.write_terrain_code(terrain) ..
            --     " depth " .. recurse_count .. '\n')
            return @params.default_value

        -- Get a list of underlying terrains.
        -- @todo
        -- underlying = if @params.use_move
        --     @tdata\underlying_mvt_terrain(terrain)
        -- else
        --     @tdata\underlying_def_terrain(terrain)
        -- assert(underlying, "")
        -- assert(next(underlying) != nil)
        underlying = @tdata\underlying_mvt_terrain(terrain)

        -- moon = require'moon'
        -- print "underlying is:"
        -- moon.p(underlying)

        if type(underlying) == 'string'
            underlying = {underlying}

        if #underlying == 1 and underlying[1] == terrain
            -- This is not an alias; get the value directly.
            -- print"#{terrain} is *not* an alias"
            result = @params.default_value
            -- result = 666

            id = @tdata\get_terrain_info(terrain).id
            assert(id, 'no id')

            if val = @cfg[id]
                -- print"we have an id"
                -- moon.p(val)

                -- Read the value from our config.
                -- result = val.to_int(@params.default_value)
                -- if @params.eval != nil
                    -- result = @params.eval(result)
                if @params.eval
                    assert(false, "there is a params.eval! Ugly.")
                    result = @params.eval(val)
                else
                    result = val

            -- @todo remove
            -- elseif fallback != nil
                -- assert(false, "in fallback")
                -- Get the value from our fallback.
                -- result = fallback.value(terrain)

            -- Validate the value.
            if result < @params.min_value
                assert(false, "result #{result} is below min_value")
                -- @todo
                -- WRN_CF("Terrain '" .. terrain .. "' has evaluated to " ..
                -- result .. " (" ..
                -- (if @params.use_move then "cost" else "defense") ..
                -- "), which is less than " .. @params.min_value ..
                -- "; resetting to " .. @params.min_value .. ".\n")
                result = @params.min_value

            if result > @params.max_value
                assert(false, "result #{result} is above max_value")
                -- @todo
                -- WRN_CF("Terrain '" .. terrain .. "' has evaluated to " ..
                --     result .. " (" ..
                --     (if @params.use_move then "cost" else "defense") ..
                --     "), which is more than " .. @params.max_value ..
                --     "; resetting to " .. @params.max_value .. ".\n")
                result = @params.max_value

            return result
        else
            -- This is an alias; select the best of all underlying terrains.
            -- print"#{terrain} *is* an alias"
            -- moon.p(underlying)
            prefer_high = @params.high_is_good
            result = @params.default_value
            assert(t_translation.MINUS)
            if underlying[1] == t_translation.MINUS
                assert(false, "is minus")
                -- Use the other value as the initial value.
                result = result == if @params.max_value
                    @params.min_value else @params.max_value

            -- Loop through all underlying terrains.
            for i in *underlying
                if i == t_translation.PLUS
                    -- Prefer what is good.
                    prefer_high = @params.high_is_good
                elseif i == t_translation.MINUS
                    -- Prefer what is bad.
                    prefer_high = not @params.high_is_good
                else
                    -- Test the underlying terrain's value
                    -- against the best so far.
                    num = value(@, i, fallback, recurse_count + 1)

                    if (prefer_high  and  num > result) or
                            (not prefer_high  and  num < result)
                        result = num

            return result


    ----
    -- Returns the value associated with the given terrain.
    -- @return int
    -- @tparam t_translation::terrain_code terrain
    -- @tparam terrain_info fallback
    value: (terrain, fallback) =>
        return value(@, terrain, fallback, 0)


    ----
    -- If there is data, writes it to the config.
    -- void write(config & out_cfg, const std::string & child_name) const;


    ----
    -- If there is (merged) data, writes it to the config.
    -- void write(config & out_cfg, const std::string & child_name,
    --            const terrain_info * fallback) const;


    ----
    -- Returns a pointer to data the incorporates our fallback.
    -- const std::shared_ptr<data> & get_merged() const;
    -- get_merged = ->


    ----
    -- Ensures our data is not shared, and propagates to our cascade.
    -- void make_unique_cascade() const;
    -- make_unique_cascade = ->


    ----
    -- Ensures our data is not shared, and propagates to our fallback.
    -- void make_unique_fallback() const;
    -- make_unique_fallback = ->


return Terrain_Data
