----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

----
-- @submodule wesnoth

----
-- Shows a message dialog, of the type used by the message ActionWSL function. Unlike the message function, this is unsynced; if you need it synced, you must do it yourself.
--
-- You need at least one key for the text input to be shown. Both the second arguments are option, but if you want text input with no options, you must pass nil for the second parameter.
-- @function wesmere.show_message_dialog
-- @tab attributes The first argument is a table describing the dialog with the following keys:
-- @string attributes.title The title to show on the message. For example, the speaker's name.
-- @string attributes.message The message content.
-- @string attributes.portrait An image to show along with the message. By default, no image is shown.
-- @bool[opt=true] attributes.left_side The default is true; set to false to show the image on the right.
-- @bool attributes.mirror If true, the image will be flipped horizontally.
-- @tab[opt] options The second argument is a list of options as a Lua array. Each option is either a (possibly-translatable) string or a config with DescriptionWSL keys. The array itself can also have an optional default key which if present should be the index of the initially selected option (useful if you don't need full DescriptionWSL but want to set a default). If present it overrides any defaults set in individual options.
-- @tab[optchain] text_input_attributes The third argument is a table describing the text input field with the following keys:
-- @string text_input_attributes.label A label to show to the left of the text field.
-- @string text_input_attributes.text Initial contents of the text field.
-- @number[opt=256] text_input_attributes.max_length Maximum input length in characters.
-- @treturn number numeric result of the dialog. If there are no options and no text input, this is -2 if the user closed by pressing Escape, otherwise it's -1. If there are options, this is the index of the option chosen (starting from 1). If there is text input but no options, the first return value is 0.
-- @treturn string If there was text input, the second value contains the text entered.
-- @usage wesmere.show_message_dialog({
--      title: "Make your choice:"
--      message: "Select an option and enter some text."
--      portrait: "wesmere-icon.png"
--  }, {
--      "The first choice is always the best!",
--      "Pick me! Second choices are better!",
--      "You know you want the third option!",
--  }, {
--      label: "Text:"
--      text: "?"
--      max_length: 16
--  })
-- -- (You don't have to format it like that, of course.)
-- @usage wesmere.show_message_dialog = (attributes, [options, [text_input_attributes]]) ->
-- show_message_dialog = (attributes, options, text_input_attributes) ->


----
-- Shows a simple popup dialog in the centre of the screen.
-- Both the title and the message support Pango markup. The image is optional.
-- @function wesmere.show_popup_dialog
-- @string title A title string for the dialog.
-- @string message The message content for the dialog.
-- @string[opt] image An image to show.
show_popup_dialog = (title, message, image) ->

----
-- Displays a dialog box described by a WSL table and returns:
-- The dialog box is equivalent to the resolution section of a GUI window as described in GUIToolkitWSL and must therefore contain at least the following children: [tooltip], [helptip], and [grid]. The [grid] must contain nested [row], [column] and [grid] tags which describe the layout of the window. (More information can be found in GUILayout; suffice to say that the basic structure is grid -> row -> column -> widget, where the widget is considered to be in a cell defined by the row and column of the grid. A list of widgets can be found at GUIWidgetInstanceWSL.)
-- Two optional functions can be passed as second and third arguments; the first one is called once the dialog is created and before it is shown; the second one is called once the dialog is closed. These functions are helpful in setting the initial values of the fields and in recovering the final user values. These functions can call the #wesmere.set_dialog_value, #wesmere.get_dialog_value, and #wesmere.set_dialog_callback functions for this purpose.
-- This function should be called in conjunction with #wesmere.synchronize_choice, in order to ensure that only one client displays the dialog and that the other ones recover the same input values from this single client.
-- @function wesmere.show_dialog
-- @treturn number if the dialog was dismissed by a button click, the integer value associated to the button via the "return_value" keyword.
-- if the dialog was closed with the enter key, -1.
-- if the dialog was closed with the escape key, -2.
-- @usage
-- -- The example below defines a dialog with a list and two buttons on the left, and a big image on the right. The preshow function fills the list and defines a callback on it. This select callback changes the displayed image whenever a new list item is selected. The postshow function recovers the selected item before the dialog is destroyed.
-- helper = wesmere.require "lua/helper.lua"
-- T = helper.set_wsl_tag_metatable {}
-- _ = wesmere.textdomain "wesmere"
--
-- dialog = {
--     T.tooltip { id: "tooltip_large" },
--     T.helptip { id: "tooltip_large" },
--     T.grid { T.row {
--         T.column { T.grid {
--             T.row { T.column { horizontal_grow: true, T.listbox { id: "the_list",
--                 T.list_definition { T.row { T.column { horizontal_grow: true,
--                     T.toggle_panel { T.grid { T.row {
--                         T.column { horizontal_alignment: "left", T.label { id: "the_label" } },
--                         T.column { T.image { id: "the_icon" } }
--                     } } }
--                 } } }
--             } } },
--         T.row { T.column { T.grid { T.row {
--             T.column { T.button { id: "ok", label: _"OK" } },
--             T.column { T.button { id: "cancel", label: _"Cancel" } }
--         } } } }
--         } },
--         T.column { T.image { id: "the_image" } }
--         } }
-- }
--
-- preshow = () ->
--     t = { "Ancient Lich", "Ancient Wose", "Elvish Avenger" }
--     select = () ->
--         i = wesmere.get_dialog_value "the_list"
--         ut = wesmere.unit_types[t[i]].__cfg
--         wesmere.set_dialog_value(string.gsub(ut.profile, "([^/]+)$", "transparent/%1"), "the_image")
--
--     wesmere.set_dialog_callback(select, "the_list")
--     for i,v in ipairs(t)
--         ut = wesmere.unit_types[v].__cfg
--         wesmere.set_dialog_value(ut.name, "the_list", i, "the_label")
--         wesmere.set_dialog_value(ut.image, "the_list", i, "the_icon")
--
--     wesmere.set_dialog_value(2, "the_list")
--     select!
--
-- li = 0
-- postshow = () ->
--     li = wesmere.get_dialog_value "the_list"
--
-- r = wesmere.show_dialog(dialog, preshow, postshow)
-- wesmere.message(string.format("Button %d pressed. Item %d selected.", r, li))
-- @usage wesmere.show_dialog = (wsl_dialog_table, [pre_show_function, [post_show_function]]) ->
show_dialog = (wsl_dialog_table, pre_show_function, post_show_function) ->

----
-- Sets the value of a widget on the current dialog. The value is given by the first argument; its semantic depends on the type of widget it is applied to. The last argument is the id of the widget. If it does not point to a unique widget in the dialog, some discriminating parents should be given on its left, making a path that is read from left to right by the engine. The row of a list is specified by giving the id' of the list as a first argument and the 1-based row number as the next argument.
-- Notes: When the row of a list does not exist, it is created. The value associated to a list is the selected row.
-- @function wesmere.set_dialog_value
-- @usage
-- -- sets the value of a widget "bar" in the 7th row of the list "foo"
-- wesmere.set_value(_"Hello world", "foo", 7, "bar")
set_dialog_value = (value, path, to, widget, id) ->

----
-- Gets the value of a widget on the current dialog. The arguments described the path for reaching the widget
-- (Version 1.13.0 and later only) For treeviews this function returns a table descibing the currently selected node. If for example in this treeview
-- +Section1
--  +Subsection11
--   *Item1
--   *Item2
--   *Item3
--  +Subsection12
--   *Item4
--   *Item5
--   *Item6
-- +Section2
--  +Subsection21
--   *Item7
--   *Item8
--   *Item9
--  +Subsection22
--   *Item10
--   *Item11
--   *Item12
-- Item 9 is selcted the value will be {2,1,3}
-- @function wesmere.get_dialog_value
-- @see set_dialog_value
get_dialog_value = (path, to, widget, id) ->

----
-- Enables or disables a widget. The first argument is a boolean specifying whether the widget should be active (true) or inactive (false). The remaining arguments are the path to locate the widget in question -- -- @see wesmere.set_dialog_value
-- @function wesmere.set_dialog_active
-- @bool active
set_dialog_active = (active, path, to, widget, id) ->

----
-- Sets the first argument as a callback function for the widget obtained by following the path of the other arguments
-- This function will be called whenever the user modifies something about the widget, so that the dialog can react to it.
-- @function wesmere.set_dialog_callback
-- @func callback_function
-- @see set_dialog_value
set_dialog_callback = (callback_function, path, to, widget, id) ->

----
-- Sets the flag associated to a widget to enable or disable Pango markup. The new flag value is passed as the first argument (boolean), and the widget to modify is obtained by following the path of the other arguments (see #wesmere.set_dialog_value). Most widgets start with Pango markup disabled unless this function is used to set their flag to true.
-- @function wesmere.set_dialog_markup
-- @bool allowed
-- @usage wesmere.set_dialog_markup(true, "notice_label")
-- wesmere.set_dialog_value("<big>NOTICE!</big>", "notice_label")
set_dialog_markup = (allowed, path, to, widget, id) ->

----
-- Switches the keyboard focus to the widget found following the given path.
--
-- This is often useful for dialogs containing a central listbox, so that it can be controlled with the keyboard as soon as it is displayed.
-- @function wesmere.set_dialog_focus
-- @bool focused
-- @see wesmere.set_dialog_value
-- @usage wesmere.set_dialog_focus("my_listbox")
set_dialog_focus = (focused, path, to, widget, id) ->

----
-- Sets a widget's visibility status. The new status is passed as the first argument, and the path to the widget is specified by the remaining arguments
-- The following visibility statuses are recognized:
-- String value    Boolean shorthand    Meaning
-- visible    true    The widget is visible and handles events.
-- hidden        The widget is not visible, doesn't handle events, but still takes up space on the dialog grid.
-- invisible    false    The widget is not visible, doesn't handle events, and does not take up space on the dialog grid.
-- @function wesmere.set_dialog_visible
-- @bool visible
-- @usage wesmere.set_dialog_visible(false, "secret_button")
-- @see set_dialog_value
set_dialog_visible = (visible, path, to, widget, id) ->

----
-- Sets the WSL passed as the second argument as the canvas content (index given by the first argument) of the widget obtained by following the path of the other arguments (see #wesmere.set_dialog_value). The content of the WSL table is described at GUICanvasWSL.
-- The meaning of the canvas index depends on the chosen widget. It may be the disabled / enabled states of the widget, or its background / foreground planes, or... For instance, overwriting canvas 1 of the window with an empty canvas causes the window to become transparent.
-- @function wesmere.set_dialog_value
-- @number index
-- @tab content
-- @usage -- draw two rectangles in the upper-left corner of the window (empty path = window widget)
-- wesmere.set_dialog_canvas(2, {
--     T.rectangle { x: 20, y: 20, w: 20, h: 20, fill_color: "0,0,255,255" },
--     T.rectangle { x: 30, y: 30, w: 20, h: 20, fill_color: "255,0,0,255" }
-- })
set_dialog_value = (index, content, path, to, widget, id) ->

----
-- Adds a childnode to a treeview widget or a treeview node.
-- The other arguments describe the path of the parent treeview (-node)
-- @function wesmere.add_dialog_tree_node
-- @string type The type (id of the node definition) of the node is passed in the first parameter.
-- @number index The second parameter (integer) spcifies where the node should be inserted in the parentnode.
add_dialog_tree_node = (type, index, path, to, widget, id) ->

----
-- Removes an item from a listbox, a multipage or a treeview. First parameter is the index of the item to delete, second parameter is the number of items to delete and the remaining parameters describe the path to the listbox, the multipage or the parent treview node.
-- @function wesmere.remove_dialog_item
-- @number index
-- @number count
remove_dialog_item = (index, count, path, to, widget, id) ->
