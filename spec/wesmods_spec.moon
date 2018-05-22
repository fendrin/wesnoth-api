
wesmods = require "wesmods"

describe "Wesmods", ->

    describe "Load Config file", ->

        it "test_file", ->

            ENV =
                test: () ->

            wesmods.load_cfg_file("spec/wesmods_input.moon", ENV)

            assert ENV.AND_ME


    -- describe "Load Root", ->
    --     it "root", ->
    --         assert(wesmods.load_wesmod_by_path("../../root"))

    -- describe "Load Root", ->
    --     it "root", ->
    --         assert(wesmods.load_wesmod_by_path("../../root/WesMod/test"))

    -- describe "Scan Root", ->

    --     it "Testroot", ->
    --         assert(wesmods.scan_root("../../root"))
