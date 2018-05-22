require "moonscript"

time = require("time")

DAWN =
    id: "dawn"
    name: "Dawn"
    image: "misc/time-schedules/default/schedule-dawn"
    red: -20
    green: -20
    sound: "ambient/morning"

MORNING =
    id: "morning"
    name: "Morning"
    image: "misc/time-schedules/default/schedule-morning"
    lawful_bonus: 25

describe "time", ->

    state =
        area: {}
        time: {
            DAWN
            MORNING
        }
        current: {
            event_context:
                turn_number: 3
        }

    describe "add_time_area", ->

        it "'dark forest'", ->

            time.add_time_area(state, {
                x: {"1-2","4-5"}
                y: {"1-2","1-2"}
                id: "dark forest"
            })

    describe "remove_time_area", ->

        it "'dark forest'", ->
            time.remove_time_area(state, "dark forest")


    describe "get_time_of_day", ->

        it "global this turn", ->

            tod = time.get_time_of_day(state)
            assert(tod, "No time table returned")
            assert.are.equals "dawn", tod.id

        it "global turn 5", ->

            tod = time.get_time_of_day(state, 5)
            assert(tod, "No time table returned")
            assert.are.equals "dawn", tod.id
