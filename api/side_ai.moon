
----
-- Tests if the given location is under shroud from the point of view of the given side.
-- @function wesnoth.switch_ai
-- Replaces a side's AI with the configuration from a specified file.
-- (Version 1.13.7 and later only)
switch_ai = (side, file) =>


----
-- @function wesnoth.append_ai
-- (Version 1.13.7 and later only)
-- Appends AI parameters (aspects, stages, goals) to the side's AI. The syntax for the parameters to be appended is the same as that supported by [modify_side].
append_ai = (side, params) =>


----
-- @function wesnoth.add_ai_component
-- Adds a component to the side's AI. The path syntax is the same as that used by [modify_ai]. The component is the content of the component - it should not contain eg a toplevel [facet] tag.
-- (Version 1.13.7 and later only)
add_ai_component = (side, path, component) =>


----
-- Like add_ai_component, but replaces an existing component instead of adding a new one.
-- @function wesnoth.change_ai_component
-- (Version 1.13.7 and later only)
change_ai_component = (side, path, component) =>


----
-- Like add_ai_component, but removes a component instead of adding one.
-- @function wesnoth.delete_ai_component
-- (Version 1.13.7 and later only)
delete_ai_component = (side, path) =>


{
    :switch_ai
    :append_ai
    :add_ai_component
    :change_ai_component
    :delete_ai_component
}
