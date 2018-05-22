
variables = require "variables"

state =
    current:
        event_context: {}



describe "#variables", ->

    describe "#set_variable", ->

        it "var = 5", ->
            variables.set_variable(state, "var", 5)
            assert.are.equal state.current.event_context.var, 5

        it "var.subvar = 5", ->
            variables.set_variable(state, "var", {})
            variables.set_variable(state, "var.subvar", 5)
            assert.are.equal state.current.event_context.var.subvar, 5

        it "var[2] = 5", ->
            variables.set_variable(state, "var", {})
            variables.set_variable(state, "var[2]", 5)
            assert.are.equal state.current.event_context.var[2], 5


    describe "#get_variable", ->

        it "var = 5", ->
            variables.set_variable(state, "var", 5)
            assert.are.equal variables.get_variable(state, "var"), 5

        it "var.subvar = 5", ->
            variables.set_variable(state, "var", {})
            variables.set_variable(state, "var.subvar", 5)
            assert.are.equal variables.get_variable(state, "var.subvar"), 5

        it "var[2] = 5", ->
            variables.set_variable(state, "var", {})
            variables.set_variable(state, "var[2]", 5)
            assert.are.equal variables.get_variable(state, "var[2]"), 5
