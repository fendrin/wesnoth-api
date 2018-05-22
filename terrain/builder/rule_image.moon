-- /**
--  * Each terrain_graphics rule is associated a set of images, which are
--  * applied on the terrain if the rule matches. An image is more than
--  * graphics: it is graphics (with several possible tod-alternatives,)
--  * and a position for these graphics.
--  * The rule_image structure represents one such image.
--  */
class Rule_Image
    new: (layer, x, y, global_image = false, center_x = -1,
            center_y = -1, is_water = false) =>
        @layer = layer
        @basex = x
        @basey = y
        -- variants()
        @global_image = global_image
        @center_x = cx
        @center_y = cy
        @is_water = is_water


    is_background: =>
        return layer < 0 or (layer == 0 and basey < UNITPOS)

    ----
    -- The layer of the image for horizontal layering
    -- int layer;
    -- /** The position of the image base (that is, the point where
    --  * the image reaches the floor) for vertical layering
    --  */
    -- int basex, basey;

    -- /** A list of variants for this image */
    -- std::vector<rule_image_variant> variants;

    -- /** Set to true if the image was defined as a child of the
    --  * [terrain_graphics] tag, set to false if it was defined as a
    --  * child of a [tile] tag */
    -- bool global_image;

    -- /** The position where the center of the image base should be
    --  */
    -- int center_x, center_y;

    -- bool is_water;
