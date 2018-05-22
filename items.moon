
----
-- @function items.place_image
-- Places an image at a given location and registers it as a WML [item] would do, so that it can be restored after save/load.
-- @usage items = wesnoth.require "lua/wml/items.lua"
-- items.place_image(17, 42, "items/orcish-flag.png")
place_image = (x, y, filename) =>


----
-- Behaves the same as #items.place_image but for halos.
-- @function items.place_halo
place_halo = (x, y, filename) =>


----
-- Removes an overlay set by #items.place_image or #items.place_halo.
-- If no filename is provided, all the overlays on a given tile are removed.
-- @function items.remove
-- @function items.remove(x, x, [filename])
-- @usage items.remove(17, 42, "items/orcish-flag.png")
remove = (x, x, filename) =>


{
    :place_image
    :place_halo
    :remove
}
