----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

package.moonpath ..= ";./?/init.moon"
describe = describe
it = it

UnitMap = require "utils.unit_map"
Unit = require "utils.Unit"

describe "UnitMap", ->

    -- import unit_types from require "units"

    unit_types =
        ["Elvish Fighter"]:
            id: "Elvish Fighter"
            moves: 10
            hitpoints: 24
            experience: 5

    fighter =
        type: "Elvish Fighter"
        experience_modifier: 100

    describe "Constructor", ->

        it "(10, 10)", ->
            unitMap = UnitMap(10, 10)
            assert(unitMap)


    describe "iter", ->

        it "over empty map", ->
            unitMap = UnitMap(10, 10)
            iter = unitMap\iter!
            assert(iter)
            assert (iter! == nil)
            for _ in iter
                assert(false)

        -- it "over 5 units", ->
        --     unitMap = UnitMap(10, 10)
        --     units = {}
        --     for i = 1, 5
        --         units[i] = Unit(unitMap, unit_types, {}, {}, fighter)
        --     for i, unit in ipairs units
        --         unitMap\place_unit(unit,i,i)
        --     iter = unitMap\iter!
        --     i = 0
        --     for unit in iter
        --         i += 1
        --         assert(unit == units[i])
