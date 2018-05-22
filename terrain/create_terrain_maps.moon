
Terrain_Type = require"wesnoth.terrain.Terrain_Type"

----
-- @todo
-- void create_terrain_maps(const config::const_child_itors &cfgs,
--                          t_translation::ter_list& terrain_list,
--                          std::map<t_translation::terrain_code,
--                          terrain_type>& letter_to_terrain);
----
-- const config::const_child_itors &cfgs,
-- t_translation::ter_list& terrain_list,
-- std::map<t_translation::terrain_code,
-- terrain_type>& letter_to_terrain)
create_terrain_maps = (cfgs, terrain_list, string_to_terrain) ->

    -- print"creating terrain maps"

    for id, terrain_cfg in pairs cfgs

        terrain = Terrain_Type(terrain_cfg)

        -- DBG_G("create_terrain_maps: " .. terrain.number .. " " ..
            -- terrain.id .. " " .. terrain.name .. " : " ..
            -- terrain.editor_group .. "\n")

        -- std::pair<std::map<t_translation::terrain_code,
        --     terrain_type>::iterator, bool> res;
        -- res = letter_to_terrain.emplace(terrain.number(), terrain);
        -- res = @letter_to_terrain[]
        -- unless letter_to_terrain[terrain.number]

        --     curr = letter_to_terrain[terrain.number]
        --     if terrain == curr
        --         LOG_G("Merging terrain " .. terrain.number ..
        --             ": " .. terrain.id .. " (" .. terrain.name .. ")\n")
        --         -- std::vector<std::string>
        --         eg1 = utils.split(curr.editor_group())
        --         -- std::vector<std::string>
        --         eg2 = utils.split(terrain.editor_group())
        --         -- std::set<std::string> egs;
        --         egs = Set!
        --         clean_merge = true
        --         for t_ in *eg1
        --             clean_merge = clean_merge and egs.insert(t_)
        --         for t_ in *eg2
        --             clean_merge = clean_merge and egs.insert(t_)

        --         joined = utils.join(egs)
        --         curr.set_editor_group(joined)
        --         if clean_merge
        --             LOG_G("Editor groups merged to: " .. joined .. "\n")
        --         else
        --             LOG_G("Merged terrain " .. terrain.number ..
        --                 ": " .. terrain.id .. " (" .. terrain.name .. ") " ..
        --                 "with duplicate editor groups [" .. terrain.editor_group .. "] " ..
        --                 "and [" .. curr.editor_group .. "]\n")

        --     else
        --         ERR_G("Duplicate terrain code definition found for " ..
        --             terrain.number .. "\n" ..
        --             "Failed to add terrain " .. terrain.id .. " (" ..
        --             terrain.name .. ") " ..
        --             "[" .. terrain.editor_group .. "]" .. "\n" ..
        --             "which conflicts with  " .. curr.id .. " (" .. curr.name .. ") " ..
        --             "[" .. curr.editor_group .. "]" .. "\n\n")
        -- else
            -- table.insert(terrain_list, terrain.number)
        string_to_terrain[terrain.string] = terrain
        table.insert(terrain_list, terrain.string)


return create_terrain_maps
