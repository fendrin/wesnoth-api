--     using starting_positions = boost::bimaps::bimap<boost::bimaps::set_of<std::string>, boost::bimaps::multiset_of<coordinate>>;

----
-- Reads a gamemap string into a 2D vector
--
-- @param str        A string containing the gamemap, the following rules
--                   are stated for a gamemap:
--                   * The map is square
--                   * The map can be prefixed with one or more empty lines,
--                     these lines are ignored
--                   * The map can be postfixed with one or more empty lines,
--                     these lines are ignored
--                   * Every end of line can be followed by one or more empty
--                     lines, these lines are ignored.
--                     @deprecated NOTE it's deprecated to use this feature.
--                   * Terrain strings are separated by comma's or an
--                     end of line symbol,
--                     for the last terrain string in the row.
--                     For readability it's allowed to pad strings
--                     with either spaces or tab,
--                     however the tab is deprecated.
--                   * A terrain string contains either a terrain or a terrain and
--      *                      starting location. The following format is used
--      *                      [S ]T
--      *                      S = starting location a positive non-zero number
--      *                      T = terrain code (see read_terrain_code)
--      * @param positions This parameter will be filled with the starting
--      *                    locations found. Starting locations can only occur once
--      *                    if multiple definitions occur of the same position only
--      *                    the last is stored. The returned value is a map:
--      *                    * first        the starting locations
--      *                    * second    a coordinate structure where the location was found
--      *
--      * @returns            A 2D vector with the terrains found the vector data is stored
--      *                    like result[x][y] where x the column number is and y the row number.
--      */
--     ter_map read_game_map(const std::string& str, starting_positions& positions, coordinate border_offset = coordinate{ 0, 0 });



-- ter_map read_game_map(const std::string& str, starting_positions& starting_positions, coordinate border_offset)
-- read_game_map = (str, starting_positions, border_offset) =>
--     offset = 0
--     x = 0
--     y = 0
--     width = 0

--     // Skip the leading newlines
--     while(offset < str.length() && utils::isnewline(str[offset])) {
--         ++offset;
--     }

--     // Did we get an empty map?
--     if((offset + 1) >= str.length()) {
--         return ter_map();
--     }

--     auto map_size = get_map_size(&str[offset], str.c_str() + str.size());
--     ter_map result(map_size.first, map_size.second);

--     while(offset < str.length()) {

--         // Get a terrain chunk
--         const std::string separators = ",\n\r";
--         const size_t pos_separator = str.find_first_of(separators, offset);
--         const std::string terrain = str.substr(offset, pos_separator - offset);

--         // Process the chunk
--         std::string starting_position;
--         // The gamemap never has a wildcard
--         const terrain_code tile = tonumber(terrain, starting_position, NO_LAYER);

--         // Add to the resulting starting position
--         if(!starting_position.empty()) {
--             if (starting_positions.left.find(starting_position) != starting_positions.left.end()) {
--                 WRN_G << "Starting position " << starting_position << " is redefined." << std::endl;
--             }
--             starting_positions.insert(starting_positions::value_type(starting_position, coordinate(x - border_offset.x, y - border_offset.y)));
--         }

--         if(result.w <= x || result.h <= y) {
--             throw error("Map not a rectangle.");
--         }

--         // Add the resulting terrain number
--         result.get(x, y) = tile;

--         // Evaluate the separator
--         if(pos_separator == std::string::npos || utils::isnewline(str[pos_separator])) {
--             // the first line we set the with the other lines we check the width
--             if(y == 0) {
--                 // x contains the offset in the map
--                 width = x + 1;
--             } else {
--                 if((x + 1) != width ) {
--                     ERR_G << "Map not a rectangle error occurred at line offset " << y << " position offset " << x << std::endl;
--                     throw error("Map not a rectangle.");
--                 }
--                 if (y > max_map_size()) {
--                     ERR_G << "Map size exceeds limit (y > " << max_map_size() << ")" << std::endl;
--                     throw error("Map height limit exceeded.");
--                 }
--             }

--             // Prepare next iteration
--             ++y;
--             x = 0;

--             // Avoid in infinite loop if the last line ends without an EOL
--             if(pos_separator == std::string::npos) {
--                 offset = str.length();

--             } else {

--                 offset = pos_separator + 1;
--                 // Skip the following newlines
--                 while(offset < str.length() && utils::isnewline(str[offset])) {
--                     ++offset;
--                 }
--             }

--         } else {
--             ++x;
--             offset = pos_separator + 1;
--             if (x > max_map_size()) {
--                 ERR_G << "Map size exceeds limit (x > " << max_map_size() << ")" << std::endl;
--                 throw error("Map width limit exceeded.");
--             }
--         }

--     }

--     if(x != 0 && (x + 1) != width) {
--         ERR_G << "Map not a rectangle error occurred at the end" << std::endl;
--         throw error("Map not a rectangle.");
--     }

--     return result;
-- }

