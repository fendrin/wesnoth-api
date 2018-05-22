moon = require "moon"
Location_Set = require "Location_Set"

describe "Location_Set", ->

    some_set = Location_Set!
    some_set\insert(17, 42)

    describe "Setup", ->

        it "Constructor", ->
            set = Location_Set!
            assert(moon.type(set) == Location_Set)

        it "size of new set is 0", ->
            set = Location_Set!
            assert.are.equal 0, set\size!


    describe "empty", ->
        set = Location_Set!
        it "Is Empty", ->
            assert(set\empty!)


    describe "insert", ->
        it "can find freshly inserted location", ->
            assert(some_set\get(17, 42))

    describe "size", ->
        it "size is one", ->
            assert(some_set\size! == 1)

    describe "clear", ->
        it "can't find removed location'", ->
            some_set\clear!
            assert(not some_set\get(17, 42))

    describe "get", ->
        it "can fetch attached string", ->
            some_set\insert(17, 42, "something")
            assert(some_set\get(17, 42) == "something")

    a_set = Location_Set!
    b_set = Location_Set!

    describe "union", ->
        it "overwrite associated data", ->
            a_set\insert(17, 42, "nothing")
            b_set\insert(17, 42, "something")
            a_set\union(b_set)
            assert(a_set\get(17, 42) == "something")

    describe "inter", ->
        it "assosiated data is kept intact if not removed", ->
            a_set\insert(17, 42, "nothing")
            b_set\insert(17, 42, "something")
            a_set\inter(b_set)
            assert(a_set\get(17, 42) == "nothing")
