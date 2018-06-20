----
-- Copyright (C) 2018 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

--- sowas
-- @submodule wesnoth

--- Working with sound files
-- @section Sound


--
-- type track
-- field shuffle
-- string blah
-- Each track contains the following fields:
--     shuffle (read-write)
--     once (read-write): generally only true for wesnoth.music_list.current
--     ms_before (read-write)
--     ms_after (read-write)
--     immediate (read-only)
--     name (read-only): the unresolved track filename
--     title (read-only): a user-friendly track title


---
-- Sets the given table as an entry into the music list.
--
-- See MusicListWML for the recognized attributes.
--
-- Passing no argument forces the engine to take into account all the recent changes to the music list.
-- (Note: this is done automatically when sequences of WML commands end,
-- so it is useful only for long events.)
--
-- This function is now deprecated. Use the wesnoth.music_list table instead
-- @tparam MusicListWML music_entry
-- @usage wesnoth.set_music { name: "traveling_minstrels.ogg" }
set_music = (music_entry) =>


---
-- This is a table giving access to the current music playlist.
--
-- It can be accessed as a normal array,
-- including the Lua length operator.<br/>
-- If you assign a music config to an entry, the track is replaced.<br/>
-- It is not a normal array however and cannot be manipulated with the table library.
-- @table music_list
-- @field current (read-write) The currently-playing track. This may sometimes be a track that's not on the playlist - "play once" tracks are not placed on the playlist.
-- @field current.__cfg (read-only) Returns a copy of the current track information.
-- @field previous (read-write): The track played before the current one. This may sometimes be a track that's not on the playlist - "play once" tracks are not placed on the playlist.
-- @field previous.__cfg (read-only) Returns a copy of the previous track information.
-- NOTE: Wesnoth's playlist implementation effectively "plays" every song as it's added to the playlist, so when replacing one playlist with another, this will return information on the second-to-last track added to the new playlist, not the track you actually heard playing from the playlist that was replaced.
-- @field current_i (read-write)
-- The index of the currently-playing track on the playlist, or nil if the currently-playing track is not on the playlist.
-- @field volume (read-write)
-- The current music volume,
-- as a percentage of the user's preferred volume set in preferences.
-- @tfield track all (read-only)
-- Returns a copy of the music list as an array of WML tables.
music_list = {}


----
-- Appends a track to the playlist.
-- @string track_name
-- @bool[opt] immediate If true is passed, also start playing the new track.
-- @int[opt] ms_before
-- @int[opt] ms_after
music_list.add = (track_name, immediate, ms_before, ms_after) =>


----
-- Removes one or more tracks by their index.
--
-- You can pass as many indices as you wish.<br/>
-- If one of the removed tracks is currently playing, it continues to play.
-- @tparam {int,...} ...
music_list.remove = (...) =>
    for i in *...
        table.remove(@board.music_list, i)


----
-- Clears the playlist.
--
-- The currently-playing track continues to play.
music_list.clear = () =>
    for i,_ in ipairs @board.music_list
        @board.music_list[i] = nil


----
-- Stop playing the current track and move on to the next one.
--
-- This honours the shuffle settings.
music_list.next = () =>


----
-- Start playing a track without appending it to the playlist.
-- @string track_name the file path to the track to playlist
music_list.play = (track_name) =>




---
-- Plays the given sound file once,<br/>
-- optionally repeating it one or more more times if an integer value
-- is provided as a second argument
-- (note that the sound is repeated the number of times specified in the second argument, i.e. a second argument of 4 will cause the sound to be played once and then repeated four more times for a total of 5 plays. See the example below).
-- @usage
-- wesnoth.play_sound"ambient/birds1.ogg"
-- wesnoth.play_sound("magic-holy-miss-3.ogg", 4) -- played 1 + 4 = 5 times
-- @string sound path to the soundfile to play
-- @int[opt] repeat_count
play_sound = (sound, repeat_count) =>


---
-- Sets the current sound volume.
-- @int new_volume percentage of the user's preferred volume set in preferences.
-- @return Returns the previous sound volume in the same format.
sound_volume = (new_volume) =>


{
    :music_list
    :play_sound
    :set_music
    :sound_volume
}
