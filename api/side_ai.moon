----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

---
-- @submodule wesnoth

----
-- Tests if the given location is under shroud from the point of view of the given side.
-- Replaces a side's AI with the configuration from a specified file.
-- (Version 1.13.7 and later only)
-- @function wesnoth.switch_ai
switch_ai = (side, file) =>


----
-- (Version 1.13.7 and later only)
-- Appends AI parameters (aspects, stages, goals) to the side's AI. The syntax for the parameters to be appended is the same as that supported by [modify_side].
-- @function wesnoth.append_ai
append_ai = (side, params) =>


----
-- Adds a component to the side's AI. The path syntax is the same as that used by [modify_ai]. The component is the content of the component - it should not contain eg a toplevel [facet] tag.
-- (Version 1.13.7 and later only)
-- @function wesnoth.add_ai_component
add_ai_component = (side, path, component) =>


----
-- Like add_ai_component, but replaces an existing component instead of adding a new one.
-- (Version 1.13.7 and later only)
-- @function wesnoth.change_ai_component
change_ai_component = (side, path, component) =>


----
-- Like add_ai_component, but removes a component instead of adding one.
-- (Version 1.13.7 and later only)
-- @function wesnoth.delete_ai_component
delete_ai_component = (side, path) =>


{
    :switch_ai
    :append_ai
    :add_ai_component
    :change_ai_component
    :delete_ai_component
}
