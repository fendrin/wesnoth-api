
wesmere = require "init"


describe "WSL Test Suite", ->

    wesmere.load_wesmod_by_path("../../root")
    wesmere.load_wesmod_by_path("../../root/WesMod/wesmere")
    wesmere.load_wesmod_by_path("../../root/WesMod/wesmere/WesMod/test")


    for key, test in pairs wesmere.content.Scenario.test

        it "running ##{test.id}", ->

            test_scenario = wesmere.load_test(key)
            test_scenario.start!

            switch key
                when "empty_test"
                    assert not test_scenario.is_regular_game_end!, "Test did finish but shouldn't"
                else
                    assert test_scenario.is_regular_game_end!, "Test didn't finish, turn number is #{test_scenario.get_turn!}"

            switch key
                when "empty_test"
                    assert true
                when "test_assert_fail", "test_assert_fail_two", "two_plus_two_fail", "test_return_fail"
                    assert not (test_scenario.get_end_level_data!.is_victory), "Test should fail but didn't'"
                else
                    assert (test_scenario.get_end_level_data!.is_victory), "Test failed, ended at turn #{test_scenario.get_turn!}"
