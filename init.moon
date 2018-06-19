----
-- module wesnoth
--

local wesnoth

self =
    Data:            -- static data
        Campaign: {}
        Scenario: {}

        Unit_Type: {}
        Movetype:  {}
        Race:      {}
        Terrain_Type: {}

        Game_Config: {}
        Binary_Path: {}
        Action: {}
        Tip:    {}

        Color_Palette: {}
        Color_Range:   {}

    board:           -- dynamic state
        sides:       {}
        units:       nil
        map:         {}
        time_of_day: {}
        music_list:  {}
        theme_items: {}

    terrains: {}     -- terrain_types

    actions:         {}
    scenario:        {}
    campaign:        {}
    current:
        event_handlers: {}
        event_context: {}

with self
    wesnoth =
        -- static data
        game_config: .Data.Game_Config
        races:       .Data.Race
        unit_types:  .Data.Unit_Type
        -- dynamic state
        music_list:  .board.music_list
        sides:       .board.sides
        theme_items: {}
        wml_actions: .actions
        game_events: {} -- this are *not* the scenario events
        wml_conditionals: {}

insert_submodule = (submodule, module) ->
    for key, thing in pairs(submodule)
        switch type(thing)
            when "function"
                module[key] = (...) -> thing(self, ...)
            when "table"
                insert_submodule(submodule.key, module.key)
            else
                module[key] = thing


submodules = {"map", "units", "sides", "pathfinder", "interface", "variables"}
for submodule_name in *submodules
    submodule = require"api.#{submodule_name}"
    insert_submodule(submodule, wesnoth)

helper  = require"api.helper"
helper_ = {}
insert_submodule(helper, helper_)

controller  = require"api.controller"
controller_ = {}
insert_submodule(controller, controller_)

assert controller_
assert helper_
assert wesnoth

export DATA = self.Data

{
    helper: helper_
    wesnoth: wesnoth
    controller: controller_
}
