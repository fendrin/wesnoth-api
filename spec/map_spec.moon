
map = require "map"

map_string = [[
Gg1 Gg1 Mh1 MH1 Hf1 Ww1 Ws1 Ww1
Gg2 Gg2 Mh2 MH2 Hf2 Ww2 Ws2 Ww2
Gg3 Gg3 Mh3 MH3 Hf3 Ww3 Ws3 Ww3
Gg4 Gg4 Mh4 MH4 Hf4 Ww4 Ws4 Ww4
Gg5 Gg5 Mh5 MH5 Hf5 Ww5 Ws5 Ww5
Gg6 Gg6 Mh6 MH6 Hf6 Ww6 Ws6 Ww6
]]

describe "Map loading", ->

    describe "parse_map_string", ->

        it "Simple Map with border", ->

            map_tab = map.parse_map_string(map_string, 2)
            assert.are.equal 2, map_tab.border_size
            assert.are.equal 4, map_tab.width
            assert.are.equal 2, map_tab.height
