----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

---
-- @submodule wesnoth


-- @todo get rid of those two
love = love
get  = require"filesystem"

log = (require"utils.log")"controller"

dir = (...)\match"(.-)[^%.]+$"
import show_story from require"#{dir}.interface"
import fire_event, add_event_handler from require"#{dir}.actions"
import load_map    from require"#{dir}.map"
import wrapInArray from require"#{dir}.misc"
import put_unit    from require"#{dir}.units"
import get_starting_location from require"#{dir}.sides"

UnitMap = require"utils.unit_map"

include = require"shared.include"
table_merge = require"utils.table_merge"

Terrain_Type_Data = require"wesnoth.terrain.Terrain_Type_Data"

env = {}
---
--
read_data_tree = () =>
    collectgarbage!
    mem_before = collectgarbage"count"

    with env
        ._ = (str) -> return str
        .wsl_action = (cfg) ->
            @Data.Action[cfg.id] = cfg

        .Movetype = (cfg) ->
            @Data.Movetype[cfg.name] = cfg
        .Race = (cfg) ->
            @Data.Race[cfg.id] = cfg
        .Credits_Group = ->
        .Lua = ->
        .Unit_Type = (cfg) ->
            -- @todo comment
            cfg.max_moves = cfg.movement
            cfg.movement = nil
            @Data.Unit_Type[cfg.id] = cfg
        .Terrain_Type = (cfg) ->
            @Data.Terrain_Type[cfg.id] = cfg
        .Scenario = (cfg) ->
            @Data.Scenario[cfg.id] = cfg
        .Tip = (cfg) ->
            table.insert(@Data.Tip, cfg)

        .Color_Range = (cfg) ->
            res =
                id:   cfg.id
                name: cfg.name
                min:  cfg.rgb[3]
                mid:  cfg.rgb[1]
                max:  cfg.rgb[2]
                rep:  cfg.rgb[4]
            @Data.Color_Range[cfg.id] = res
        .Color_Palette = (cfg) ->
            @Data.Color_Palette = cfg

        .Game_Config = (cfg) ->
            for key, value in pairs cfg
                @Data.Game_Config[key] = value
        .Textdomain = ->
        .Campaign = (cfg) ->
            @Data.Campaign[cfg.id] = cfg
        .Multiplayer_Side = ->
        .Binary_Path = (cfg) ->
            table.insert(@Data.Binary_Path, cfg)
        .INCLUDE = (path) -> include(path, env)

        ._ = (str) -> str
        ._merge_ = table_merge

        .tostring = tostring

    include(env)
    collectgarbage!
    log.info"Data Memory usage: #{collectgarbage"count" - mem_before}"


----
-- Setups a scenario's assets to be ready to start
-- @param id of the scenario to load
-- @return if scenario was succesfully loaded.
load_scenario = (id) =>

    @terrains = Terrain_Type_Data(@Data.Terrain_Type)
    assert(@terrains)

    -- find the scenario matching the id
    @scenario = @Data.Scenario[id]
    return false unless @scenario

    -- Let's load the map.
    if map_file = @scenario.map
        -- @todo get rid of the love and get dependency
        map_str = love.filesystem.read(get.data(map_file))
        load_map(@, map_str, @scenario.border_size)
    -- support inline maps.
    elseif map_data = @scenario.map_data
        load_map(@, map_data, @scenario.border_size)

    -- unit map setup
    width = @board.map.width
    assert width > 0
    height = @board.map.height
    assert height > 0
    @board.units = UnitMap(width, height)

    -- setup sides before the map, to store starting_locations. ???
    sides = wrapInArray(@scenario.side)
    sides = @scenario.side

    for i, side in ipairs sides
        @board.sides[i] = side
        unless side.gold
            @board.sides[i].gold = 0
        loc = get_starting_location(@, side.side)

        if side.type
            put_unit(self, side, loc.x, loc.y)
        if unit = side.unit
            units = wrapInArray(unit)
            for u in *units
                u.side = i
                put_unit(@, u)

    -- experience_modifier = @scenario.experience_modifier or 100
    -- turn_limit = @scenario.turns or -1

    -- time of day
    if time = @scenario.time
        @board.time_of_day = time

    ENV = {
        wesnoth: (require"wesnoth").wesnoth

        :print
        :assert
        :tostring
        _: (str) -> return str
    }
    for key, thing in pairs env
        char = key\sub(1,1)
        unless char\match("%u")
            continue
        if type(thing) == "function"
            setfenv(thing, @current.event_context)

            ENV[key] = thing
            @current.event_context[key] = thing

    @current.event_context["_"] = (str)-> return str

    for key, action in pairs @Data.Action
        log.debug("adding #{key}")
        setfenv(action.action, ENV)

        @current.event_context[key] = action.action

    -- setup the toplevel events
    log.info"adding event handlers"
    for key, events in pairs @scenario
        char = key\sub(1,1)
        unless char\match("%u")
            continue
        events = wrapInArray(events)
        for event in *events
            switch type(event)
                when "table"
                    event.name = key
                    add_event_handler(@, event)
                when "function"
                    add_event_handler(@, {
                        name: key
                        command: event
                    })
    for event in *@scenario.event
        add_event_handler(@, event)

    log.info"scenario load complete"

----
-- Start the scenario that has been loaded before or fail.
start_scenario = () =>
    assert(@scenario, "No scenario loaded.")
    if story = @scenario.story
        default_title = @scenario.name
        show_story(@, story, default_title)

    -- should be fired every time a scenario got reloaded
    fire_event(@, "preload")
    -- before anything is on the screen
    fire_event(@, "prestart")
    fire_event(@, "start")
    --- @todo the check for end level is needed for story only scenarios.
    -- unless check_end_level!
    --     fire_event(@, "pre new turn")
    fire_event(@, "pre new turn")


----
-- Reloads the data tree with the specified campaign's define set
load_campaign = (id) =>
    @campaign = @Data.Campaign[id]
    env[@campaign.define] = true
    if extra_defines = @campaign.extra_defines
        for extra in extra_defines
            env[extra] = true
    read_data_tree(@)

    load_scenario(@, @campaign.first_scenario)


----
-- @return the gameBoard
gameBoard = () =>
    return @board


{
    :read_data_tree
    :load_campaign
    :load_scenario
    :start_scenario
    :gameBoard
}
