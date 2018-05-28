----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+


sides = require "sides"

describe "sides", ->

    state =
        board:
            map: {}
            village: {}

    for i=1, 10
        state.board.village[i] = {}
        state.board.map[i] = {}

    describe "get_village_owner", ->

        it "@(5,4)", ->

            loc = { x: 5, y:4 }

            sides.set_village_owner(state, loc.x, loc.y, 2)

            owner = sides.get_village_owner(state, loc.x, loc.y)

            assert.are.equals 2, owner

    describe "set_village_owner", ->

    describe "get_sides", ->

    describe "match_side", ->

        -- describe "team_name", ->

        --     it "team_wesmere", ->

        --         assert(sides.match_side(state, 1, { team_name: "team_wesmere" }))

        --     it "not_team_wesmere", ->

        --         assert(not sides.match_side(state, 1, { team_name: "not_team_wesmere" }))

    describe "get_starting_location", ->

    describe "all_sides", ->

    describe "is_enemy", ->

