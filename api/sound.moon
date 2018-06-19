

----
-- wesnoth.set_music
-- Sets the given table as an entry into the music list. See MusicListWML for the recognized attributes.
-- @usage wesnoth.set_music { name: "traveling_minstrels.ogg" }
-- Passing no argument forces the engine to take into account all the recent changes to the music list. (Note: this is done automatically when sequences of WML commands end, so it is useful only for long events.)
-- (Version 1.13.8 and later only) This function is now deprecated. Use the wesnoth.music_list table instead
set_music = (music_entry) =>


----
-- wesnoth.music_list
-- (Version 1.13.8 and later only)
-- This is a table giving access to the current music playlist. It can be accessed as a normal array, including the Lua length operator. If you assign a music config to an entry, the track is replaced. It is not a normal array however and cannot be manipulated with the table library.
-- In addition, it has the following named fields:
--     wesnoth.music_list.current (read-write): The currently-playing track. This may sometimes be a track that's not on the playlist - "play once" tracks are not placed on the playlist.
--     wesnoth.music_list.current.__cfg (read-only): Returns a copy of the current track information.
--     wesnoth.music_list.previous (read-write): The track played before the current one. This may sometimes be a track that's not on the playlist - "play once" tracks are not placed on the playlist.
--     wesnoth.music_list.previous.__cfg (read-only): Returns a copy of the previous track information.
-- NOTE: Wesnoth's playlist implementation effectively "plays" every song as it's added to the playlist, so when replacing one playlist with another, this will return information on the second-to-last track added to the new playlist, not the track you actually heard playing from the playlist that was replaced.
music_list = {}
--     wesnoth.music_list.current_i (read-write):
-- The index of the currently-playing track on the playlist, or nil if the currently-playing track is not on the playlist.
--     wesnoth.music_list.volume (read-write):
-- The current music volume, as a percentage of the user's preferred volume set in preferences.
--     wesnoth.music_list.all (read-only):
-- Returns a copy of the music list as an array of WML tables.

-- It also contains some functions:

----
-- wesnoth.music_list.add(track_name, [immediate,] [ms_before, [ms_after]]):
-- Appends a track to the playlist. If true is passed, also start playing the new track.
music_list.add = (track_name, immediate, ms_before, ms_after) =>


----
-- wesnoth.music_list.remove(n1, ...):
-- Removes one or more tracks by their index. You can pass as many indices as you wish. If one of the removed tracks is currently playing, it continues to play.
music_list.remove(...) =>
    for i in *...
        table.remove(@board.music_list, i)


----
-- wesnoth.music_list.clear():
-- Clears the playlist. The currently-playing track continues to play.
music_list.clear() =>
    for i,_ in ipairs @board.music_list
        @board.music_list[i] = nil


----
-- wesnoth.music_list.next():
-- Stop playing the current track and move on to the next one. This honours the shuffle settings.
music_list.next() =>


----
-- wesnoth.music_list.play(track_name):
-- Start playing a track without appending it to the playlist.
music_list.play = (track_name) =>



----
-- Each track contains the following fields:
--     shuffle (read-write)
--     once (read-write): generally only true for wesnoth.music_list.current
--     ms_before (read-write)
--     ms_after (read-write)
--     immediate (read-only)
--     name (read-only): the unresolved track filename
--     title (read-only): a user-friendly track title


----
-- wesnoth.play_sound
--     wesnoth.play_sound(sound, [repeat_count])
-- Plays the given sound file once, optionally repeating it one or more more times if an integer value is provided as a second argument (note that the sound is repeated the number of times specified in the second argument, i.e. a second argument of 4 will cause the sound to be played once and then repeated four more times for a total of 5 plays. See the example below).
-- @usage
-- wesnoth.play_sound "ambient/birds1.ogg"
-- wesnoth.play_sound("magic-holy-miss-3.ogg", 4) -- played 1 + 4 = 5 times
play_sound = (sound, repeat_count) =>


----
-- wesnoth.sound_volume
-- (Version 1.13.8 and later only)
--     wesnoth.sound_volume(new_volume)
-- Sets the current sound volume, as a percentage of the user's preferred volume set in preferences. Returns the previous sound volume in the same format.
sound_volume = (new_volume) =>



{
    :music_list
    :play_sound
    :set_music
    :sound_volume
}




