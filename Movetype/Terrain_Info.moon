----
-- Copyright (C) 2014 - 2018 by David White <dave@whitevine.net>
-- SPDX-License-Identifier: GPL-2.0+

dir = (...)\match"(.-)[^%.]+$"
Terrain_Data = require"#{dir}Terrain_Data"
-- ERR_CF = {}

----
-- Stores a set of data based on terrain.
class Terrain_Info

    -- explicit terrain_info(const parameters & params,
    --                       const terrain_info * fallback=nullptr,
    --                       const terrain_info * cascade=nullptr);
    -- terrain_info(const config & cfg, const parameters & params,
    --              const terrain_info * fallback=nullptr,
    --              const terrain_info * cascade=nullptr);
    -- terrain_info(const terrain_info & that,
    --              const terrain_info * fallback=nullptr,
    --              const terrain_info * cascade=nullptr);
    -- terrain_info & operator=(const terrain_info & that);


    ----
    -- Constructor.
    -- @param[in] params    The parameters to use when calculating values.
    --                      This is stored as a reference, so it must be long-lived (typically a static variable).
    -- @param[in] fallback  Used as a backup in case we are asked for data we do not have (think vision costs falling back to movement costs).
    -- @param[in] cascade   A terrain_info that uses us as a fallback. (Needed to sync cache clearing.)
    -- @note The fallback/cascade mechanism is a bit fragile and really should only be used by movetype.
    -- movetype::terrain_info::terrain_info(const parameters & params,
    --                                      const terrain_info * fallback,
    --                                      const terrain_info * cascade) :
    new: (cfg, params, terrain_types, fallback, cascade) =>
        assert(cfg, "no cfg")
        assert(params, 'no params')

        @data = Terrain_Data(cfg, params, terrain_types)
        -- @merged_data = Terrain_Data!
        -- @fallback = fallback
        -- @cascade  = cascade


    ----
    -- The parameters used when calculating a terrain-based value.
    Parameters: class

        ----
        -- int min,
        -- int max,
        -- int (*eval_fun)(int)=nullptr,
        -- bool move=true,
        -- bool high=false
        new: (min, max, eval_fun, move=true, high=false) =>
            @min_value = min -- The smallest allowable value.
            @max_value = max -- The largest allowable value.
            -- The default value (if no data is available).
            @default_value = if high then min else max
            -- Converter for values taken from a config. May be nil.
            @eval = eval_fun
            -- Whether to look at underlying movement or defense terrains.
            @use_move = move
            -- Whether we are looking for highest or lowest
            -- (unless inverted by the underlying terrain).
            @high_is_good = high

    ----
    --  * Constructor.
    --  * @param[in] cfg       An initial data set.
    --  * @param[in] params    The parameters to use when calculating values.
    --  *                      This is stored as a reference, so it must be long-lived (typically a static variable).
    --  * @param[in] fallback  Used as a backup in case we are asked for data we do not have (think vision costs falling back to movement costs).
    --  * @param[in] cascade   A terrain_info that uses us as a fallback. (Needed to sync cache clearing.)
    --  * @note The fallback/cascade mechanism is a bit fragile and really should only
    --  *       be used by movetype.
    -- movetype::terrain_info::terrain_info(const config & cfg, const parameters & params,
    --                                      const terrain_info * fallback,
    --                                      const terrain_info * cascade) :
    --     data_(new data(cfg, params)),
    --     merged_data_(),
    --     fallback_(fallback),
    --     cascade_(cascade)

    -- /**
    --  * Copy constructor.
    --  * @param[in] that      The terran_info to copy.
    --  * @param[in] fallback  Used as a backup in case we are asked for data we do not have (think vision costs falling back to movement costs).
    --  * @param[in] cascade   A terrain_info that uses us as a fallback. (Needed to sync cache clearing.)
    --  * @note The fallback/cascade mechanism is a bit fragile and really should only
    --  *       be used by movetype.
    -- movetype::terrain_info::terrain_info(const terrain_info & that,
    --                                      const terrain_info * fallback,
    --                                      const terrain_info * cascade) :
    --     // If we do not have a fallback, we need to incorporate that's fallback.
    --     // (See also the assignment operator.)
    --     data_(fallback ? that.data_ : that.get_merged()),
    --     merged_data_(that.merged_data_),
    --     fallback_(fallback),
    --     cascade_(cascade)

    -- /**
    --  * Assignment operator.
    --  */
    -- movetype::terrain_info & movetype::terrain_info::operator=(const terrain_info & that)
    --     if ( this != &that ) {
    --         // If we do not have a fallback, we need to incorporate that's fallback.
    --         // (See also the copy constructor.)
    --         data_ = fallback_ ? that.data_ : that.get_merged();
    --         merged_data_ = that.merged_data_;
    --         // We do not change our fallback nor our cascade.
    --     return *this;

    ----
    -- Clears the cache of values.
    -- void movetype::terrain_info::clear_cache() const
    clear_cache: =>
        @merged_data.reset!
        @data.clear_cache(@cascade)

    ----
    -- Returns whether or not our data is empty.
    -- bool movetype::terrain_info::empty() const
    empty: =>
        return @data\empty!

    ----
    -- Merges the given config over the existing values.
    -- @param[in] new_values  The new values.
    -- @param[in] overwrite   If true, the new values overwrite the old.
    --                        If false, the new values are added to the old.
    -- void movetype::terrain_info::merge(const config & new_values, bool overwrite)
    merge: (new_values, overwrite) =>
        -- Nothing will change, so skip the copy-on-write.
        return unless @data.config_has_changes(new_values, overwrite)

        -- Reset merged_data_ before seeing if data_ is unique,
        -- since the two might point to the same thing.
        @merged_data.reset!

        -- Copy-on-write.
        unless @data.unique!
            @data.reset(Terrain_Data(@data))
            -- We also need to make copies of our fallback and cascade.
            -- This is to keep the caching manageable, as this means each
            -- individual movetype will either share *all* of its cost data
            -- or not share *all* of its cost data. In particular, we avoid:
            -- 1) many sets of (unshared) vision costs whose cache would need
            --    to be cleared when a shared set of movement costs changes;
            -- 2) a caching nightmare when shared vision costs fallback to
            --    unshared movement costs.
            if @fallback
                @fallback.make_unique_fallback!
            if @cascade
                @cascade.make_unique_cascade!

        @data.merge(new_values, overwrite, @cascade)

    ----
    -- Returns the value associated with the given terrain.
    -- int movetype::terrain_info::value(const t_translation::terrain_code & terrain) const
    value: (terrain) =>
        return @data\value(terrain, @fallback)


    ----
    -- Returns a pointer to data that incorporates our fallback.
    -- const std::shared_ptr<movetype::terrain_info::data> &
    --     movetype::terrain_info::get_merged() const
    get_merged: =>
        -- Create-on-demand.
        unless @merged_data

            unless @fallback
                -- Nothing to incorporate.
                @merged_data = @data
            elseif @data.empty!
                -- Pure fallback.
                @merged_data = @fallback.get_merged!
            else
                -- Need to merge data.
                merged = {} -- config merged;
                @write(merged, "", true)
                -- @todo
                -- @merged_data = std::make_shared<data>(merged, data_->params());
                @merged_data = Terrain_Data(merged, @data.params)
        return @merged_data

    ----
    -- Ensures our data is not shared, and propagates to our cascade.
    make_unique_cascade: =>
        unless @data.unique!
        -- Const hack because this is not really changing the data.
        -- @todo
        -- const_cast<terrain_info *>(this)->data_.reset(new data(*data_));
            if @cascade
                @cascade.make_unique_cascade!

    ----
    -- Ensures our data is not shared, and propagates to our fallback.
    -- void movetype::terrain_info::make_unique_fallback() const
    make_unique_fallback: =>
        unless @data.unique!
            -- @todo
            -- Const hack because this is not really changing the data.
            -- const_cast<terrain_info *>(this)->data_.reset(new data(*data_));
            if @fallback
                @fallback.make_unique_fallback!

return Terrain_Info
