
HasGetters = require "HasGetters"


describe "HasGetters", ->

    describe "Lookup Table", ->

        Object_w_Table = class extends HasGetters
            getters:
                key1: => "value1"
                key2: => "value2"
                foo:  => "wrong"
                get_bar: => @bar

            new: =>
                @foo = "right"
                @bar = "some"

        object_w_table = Object_w_Table!

        it "value1", ->
            assert.are.equal "value1", object_w_table.key1

        it "value2", ->
            assert.are.equal "value2", object_w_table.key2

        it "unknown key", ->
            assert.are.equal nil, object_w_table.unknown

        it "outside getters", ->
            assert.are.equal "some", object_w_table.bar

        it "inside both", ->
            assert.are.equal "right", object_w_table.foo

        it "get_bar", ->
            assert.are.equal "some", object_w_table.get_bar

    describe "Lookup Function", ->

        Object_w_Function = class extends HasGetters
            getters: (key) =>
                switch key
                    when "key1"
                        "value1"
                    when "key2"
                        "value2"
                    when "foo"
                        "wrong"
                    when "get_bar"
                        @bar
                    else nil

            new: =>
                @foo = "right"
                @bar = "some"

        object = Object_w_Function!

        it "value1", ->
            assert.are.equal "value1", object.key1

        it "value2", ->
            assert.are.equal "value2", object.key2

        it "unknown key", ->
            assert.are.equal nil, object.unknown

        it "outside getters", ->
            assert.are.equal "some", object.bar

        it "inside both", ->
            assert.are.equal "right", object.foo

        it "get_bar", ->
            assert.are.equal "some", object.get_bar
