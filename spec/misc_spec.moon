
misc = require "misc"
import try from misc


describe "misc", ->

    describe "try", ->

        it "do returns", ->

            local finally_reached, catch_reached
            result = try
                do: ->
                    finally_reached, catch_reached = false, false
                    return "foobar"
                catch: (err) ->
                    assert(false) -- should not be reached
                finally: ->
                    finally_reached = true

            assert.are.equal "foobar", result
            assert.are.equal false, catch_reached
            assert.are.equal true, finally_reached


        it "do fails, catch returns", ->

            local finally_reached, catch_reached
            result = try
                do: ->
                    finally_reached, catch_reached = false, false
                    error "foo", 2
                catch: (err) ->
                    -- assert.are.equal "foo", err
                    catch_reached = true
                    return "bar"
                finally: ->
                    assert(catch_reached)
                    finally_reached = true

            assert.are.equal "bar", result
            assert.are.equal true, catch_reached
            assert.are.equal true, finally_reached


        it "do fails, catch errors", ->

            local finally_reached, catch_reached
            ok, value = pcall -> try
                do: ->
                    finally_reached, catch_reached = false, false
                    error "foo", 2
                catch: (err) ->
                    -- assert.are.equal "foo", err
                    catch_reached = true
                    error "bar", 2
                finally: ->
                    assert(catch_reached)
                    finally_reached = true

            assert.are.equal false, ok
            assert.are.equal "bar", value
            assert.are.equal true, catch_reached
            assert.are.equal true, finally_reached
