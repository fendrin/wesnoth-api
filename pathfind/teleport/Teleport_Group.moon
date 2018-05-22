-- wesnoth = require""
import get_locations from (require"server.wesnoth").wesnoth

----
-- Represents the tunnel wml tag.
class Teleport_Group

    ----
    -- Constructs the object from a config file.
    -- @param cfg        the contents of a [tunnel] tag
    -- @param way_back    inverts the direction of the teleport
    -- teleport_group::teleport_group(const vconfig& cfg, bool reversed) : cfg_(cfg.get_config()), reversed_(reversed), id_()
    new: (cfg, way_back=false) =>
        assert(cfg.source)
        assert(cfg.target)
        assert(cfg.filter)
        @cfg_ = cfg
        @reversed_ = way_back
        unless cfg.id
            @id_ = "" -- resources::tunnels->next_unique_id()
        else
            @id_ = tostring cfg.id
            if @reversed_ -- Differentiate the reverse tunnel from the forward one
                @id_ ..= reversed_suffix
        -- cfg_; // unexpanded contents of a [tunnel] tag
        -- bool reversed_;     // Whether the tunnel's direction is reversed
        -- string id_;     // unique id of the group


    ----
    -- Constructs the object from a saved file.
    -- @param cfg    the contents of a [tunnel] tag
    -- This constructor is *only* meant for loading from saves
    -- teleport_group::teleport_group(const config& cfg) : cfg_(cfg), reversed_(cfg["reversed"].to_bool(false)), id_(cfg["id"])
    --     assert(cfg.has_attribute("id"));
    --     assert(cfg.has_attribute("reversed"));
    --     assert(cfg_.child_count("source") == 1);
    --     assert(cfg_.child_count("target") == 1);
    --     assert(cfg_.child_count("filter") == 1);


    ----
    -- Fills the argument loc_pair if the unit u matches the groups filter.
    -- @param loc_pair        returned teleport_pair if the unit matches
    -- @param Unit unit       this unit must match the group's filter
    -- @param ignore_units    don't consider zoc and blocking when calculating the shorted path between
    -- void get_teleport_pair(
    --               teleport_pair& loc_pair
    --             , const unit& u
    --             , const bool ignore_units) const;
    get_teleport_pair: (loc_pair, unit, ignore_units) =>
        -- const filter_context * fc = resources::filter_con;
        -- assert(fc);
        -- if ignore_units
        --     fc = new ignore_units_filter_context(*resources::filter_con);

        filter = @cfg_.filter -- vconfig filter(cfg_.child_or_empty("filter"), true);
        source = @cfg_.source -- vconfig source(cfg_.child_or_empty("source"), true);
        target = @cfg_.target -- vconfig target(cfg_.child_or_empty("target"), true);

        -- const unit_filter ufilt(filter, resources::filter_con);
        -- Note: Don't use the ignore units filter context here, only for the terrain filters.
        -- (That's how it worked before the filter contexts were introduced)

        if unit\matches(filter) -- if (ufilt.matches(u))
            source_locs = get_locations(source) -- source_filter.get_locations(reversed_ ? loc_pair.second : loc_pair.first,  u);
            target_locs = get_locations(target) -- target_filter.get_locations(reversed_ ? loc_pair.first  : loc_pair.second, u);
            loc_pair[1] = if @reversed_ then target_locs else source_locs
            loc_pair[2] = if @reversed_ then source_locs else target_locs


    ----
    -- Can be set by the id attribute or is randomly chosen.
    -- @return unique id of the teleport group
    -- const std::string& get_teleport_id() const;
    get_teleport_id: =>
        return @id_


    ----
    -- Returns whether the group should always be visible,
    -- even for enemy movement under shroud.
    -- @return bool visibility of the teleport group
    always_visible: =>
        return @cfg_.always_visible or false


    ----
    -- @return bool Returns whether allied units on the exit hex can be passed.
    pass_allied_units: =>
        return @cfg_.pass_allied_units or true


    ----
    -- Returns whether vision through tunnels is possible.
    -- bool allow_vision() const;
    -- bool teleport_group::allow_vision() const {
    allow_vision: =>
        return @cfg_.allow_vision or true


    ----
    -- Inherited from savegame_config.
    -- config to_config() const;
    -- config teleport_group::to_config() const {
    --     config retval = cfg_;
    --     retval["saved"] = "yes";
    --     retval["reversed"] = reversed_ ? "yes" : "no";
    --     retval["id"] = id_;
    --     return retval;
    -- }
