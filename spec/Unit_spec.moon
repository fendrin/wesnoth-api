
Unit = require "Unit"
UnitMap = require "unit_map"
Loc = require "Location"

unit_types = require("units").unit_types

loc = Loc(12,8)
unit_map = UnitMap(25,25)


describe "Unit", ->

    unit_types["Elvish Fighter"] =
        id: "Elvish Fighter"
        hitpoints: 28
        experience: 100

    cfg =
        id: "Kalenz"
        type: "Elvish Fighter"
        experience_modifier: 80

    it "Constructor", ->
        unit = Unit(unit_map, cfg)
        assert(unit)

    describe "get unit.type", ->

        it "Elvish Fighter", ->
            unit = Unit(unit_map, cfg)
            assert.are.equal "Elvish Fighter", unit.type

    describe "getters", ->

        it "unit.x", ->
            unit = Unit(unit_map, cfg)
            -- assert
            unit_map\place_unit(unit, loc.x, loc.y)
            assert.are.equal loc.x, unit.x

        it "unit.y", ->
            unit = Unit(unit_map, cfg)
            -- assert unit_map\place_unit(unit, loc.x, loc.y)
            assert.are.equal loc.y, unit.y

        it "unit.loc", ->
            unit = Unit(unit_map, cfg)
            -- assert unit_map\place_unit(unit, loc.x, loc.y)
            assert.are.equal loc, unit.loc

    describe "matches", ->

        describe "id:", ->

            it "Kalenz", ->
                unit = Unit(unit_map, cfg)
                assert(unit\matches({id: "Kalenz"}))

            it "notKalenz", ->
                unit = Unit(unit_map, cfg)
                assert(not unit\matches({id: "notKalenz"}))

            it "Kalenz, Rudolph, Adolf, Stalin", ->
                unit = Unit(unit_map, cfg)
                assert(unit\matches({id: {"Kalenz", "Rudolph", "Adolf", "Stalin"} }))

            it "notKalenz, Rudolph, Adolf, Stalin", ->
                unit = Unit(unit_map, cfg)
                assert(not unit\matches({id: {"notKalenz", "Rudolph", "Adolf", "Stalin"} }))

        describe "loc:", ->

            it "#{loc.x},#{loc.y}", ->
                unit = Unit(unit_map, cfg)
                assert(unit\matches({loc:{loc.x, loc.y}}))

            it "#{loc.x + 1},#{loc.y}", ->
                unit = Unit(unit_map, cfg)
                assert(not unit\matches({loc:{loc.x +1, loc.y}}))




