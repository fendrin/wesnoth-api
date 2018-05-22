
UnitMap = require "unit_map"
Unit = require "Unit"

describe "UnitMap", ->

    import unit_types from require "units"

    unit_types["Elvish Fighter"] =
        id: "Elvish Fighter"
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
            for none in iter
                assert(false)

        it "over 5 units", ->
            unitMap = UnitMap(10, 10)
            units = {}
            for i = 1, 5
                units[i] = Unit(unitMap, fighter)
            for i, unit in ipairs units
                unitMap\place_unit(unit,i,i)
            iter = unitMap\iter!
            i = 0
            for unit in iter
                i += 1
                assert(unit == units[i])
