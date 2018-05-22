require "moonscript"
Location = require "Location"
describe = describe
it = it

-- source: moonscript_spec.moon
describe "#Location", ->

    describe "(1/1)", ->

        loc1 = Location(1,1)

        it "distance_between (1/2)", ->
            loc2 = Location(1,2)
            assert.are.equal 1, loc1\distance_between(loc2.x, loc2.y)

        loc2 = Location(12,18)
        it "distance_between (12/18)", ->
            assert.are.equal 23, loc1\distance_between(loc2.x, loc2.y)

        it "(1/1) - (12/18)", ->
            assert.are.equal 23, loc1 - loc2

        it "alternative argument", ->
            assert.are.equal 23, loc1\distance_between(loc2)

    describe "(14/18)", ->

        loc = Location(14, 18)

        it "matches x: 12-16 y: 17-23", ->
            assert(loc\matches_range("12-16", "17-23"))

        it "matches not", ->
            assert(not loc\matches_range("15-17", "14-17"))


    describe "Equality test", ->

        it "Is Equal", ->

            loc1 = Location(5, 12)
            loc2 = Location(5, 12)
            assert(loc1 == loc2)

        it "Not Equal", ->

            loc1 = Location(12, 4)
            loc2 = Location(12, 3)
            assert(loc1 != loc2)


    describe "Constructor tests", ->

        it "Location({})", ->
            loc = Location({})
            assert.are.equal(nil, loc)

        it "Location({loc:{5,19}})", ->
            loc = Location({loc:{5,19}})
            assert.are.equal 5, loc.x
            assert.are.equal 19, loc.y

        it "Location(5, 10)", ->
            loc = Location(5, 10)
            assert.are.equal 5, loc.x
            assert.are.equal 10, loc.y

        it "Location(Location(5, 10))", ->
            loc = Location(Location(5, 10))
            assert.are.equal 5, loc.x
            assert.are.equal 10, loc.y

        it "Location({ x: 5, y: 10})", ->
            loc = Location({ x: 5, y: 10})
            assert.are.equal 5, loc.x
            assert.are.equal 10, loc.y

        it "Location( {5,10} )", ->
            loc = Location( {5,10} )
            assert.are.equal 5, loc.x
            assert.are.equal 10, loc.y

    describe "index access", ->

        it "Location(5, 10)", ->
            loc = Location(5, 10)
            assert.are.equal 5, loc[1]
            assert.are.equal 10, loc[2]

    describe "adjacents! tests", ->

        describe "(5/5)", ->

            loc1 = Location(5,5)
            it "direction test NORTH", ->
                passed = loc1\adjacents!.NORTH
                expected = Location(5,4)
                assert.are.equal expected, passed

            it "direction test SOUTH", ->
                passed = loc1\adjacents!.SOUTH
                expected = Location(5,6)
                assert.are.equal expected, passed

            it "direction test SOUTH_WEST", ->
                passed = loc1\adjacents!.SOUTH_WEST
                expected = Location(4,5)
                assert.are.equal expected, passed

            it "direction test SOUTH_EAST", ->
                passed = loc1\adjacents!.SOUTH_EAST
                expected = Location(6,5)
                assert.are.equal expected, passed

            it "direction test NORTH_WEST", ->
                passed = loc1\adjacents!.NORTH_WEST
                expected = Location(4,4)
                assert.are.equal expected, passed

            it "direction test NORTH_EAST", ->
                passed = loc1\adjacents!.NORTH_EAST
                expected = Location(6,4)
                assert.are.equal expected, passed

        describe "(9/10)", ->

            loc2 = Location(9,10)
            it "direction test2 NORTH", ->
                north = loc2\adjacents!.NORTH
                another_north = Location(9,9)
                assert.are.equal another_north, north

            it "direction test2 SOUTH", ->
                passed = loc2\adjacents!.SOUTH
                expected = Location(9,11)
                assert.are.equal expected, passed

            it "direction test2 SOUTH_WEST", ->
                passed = loc2\adjacents!.SOUTH_WEST
                expected = Location(8,10)
                assert.are.equal expected, passed

            it "direction test2 SOUTH_EAST", ->
                passed = loc2\adjacents!.SOUTH_EAST
                expected = Location(10,10)
                assert.are.equal expected, passed

            it "direction test2 NORTH_WEST", ->
                passed = loc2\adjacents!.NORTH_WEST
                expected = Location(8,9)
                assert.are.equal expected, passed

            it "direction test2 NORTH_EAST", ->
                passed = loc2\adjacents!.NORTH_EAST
                expected = Location(10,9)
                assert.are.equal expected, passed
