----
-- Copyright (C) 2006 - 2018 by Mark de Wever <koraq@xs4all.nl>
-- Part of the Battle for Wesnoth Project http://www.wesnoth.org/
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY.
--
-- See the COPYING file for more details.


import splitv from require"pl.utils"

----
-- @file
-- Routines for terrain-conversion.


-- Contains an x and y coordinate used for starting positions in maps.
--     using coordinate = map_location;

--     // Exception thrown if there's an error with the terrain.
--     // Note: atm most thrown result in a crash, but I like
--     // an uncatched exception better than an assert.
--     struct error : public game::error {
--         error(const std::string& message) : game::error(message) {}
--     };

--     // Some types of terrain which must be known, and can't just
--     // be loaded in dynamically because they're special.
--     // It's asserted that there will be corresponding entries for
--     // these types of terrain in the terrain configuration file.
--     extern const terrain_code VOID_TERRAIN;
--     extern const terrain_code FOGGED;

--     // On the map the user can use this type to make odd shaped maps look good.
--     extern const terrain_code OFF_MAP_USER;

--     extern const terrain_code HUMAN_CASTLE;
--     extern const terrain_code HUMAN_KEEP;
--     extern const terrain_code SHALLOW_WATER;
--     extern const terrain_code DEEP_WATER;
--     extern const terrain_code GRASS_LAND;
--     extern const terrain_code FOREST;
--     extern const terrain_code MOUNTAIN;
--     extern const terrain_code HILL;

--     extern const terrain_code CAVE_WALL;
--     extern const terrain_code CAVE;
--     extern const terrain_code UNDERGROUND_VILLAGE;
--     extern const terrain_code DWARVEN_CASTLE;
--     extern const terrain_code DWARVEN_KEEP;

--     extern const terrain_code PLUS;    // +
--     extern const terrain_code MINUS;    // -
--     extern const terrain_code NOT;        // !
--     extern const terrain_code STAR;    // *
--     extern const terrain_code BASE;    // references the base terrain in movement/defense aliases

--     extern const ter_match ALL_OFF_MAP;
--     extern const ter_match ALL_FORESTS;
--     extern const ter_match ALL_HILLS;
--     extern const ter_match ALL_MOUNTAINS; //excluding impassable mountains
--     extern const ter_match ALL_SWAMPS;

    -----
    --      * Reads a single terrain from a string.
    --      *
    --      * @param str        The string which should contain 1 terrain code;
    --                                         the new format of a terrain code
    --      *                is 2 to 4 characters in the set
    --      *@verbatim
    --      *                [a-Z][A-Z]/|\_
    --      *@endverbatim
    --      *                The underscore is intended for internal use.
    --      *                Other letters and characters are not validated but
    --      *                users of these letters can get nasty surprises.
    --      *                The * is used as wildcard in some cases.
    --      *                The terrain code can be two groups separated by a caret,
    --      *                the first group is the base terrain,
    --      *                the second the overlay terrain.
    --      *
    --      * @param filler    if there's no layer this value will be used as the second layer
    --      *
    --      * @return            A single terrain code
    --      */
    --     terrain_code read_terrain_code(const std::string& str, const ter_layer filler = NO_LAYER);

--     /**
--      * Writes a single terrain code to a string.
--      * The writers only support the new format.
--      *
--      * @param tcode    The terrain code to convert to a string
--      *
--      * @return        A string containing the terrain code
--      */
--     std::string write_terrain_code(const terrain_code& tcode);
--     inline std::ostream &operator<<(std::ostream &s, const terrain_code &a)
--         { s << write_terrain_code(a); return s; }

--     /**
--      * Reads a list of terrains from a string, when reading the
--      *
--      * @param str        A string with one or more terrain codes (see read_terrain_code)
--      * @param filler    If there's no layer, this value will be used as the second layer
--      *
--      * @returns        A vector which contains the terrain codes found in the string
--      */
--      ter_list read_list(const std::string& str, const ter_layer filler = NO_LAYER);

--     /**
--      * Writes a list of terrains to a string, only writes the new format.
--      *
--      * @param list        A vector with one or more terrain codes
--      *
--      * @returns        A string with the terrain codes, comma separated
--      *            and a space behind the commas. Not padded.
--      */
--     std::string write_list(const ter_list& list);


--     /**
--      * Write a gamemap in to a vector string.
--      *
--      * @param map                 A terrain vector, as returned from read_game_map
--      * @param positions A starting positions map, as returned from read_game_map
--      *
--      * @returns            A terrain string which can be read with read_game_map.
--      *                    For readability the map is padded to groups of 12 chars,
--      *                    followed by a comma and space.
--      */
--     std::string write_game_map(const ter_map& map, const starting_positions& positions = starting_positions(), coordinate border_offset = coordinate{ 0, 0 });

--     /**
--      * Tests whether a specific terrain matches a list of expressions.
--      * The list can use wildcard matching with *.
--      * It also has an inversion function.
--      * When a ! is found the result of the match is inverted.
--      * The matching stops at the first match (regardless of the ! found)
--      * the data is match from start to end.
--      *
--      * Example:
--      * Ww, W*        does match and returns true
--      * Ww, {!, W*}    does match and returns false (due to the !)
--      * WW, Ww        doesn't match and return false
--      *
--      * Multilayer rules:
--      * If a terrain has multiple layers, each layer will be matched separately,
--      * returning true only if both layers match.
--      *
--      * Example:
--      * A*^*     matches Abcd but also Abcd^Abcd
--      * A*^      matches Abcd but *not* Abcd^Abcd
--      * A*^Abcd  does not match Abcd but matches Abcd^Abcd
--      *
--      * Note: If an expression doesn't specify a second layer (i.e. it contains
--      * no caret) the second layer will be filled in with a default value
--      * (See read_terrain_code and read_list).
--      *
--      * In the terrain building code, the second layer will default to the wildcard,
--      * so both A* and A*^* will match Abcd^Abcd
--      *
--      * @param src    the value to match (may not contain wildcards)
--      * @param dest    the list of expressions to match against
--      *
--      * @returns        the result of the match (depending on the !'s)
--      */
--     bool terrain_matches(const terrain_code& src, const ter_list& dest);

--     /**
--      * Tests whether a specific terrain matches an expression,
--      * for matching rules see above.
--      *
--      * @param src    the value to match (may not contain wildcards)
--      * @param dest    the expression to match against
--      *
--      * @returns        the result of the match (depending on the !'s)
--      */
--     bool terrain_matches(const terrain_code& src, const terrain_code& dest);

--     /**
--      * Tests whether a certain terrain matches a list of expressions, for matching
--      * rules see above. The matching requires some bit mask which impose a
--      * certain overhead. This version uses a cache to cache the masks so if
--      * a list needs to be matched often this version is preferred.
--      *
--      * @param src    the value to match (may not contain wildcards)
--      * @param dest    the cached list of expressions to match against
--      *
--      * @returns        the result of the match (depending on the !'s)
--      */
--     bool terrain_matches(const terrain_code& src, const ter_match& dest);

--     /**
--      * Tests whether a terrain code contains a wildcard
--      *
--      *  @param tcode    the terrain code to test for a wildcard
--      *
--      *  @returns        true if wildcard found,    else false
--      */
--     bool has_wildcard(const terrain_code& tcode);

--     /**
--      * Tests whether a terrain-code list contains at least
--      * one item with a wildcard
--      *
--      *  @param list        the list to test for a wildcard
--      *
--      *  @returns        true if a wildcard found, else false
--      */
--     bool has_wildcard(const ter_list& list);

--     // These terrain letters are in the builder format,
--     // and not usable in other parts of the engine
--     const ter_layer TB_STAR = '*' << 24;    // It can be assumed this is the equivalent of STAR
--     const ter_layer TB_DOT  = '.' << 24;

--     /**
--      * Reads a builder map.
--      * A builder map differs a great deal from a normal map,
--      * hence the different functions.
--      *
--      * @param str        The map data, a terrain letter is either a * or a . or a number as
--      *                    anchor. The star or dot are stored in the base part of the terrain
--      *                    and the anchor in the overlay part. If more letters are allowed as
--      *                    special case they will be stored in the base part.
--      *                    Anchor 0 is no anchor.
--      *
--      * @returns            A 2D vector with the data found the vector data is stored
--      *                    like result[y][x] where x the column number is and y the row number.
--      */
--     ter_map read_builder_map(const std::string& str);

-- } // end namespace t_translation

----------------------------------------------------------------------------


-- #define GETTEXT_DOMAIN "wesnoth-lib"

-- #include "gettext.hpp"
-- #include "lexical_cast.hpp"
-- #include "log.hpp"
-- #include "terrain/translation.hpp"
-- #include "serialization/string_utils.hpp"
-- #include "wml_exception.hpp"


-- #define ERR_G LOG_STREAM(err, lg::general())
-- #define WRN_G LOG_STREAM(warn, lg::general())

-- namespace t_translation {

--     int max_map_size() {
--         return 1000; //TODO make this overridable by the user without having to rebuild
--     }

-- /***************************************************************************************/
-- // forward declaration of internal functions

--     // The low level convertors,
--     // These function are the ones which know about the internal format.
--     // All other functions are unaware of the internal format.

--     /**
--      * Get the mask for a single layer.
--      *
--      * @param terrain   1 layer of a terrain, might have a wildcard.
--      *
--      * @return          Mask for that layer.
--      */
--     static ter_layer get_layer_mask_(ter_layer terrain); //inlined

--     /**
--      * Gets a mask for a terrain, this mask is used for wildcard matching.
--      *
--      * @param terrain   The terrain which might have a wildcard.
--      *
--      * @return          The mask for this terrain.
--      */
--     static terrain_code get_mask_(const terrain_code& terrain);

--     static ter_layer string_to_layer_(const char* begin, const char* end);

--     /**
--      * Converts a string to a layer.
--      *
--      * @param str       The terrain string to convert, but needs to be
--      *                  sanitized so no spaces and only the terrain to convert.
--      *
--      * @return          The converted layer.
--      */
--     static ter_layer string_to_layer_(const std::string& str)
--     {
--         return string_to_layer_(str.c_str(), str.c_str() + str.size());
--     }

--     /**
--      * Converts a terrain string to a number.
--      * @param str               The terrain string with an optional number.
--      * @param start_position    Returns the start_position, the caller should
--      *                          set it on -1 and it's only changed it there is
--      *                          a starting position found.
--      * @param filler            If the terrain has only 1 layer then the filler
--      *                          will be used as the second layer.
--      *
--      * @return                  The terrain code found in the string if no
--      *                          valid terrain is found VOID will be returned.
--      */
--     static terrain_code tonumber(std::string str, std::string& start_position, const ter_layer filler);
--     static terrain_code tonumber(const std::string& str, const ter_layer filler = NO_LAYER);

--     /**
--      * Converts a terrain number to a string
--      *
--      * @param terrain               The terrain number to convert.
--      * @param start_position        The starting position, if smaller than 0
--      *                              it's ignored else it's written.
--      *
--      * @return                      The converted string, if no starting
--      *                              position given it's padded to 4 chars else
--      *                              padded to 7 chars.
--      */
-- static std::string number_to_string_(terrain_code terrain, const std::string& start_position)
--     static std::string number_to_string_(terrain_code terrain, const std::string& start_position = "");
number_to_string_ = (terrain, start_position = "") ->

    result = ""

    -- Insert the start position
    -- if(!start_position.empty()) {
    --         result = start_position + " ";
    --     }

--     /*
--      * The initialization of tcode is done to make gcc-4.7 happy. Otherwise it
--      * some uninitialized fields might be used. Its analysis are wrong, but
--      * Initialize to keep it happy.
--      */
--     unsigned char tcode[9] {0};
--     // Insert the terrain tcode
--     tcode[0] = ((terrain.base & 0xFF000000) >> 24);
--     tcode[1] = ((terrain.base & 0x00FF0000) >> 16);
--     tcode[2] = ((terrain.base & 0x0000FF00) >> 8);
--     tcode[3] =  (terrain.base & 0x000000FF);

--     if(terrain.overlay != NO_LAYER) {
--         tcode[4] = '^'; //the layer separator
--         tcode[5] = ((terrain.overlay & 0xFF000000) >> 24);
--         tcode[6] = ((terrain.overlay & 0x00FF0000) >> 16);
--         tcode[7] = ((terrain.overlay & 0x0000FF00) >> 8);
--         tcode[8] =  (terrain.overlay & 0x000000FF);
--     } else {
--         // If no second layer, the second layer won't be written,
--         // so no need to initialize that part of the array
--         tcode[4] = 0;
--     }

--     for(int i = 0; i < 9; ++i) {
--         if(tcode[i] != 0 && tcode[i] != 0xFF) {
--             result += tcode[i];
--         }
--         if(i == 4 && tcode[i] == 0) {
--             // no layer, stop
--             break;
--         }
--     }

--     return result;
-- }




--     /**
--      * Converts a terrain string to a number for the builder.
--      * The translation rules differ from the normal conversion rules
--      *
--      * @param str   The terrain string.
--      *
--      * @return      Number for the builder map.
--      */
--     static terrain_code string_to_builder_number_(std::string str);

-- /***************************************************************************************/

-- const terrain_code OFF_MAP_USER = tonumber("_off^_usr");

-- const terrain_code VOID_TERRAIN = tonumber("_s");
-- const terrain_code FOGGED = tonumber("_f");

-- const terrain_code HUMAN_CASTLE = tonumber("Ch");
-- const terrain_code HUMAN_KEEP = tonumber("Kh");
-- const terrain_code SHALLOW_WATER = tonumber("Ww");
-- const terrain_code DEEP_WATER = tonumber("Wo");
-- const terrain_code GRASS_LAND = tonumber("Gg");
-- const terrain_code FOREST = tonumber("Gg^Ff");
-- const terrain_code MOUNTAIN = tonumber("Mm");
-- const terrain_code HILL = tonumber("Hh");

-- const terrain_code CAVE_WALL = tonumber("Xu");
-- const terrain_code CAVE = tonumber("Uu");
-- const terrain_code UNDERGROUND_VILLAGE = tonumber("Uu^Vu");
-- const terrain_code DWARVEN_CASTLE = tonumber("Cud");
-- const terrain_code DWARVEN_KEEP = tonumber("Kud");

-- const terrain_code PLUS = tonumber("+");
-- const terrain_code MINUS = tonumber("-");
-- const terrain_code NOT = tonumber("!");
-- const terrain_code STAR = tonumber("*");
-- const terrain_code BASE = tonumber("_bas");


-- const ter_match ALL_OFF_MAP("_off^_usr,*^_fme");
-- const ter_match ALL_FORESTS("F*,*^F*");
-- const ter_match ALL_HILLS("!,*^V*,!,H*");
-- const ter_match ALL_MOUNTAINS("!,*^V*,!,M*"); //excluding impassable mountains
-- const ter_match ALL_SWAMPS("!,*^V*,*^B*,!,S*"); //excluding swamp villages and bridges

-- /***************************************************************************************/




-- ter_match::ter_match() :
--     terrain(),
--     mask(),
--     masked_terrain(),
--     has_wildcard(false),
--     is_empty(true)
-- {}

-- ter_match::ter_match(const std::string& str, const ter_layer filler) :
--     terrain(t_translation::read_list(str, filler)),
--     mask(),
--     masked_terrain(),
--     has_wildcard(t_translation::has_wildcard(terrain)),
--     is_empty(terrain.empty())

-- {
--     mask.resize(terrain.size());
--     masked_terrain.resize(terrain.size());

--     for(size_t i = 0; i < terrain.size(); i++) {
--         mask[i] = t_translation::get_mask_(terrain[i]);
--         masked_terrain[i] = mask[i] & terrain[i];
--     }
-- }

-- ter_match::ter_match(const terrain_code& tcode):
--     terrain(ter_list(1, tcode)),
--     mask(),
--     masked_terrain(),
--     has_wildcard(t_translation::has_wildcard(terrain)),
--     is_empty(terrain.empty())
-- {
--     mask.resize(terrain.size());
--     masked_terrain.resize(terrain.size());

--     for(size_t i = 0; i < terrain.size(); i++) {
--         mask[i] = t_translation::get_mask_(terrain[i]);
--         masked_terrain[i] = mask[i] & terrain[i];
--     }
-- }

-- terrain_tonumber = (str) ->
string_to_terrain = (str) ->
    assert(str)
        -- .* : matches any 0+ characters as many as possibl
        --    (in a "greedy" way, since the whole string is grabbed and then backtracking occurs to find...)
        -- %^ : the last literal ^
        -- (.*) - match and capture any 0+ characters (up to the end of the string).
    base = str\match("^(.*)%^.*")
    overlay = str\match("^.*%^(.*)")
    unless base
        base = str
    -- print "terrain string is #{str}"
    -- print "base is #{base}"
    -- print "overlay is #{overlay}"
    return {
        :base
        :overlay
    }


----
-- @return terrain_code
-- const std::string& str
-- const ter_layer filler
read_terrain_code = (str, filler) ->
    assert(str, "no str arg provided")
    return string_to_terrain(str)
    -- return terrain_tonumber(str, filler)

-- std::string write_terrain_code(const terrain_code& tcode)
-- {
--     return number_to_string_(tcode);
-- }

----
-- @return ter_list
-- read_list(const std::string& str, const ter_layer filler)
read_list = (str, filler) ->

    result = {}

    -- Handle an empty string
    if str == ''
        return result

    return splitv(str, ',')

    -- for terrain in splitv(str, ',')
--     size_t offset = 0;
--     while(offset < str.length()) {

--         // Get a terrain chunk
--         const std::string separators = ",";
--         const size_t pos_separator = str.find_first_of(separators, offset);
--         const std::string terrain = str.substr(offset, pos_separator - offset);

--         // Process the chunk
--         const terrain_code tile = tonumber(terrain, filler);

--         // Add the resulting terrain number
--         result.push_back(tile);

--         // Evaluate the separator
--         if(pos_separator == std::string::npos) {
--             offset =  str.length();
--         } else {
--             offset = pos_separator + 1;
--         }
--     }

    -- return result


-- std::string write_list(const ter_list& list)
-- {
--     std::stringstream result;

--     ter_list::const_iterator itor = list.begin();
--     for( ; itor != list.end(); ++itor) {
--         if(itor == list.begin()) {
--             result << number_to_string_(*itor);
--         } else {
--             result << ", " << number_to_string_(*itor);
--         }
--     }

--     return result.str();
-- }

-- static std::pair<int, int> get_map_size(const char* begin, const char* end)
-- {
--     int w = 1;
--     int h = 0;
--     for (const char* it = begin; it != end;) {
--         int cur_w = 1;
--         ++h;


--         for (;it != end && (*it != '\n' && *it != '\r'); ++it) {
--             if (*it == ',') {
--                 ++cur_w;
--             }
--         }
--         w = std::max(w, cur_w);

--         while (it != end && (*it == '\n' || *it == '\r')) {
--             ++it;
--         }

--     }
--     return{ w, h };
-- }


-- std::string write_game_map(const ter_map& map, const starting_positions& starting_positions, coordinate border_offset)
-- {
--     std::stringstream str;

--     for(int y = 0; y < map.h; ++y) {
--         for(int x = 0; x < map.w; ++x) {

--             // If the current location is a starting position,
--             // it needs to be added to the terrain.
--             // After it's found it can't be found again,
--             // so the location is removed from the map.
--             auto itor = starting_positions.right.find(coordinate(x - border_offset.x, y - border_offset.y));
--             std::string starting_position;
--             if (itor != starting_positions.right.end()) {
--                 starting_position = itor->second;
--             }
--             // Add the separator
--             if(x != 0) {
--                 str << ", ";
--             }
--             str << number_to_string_(map[x][y], starting_position);
--         }

--         if (y < map.h -1)
--             str << "\n";
--     }

--     return str.str();
-- }

-- bool terrain_matches(const terrain_code& src, const terrain_code& dest)
-- {
--     return terrain_matches(src, ter_list(1, dest));
-- }

-- bool terrain_matches(const terrain_code& src, const ter_list& dest)
-- {
--     // NOTE we impose some code duplication.
--     // It could have been rewritten to get a match structure
--     // and then call the version with the match structure.
--     // IMO that's some extra overhead to this function
--     // which is not required. Hence the two versions
--     if(dest.empty()) {
--         return false;
--     }

-- #if 0
--     std::cerr << std::hex << "src = " << src.base << "^" << src.overlay << "\t"
--         << src_mask.base << "^" << src_mask.overlay << "\t"
--         << masked_src.base << "^" << masked_src.overlay << "\t"
--         << src_has_wildcard << "\n";
-- #endif

--     bool result = true;
--     ter_list::const_iterator itor = dest.begin();

--     // Try to match the terrains if matched jump out of the loop.
--     for(; itor != dest.end(); ++itor) {

--         // Match wildcard
--         if(*itor == STAR) {
--             return result;
--         }

--         // Match inverse symbol
--         if(*itor == NOT) {
--             result = !result;
--             continue;
--         }

--         // Full match
--         if(src == *itor) {
--             return result;
--         }

--         // Does the destination wildcard match
--         const terrain_code dest_mask = get_mask_(*itor);
--         const terrain_code masked_dest = (*itor & dest_mask);
--         const bool dest_has_wildcard = has_wildcard(*itor);
-- #if 0
--         std::cerr << std::hex << "dest= "
--             << itor->base << "^" << itor->overlay  << "\t"
--             << dest_mask.base << "^" << dest_mask.overlay << "\t"
--             << masked_dest.base << "^" << masked_dest.overlay << "\t"
--             << dest_has_wildcard << "\n";
-- #endif
--         if(dest_has_wildcard &&
--                 (src.base & dest_mask.base) == masked_dest.base &&
--                 (src.overlay & dest_mask.overlay) == masked_dest.overlay) {
--             return result;
--         }

-- /* Test code */ /*
--         if(src_has_wildcard && dest_has_wildcard && (
--                 (
--                     get_layer_mask_(itor->base) != NO_LAYER &&
--                     get_layer_mask_(src.overlay) != NO_LAYER &&
--                     (src.base & dest_mask.base) == masked_dest.base &&
--                     (itor->overlay & src_mask.overlay) == masked_src.overlay
--                 ) || (
--                     get_layer_mask_(itor->overlay) != NO_LAYER &&
--                     get_layer_mask_(src.base) != NO_LAYER &&
--                     (src.overlay & dest_mask.overlay) == masked_dest.overlay &&
--                     (itor->base & src_mask.base) == masked_src.base
--                 ))) {

--             return result;
--         }
-- */
--     }

--     // No match, return the inverse of the result
--     return !result;
-- }

-- // This routine is used for the terrain building,
-- // so it's one of the delays while loading a map.
-- // This routine is optimized a bit at the loss of readability.
-- bool terrain_matches(const terrain_code& src, const ter_match& dest)
-- {
--     if(dest.is_empty) {
--         return false;
--     }

--     bool result = true;

--     // Try to match the terrains if matched jump out of the loop.
--     // We loop on the dest.terrain since the iterator is faster than operator[].
--     // The i holds the value for operator[].
--     // Since dest.mask and dest.masked_terrain need to be in sync,
--     // they are less often looked up, so no iterator for them.
--     size_t i = 0;
--     ter_list::const_iterator end = dest.terrain.end();
--     for(ter_list::const_iterator terrain_itor = dest.terrain.begin();
--             terrain_itor != end;
--             ++i, ++terrain_itor) {

--         // Match wildcard
--         if(*terrain_itor == STAR) {
--             return result;
--         }

--         // Match inverse symbol
--         if(*terrain_itor == NOT) {
--             result = !result;
--             continue;
--         }

--         // Full match
--         if(*terrain_itor == src) {
--             return result;
--         }

--         // Does the destination wildcard match
--         if(dest.has_wildcard &&
--                 (src.base & dest.mask[i].base) == dest.masked_terrain[i].base &&
--                 (src.overlay & dest.mask[i].overlay) == dest.masked_terrain[i].overlay) {
--             return result;
--         }

-- /* Test code */ /*
--         if(src_has_wildcard && has_wildcard(*terrain_itor) && (
--                 (
--                     get_layer_mask_(terrain_itor->base) != NO_LAYER &&
--                     get_layer_mask_(src.overlay) != NO_LAYER &&
--                     (src.base & dest.mask[i].base) == dest.masked_terrain[i].base &&
--                     (terrain_itor->overlay & src_mask.overlay) == masked_src.overlay
--                 ) || (
--                     get_layer_mask_(terrain_itor->overlay) != NO_LAYER &&
--                     get_layer_mask_(src.base) != NO_LAYER &&
--                     (src.overlay & dest.mask[i].overlay) == dest.masked_terrain[i].overlay &&
--                     (terrain_itor->base & src_mask.base) == masked_src.base
--                 ))) {

--             return result;
--         }
-- */
--     }

--     // No match, return the inverse of the result
--     return !result;
-- }

-- bool has_wildcard(const terrain_code& tcode)
-- {
--     if(tcode.overlay == NO_LAYER) {
--         return get_layer_mask_(tcode.base) != NO_LAYER;
--     } else {
--         return get_layer_mask_(tcode.base) != NO_LAYER || get_layer_mask_(tcode.overlay) != NO_LAYER;
--     }
-- }

-- bool has_wildcard(const ter_list& list)
-- {
--     if(list.empty()) {
--         return false;
--     }

--     // Test all items for a wildcard
--     ter_list::const_iterator itor = list.begin();
--     for(; itor != list.end(); ++itor) {
--         if(has_wildcard(*itor)) {
--             return true;
--         }
--     }

--     // No wildcard found
--     return false;
-- }

-- ter_map read_builder_map(const std::string& str)
-- {
--     boost::multi_array<int, sizeof(ter_map)> a;

--     size_t offset = 0;
--     // Skip the leading newlines
--     while(offset < str.length() && utils::isnewline(str[offset])) {
--         ++offset;
--     }
--     // Did we get an empty map?
--     if((offset + 1) >= str.length()) {
--         return ter_map();
--     }

--     auto map_size = get_map_size(&str[offset], str.c_str() + str.size());
--     ter_map result(map_size.second, map_size.first, terrain_code(t_translation::TB_DOT, ter_layer()));

--     int x = 0, y = 0;
--     while(offset < str.length()) {

--         // Get a terrain chunk
--         const std::string separators = ",\n\r";
--         const size_t pos_separator = str.find_first_of(separators, offset);
--         std::string terrain = "";
--         // Make sure we didn't hit an empty chunk
--         // which is allowed
--         if(pos_separator != offset) {
--             terrain = str.substr(offset, pos_separator - offset);
--         }

--         // Process the chunk
--         const terrain_code tile = string_to_builder_number_(terrain);

--         // Make space for the new item
--         if (result.h <= x || result.w <= y) {
--             throw error("Map not a rectangle.");
--         }

--         // Add the resulting terrain number,
--         result.get(y, x) = tile;

--         // evaluate the separator
--         if(pos_separator == std::string::npos) {
--             // Probably not required to change the value,
--             // but be sure the case should be handled at least.
--             // I'm not sure how it is defined in the standard,
--             // but here it's defined at max u32 which with +1 gives 0
--             // and make a nice infinite loop.
--             offset = str.length();
--         } else if(utils::isnewline(str[pos_separator])) {
--             // Prepare next iteration
--             ++y;
--             x = 0;

--             offset =  pos_separator + 1;
--             // Skip the following newlines
--             while(offset < str.length() && utils::isnewline(str[offset])) {
--                 ++offset;
--             }

--         } else {
--             ++x;
--             offset = pos_separator + 1;
--         }

--     }

--     return result;
-- }

-- /***************************************************************************************/
-- // Internal

-- inline ter_layer get_layer_mask_(ter_layer terrain)
-- {
--     // Test for the star 0x2A in every position
--     // and return the appropriate mask
-- /*
--  *    This is what the code intents to do, but in order to gain some more
--  *    speed it's changed to the code below, which does the same but faster.
--  *    This routine is used often in the builder and the speedup is noticeable. */
--     if((terrain & 0xFF000000) == 0x2A000000) return 0x00000000;
--     if((terrain & 0x00FF0000) == 0x002A0000) return 0xFF000000;
--     if((terrain & 0x0000FF00) == 0x00002A00) return 0xFFFF0000;
--     if((terrain & 0x000000FF) == 0x0000002A) return 0xFFFFFF00;

-- /*
--     uint8_t *ptr = (uint8_t *) &terrain;

--     if(ptr[3] == 0x2A) return 0x00000000;
--     if(ptr[2] == 0x2A) return 0xFF000000;
--     if(ptr[1] == 0x2A) return 0xFFFF0000;
--     if(ptr[0] == 0x2A) return 0xFFFFFF00;
-- */
--     // no star found return the default
--     return 0xFFFFFFFF;
-- }

-- static terrain_code get_mask_(const terrain_code& terrain)
-- {
--     if(terrain.overlay == NO_LAYER) {
--         return terrain_code(get_layer_mask_(terrain.base), 0xFFFFFFFF);
--     } else {
--         return terrain_code(get_layer_mask_(terrain.base), get_layer_mask_(terrain.overlay));
--     }
-- }

-- static ter_layer string_to_layer_(const char* begin, const char* end)
-- {
--     size_t size = end - begin;
--     if (begin == end) {
--         return NO_LAYER;
--     }
--     ter_layer result = 0;

--     // Validate the string
--     VALIDATE(size <= 4, _("A terrain with a string with more "
--         "than 4 characters has been found, the affected terrain is :") + std::string(begin, end));

--     // The conversion to int puts the first char
--     // in the highest part of the number.
--     // This will make the wildcard matching
--     // later on a bit easier.
--     for(size_t i = 0; i < 4; ++i) {
--         const unsigned char c = (i < size) ? begin[i] : 0;

--         // Clearing the lower area is a nop on i == 0
--         // so no need for if statement
--         result <<= 8;

--         // Add the result
--         result += c;
--     }

--     return result;
-- }

----
-- static terrain_code
-- tonumber(const std::string& str, const ter_layer filler) {
-- terrain_tonumber = (str, filler)
    -- dummy = ''
    -- return tonumber(str, dummy, filler);


----
-- static terrain_code
-- tonumber(std::string str, std::string& start_position, const ter_layer filler)
terrain_tonumber = (str, start_position, filler) ->

    -- c_str = str.c_str();
    --     terrain_code result;
    result = {}

    -- Strip the spaces around us
    -- whitespace = " \t"
    --     size_t begin = str.find_first_not_of(whitespace);
    --     size_t end = str.find_last_not_of(whitespace) + 1;
    --     if(begin == std::string::npos) {
    --         return result;
    --     }

    --     // Split if we have 1 space inside
    --     size_t offset = str.find(' ', begin);
    --     if(offset < end) {
    --         try {
    --             start_position = str.substr(begin, offset - begin);
    --         } catch(bad_lexical_cast&) {
    --             return VOID_TERRAIN;
    --         }
    --         begin = offset + 1;
    --     }

    --     offset = str.find('^', 0);
    --     if(offset !=  std::string::npos) {
    --         result = terrain_code { string_to_layer_(c_str + begin, c_str + offset), string_to_layer_(c_str + offset + 1, c_str + end) };
    --     } else {
    --         result = terrain_code { string_to_layer_(c_str + begin, c_str + end), filler };

    --         // Ugly hack
    --         if(filler == WILDCARD && (result.base == NOT.base ||
    --                 result.base == STAR.base)) {

    --             result.overlay = NO_LAYER;
    --         }
    --     }
    base, overlay = "amok", "lauf"

    return result


-- static terrain_code string_to_builder_number_(std::string str)
-- {
--     // Strip the spaces around us
--     const std::string& whitespace = " \t";
--     str.erase(0, str.find_first_not_of(whitespace));
--     if(! str.empty()) {
--         str.erase(str.find_last_not_of(whitespace) + 1);
--     }

--     // Empty string is allowed here, so handle it
--     if(str.empty()) {
--         return terrain_code();
--     }

--     const int number = lexical_cast_default(str, -1);
--     if(number == -1) {
--         // At this point we have a single char
--         // which should be interpreted by the
--         // map builder, so return this number
--         return terrain_code(str[0] << 24, 0);
--     } else {
--         return terrain_code(0, number);
--     }
-- }

-- } // end namespace t_translation

-- #if 0
-- // small helper rule to test the matching rules
-- // building rule
-- // make terrain_translation.o &&  g++ terrain_translation.o libwesnoth-core.a -lSDL -o terrain_translation
-- int main(int argc, char** argv)
-- {
--     if(argc > 1) {

--         if(std::string(argv[1]) == "match" && argc == 4) {
--             t_translation::terrain_code src = t_translation::read_terrain_code(std::string(argv[2]));

--             t_translation::ter_list dest = t_translation::read_list(std::string(argv[3]));

--             if(t_translation::terrain_matches(src, dest)) {
--                 std::cout << "Match\n" ;
--             } else {
--                 std::cout << "No match\n";
--             }
--         }
--     }
-- }
-- #endif


--     :PLUS
--     :MINUS
--     :NOT
--     :STAR
--     :BASE

-- }
{
    PLUS:  '+'
    MINUS: '-'
    NOT:   '!'
    STAR:  '*'
    BASE:  "_bas"
    :read_list
    :read_terrain_code
}

