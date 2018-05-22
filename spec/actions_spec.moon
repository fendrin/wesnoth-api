actions = require "actions"

describe "actions", ->

    state =
        current:
            event_handlers: {}
            event_context: {}

    describe "add_event_handler", ->

        event =
            name: "MyEvent"
            command: ->
                return 5

        it "add MyEvent", ->
            actions.add_event_handler state, event
            assert state.current.event_handlers["MyEvent"]


    describe "fire_no_events", ->

        it "fire 'NotMyEvent'", ->
            fired, err = actions.fire_event state, "NotMyEvent"
            assert not fired
            assert.are.equal err, "No 'NotMyEvent' Events"


    describe "fire_event", ->

        it "MyEvent", ->
            fired, err = actions.fire_event state, "MyEvent"
            assert(fired, err)


    describe "fire", ->

        message =
            speaker: "Kalenz"
            message: "Orcs are the best pals."

        it "the message action", ->

            actions.fire("message", message)
