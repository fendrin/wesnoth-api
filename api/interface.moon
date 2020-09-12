----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

---
-- @submodule wesnoth

-- This page describes the LuaWSL functions and helpers for interfacing with the user.


log = loging"api/interface"


-- LuaWSL:Display

----
-- Displays a string in the chat window and dumps it to the lua/info log domain (--log-info=scripting/lua on the command-line).
-- @function wesmere.message
-- @string[opt="<Lua>"] speaker The chat line header is "<Lua>" by default, but it can be changed by passing a string before the message.
-- @string message
-- @usage wesmere.message "Hello World!"
-- @usage
-- wesmere.message("Big Brother", "I'm watching you.")
-- will result in "<Big Brother> I'm watching you."
-- See also @see helper.wsl_error for displaying error messages.
message = (speaker="<Lua>", message) ->

----
-- Removes all messages from the chat window. No argument or returned values.
-- @function wesmere.clear_messages
-- @usage wesmere.clear_messages!
clear_messages = () ->

----
-- Creates a function proxy for lazily translating strings from the given domain.
-- @function wesmere.textdomain
-- @usage #textdomain "my-campaign"
-- the comment above ensures the subsequent strings will be extracted to the proper domain
-- _ = wesmere.textdomain "my-campaign"
-- wesmere.set_variable("my_unit.description", _ "the unit formerly known as Hero")
-- The metatable of the function proxy appears as "message domain". The metatable of the translatable strings (results of the proxy) appears as "translatable string".
-- The translatable strings can be appended to other strings/numbers with the standard .. operator. Translation can be forced with the standard tostring operator in order to get a plain string.
-- wesmere.message(string.format(tostring(_ "You gain %d gold."), amount))
textdomain = (domain) ->

----
-- Delays the engine like the [delay] tag.
-- @function wesmere.delay
-- @number milliseconds time to delay in milliseconds
-- @usage wesmere.delay(500)
delay = (milliseconds) ->

----
-- Pops some text above a map tile.
-- @function wesmere.float_label
-- @number x
-- @number y
-- @string text
-- @usage wesmere.float_label(unit.x, unit.y, "<span color='#ff0000'>Ouch</span>")
float_label = (x, y, text) ->

----
-- Selects the given location in the game map as if the player would have clicked onto it.
-- @function wesmere.select_hex
-- @number x
-- @number y
-- @bool[opt=true] show_movement whether to show the movement range of any unit on that location (def: true)
-- @bool[optchain=false] fire_events whether to fire any select events
-- @usage wesmere.select_hex(14,6, true, true)
select_hex = (x, y, show_movement=true, fire_events=false) ->

----
-- Reverses any select_hex call, leaving all locations unhighlighted. Takes no arguments.
-- @function wesmere.deselect_hex
-- @treturn Location formerly selected hex
-- @usage wesmere.deselect_hex!
deselect_hex = () ->

----
-- Scrolls the map to the given location. If true is passed as the third parameter, scrolling is disabled if the tile is hidden under the fog. If true is passed as the fourth parameter, the view instantly warps to the location regardless of the scroll speed setting in Preferences.
-- @function wesmere.scroll_to_tile
-- @number x
-- @number y
-- @bool[opt=false] only_if_visible
-- @bool[optchain=false] instant
-- @usage u = wesmere.get_unit { id: "hero" }
-- wesmere.scroll_to_tile(u.x, u.y)
-- @usage wesmere.scroll_to_tile = (x, y, [only_if_visible=false, [instant=false]]) ->
scroll_to_tile = (x, y, only_if_visible=false, instant=false) ->

----
-- Locks or unlocks gamemap view scrolling for human players.
-- Human players cannot scroll the gamemap view as long as it is locked, but Lua or WSL actions such as wesmere.scroll_to_tile still can; the locked/unlocked state is preserved when saving the current game. This feature is generally intended to be used in cutscenes to prevent the player scrolling away from scripted actions.
-- @function wesmere.lock_view
-- @bool[opt=true] lock If true is passed as the first parameter, the view is locked; pass false to unlock.
-- @usage wesmere.lock_view(true)
-- wesmere.scroll_to_tile(12, 14, false, true)
lock_view = (lock=true) ->

----
-- Returns a boolean indicating whether gamemap view scrolling is currently locked.
-- @function wesmere.view_locked
-- @treturn bool iff scrolling is locked
view_locked = () ->

----
-- Plays the given sound file once, optionally repeating it one or more more times if an integer value is provided as a second argument (note that the sound is repeated the number of times specified in the second argument, i.e. a second argument of 4 will cause the sound to be played once and then repeated four more times for a total of 5 plays. See the example below).
-- @function wesmere.play_sound
-- @string sound
-- @number[opt=0] repeat_count
-- @usage wesmere.play_sound "ambient/birds1.ogg"
-- @usage wesmere.play_sound("magic-holy-miss-3.ogg", 4) -- played 1 + 4 = 5 times
play_sound = (sound, repeat_count=0) ->

----
-- Sets the given table as an entry into the music list. See MusicListWSL for the recognized attributes.
-- @function wesmere.set_music
-- @tab music_entry Passing no argument forces the engine to take into account all the recent changes to the music list. (Note: this is done automatically when sequences of WSL commands end, so it is useful only for long events.)
-- @usage wesmere.set_music { name: "traveling_minstrels.ogg" }
set_music = (music_entry) =>
    -- @todo don't use love in here, the lib should be usable without it.
    love = love
    client = love.thread.getChannel('client')
    music_entry.command_name = "Music"
    client\push(music_entry)

----
-- Returns true if messages are currently being skipped, for example because the player has chosen to skip replay, or has pressed escape to dismiss a message.
-- @function wesmere.is_skipping_messages
-- @treturn bool
is_skipping_messages = () ->

----
-- Sets the skip messages flag. By default it sets it to true, but you can also pass false to unset the flag.
-- @todo is this part of game_server or display_client only?
-- @function wesmere.skip_messages
-- @bool[opt=true] skip
skip_messages = (skip=true) ->

----
-- Returns a proxy to the unit currently displayed in the side pane of the user interface, if any.
-- @function wesmere.get_displayed_unit
-- @usage name = tostring(wesmere.get_displayed_unit().name)
get_displayed_unit = () ->

----
-- This field is not a function but an associative table. It links item names to the functions that describe their content. These functions are called whenever the user interface is refreshed. The description of an item is a WSL table containing [element] children. Each subtag shall contain either a text or an image field that is displayed to the user. It can also contain a tooltip field that is displayed to the user when moused over, and a "help" field that points to the help section that is displayed when the user clicks on the theme item.
-- Note that the wesmere.theme_items table is originally empty and using pairs or next on it will not return the items from the current theme. Its metatable ensures that the drawing functions of existing items can be recovered though, as long as their name is known. The example below shows how to modify the unit_status item to display a custom status:
-- old_unit_status = wesmere.theme_items.unit_status
-- function wesmere.theme_items.unit_status()
--     local u = wesmere.get_displayed_unit()
--     if not u then return {} end
--         local s = old_unit_status()
--         if u.status.entangled then
--             table.insert(s, { "element", {
--                 image = "entangled.png",
--                 tooltip = _"entangled: This unit is entangled. It cannot move but it can still attack."
--             } })
--         end
--     return s
-- end
-- The following is a list of valid entries in wesmere.theme_items which will have an effect in the game. Unfortunately when this feature was created the full range of capabilities of the feature was never properly documented. The following list is automatically generated. To find out what each entry will do, you will have to make guesses and experiment, or read the source code at src/reports.cpp. If you find out what an entry does, you are more than welcome to edit the wiki and give a proper description to any of these fields.
-- @table wesmere.theme_items
-- @field unit_name
-- @field selected_unit_name
-- @field unit_type
-- @field selected_unit_type
-- @field unit_race
-- @field selected_unit_race
-- @field unit_side
-- @field selected_unit_side
-- @field unit_level
-- @field selected_unit_level
-- @field unit_amla
-- @field unit_traits
-- @field selected_unit_traits
-- @field unit_status
-- @field selected_unit_status
-- @field unit_alignment
-- @field selected_unit_alignment
-- @field unit_abilities
-- @field selected_unit_abilities
-- @field unit_hp
-- @field selected_unit_hp
-- @field unit_xp
-- @field selected_unit_xp
-- @field unit_advancement_options
-- @field selected_unit_advancement_options
-- @field unit_defense
-- @field selected_unit_defense
-- @field unit_vision
-- @field selected_unit_vision
-- @field unit_moves
-- @field selected_unit_moves
-- @field unit_weapons
-- @field highlighted_unit_weapons
-- @field selected_unit_weapons
-- @field unit_image
-- @field selected_unit_image
-- @field selected_unit_profile
-- @field unit_profile
-- @field tod_stats
-- @field time_of_day
-- @field unit_box
-- @field turn
-- @field gold
-- @field villages
-- @field num_units
-- @field upkeep
-- @field expenses
-- @field income
-- @field terrain_info
-- @field terrain
-- @field zoom_level
-- @field position
-- @field side_playing
-- @field observers
-- @field selected_terrain
-- @field edit_left_button_function
-- @field report_clock
-- @field report_countdown
-- theme_items = {}

----
-- Displays a WSL message box querying a choice from the user. Attributes and options are taken from given tables (see [message]).
-- @function helper.get_user_choice
-- @tab message_table
-- @tab options
-- @treturn number The index of the selected option is returned.
-- @usage result = helper.get_user_choice({ speaker: "narrator" }, { "Choice 1", "Choice 2" })
-- helper.get_user_choice = (message_table, options) ->


-- wesnoth.show_message_dialog

--     wesnoth.show_message_dialog(attributes, [options, [text_input_attributes]])

-- (Version 1.13.2 and later only)

-- Shows a message dialog, of the type used by the [message] ActionWML tag. Unlike the [message] tag, this is unsynced; if you need it synced, you must do it yourself. The first argument is a table describing the dialog with the following keys:

--     title - The title to show on the message. For example, the speaker's name.
--     message - The message content.
--     portrait - An image to show along with the message. By default, no image is shown.
--     left_side - The default is true; set to false to show the image on the right.
--     mirror - If true, the image will be flipped horizontally.

-- The second argument is a list of options as a Lua array. Each option is either a (possibly-translatable) string or a config with DescriptionWML keys. The array itself can also have an optional default key which if present should be the index of the initially selected option (useful if you don't need full DescriptionWML but want to set a default). If present it overrides any defaults set in individual options.

-- The third argument is a table describing the text input field with the following keys:

--     label - A label to show to the left of the text field.
--     text - Initial contents of the text field.
--     max_length - Maximum input length in characters (defaults to 256).

-- You need at least one key for the text input to be shown. Both the second arguments are option, but if you want text input with no options, you must pass nil for the second parameter.

-- This function returns two values. The first is the numeric result of the dialog. If there are no options and no text input, this is -2 if the user closed by pressing Escape, otherwise it's -1. If there are options, this is the index of the option chosen (starting from 1). If there is text input but no options, the first return value is 0. If there was text input, the second value contains the text entered.

-- Example:

--     Expand
--     Select All

--  wesnoth.show_message_dialog({
--      title = "Make your choice:",
--      message = "Select an option and enter some text.",
--      portrait = "wesnoth-icon.png",
--  }, {
--      "The first choice is always the best!",
--      "Pick me! Second choices are better!",
--      "You know you want the third option!",
--  }, {
--      label = "Text:",
--      text = "?",
--      max_length = 16
--  })

-- (You don't have to format it like that, of course.)
show_message_dialog = (attributes, options, text_input_attributes) =>
    log.debug"show_message_dialog called"
    love = love
    attributes.command_name = "message"
    client = love.thread.getChannel'client'
    client\push(attributes)


show_story = (story, default_title) =>
    assert(story)
    client = love.thread.getChannel'client'
    story.command_name = "story"
    client\push(story)


{
    :message
    :clear_messages
    :textdomain
    :delay
    :float_label
    :select_hex
    :deselect_hex -- (Version 1.13.2 and later only)
    :scroll_to_tile
    :lock_view
    :view_locked
    :play_sound
    :set_music
    :show_story
    :show_message_dialog -- (Version 1.13.2 and later only)
    :show_popup_dialog -- (Version 1.13.2 and later only)
    :show_dialog
    :set_dialog_value
    :get_dialog_value
    :set_dialog_active
    :set_dialog_callback
    :set_dialog_markup
    :set_dialog_focus -- (Version 1.13.2 and later only)
    :set_dialog_visible -- (Version 1.13.2 and later only)
    :set_dialog_canvas
    :add_dialog_tree_node -- (Version 1.13.0 and later only)
    :remove_dialog_item -- (Version 1.13.1 and later only)
    :get_displayed_unit
    :theme_items
    -- helper.get_user_choice
    :is_skipping_messages -- (Version 1.13.2 and later only)
    :skip_messages -- (Version 1.13.2 and later only)
}
