----
-- Copyright (C) 2003 - 2018 by David White <dave@whitevine.net>
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

Set = require'shared.Set'
t_translation = require"wesnoth.terrain.translation"


class Terrain_Type

    ----
    -- @todo
    -- terrain_type()
    -- terrain_type(config& cfg)
    -- terrain_type(terrain_type& base, terrain_type& overlay)
    -- @param first
    -- @param second
    new: (first, second) =>
        unless first
            from_void(@)
            return
        unless second
            from_config(@, first)
            return
        from_base_and_overlay(@, first, second)

    -- const t_string& editor_name() const
    -- { return editor_name_.empty() ? description() : editor_name_; }
    -- const t_string& description() const
    -- { return description_.empty() ? name_ : description_; }
    -- const t_string& help_topic_text() const
    -- { return help_topic_text_; }

    -- int unit_height_adjust() const { return height_adjust_; }
    -- double unit_submerge() const { return submerge_; }
    -- int gives_healing() const { return heals_; }

    -- bool is_village()  const { return village_; }
    -- bool is_castle()   const { return castle_; }
    -- bool is_keep()     const { return keep_; }
    -- bool is_overlay()  const { return overlay_; }
    -- bool is_combined() const { return combined_; }

    -- these descriptions are shown for the terrain in the mouse over
    -- depending on the owner or the village

    -- const std::string& editor_group() const { return editor_group_; }
    -- void set_editor_group(const std::string& str)
    -- { editor_group_ = str; }
    -- t_translation::terrain_code default_base() const
    -- { return editor_default_base_; }


    ----
    -- @return bool
    is_nonnull: () =>
        return (@number != t_translation.NONE_TERRAIN) and
            (@number != t_translation.VOID_TERRAIN )


    ----
    -- Returns the light (lawful) bonus for this terrain
    -- when the time of day gives a @a base bonus.
    -- @return int base
    light_bonus: (base) =>
        return bounded_add(base, @light_modification, @max_light, @min_light)


    -- t_translation::terrain_code terrain_with_default_base() const;



-- private:

--     /** The image used as symbol icon */
--     std::string icon_image_;

--     /** The image used in the minimap */
--     std::string minimap_image_;
--     std::string minimap_image_overlay_;

--     /**
--      *  The image used in the editor palette if not defined in
        -- WML it will be
--      *  initialized with the value of minimap_image_
--      */
--     std::string editor_image_;
--     std::string id_;
--     t_string name_;
--     t_string editor_name_;
--     t_string description_;
--     t_string help_topic_text_;

--     //the 'number' is the number that represents this
--     //terrain type. The 'type' is a list of the 'underlying types'
--     //of the terrain. This may simply be the same as the number.
--     //This is the internal number used, WML still uses character strings.
--     t_translation::terrain_code number_;
--     t_translation::ter_list mvt_type_;
--     t_translation::ter_list vision_type_;
--     t_translation::ter_list def_type_;
--     t_translation::ter_list union_type_;

--     int height_adjust_;
--     bool height_adjust_set_;

--     double submerge_;
--     bool submerge_set_;

--     int light_modification_;
--     int max_light_;
--     int min_light_;
--     int heals_;

--     t_string income_description_;
--     t_string income_description_ally_;
--     t_string income_description_enemy_;
--     t_string income_description_own_;

--     std::string editor_group_;

--     bool village_, castle_, keep_;

--     bool overlay_, combined_;
--     t_translation::terrain_code editor_default_base_;
--     bool hide_help_, hide_in_editor_, hide_if_impassable_;
-- };

-- *******************************************************************

    ----
    --
    from_void = =>
        -- minimap_image_(),
        -- minimap_image_overlay_(),
        -- editor_image_(),
        -- id_(),
        -- name_(),
        -- editor_name_(),
        -- description_(),
        -- help_topic_text_(),
        -- income_description_(),
        -- income_description_ally_(),
        -- income_description_enemy_(),
        -- income_description_own_(),
        -- editor_group_(),
        @number      = t_translation.VOID_TERRAIN
        @mvt_type    = {t_translation.VOID_TERRAIN}
        @vision_type = {t_translation.VOID_TERRAIN}
        @def_type    = {t_translation.VOID_TERRAIN}
        @union_type  = {t_translation.VOID_TERRAIN}
        @height_adjust = 0
        @height_adjust_set = false
        @submerge = 0.0
        @submerge_set = false
        @light_modification = 0
        @max_light = 0
        @min_light = 0
        @heals = 0
        @village  = false
        @castle   = false
        @keep     = false
        @overlay  = false
        @combined = false
        @editor_default_base = t_translation.VOID_TERRAIN
        @hide_help = false
        @hide_in_editor = false
        @hide_if_impassable = false


    ----
    -- @todo
    -- @param cfg
    from_config = (cfg) =>

        @combined = false

        for key, value in pairs cfg
            @[key] = value

        @minimap_image = cfg.symbol_image

        -- @todo enable translation
        -- name_(cfg["name"].t_str()),
        -- description_(cfg["description"].t_str()),
        -- editor_name_(cfg["editor_name"].t_str()),

        -- village_(cfg["gives_income"].to_bool()),
        -- hide_help_(cfg["hide_help"].to_bool(false)),
        -- hide_if_impassable_(cfg["hide_if_impassable"].to_bool(false))
        -- hide_in_editor_(cfg["hidden"].to_bool(false)),

        -- submerge_(cfg["submerge"].to_double()),

        -- @todo those have different names
        -- height_adjust_(cfg["unit_height_adjust"]),
        -- light_modification_(cfg["light"]),

        @mvt_type = {}
        -- vision_type_()
        -- def_type_()
        -- union_type_()

        -- income_description_()
        -- income_description_ally_()
        -- income_description_enemy_()
        -- income_description_own_()

        -- @minimap_image_overlay = ""

        -- editor_image_(cfg["editor_image"].empty() ? "terrain/" +
        --     minimap_image_ + ".png" : "terrain/" +
        --     cfg["editor_image"].str() + ".png"),
        -- help_topic_text_(cfg["help_topic_text"].t_str())

        assert(cfg.string,  "no 'string' in Terrain_Type")
        -- print cfg.string or "no string found"
        -- @number = t_translation.read_terrain_code(cfg["string"])
        @number = t_translation.read_terrain_code(cfg.string)

        -- height_adjust_set_(!cfg["unit_height_adjust"].empty()),
        -- submerge_set_(!cfg["submerge"].empty()),
        -- max_light_(cfg["max_light"].to_int(light_modification_)),
        -- min_light_(cfg["min_light"].to_int(light_modification_)),
        -- editor_group_(cfg["editor_group"]),

        -- castle_(cfg["recruit_onto"].to_bool()),
        -- keep_(cfg["recruit_from"].to_bool()),

        -- @overlay = @number.base == t_translation.NO_LAYER
        -- @editor_default_base = t_translation.read_terrain_code(
        --     cfg["default_base"])

        ----
        -- @todo reenable these validations.
        -- The problem is that all MP scenarios/campaigns
        -- share the same namespace and one rogue scenario
        -- can avoid the player to create a MP game.
        -- So every scenario/campaign should
        -- get its own namespace to be safe.
        -- if false
        --     VALIDATE(number_ != t_translation.NONE_TERRAIN,
        --         missing_mandatory_wml_key("terrain_type", "string"))
        --     VALIDATE(not minimap_image_.empty(),
        --         missing_mandatory_wml_key("terrain_type", "symbol_image",
        --         "string", t_translation.write_terrain_code(number_)))
        --     VALIDATE(not name_.empty(),
        --         missing_mandatory_wml_key("terrain_type", "name",
        --         "string", t_translation.write_terrain_code(number_)))

        -- unless @editor_image
            -- @editor_image = "terrain/" .. @minimap_image .. ".png"

        -- if @hide_in_editor
            -- @editor_image = ""

        table.insert(@mvt_type, @string)
        -- table.insert(@def_type, @number)
        -- table.insert(@vision_type, @number)

        -- @todo
        -- const t_translation::ter_list&
        -- alias = t_translation.read_list(cfg["aliasof"])
        alias = cfg.aliasof
        if alias
            @mvt_type     = alias
        --     @vision_type  = alias
        --     @def_type     = alias

        -- const t_translation::ter_list&
        -- mvt_alias = t_translation.read_list(cfg["mvt_alias"])
        -- @mvt_type = mvt_alias if mvt_alias

        -- const t_translation::ter_list&
        -- def_alias = t_translation.read_list(cfg["def_alias"])
        -- @def_type = def_alias if def_alias

        -- const t_translation::ter_list&
        -- vision_alias = t_translation.read_list(cfg["vision_alias"])
        -- @vision_type = vision_alias if vision_alias

        -- @union_type = {}

        -- for type in *@mvt_type
        --     table.insert(@union_type, type)
        -- for type in *@def_type
        --     table.insert(@union_type, type)
        -- for type in *@vision_type
        --     table.insert(@union_type, type)

        -- remove + and -
        -- union_type_.erase(std::remove(union_type_.begin(),
        --     union_type_.end(), t_translation::MINUS), union_type_.end());

        -- union_type_.erase(std::remove(union_type_.begin(),
        --     union_type_.end(), t_translation::PLUS), union_type_.end());

        -- remove doubles
        -- std::sort(union_type_.begin(),union_type_.end());
        -- union_type_.erase(std::unique(union_type_.begin(),
        --     union_type_.end()), union_type_.end());

        -- mouse over message are only shown on villages
        if @village
            @income_description = cfg["income_description"]
            unless @income_description
                -- @todo
                -- @income_description = _("Village")
                @income_description = "Village"

            @income_description_ally = cfg["income_description_ally"]
            unless @income_description_ally
                -- @todo
                -- @income_description_ally = _("Allied village")
                @income_description_ally = "Allied village"

            @income_description_enemy = cfg["income_description_enemy"]
            unless @income_description_enemy
                -- @todo
                -- @income_description_enemy = _("Enemy village")
                @income_description_enemy = "Enemy village"

            @income_description_own = cfg["income_description_own"]
            unless @income_description_own
                -- @todo
                -- @income_description_own = _("Owned village")
                @income_description_own = "Owned village"


    ----
    -- @todo
    -- @tparam terrain_type base
    -- @tparam terrain_type overlay
    from_base_and_overlay = (base, overlay) =>
        -- icon_image_(),
        -- help_topic_text_(),
        -- union_type_(),
        -- income_description_(),
        -- income_description_ally_(),
        -- income_description_enemy_(),
        -- income_description_own_(),
        -- editor_group_(),
        -- editor_default_base_(),

        @minimap_image_overlay = overlay.minimap_image
        @minimap_image = base.minimap_image
        @editor_image  = base.editor_image + "~BLIT(" +
            overlay.editor_image + ")"

        @id = base.id .. "^" .. overlay.id
        @name = overlay.name
        @editor_name = (unless base.editor_name then base.name
        else base.editor_name) .. " / " .. (unless overlay.editor_name
            overlay.name else overlay.editor_name)

        @description = overlay.description() or base.description()
        -- @todo explain the next line
        @number = (t_translation.Terrain_Code(base.number.base,
            overlay.number.overlay))
        @mvt_type    = overlay.mvt_type
        @vision_type = overlay.vision_type
        @def_type    = overlay.def_type
        @height_adjust     = base.height_adjust
        @height_adjust_set = base.height_adjust_set
        @submerge     = base.submerge
        @submerge_set = base.submerge_set
        @light_modification = base.light_modification +
            overlay.light_modification
        @max_light = math.max(base.max_light, overlay.max_light)
        @min_light = math.min(base.min_light, overlay.min_light)
        @heals     = math.max(base.heals, overlay.heals)
        @village   = base.village or overlay.village
        @castle    = base.castle  or overlay.castle
        @keep      = base.keep    or overlay.keep
        @overlay   = false
        @combined  = true
        @hide_help = base.hide_help or overlay.hide_help
        @hide_in_editor     = base.hide_in_editor or overlay.hide_in_editor
        @hide_if_impassable = base.hide_if_impassable or
            overlay.hide_if_impassable

        if overlay.height_adjust_set
            @height_adjust_set = true
            @height_adjust = overlay.height_adjust

        if overlay.submerge_set
            @submerge_set = true
            @submerge = overlay.submerge

        merge_alias_lists(@mvt_type,    base.mvt_type)
        merge_alias_lists(@def_type,    base.def_type)
        merge_alias_lists(@vision_type, base.vision_type)

        -- @todo this causes a copy in c++?
        @union_type = @mvt_type
        -- @todo
        -- @union_type.insert( union_type_.end(), def_type_.begin(),
            -- def_type_.end() );
        -- union_type_.insert( union_type_.end(), vision_type_.begin(),
            -- vision_type_.end() );

        -- remove + and -
        -- @union_type.erase(std::remove(@union_type.begin(), @union_type.end(),
                    -- t_translation.MINUS), union_type_.end());

        -- @union_type.erase(std::remove(union_type_.begin(), union_type_.end(),
                    -- t_translation.PLUS), union_type_.end());

        -- remove doubles
        -- std::sort(union_type_.begin(),union_type_.end());
        -- union_type_.erase(std::unique(union_type_.begin(), union_type_.end()), union_type_.end());

        -- mouse over message are only shown on villages
        if base.village
            @income_description       = base.income_description
            @income_description_ally  = base.income_description_ally
            @income_description_enemy = base.income_description_enemy
            @income_description_own   = base.income_description_own
        elseif overlay.village
            @income_description       = overlay.income_description
            @income_description_ally  = overlay.income_description_ally
            @income_description_enemy = overlay.income_description_enemy
            @income_description_own   = overlay.income_description_own


    ----
    -- t_translation::terrain_code
    -- terrain_type::terrain_with_default_base() const {
    terrain_with_default_base: =>
        if @overlay and @editor_default_base != t_translation.NONE_TERRAIN
            return t_translation.terrain_code(
                @editor_default_base.base, @number.overlay)
        return @number


    ----
    -- @return bool
    -- terrain_type::operator==(const terrain_type& other) const {
    _eq: (other) =>
        return @minimap_image       == other.minimap_image and
            @minimap_image_overlay  == other.minimap_image_overlay and
            @editor_image           == other.editor_image and
            @id                     == other.id and
            -- @name.base_str()        == other.name_.base_str() and
            -- @editor_name.base_str() == other.editor_name_.base_str() and
            @name                   == other.name and
            @editor_name            == other.editor_name and
            @number                 == other.number and
            @height_adjust          == other.height_adjust and
            @height_adjust_set      == other.height_adjust_set and
            @submerge               == other.submerge and
            @submerge_set           == other.submerge_set and
            @light_modification     == other.light_modification and
            @max_light              == other.max_light and
            @min_light              == other.min_light and
            @heals                  == other.heals and
            @village                == other.village and
            @castle                 == other.castle and
            @keep                   == other.keep and
            @editor_default_base    == other.editor_default_base and
            @hide_in_editor         == other.hide_in_editor and
            @hide_help              == other.hide_help


    ----
    -- @todo
    -- @param first
    -- @param second
    -- void merge_alias_lists(t_translation::ter_list& first, const t_translation::ter_list& second)
    merge_alias_lists = (first, second) ->
        -- Insert second vector into first when
        -- the terrain _ref^base is encountered
        revert = if first.front! == t_translation.MINUS then true else false
        -- t_translation::ter_list::iterator i;

        for i in *first
            if i == t_translation.PLUS
                revert = false
                continue
            elseif i == t_translation.MINUS
                revert = true
                continue

            if i == t_translation.BASE
                -- t_translation::ter_list::iterator insert_it = first.erase(i);
                insert_it = table.remove(i)
                -- if we are in reverse mode,
                -- insert PLUS before and MINUS after the base list
                -- so calculation of base aliases will work normal
                if revert
                    -- // insert_it = first.insert(insert_it, t_translation::PLUS)
                    -- // insert_it++;
                    -- insert_it = first.insert(insert_it, t_translation::MINUS);
                    table.insert(insert_it, t_translation.MINUS)
                else
                    -- else insert PLUS after the base aliases
                    -- to restore previous "reverse state"
                    -- insert_it =  first.insert(insert_it, t_translation::PLUS);
                    table.insert(insert_it, t_translation.PLUS)

                -- first.insert(insert_it, second.begin(), second.end());
                table.insert(first)
                break


return Terrain_Type
