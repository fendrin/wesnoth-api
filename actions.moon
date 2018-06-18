----
-- @submodule wesmere

-- LuaWSL:Events
-- This page describes the LuaWSL functions and helpers for interacting with events and action handlers.

dir = (...)\match"(.-)[^%.]+$"

try = require"try"

-- import try, wsl_error from require "#{dir}.misc"
import get_unit from require "#{dir}.units"

import setfenv from require "pl.utils"

log = (require"log")"actions"
-- log =
--     error: error
--     trace: -> --print
--     debug: print
--     info: print

----
-- This is not a function but an associative table indexed by WSL action names. It contains functions performing the corresponding actions. Using these functions is similar to calling #wesmere.fire, while setting entries of the table is similar to calling #wesmere.register_wsl_action.
-- Note: When calling an action handler directly through its function stored in wesmere.wsl_actions, the engine is not involved. As a consequence, whether variable substitution will happen is up to the handler. In particular, if the argument is a plain table, the caller should have substituted WSL variables beforehand to be on the safe side. Moreover, table arguments might be modified by the action handler, so they should usually not be reused for consecutive calls. If variable substitution should happen and/or table content should be preserved, one can call #wesmere.tovconfig and pass its result to the handler. Calling #wesmere.fire is another possibility.
-- @table wesmere.wsl_actions
-- @usage wesmere.wsl_actions.freeze_unit = (cfg) ->
--     unit_id = cfg.id or helper.wsl_error "'freeze_unit' expects an id key."
--     helper.modify_unit({ id: unit_id }, { moves: 0 })
-- -- The new tag can now be used in plain WSL code:
-- freeze_unit
--     id: "Delfador"
-- @usage -- You can override functions already assigned to the table. This is useful if you need to extend functionality of core functions. For instance, the following script overrides the 'print' function so that messages are displayed with a bigger font.
-- wesmere.wsl_actions.print = (cfg) ->
--     cfg.size = (cfg.size or 12) + 10
--     wsl_actions.print(cfg)
-- wsl_actions = {}


----
-- Fires a WSL action.
-- @function wesmere.fire
-- @string wsl_action_name the name of the action.
-- @tab wsl_action_table the WSL table describing the action. Note: WSL variables are substituted.
-- @usage wesmere.fire("message", { speaker: "narrator", message: _ "Hello World!" })
-- @return the return value of the wsl action function
fire = (wsl_action_name, wsl_action_table) ->
    -- if action = wsl_actions[wsl_action_name]
    --     return wsl_actions[wsl_action_name](wsl_action_table)
    -- else error("WSLAction '#{wsl_action_name}' not known")

----
-- This is an associative table like wesmere.wsl_actions. You can use it to define new conditional wsl tags that will be recognized in WSL when using [if], [show_if], [while], etc., or more generally when wesmere.eval_conditional is run.
-- You cannot override the meaning of any core conditional tags.
-- @table wesmere.wsl_conditionals
-- @usage function wesmere.wsl_conditionals.foo(cfg)
--      bar = cfg.bar or error("[foo] tag did not have 'bar' attribute")
--      return (bar == "baz")
-- @usage If this MoonScript code is executed, it would make the following syntax be valid WSL in your add-on:
-- if wesmere.eval_conditional
--         foo:
--             bar: X
--     message
--         ...
-- wsl_conditionals = {}

----
-- This is not a function but an associative table indexed by engine action names. It contains function hooks the engine calls whenever it performs a particular action.
-- The on_save and on_load hooks can be used to manipulate data that are neither meant to be forwarded to the next level nor substituted on the fly. (For either of these two purposes, WSL variables are the best choice.) For instance, toplevel tags like [item], [event], [time_area], and so on, could typically be handled by such hooks.
-- @table wesmere.game_events
-- @func on_save: function called when the engine (auto)saves a scenario file; it should return a WSL table and the children of this table are added to the savefile.
-- @func on_load: function called when the engine loads a scenario file; its argument is a WSL table that contains all the children of the savefile that the engine did not handle.
-- @func on_event: function called before each WSL event is executed; its argument is the event name; other event arguments can be recovered from wesmere.current.event_context.
-- some value that survives save/load cycles, but that is not forwarded to the next level
-- @usage level_local_data = 0
-- old_on_load = wesmere.game_event.on_load
-- wesmere.game_event.on_load = (cfg) ->
--     for i = 1,#cfg
--         if cfg[i][1] == "my_data"
--             -- recover the value stored in the savefile
--             level_local_data = cfg[i][2].value
--             -- erase the child, since it has been handled
--             table.remove(cfg, i)
--             break
--     -- call the previous hook, in case there are still some containers in the savefile
--     old_on_load(cfg)
-- old_on_save = wesmere.game_events.on_save
-- wesmere.game_events.on_save = () ->
--     -- call the previous hook, in case it had some containers to store
--     cfg = old_on_save!
--     -- add our own container to them
--     table.insert(cfg, { "my_data", { value: level_local_data } })
--     -- tell the engine to store them in the savefile
--     return cfg
-- Note: since the on_load hook is called very early in the scenario, it cannot be set inside a [lua] tag in an [event], not even a preload one. It has to be set inside a [lua] tag outside or at [scenario] level.
-- Note: Some tag names are reserved for engine use and should not be modified using the above on_save/on_load method. These tag names are:
-- "color_palette", "color_range", "era", "event", "generator",
-- "label", "lua", "menu_item", "music", "side", "sound_source", "story",
-- "terrain_graphics", "time", "time_area", "tunnel", "variables"
-- Note: a on_event handler will not prevent undoing of that event, so usually you need to add an event to diallow undo to prevent OOS. You can add an event handler for that event inside a on_event callback. A possible way to define a disallow_undo function is:
-- disallow_undo = () ->
--	wesmere.wsl_actions.event { name: wesmere.current.event_context.name }
-- Which should then be called from every on_event callback which changes the gamestate.


----
-- Fires all the WSL events with the given name. Optional parameters allow passing two locations and two tables. These parameters will be matched against the [filter], [filter_second], [filter_attack], and [filter_second_attack] of any event handler, and are used to fill the WSL variables "unit", "second_unit", "weapon", and "second_weapon". These parameters can also be read through current.event_context.
-- @function wesmere.fire_event
-- @string event_name
-- @number[opt] x1
-- @number[optchain] y1
-- @number[opt] x2
-- @number[optchain] y2
-- @number[opt] first_weapon
-- @number[optchain] second_weapon
-- @treturn bool The function returns a boolean indicating whether the game state was modified.
-- @usage wesmere.fire_event("explosion", 17, 42, { damage: "fire" })
-- @usage wesmere.fire_event = (event_name, [x1, y1, [x2, y2]], [first_weapon, [second_weapon]]) ->
fire_event = (event_name, x1, y1, x2, y2, first_weapon, second_weapon) =>
    handlers = @current.event_handlers[event_name]
    return false, "No '#{event_name}' Events" unless handlers

    event_context = @current.event_context
    assert(event_context)

    ----
    -- execute a single event handler
    -- see Lua Manual http://somewhere
    -- @function execute_event_handler
    -- @tab handler
    -- @param primary
    -- @param second
    -- @param first_weapon
    -- @param second_weapon
    -- @tab ENV the environment that will be the context the handler gets executed in.
    execute_event_handler = (handler, primary, second, first, second, ENV) ->
        return false, "handler disabled" if handler.remove
        -- return false, "failed side filter" if handler.filter_side and not wesmere.match_side(ENV.side_number, handler.filter_side)
        -- return false, "failed condition" if handler.filter_condition and not wesmere.eval_conditional(handler.filter_condition)
        -- if filter = handler.filter
        --     return false, "no unit thus no filtering" unless unit
        --     return false, "unit does not match filter" unless unit\matches(filter)
        -- if filter = handler.filter_second
        --     return false, "no second unit thus no filtering" unless second_unit
        --     return false, "second unit does not match filter" unless second_unit\matches(filter)
        -- -- @todo filter_attack
        -- if filter = handler.filter_attack
        --     first_weapon

        -- @todo filter_second_attack

        -- @todo delayed_variable_substitution ?
        log.trace("Executing: #{handler.name}")

        if handler.first_time_only
            handler.remove = true

        setfenv(handler.do, ENV)

        try
            do: ->
                handler.do(primary, second)
            catch: (err) ->
                error "Error executing #{handler.name} handler command: #{err}"

        return true


    local unit, second_unit
    if x1
        try
            do: -> unit = get_unit(x1, y1)
            catch: (err) -> error "wesmere.fire_event: #{err}"
    if x2
        second_unit = get_unit(x2, y2)

    with event_context
        .name = event_name
        .x1 = x1
        .y1 = y1
        .x2 = x2
        .y2 = y2
        .Unit = unit
        .Second_Unit = second_unit -- primary unit; secondary_unit
        -- @todo
        -- .weapon =
        -- .second_weapon =
        -- .unit_x
        -- .unit_y =
        -- .damage_inflicted = 0

    modified = false

    if primary
        primary_unit = (type(primary) == Unit) and primary or @get_unit(primary)
    if secondary
        secondary_unit = (type(secondary) == Unit) and secondary or @get_unit(secondary)

    for event in *handlers
        fired, err = execute_event_handler(event, primary_unit,
            secondary_unit, first_weapon, second_weapon, event_context)
        if fired
            modified = fired
        else print "err"

    return modified

-- fire_event = (event_name, x1, y1, x2, y2, first_weapon, second_weapon) =>
--     try
--         do: -> fire_event_(@, event_name, x1, y1, x2, y2, first_weapon, second_weapon)
--         catch: (err) -> error "fire_event_wrapper"



----
-- Registers a new event handler.
-- @function wesmere.add_event_handler
-- @tab cfg This takes a WSL table containing the same information normally used by the [event] table.
add_event_handler = (cfg) =>


    return false unless cfg.name
    -- @todo handle id
    -- @todo handle remove
    -- assert(cfg)
    -- assert(type cfg == "table")
    -- assert(cfg.do, "Missing 'do' in #{cfg.name} event")
    -- assert(cfg.name, "Missing 'name' in event")
    -- (require'moon').p cfg

    if @current.event_handlers[cfg.name]
        table.insert(@current.event_handlers[cfg.name], cfg)
    else
        @current.event_handlers[cfg.name] = { cfg }
    return true -- @todo


----
-- Removes an event handler. This requires the event handler to have been assigned an id at creation time.
-- @function wesmere.remove_event_handler
-- @string id
remove_event_handler = (id) ->
    for name, handlers in pairs wesmere.game_events
        for handler in *handlers
            if handler.id == id
                handler.remove = true


----
-- Returns true if the conditional described by the WSL table passes. Note: WSL variables are substituted.
-- @function wesmere.eval_conditional
-- @tab conditional_table
-- @usage result = wesmere.eval_conditional
--    have_unit:
--        id: "hero"
--    variable:
--        name: "counter"
--        numerical_equals: "old_counter"
eval_conditional = (conditional_table) ->


----
-- Converts a WSL table into a proxy object which performs variable substitution on the fly.
-- @function wesmere.tovconfig
tovconfig = (config) ->
-- @usage wesmere.set_variable("varname", "to_be_deleted")
-- wesmere.wsl_actions.clear_variable { name: "to_be_deleted" }               -- correct
-- wesmere.wsl_actions.clear_variable { name: "$varname" }                    -- error: try to delete a variable literally called "$varname"
-- wesmere.wsl_actions.clear_variable(wesmere.tovconfig { name: "$varname" }) -- correct: "$varname" is replaced by "to_be_deleted" at the right time


----
-- @function helper.set_wsl_action_metatable
set_wsl_action_metatable = () ->
-- Sets the metatable of a table so that it can be used to fire WSL actions. Returns the table. The fields of the table are then simple wrappers around a call to #wesmere.fire.
-- @usage W = helper.set_wsl_action_metatable {}
-- W.message { speaker = "narrator", message = "?" }


----
-- Interrupts the @current execution and displays a chat message that looks like a WSL error.
-- @function helper.wsl_error
-- @usage names = cfg.name or helper.wsl_error("clear_variable() missing required name: key.")
--wsl_error = (message) ->
--    error(message)


----
-- Returns the __literal field of its argument if it is a userdata, the argument itself otherwise. This function is meant to be called when a WSL action handler can be called indifferently from WSL (hence receiving a userdata) or from Lua (hence possibly receiving a table).
-- Note: when the argument is a plain table, the function returns it as is. In particular, modifying the fields of the returned table causes the original table to be modified too.
-- @function helper.literal
-- @usage function wsl_actions.display_literal_value(cfg)
--     cfg = helper.literal(cfg)
--     wesmere.message(tostring(cfg.value))
literal = (config) ->


----
-- Returns the __parsed field of its argument if it is a userdata, the argument itself otherwise. See also #helper.literal.
-- @function helper.parsed
parsed = (config) ->


----
-- Returns the __shallow_literal field of its argument if it is a userdata, the argument itself otherwise. See also #helper.literal.
-- @function helper.shallow_literal
shallow_literal = (config) ->


----
-- Returns the __shallow_parsed field of its argument if it is a userdata, the argument itself otherwise. See also #helper.literal.
-- @function helper.shallow_parsed
shallow_parsed = (config) ->


{
    :fire
    :wsl_actions
    :wsl_conditionals -- (Version 1.13.0 and later only)
    :game_events
    :fire_event
    :add_event_handler -- (Version 1.13.0 and later only)
    :remove_event_handler -- (Version 1.13.0 and later only)
    :eval_conditional
    :tovconfig
-- helper.set_wml_action_metatable
--    :wsl_error
-- helper.literal
-- helper.parsed
-- helper.shallow_literal
-- helper.shallow_parsed
}



