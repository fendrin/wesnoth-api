----
-- @submodule wesmere

-- LuaWSL:Variables
-- This page describes the LuaWSL functions and helpers for handling WSL variables and containers.

----
-- Loads a WSL variable with the given qualified name (argument 1) and converts it into a Lua object. Returns nil if the name does not point to anything, a scalar for a WSL attribute, and a table for a WSL object. The format of the table is described in LuaWSL#Encoding WSL objects into Lua tables.
-- Argument 2, if true, prevents the recursive conversion when the name points to an object; a fresh empty table is returned in this case. This is mainly used for writing proxy objects, e.g. in #helper.set_wsl_var_metatable.
-- Note that, if the variable name happens to designate a sequence of WSL objects, only the first one (index 0) is fetched. If all the WSL objects with this name should have been returned, use #helper.get_variable_array instead.
-- @function wesmere.get_variable
-- @usage wesmere.fire("store_unit", { variable:"my_unit", filter: { id:"hero" } } )
-- heros_hp = wesmere.get_variable("my_unit[0].hitpoints")
-- wesmere.message(string.format("The 'hero' unit has %d hitpoints.", heros_hp))
get_variable = (var_name) =>
    assert(@)
    assert(var_name)
    local value
    set_value = (val) ->
        value = val
    @current.event_context._set_value = set_value
    fun, err = load("_set_value(#{var_name})", "get_variable:", "t", @current.event_context)
    unless fun
        error(err)
    else fun!
    return value


----
-- Stores a Lua value (argument 2) to a WSL variable (argument 1).
-- Setting a WSL variable to nil erases it.
-- @function wesmere.set_variable
-- @usage wesmere.set_variable("my_unit.hitpoints", heros_hp + 10)
set_variable = (var_name, value) =>
    assert(@)
    assert(@current.event_context)
    @current.event_context._value = value
    return unless var_name
    assert(var_name, "wesmere.set_variable: Missing 'var_name' argument.")
    fun, err = load("#{var_name} = _value", "set_variable:", "t", @current.event_context)
    unless fun
        error(err)
    else fun!


----
-- Returns all the WSL variables currently set in form of a WSL table.
-- @function wesmere.get_all_vars
-- @usage wesmere.get_all_vars = () ->
-- for key, value in pairs( wesmere.get_all_vars! )
--     if type( value ) == "table"
--         print( key, value[1], value[2] )
--     else
--         print( key, value )
get_all_vars = () =>
    return @current.event_context


--
-- Sets the metatable of a table so that it can be used to access WSL variables. Returns the table. The fields of the tables are then proxies to the WSL objects with the same names; reading/writing to them will directly access the WSL variables.
-- helper.set_wsl_var_metatable(_G)
-- my_persistent_variable = 42
-- it's not reccomended to use helper.set_wsl_var_metatable(_G) because that limits possible gobal variables to valid wsl attributes or tables. This can have some surprising effects:
-- c = { a= 9}
-- d = c
-- c.a = 8
-- wesmere.message(d.a) -- normaly prints 8 but prints 9 with helper.set_wsl_var_metatable(_G)
-- local lla = { {"a", {}}}
-- lla[1][2] = lla
-- la = lla -- crashes wesmere with helper.set_wsl_var_metatable(_G)
-- helper = wesmere.require("lua/helper.lua")
-- helper.set_wsl_var_metatable(_G)
-- -- some code later (maybe in another addon)
-- H = wesmere.require("lua/helper.lua") -- fails because wesmere.require("lua/helper.lua") doesn' return a valid wsltable..
-- helper = wesmere.require("lua/helper.lua")
-- helper.set_wsl_var_metatable(_G)
-- -- some code later (maybe in another addon)
-- T = helper.set_wsl_tag_metatable {}  -- doesn't work
-- V = helper.set_wsl_var_metatable({}) -- doesn't work
-- even if you don't use such code in your addon it's still bad because other code of modifications or eras to be used with your addon might do. And you'll mess up their code. This is also true for SP campaigns because it might interfere with ai code and we plan to enable modifications in SP too. Instead you should use set_wsl_var_metatable with another table ('V' in this example):
-- V = helper.set_wsl_var_metatable({})
-- V.my_persistent_variable = 42
-- @function helper.set_wsl_var_metatable
--helper.set_wsl_var_metatable = () ->


--
-- Returns the first sub-tag of a WSL object with the given name.
-- If a third parameter is passed, only children having a id attribute equal to it are considered.
-- @function helper.get_child
-- @usage u = wesmere.get_units({ id = "Delfador" })[1]
-- costs = helper.get_child(u.__cfg, "movement_costs")
-- wesmere.message(string.format("Delfador needs %d points to move through a forest.", costs.forest))
--helper.get_child = (config, child_tag_name) ->

--
-- Returns the nth sub-tag of a WSL object with the given name.
-- @function helper.get_nth_child
-- @param config
-- @param child_tag_name
-- @param n
--helper.get_child = (config, child_tag_name, n) ->

--
-- Returns the number of children in the config with the given tag name.
-- @function helper.child_count
--helper.child_count = (config, child_tag_name) ->

--
-- Returns an iterator over all the sub-tags of a WSL object with the given name.
-- @function helper.child_range
-- helper.child_range = (config, child_tag_name) ->
--     u = wesmere.get_units({ id: "Delfador" })[1]
--     for att in helper.child_range(u.__cfg, "attack")
--         wesmere.message(tostring(att.description))

--
-- Like helper.child_range, but returns an array instead of an iterator. Useful if you need random access to the children.
-- @function helper.child_array
--helper.child_array = (config, child_tag_name) ->

--
-- Fetches all the WSL container variables with given name and returns a table containing them (starting at index 1).
-- @function helper.get_variable_array
-- @usage get_recall_list = (side) ->
--     wesmere.fire("store_unit", { x: "recall", variable: "LUA_recall_list })
--     l = get_variable_array "LUA_recall_list"
--     wesmere.set_variable "LUA_recall_list"
--     return l
-- helper.get_variable_array = (var_name) ->


--
-- Creates proxies for all the WSL container variables with given name and returns a table containing them (starting at index 1).
-- This function is similar to #helper.get_variable_array, except that the proxies can be used for modifying WSL containers.
-- @function helper.get_variable_proxy_array
-- helper.get_variable_proxy_array = (var_name) ->


--
-- Creates WSL container variables with given name from given table.
-- @function helper.set_variable_array
-- helper.set_variable_array = (varname, array) ->
--     helper.set_variable_array("target", { t1, t2, t3 })
--     -- target[0] <- t1; target[1] <- t2; target[2] <- t3


{
    :get_variable
    :set_variable
    :get_all_vars -- (Version 1.13.0 and later only)
-- helper.set_wml_var_metatable
-- helper.get_child
-- helper.get_nth_child (Version 1.13.2 and later only)
-- helper.child_count (Version 1.13.2 and later only)
-- helper.child_range
-- helper.child_array (Version 1.13.2 and later only)
-- helper.get_variable_array
-- helper.get_variable_proxy_array
-- helper.set_variable_array
}

