----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

scenario = require "scenario"
import ENV, content from require "wesmods"

scenario_cfg =
    id: "scenario_test"
    name: "scenario to end all scenarios"

    side:
        side:1
        gold:39
        unit:
            id:"Kalenz"
            type: "Elvish Fighter"

    Start: ->
        -- error("bin uebel")
   --     my_message "Hallo Welt"
        --     id:"Kalenz"
        -- fire_event
        --     name: "MyEvent"

    MyEvent: ->
        print [[

          a lot

        ]]
        error("sowas")


-- describe "scenario", ->

--     describe "start", ->

--         ENV.folders.Scenario = {}

--         content.Mechanic =
--             wsl_action: {
--                 my_message:
--                     action: (txt) -> print txt
--             }

--         scenario.start_scenario(scenario_cfg)

--         it "execute event", ->


