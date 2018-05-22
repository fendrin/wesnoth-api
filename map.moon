----
-- LuaWSL:Tiles
-- This page describes the LuaWSL functions for handling terrains and tiles. The items library can be loaded by
-- @usage items = wesmere.require "lua/wsl/items.lua"
-- @submodule wesmere


-- array2d = require "pl.array2d"
-- import content from require "server.wesnoth.wesmods"
dir = (...)\match"(.-)[^%.]+$"
import try from require "#{dir}.misc"
Location = require "shared.Location"

BORDER_SIZE = 1


parse_map_string = (map_string, border_size=BORDER_SIZE) ->
    assert(map_string)
    -- log.trace("Parsing map string: " .. map_string)
    map = {
        starting_location: {}
    }

    y = 1 - border_size
    local x
    for line in string.gmatch(map_string, "[^\r\n]+")
        x = 1 - border_size
        for hex_string in string.gmatch(line, "([^,]+)")
            map[x] = {} if map[x] == nil
            terrain_string = {}
            for thing in string.gmatch(hex_string, "([^ ]+)")
                table.insert(terrain_string, thing)
            if #terrain_string == 1
                map[x][y] = terrain_string[1]\match"^%s*(.-)%s*$"
            else
                map[x][y] = terrain_string[2]\match"^%s*(.-)%s*$"
                map.starting_location[tonumber(terrain_string[1])] = {
                    x: x
                    y: y
                }
            x += 1
        y += 1
    with map
        .width = x-1-border_size
        .height = y-1-border_size
        .border_size = border_size
    return map


load_map = (map_str, border_size=BORDER_SIZE) =>

    @board.map = parse_map_string(map_str, border_size)



    -- export Map = @board.map
    --     if starting_locations = map.starting_location
    --         for start_loc in *starting_locations
    --             location = Location(start_loc)
    --             side = start_loc.side
    --             assert(side, "No side in starting_location")
    --             if starting_side = @sides[side]
    --                 starting_side.starting_location = location


    -- else
    --     error("Map with id '#{id}' not found")

    -- @board.villages = array2d.new(@board.map.width, @board.map.height) -- , false)


----
-- Returns the width, the height, and the border size of the map.
-- @function wesmere.get_map_size
-- @tab state the game state
-- @treturn number width
-- @treturn number height
-- @treturn number border size
-- @usage w,h,b = wesmere.get_map_size!
get_map_size = () =>
    width  = @board.map.width
    height = @board.map.height
    border = @board.map.border_size
    return width, height, border

----
-- Returns the terrain code for the given location.
-- @tab self the game state
-- @tparam number x
-- @tparam number y
-- @usage is_grassland = wesmere.get_terrain(12, 15) == "Gg"
get_terrain = (x, y) =>
    -- local loc
    -- try
        -- do: -> loc = Location(x,y)
        -- catch: (err) -> error "get_terrain: Invalid arguments: #{err}"
    return nil unless @board.map[x]
    return nil unless @board.map[x][y]
    return @board.map[x][y]

----
-- Modifies the terrain at the given location.
-- wesmere.set_terrain
-- @tab self the game state
-- @number x
-- @number y
-- @string terrain_code
-- @string[opt="both"] layer An optional 4th parameter can be passed (layer): overlay, base or both, default both: Change the specified layer only.
-- @bool[opt=false] replace_if_failed An optional 5th boolean parameter (replace_if_failed) can be passed, see the documentation of the 'terrain' table. To pass the 5th parameter but not the 4th, pass nil for the 4th.
-- @treturn string the replaced terrain code
-- @usage create_village = (x, y) ->
--     wesmere.set_terrain(x, y, "Gg^Vh")
set_terrain = (x, y, terrain_code, layer="both", replace_if_failed=false) =>
    old = board.map[x][y]
    -- base, overlay = old\match("([^\^]+),([^\^]+)")

    switch layer
        when nil
            @board.map[x][y] = terrain_code
        when "both"
            @board.map[x][y] = terrain_code
        when "overlay"
            @board.map[x][y] = base + "^" + terrain_code
        when "base"
            @board.map[x][y] = terrain_code + "^" + overlay
        else
            @wesmere.wsl_error("wesmere.set_terrain: unknown layer: " + layer)

    return old

----
-- Returns the terrain details for the given terrain code.
-- @function wesmere.get_terrain_info
-- @string terrain_code
-- @usage is_keep = wesmere.get_terrain_info(wesmere.get_terrain(12, 15)).keep
-- @treturn {id=string,name=tstring,description=tstring,editor_name=tstring,castle=bool,keep=bool,village=bool,healing=number} Terrain info is a plain table.
get_terrain_info = (terrain_code) ->
    -- return {
    --     id:
    --     name:
    --     description:
    --     editor_name:
    --     castle:
    --     keep:
    --     village:
    --     healing:
    -- }


----
-- Returns the two coordinates of the currently selected tile. This is mostly useful for defining command-mode helpers.
-- @function wesmere.get_selected_tile
-- @treturn number x
-- @treturn number y
-- @usage chg_unit = (attr, val) ->
--    x, y = wesmere.get_selected_tile()
--    if not x then wesmere.message("Error", "No unit selected."); return
--    helper.modify_unit({ x = x, y = y }, { [attr]: val })
-- Function chg_unit can be used in command mode to modify unit attributes on the fly:
--   :lua chg_unit("status.poisoned", true)
get_selected_tile = () ->


----
-- This function, when called without arguments, returns a table containing all the villages present on the map (as tables of two elements). If it's called with a WSL table as argument, a table containing only the villages matching the supplied StandardLocationFilter is returned.
-- @function wesmere.get_villages
-- @tparam[opt] StandardLocationFilter filter
-- @treturn {Location,...}
-- @usage -- How many villages do we have on our map?
-- v = #wesmere.get_villages!
get_villages = (filter) ->
    local locations
    try
        do: -> locations = get_locations(filter)
        catch: (err) -> error "get_villages: #{err}"
    return for loc in locations
        if is_village(loc)
            loc
        else continue


----
-- Returns true if the given location passes the filter.
-- wesmere.match_location
-- @tab self the game state
-- @number x
-- @number y
-- @tparam StandardLocationFilter filter
-- @usage b = wesmere.match_location(x, y, { terrain: "Ww", { "filter_adjacent_location", terrain: "Ds,*^Bw*" } })
match_location = (x, y, filter) =>

    local loc
    try
        do: ->
            loc = Location(x,y)
        catch: (err) ->
            error "match_location: Invalid location arguements #{err}"

    -- Filter Areas
    -- if (cfg_.has_attribute("area") &&
    --     fc_->get_tod_man().get_area_by_id(cfg_["area"]).count(loc) == 0)
    --    return false;
    if area = filter.area
        -- @todo implement
        return false

    -- if(cfg_.has_attribute("terrain")) {
    --     if(cache_.parsed_terrain == NULL) {
    --         cache_.parsed_terrain = new t_translation::t_match(cfg_["terrain"]);
    --     }
    --     if(!cache_.parsed_terrain->is_empty) {
    --         const t_translation::t_terrain letter = fc_->get_disp_context().map().get_terrain_info(loc).number();
    --         if(!t_translation::terrain_matches(letter, *cache_.parsed_terrain)) {
    --             return false;
    --         }
    --     }
    -- }
    if terrain = filter.terrain
        -- @todo implement
        return false

    -- //Allow filtering on location ranges
    -- if(!ignore_xy) {
    --     if(!loc.matches_range(cfg_["x"], cfg_["y"])) {
    --         return false;
    --     }
    --     //allow filtering by searching a stored variable of locations
    --     if(cfg_.has_attribute("find_in")) {
    --         if (const game_data * gd = fc_->get_game_data()) {
    --             try
    --             {
    --                 variable_access_const vi = gd->get_variable_access_read(cfg_["find_in"]);

    --                 bool found = false;
    --                 BOOST_FOREACH(const config &cfg, vi.as_array()) {
    --                     if (map_location(cfg, NULL) == loc) {
    --                         found = true;
    --                         break;
    --                     }
    --                 }
    --                 if (!found) return false;
    --             }
    --             catch(const invalid_variablename_exception&)
    --             {
    --                 return false;
    --             }
    --         }
    --     }
    -- }
    unless ignore_xy
        return false unless loc\matches_range(filter.x, filter.y)

    -- //Allow filtering on unit
    -- if(cfg_.has_child("filter")) {
    --     const unit_map::const_iterator u = fc_->get_disp_context().units().find(loc);
    --     if (!u.valid())
    --         return false;
    --     if (!cache_.ufilter_)
    --         cache_.ufilter_.reset(new unit_filter(vconfig(cfg_.child("filter")), fc_, flat_));
    --     if (!cache_.ufilter_->matches(*u, loc))
    --         return false;
    -- }
    if unit_filter = filter.filter
        unit = get_unit(loc)
        return false unless unit\match(unit_filter)

    -- // Allow filtering on visibility to a side
    -- if (cfg_.has_child("filter_vision")) {
    --     const vconfig::child_list& vis_filt = cfg_.get_children("filter_vision");
    --     vconfig::child_list::const_iterator i, i_end = vis_filt.end();
    --     for (i = vis_filt.begin(); i != i_end; ++i) {
    --         bool visible = (*i)["visible"].to_bool(true);
    --         bool respect_fog = (*i)["respect_fog"].to_bool(true);
    --         side_filter ssf(*i, fc_);
    --         std::vector<int> sides = ssf.get_teams();
    --         bool found = false;
    --         BOOST_FOREACH(const int side, sides) {
    --             const team &viewing_team = fc_->get_disp_context().teams().at(side - 1);
    --             bool viewer_sees = respect_fog ? !viewing_team.fogged(loc) : !viewing_team.shrouded(loc);
    --             if (visible == viewer_sees) {
    --                 found = true;
    --                 break;
    --             }
    --         }
    --         if (!found) {return false;}
    --     }
    -- }
    if vision_filter = filter.filter_vision
        for each in vision_filter
            visible = each.visible != 0
            respect_fog = each.respect_fog

    -- //Allow filtering on adjacent locations
    -- if(cfg_.has_child("filter_adjacent_location")) {
    --     map_location adjacent[6];
    --     get_adjacent_tiles(loc, adjacent);
    --     const vconfig::child_list& adj_cfgs = cfg_.get_children("filter_adjacent_location");
    --     vconfig::child_list::const_iterator i, i_end, i_begin = adj_cfgs.begin();
    --     for (i = i_begin, i_end = adj_cfgs.end(); i != i_end; ++i) {
    --         int match_count = 0;
    --         vconfig::child_list::difference_type index = i - i_begin;
    --         std::vector<map_location::DIRECTION> dirs = (*i).has_attribute("adjacent")
    --             ? map_location::parse_directions((*i)["adjacent"]) : map_location::default_dirs();
    --         std::vector<map_location::DIRECTION>::const_iterator j, j_end = dirs.end();
    --         for (j = dirs.begin(); j != j_end; ++j) {
    --             map_location &adj = adjacent[*j];
    --             if (fc_->get_disp_context().map().on_board(adj)) {
    --                 if(cache_.adjacent_matches == NULL) {
    --                     while(index >= std::distance(cache_.adjacent_match_cache.begin(), cache_.adjacent_match_cache.end())) {
    --                         const vconfig& adj_cfg = adj_cfgs[cache_.adjacent_match_cache.size()];
    --                         std::pair<terrain_filter, std::map<map_location,bool> > amc_pair(
    --                             terrain_filter(adj_cfg, *this),
    --                             std::map<map_location,bool>());
    --                         cache_.adjacent_match_cache.push_back(amc_pair);
    --                     }
    --                     terrain_filter &amc_filter = cache_.adjacent_match_cache[index].first;
    --                     std::map<map_location,bool> &amc = cache_.adjacent_match_cache[index].second;
    --                     std::map<map_location,bool>::iterator lookup = amc.find(adj);
    --                     if(lookup == amc.end()) {
    --                         if(amc_filter(adj)) {
    --                             amc[adj] = true;
    --                             ++match_count;
    --                         } else {
    --                             amc[adj] = false;
    --                         }
    --                     } else if(lookup->second) {
    --                         ++match_count;
    --                     }
    --                 } else {
    --                     assert(index < std::distance(cache_.adjacent_matches->begin(), cache_.adjacent_matches->end()));
    --                     std::set<map_location> &amc = (*cache_.adjacent_matches)[index];
    --                     if(amc.find(adj) != amc.end()) {
    --                         ++match_count;
    --                     }
    --                 }
    --             }
    --         }
    --         static std::vector<std::pair<int,int> > default_counts = utils::parse_ranges("1-6");
    --         std::vector<std::pair<int,int> > counts = (*i).has_attribute("count")
    --             ? utils::parse_ranges((*i)["count"]) : default_counts;
    --         if(!in_ranges(match_count, counts)) {
    --             return false;
    --         }
    --     }
    -- }

    -- const t_string& t_tod_type = cfg_["time_of_day"];
    -- const t_string& t_tod_id = cfg_["time_of_day_id"];
    -- const std::string& tod_type = t_tod_type;
    -- const std::string& tod_id = t_tod_id;
    -- if(!tod_type.empty() || !tod_id.empty()) {
    --     // creating a time_of_day is expensive, only do it if we will use it
    --     time_of_day tod;
    --     if(flat_) {
    --         tod = fc_->get_tod_man().get_time_of_day(loc);
    --     } else {
    --         tod = fc_->get_tod_man().get_illuminated_time_of_day(fc_->get_disp_context().units(), fc_->get_disp_context().map(),loc);
    --     }
    --     if(!tod_type.empty()) {
    --         const std::vector<std::string>& vals = utils::split(tod_type);
    --         if(tod.lawful_bonus<0) {
    --             if(std::find(vals.begin(),vals.end(),lexical_cast<std::string>(unit_type::ALIGNMENT::CHAOTIC)) == vals.end()) {
    --                 return false;
    --             }
    --         } else if(tod.lawful_bonus>0) {
    --             if(std::find(vals.begin(),vals.end(),lexical_cast<std::string>(unit_type::ALIGNMENT::LAWFUL)) == vals.end()) {
    --                 return false;
    --             }
    --         } else if(std::find(vals.begin(),vals.end(),lexical_cast<std::string>(unit_type::ALIGNMENT::NEUTRAL)) == vals.end()) {
    --             return false;
    --         }
    --     }
    --     if(!tod_id.empty()) {
    --         if(tod_id != tod.id) {
    --             if(std::find(tod_id.begin(),tod_id.end(),',') != tod_id.end() &&
    --                 std::search(tod_id.begin(),tod_id.end(),
    --                 tod.id.begin(),tod.id.end()) != tod_id.end()) {
    --                 const std::vector<std::string>& vals = utils::split(tod_id);
    --                 if(std::find(vals.begin(),vals.end(),tod.id) == vals.end()) {
    --                     return false;
    --                 }
    --             } else {
    --                 return false;
    --             }
    --         }
    --     }
    -- }

    -- //allow filtering on owner (for villages)
    -- const config::attribute_value &owner_side = cfg_["owner_side"];
    -- const vconfig& filter_owner = cfg_.child("filter_owner");
    -- if(!filter_owner.null()) {
    --     if(!owner_side.empty()) {
    --         WRN_NG << "duplicate side information in a SLF, ignoring inline owner_side=" << std::endl;
    --     }
    --     if(!fc_->get_disp_context().map().is_village(loc))
    --         return false;
    --     side_filter ssf(filter_owner, fc_);
    --     const std::vector<int>& sides = ssf.get_teams();
    --     bool found = false;
    --     if(sides.empty() && fc_->get_disp_context().village_owner(loc) == -1)
    --         found = true;
    --     BOOST_FOREACH(const int side, sides) {
    --         if(fc_->get_disp_context().teams().at(side - 1).owns_village(loc)) {
    --             found = true;
    --             break;
    --         }
    --     }
    --     if(!found)
    --         return false;
    -- }
    -- else if(!owner_side.empty()) {
    --     const int side_index = owner_side.to_int(0) - 1;
    --     if(fc_->get_disp_context().village_owner(loc) != side_index) {
    --         return false;
    --     }
    -- }
    if owner_side = filter.owner_side
        return false if @board.village[loc.x][loc.y] != owner_side

    if filter_owner = filter.filter_owner
        owner_side = @board.village[loc.x][loc.y]
        return false unless match_side(owner_side, filter_owner)

    return true

----
-- Returns a table containing all the locations matching the given filter. Locations are stored as pairs: tables of two elements.
-- @function wesmere.get_locations
-- @tparam StandardLocationFilter See StandardLocationFilter for details about location filters.
-- @treturn {Location,...} The matching locations
-- @usage -- replace all grass terrains by roads
-- for loc in *wesmere.get_locations { terrain: "Gg" }
--     wesmere.set_terrain(loc[1], loc[2], "Rr")
get_locations = (filter) =>

    assert(type(filter) == "table" or type(filter) == "function", "get_locations: Filter argument must be a table or function")

    result = {}
    for x=1, @board.map.width
        for y=1, @board.map.width
            if match_location(@, x, y, filter)
                table.insert(result, Location(x,y))

    -- get_ranges = (x, y) ->
    --     x_ranges = {}
    --     y_ranges = {}

    --     lower_x, upper_x = x\gmatch("^-","-^")
    --     lower_y, upper_y = y\gmatch("^-","-^")

    -- return for loc in *get_ranges(x,y)
    --     if match_location(@, loc.x, loc.y, filter)
    --         loc
    --     else continue
    return result


----
-- Places a tile overlay (either an image or a halo) at a given location. The overlay is described by a table supporting the same fields as [item]. Note that the overlay is not kept over save/load cycles.
-- @function wesmere.add_tile_overlay
-- @number x
-- @number y
-- @tab item_wsl
-- @usage wesmere.add_tile_overlay(17, 42, { image: "items/orcish-flag.png" })
add_tile_overlay = (x, y, item_wsl) ->

----
-- Removes all the overlays at the given location. If a filename is passed as a third argument, only this overlay (either image or halo) is removed.
-- @function wesmere.remove_tile_overlay
-- @number x
-- @number y
-- @string[opt] filename
-- @usage wesmere.remove_tile_overlay(17, 42, "items/orcish-flag.png")
remove_tile_overlay = (x, y, filename) ->

----
-- Places an image at a given location and registers it as a WSL [item] would do, so that it can be restored after save/load.
-- @function items.place_image
-- @number x
-- @number y
-- @string filename
-- @usage items = wesmere.require "lua/wsl/items.lua"
-- items.place_image(17, 42, "items/orcish-flag.png")
-- items.place_image = (x, y, filename) ->

----
-- Behaves the same as #items.place_image but for halos.
-- @function items.place_halo
-- @number x
-- @number y
-- @string filename
-- items.place_halo = (x, y, filename) ->

----
-- Removes an overlay set by #items.place_image or #items.place_halo. If no filename is provided, all the overlays on a given tile are removed.
-- @function items.remove
-- @number x
-- @number y
-- @string[opt] filename
-- @usage items.remove(17, 42, "items/orcish-flag.png")
-- items.remove = (x, x, filename) ->


{
    :load_map
    :parse_map_string
    -- :board
    :get_map_size
    :get_terrain
    :set_terrain
    :get_terrain_info
    :get_selected_tile
    :get_locations
    :get_villages
    :match_location
    :add_tile_overlay
    :remove_tile_overlay
    --items.place_image
    --items.place_halo
    --items.remove
}
