----
-- A unit
-- @classmod Unit

-- moon = require "moon"
Set = require "pl.Set"
Loc = require "Location"
HasGetters = require "HasGetters"
dir = (...)\match"(.-)[^%.]+$"
-- UnitMap = require "#{dir}.unit_map"

import wrapInArray from require "#{dir}.misc"
-- import try, wrapInArray from require "server.wesnoth.misc"
-- import wsl_error        from require "server.wesnoth.actions"
-- import board            from require "server.wesnoth.map"
-- unit_types = Data.Unit_Type
Movetype = require"#{dir}Movetype"


----
-- @table this
-- @tfield number hitpoints
-- @tfield number advances_to
-- @tfield number alignment
-- @tfield number alpha
-- @tfield number attacks_left
-- @tfield bool can_recruit
-- @tfield number cost
-- @tfield number experience
-- @tfield number facing
-- @tfield number flying
-- @tfield number gender
-- @tfield number goto_x
-- @tfield number goto_y
-- @tfield number hitpoints
-- @tfield string id
-- @tfield tstring language_name (same as the name key in the unit config)
-- @tfield number max_experience
-- @tfield number max_hitpoints
-- @tfield number max_moves
-- @tfield number moves
-- @tfield number overlays
-- @tfield number resting
-- @tfield number side
-- @tfield string type
-- @tfield tstring unit_description
-- @tfield bool unrenamable
-- @tfield number upkeep
-- @tfield number x
-- @tfield number y
-- @tfield number zoc
-- @tfield tab movement_costs
-- @tfield number movement_costs.arsch
-- @tfield number movement_costs.pimmel
-- @tfield number [defense]
-- @tfield number [resistance]
-- @tfield number [variables]
-- @tfield tab status
-- @tfield bool status.poisoned
-- @tfield bool status.slowed
-- @tfield bool status.petrified
-- @tfield bool status.uncovered
-- @tfield bool status.guardian
-- @tfield bool status.unhealable
-- @tfield {tab,...} attack
-- @tfield tstring attack.description a translatable text for name of the attack, to be displayed to the user.
-- @tfield string attack.name the name of the attack. Used as a default description, if description is not present, and to determine the default icon, if icon is not present (if name=x then icon=attacks/x.png is assumed unless present). Non-translatable. Used for the has_weapon key and animation filters; see StandardUnitFilter and AnimationWSL
-- @tfield string attack.type the damage type of the attack. Used in determining resistance to this attack (see [resistance]).
-- @tfield tab attack.specials contains the specials of the attack. See AbilitiesWSL.
-- @tfield string attack.icon the image to use as an icon for the attack in the attack choice menu, as a path relative to the images directory.
-- @tfield string attack.range the range of the attack. Used to determine the enemy's retaliation, which will be of the same type. Also displayed on the status table in parentheses; 'melee'(default) displays "melee", while 'ranged' displays "ranged". Range can be anything. Standard values are now "melee" and "ranged". From now on, short and long will be treated as totally different ranges. You can create any number of ranges now (with any name), and units can only retaliate against attacks for which they have a corresponding attack of the same range. This value is translatable.
-- @tfield number attack.damage the damage of this attack
-- @tfield number attack.number the number of strikes per attack this weapon has
-- @tfield number attack.accuracy a number added to the chance to hit whenever using this weapon offensively; negative values work too
-- @tfield number attack.parry a number deducted from the enemy chance to hit whenever using this weapon offensively; negative values work too
-- @tfield number attack.movement_used determines how many movement points using this attack expends. By default all movement is used up, set this to 0 to make attacking with this attack expend no movement.
-- @tfield number attack.attack_weight helps the AI to choose which attack to use when attacking; highly weighted attacks are more likely to be used. Setting it to 0 disables the attack on attack
-- @tfield number attack.defense_weight used to determine which attack is used for retaliation. This affects gameplay, as the player is not allowed to determine his unit's retaliation weapon. Setting it to 0 disable the attacks on defense
-- @tfield tab modifications_description
-- @tfield {tab,...} modifications
-- @tfield {tab,...} modifications.trait a trait the unit has. Same format as [trait], UnitsWSL.
-- @tfield {tab,...} modifications.object an object the unit has. Same format as [object], DirectActionsWSL.
-- @tfield {tab,...} modifications.advance an advancement the unit has. Same format as [advancement], UnitTypeWSL. Might be used if the unit type has some advancements, but this particular one is supposed to have some of them already taken. (Version 1.13.2 and later only) In 1.13.2 and later this has been renamed to [advancement], to match the UnitTypeWSL tag of the same name.


----
-- Unit
class Unit extends HasGetters

    @count: 0

    getters: (key) =>
        -- print key
        switch key
            when "x"
                if loc = @unit_map\get_loc(@id)
                    return loc.x
            when "y"
                if loc = @unit_map\get_loc(@id)
                    return loc.y
            when "loc"
                -- @todo handle offmap units?
                return @unit_map\get_loc(@id)
            else
                return @unit_types[@type][key]


    generate_id = (cfg, internal_id) ->
        return "#{cfg.type}-#{internal_id}"


    generate_name = (cfg) ->
        return "Hans-Franz"


    ----
    -- Constructor
    -- @param self
    -- @param unit_map
    -- @param unit_types
    -- @param cfg
    new: (unit_map, unit_types, terrain_types, move_types, cfg) =>

        assert(unit_map,
            "Unit Constructor: Missing 'unit_map' argument.")
        assert(unit_types,
            "Unit Constructor: Missing 'unit_types' argument")
        assert(terrain_types,
            "Unit Constructor: Missing 'terrain_types' argument")
        assert(cfg,
            "Unit Constructor: Missing 'cfg' argument.")
        @unit_map   = unit_map
        @unit_types = unit_types
        @__cfg      = cfg

        error("Unit without type.") unless cfg.type
        @type = cfg.type
        unit_type = unit_types[@type]
        unless unit_type
            error("Unit Type '#{@type}' is unknown.")

        @@count += 1
        @internal_id = @@count

        @id   = cfg.id or generate_id(cfg, @internal_id)
        @name = cfg.name or generate_name(cfg)
        @side = cfg.side or 1

        @max_hitpoints = cfg.max_hitpoints or unit_type.hitpoints
        @hitpoints     = cfg.hitpoints or @max_hitpoints

        @max_experience = (cfg.max_experience or unit_type.experience) *
            (cfg.experience_modifier or 100) / 100
        @experience = cfg.experience or 0

        -- assert(unit_type, 'unit constructor: no unit_type')
        -- moon.p(unit_type)
        -- assert(unit_type.movement,
        --     "unit constructor: no unit_type.movement")

        @moves     = cfg.movement or unit_type.max_moves
        @max_moves = cfg.movement or unit_type.max_moves
        assert(@moves, 'unit constructor: no self.moves')
        assert(@max_moves, 'unit constructor: no self.max_moves')

        @canrecruit = cfg.canrecruit or cfg.can_recruit
        @can_recruit = cfg.canrecruit or cfg.can_recruit

        -- @todo what about movement_type in unit cfg?
        move_type = unit_type.movement_type
        -- print move_type
        -- assert(false)

        -- @todo merge in modifications from unit cfg
        move_cfg  = move_types[move_type]
        -- moon.p move_types
        assert(move_cfg, "no config for #{move_type}")
        assert(terrain_types)
        @movement_type_ = Movetype(move_cfg, terrain_types)
        assert(@movement_type_)

        @states = {}


    ----
    --
    --
    state: (state_id) =>
        -- @todo
        return @states[state_id]


    ----
    -- Prints the table containing all the unit's data
    -- @param self
    debug: =>
        -- require"moon".p(@)


    ----
    -- Get the defense propability value
    -- @param self
    -- @param terrain optional terrain
    -- @return propability of defense on @terrain
    defense: (terrain) =>
        -- log.warn("Not implemented yet")


    ----
    -- Get the movement cost
    -- @param self
    -- @param terrain optional terrain
    -- @return movement costs on @terrain
    movement: (terrain) =>
        -- @todo
        -- assert(false, "im movement")
        -- return @movement_type.movement_cost(terrain,
        --     @get_state("STATE_SLOWED"))
        -- moon.p(@movement_type)
        return 1
        -- return @movement_type_\movement_cost(terrain)


    ----
    -- Return the terrain the unit is currenty on
    -- @param self
    terrain: =>
        -- log.warn("Not implemented yet")


    ----
    -- Returns true if the given unit matches the WSL filter passed as the second argument. If other_unit is specified, it is used for the $other_unit auto-stored variable in the filter. Otherwise, this variable is not stored for the filter.
    -- @tparam Unit self
    -- @tparam StandardUnitFilter|func filter
    -- @tparam[opt] Unit other_unit
    -- @treturn bool iff this unit matches the filter
    -- @usage assert(unit.canrecruit ==
    --        wesnoth.match_unit(unit, { can_recruit: true }))
    matches: (filter, other_unit) =>
        assert(filter, "Unit.matches: missing filter argument.")
        assert(type(filter) == "function" or type(filter) == "table")
        return filter(@, other_unit) if type(filter) == "function"

        -- return true if next(filter) == nil -- empty filter matches every unit

        -- if or_filter = filter["or"]
        --     return true if @filter(or_filter)

        -- if and_filter = filter["and"]
        --     return false unless @filter(and_filter)

        -- if not_filter = filter["not"]
        --     return false if @filter(not_filter)

        -- if loc = Loc(filter)
        --     return false unless loc.x == @x
        --     return false unless loc.y == @y


        -- @todo log.warn("filtering the unit with the id: #{@.id}")

---------------special ones----------------
    -- defense: current defense of the unit on current tile
    -- (chance to hit %, like in movement type definitions)
        -- if filter.defense
        --     return false if Set(filter.defense)[@defense!]
        -- if filter.movement_cost
        --     return false if Set(filter.movement_cost)[@movement_cost!]
    --find_in: name of an array or container variable; if present, the unit will not match unless it is also found stored in the variable
        -- items = { id: true, speaker: true, type: true }
        if id = filter.id
            return @id == id
            -- ids = wrapInArray(id)
            -- return false unless Set(ids)[@id]
        -- if speaker = filter.speaker
        --     return false unless Set(speaker)[@id]
        -- if type = filter.type
        --     return false unless Set(filter.type)[@type]
        -- TODO implement table filter
        return true


    ----
    -- Places a unit on the map. This unit is described either by a WSL table or by a proxy unit. Coordinates can be passed as the first two arguments, otherwise the table is expected to have two fields x and y, which indicate where the unit will be placed. If the function is called with coordinates only, the unit on the map at the given coordinates is removed instead. (Version 1.13.2 and later only) This use is now deprecated; use wesnoth.erase_unit instead.
    -- @tparam Unit self
    -- @number[opt] x
    -- @number[opt] y
    -- @usage -- create a unit with random traits, then erase it
    -- wesmere.put_unit(17, 42, { type: "Elvish Lady" })
    -- wesmere.put_unit(17, 42)
    -- When the argument is a proxy unit, no duplicate is created. In particular, if the unit was private or on a recall list, it no longer is; and if the unit was on the map, it has been moved to the new location. Note: passing a WSL table is just a shortcut for calling #wesmere.create_unit and then putting the resulting unit on the map.
    -- -- move the leader back to the top-left corner
    -- wesmere.put_unit(1, 1, wesmere.get_units({ can_recruit: true })[1])
    to_map: (x, y) =>


    ----
    -- Erases the unit from the map.
    -- After calling this on a unit, the unit is no longer valid.
    -- @tparam Unit self
    erase: () =>


    ----
    -- Places a unit on a recall list. This unit is described either by a WSL table or by a proxy unit. The side of the recall list is given by the second argument, or by the side of the unit if missing.
    -- @tparam Unit self
    -- @number[opt] side the list is inserted into
    to_recall: (side) =>


    ----
    -- Advances the unit (and shows the advance unit dialog if needed) if the unit has enough xp. This function should be called after modifying the units experience directly. A similar function is called by wesmere internally after unit combat. The second argument is a boodean value that specifies whether the advancement should be animated. The third agrument is a boodean value that specifies whether advancement related events should be fired.
    -- @tparam Unit self
    -- @bool animate whether the advancement should be animated.
    -- @bool fire_events whether advancement related events should be fired.
    advance: (animate, fire_events) =>


    ----
    -- Modifies the unit.
    -- @tparam Unit self
    -- @string type the type of the modification (one of "trait", "object", or "advancement").
    -- @tab effects See EffectWSL for details about effects.
    -- @bool[opt] write_to_mods
    add_modification: (type, effects, write_to_mods) =>





    ----
    --
    -- @tparam Unit self
    -- @string terrain_code
    vision: (terrain_code) =>


    ----
    --
    -- @tparam Unit self
    -- @string terrain_code
    jamming: (terrain_code) =>


    ----
    --
    -- @tparam Unit self
    -- @tab ability_table
    ability: (ability_table) =>

    ----
    --
    -- @tparam Unit self
    -- @string to_type
    transform: (to_type) =>

    ----
    -- Returns the resistance of a unit against an attack type. (Note: it is a WSL resistance. So the higher it is, the weaker the unit is.) The third argument indicates whether the unit is the attacker. Last arguments are the coordinates of an optional map location (for the purpose of taking abilities into account).
    -- @tparam Unit self
    -- @string damage_type
    resistance: (damage_type) =>

    ----
    -- Returns the defense of a unit on a particular terrain. (Note: it is a WSL defense. So the higher it is, the weaker the unit is.)
    -- @tparam Unit self
    -- @string terrain_code
    defense: (terrain_code) =>

    ----
    -- Creates a private unit from another unit.
    -- @tparam Unit self
    -- @treturn Unit the clone
    clone: () =>

    ----
    -- Removes the unit from the map
    -- @tparam Unit self
    extract: () =>

    ----
    -- Returns the unit's id in string context
    -- @tparam Unit self
    -- @treturn string "id: <unit_id>"
    __tostring: =>
        return("id: " .. @id)

    ----
    -- Compare function
    -- @tparam Unit self
    -- @tparam Unit other
    __eq: (other) =>
        return @id == other.id


    client_info: () =>
        return {

        }

return Unit
