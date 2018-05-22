
----
-- Stores a set of resistances.
class Resistances

    -- resistances() : cfg_()
    -- resistances(const config & cfg) : cfg_(cfg)
    new: (cfg) =>
        @cfg = cfg

    ----
    -- Returns a map from attack types to resistances.
    -- utils::string_map movetype::resistances::damage_table() const
    damage_table: =>
        -- result = {}
        -- for key, value in pairs @cfg
        --     result[key] = value
        -- return result
        return @cfg

    ----
    -- Returns the resistance against the indicated attack.
    -- int movetype::resistances::resistance_against(const attack_type & attack) const
    resistance_against: (attack) =>
        return @cfg[attack.type] or 100

    ----
    -- Returns the resistance against the indicated damage type.
    -- int movetype::resistances::resistance_against(const std::string & damage_type) const
    resistance_against: (damage_type) =>
        return @cfg[damage_type] or 100

    ----
    -- Merges the given config over the existing costs.
    -- If @a overwrite is false, the new values will be added to the old.
    -- void movetype::resistances::merge(const config & new_data, bool overwrite)
    merge: (new_data, overwrite) =>
        if overwrite
            -- We do not support child tags here,
            -- so do not copy any that might be in the input.
            -- (If in the future we need to support child tags,
            --  change "merge_attributes" to "merge_with".)
            -- @todo this won't work
            -- @cfg.merge_attributes(new_data)
            for key,value in pairs new_data
                @cfg[key] = value
        else
            for key,value in pairs new_data
                @cfg[key] = math.max(0, (@cfg[key] or 100) + (value or 0))

    ----
    -- Writes our data to a config, as a child if @a child_name is specified.
    --
    -- Writes our data to a config, as a child if @a child_name is specified.
    -- (No child is created if there is no data.)
    -- void movetype::resistances::write(config & out_cfg, const std::string & child_name) const
    write: (out_cfg, child_name="") =>
        if #@cfg == 0
            return

        if child_name == ""
            out_cfg.merge_with(@cfg)
        else
            out_cfg.add_child(child_name, @cfg)
