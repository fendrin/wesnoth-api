-- /**
--   * Represents a tile of the game map, with all associated
--   * builder-specific parameters: flags, images attached to this tile,
--   * etc. An array of those tiles is built when terrains are built either
--   * during construction, or upon calling the rebuild_all() method.
--   */
class Tile

    -- /** Constructor for the tile() structure */
    -- tile();
    -- terrain_builder::tile::tile()
    --     : flags()
    --     , images()
    --     , images_foreground()
    --     , images_background()
    -- {
    -- }
    new: =>
        @last_tod = "invalid_tod"
        @sorted_images = false

    ----
    -- Represent a rule_image applied with a random seed.
    class Rule_Image_Rand

        -- rule_image_rand(const rule_image* r_i, unsigned int rnd)
        new: (r_i, rnd) =>
            @ri = r_i
            @rand = rnd

        -- const rule_image* operator->() const
        -- {
        --     return ri;
        -- }

        -- sort by layer first then by basey
        -- bool operator<(const rule_image_rand& o) const
        _lt: (o) =>
            return @ri.layer < o.ri.layer or
                (@ri.layer == o.ri.layer and
                @ri.basey < o.ri.basey)


    -- typedef std::pair<const rule_image_rand*, const rule_image_variant*> log_details;
    -- typedef std::vector<log_details> logs;
    -- /** Rebuilds the whole image cache, for a given time-of-day.
    --   * Must be called when the time-of-day has changed,
    --   * to select the correct images.
    --   *
    --   * @param tod    The current time-of-day
    --   */
    -- void rebuild_cache(const std::string& tod, logs* log = nullptr);
    -- void terrain_builder::tile::rebuild_cache(const std::string& tod, logs* log)
    rebuild_cache: (tod, log) =>
        @images_background.clear()
        @images_foreground.clear()

        unless @sorted_images
            -- sort images by their layer (and basey)
            -- but use stable to keep the insertion order in equal cases
            -- @todo
            std.stable_sort(@images.begin(), @images.end())
            @sorted_images = true

        for ri in @images
            is_background = ri.is_background()
            animate = (not ri.ri.is_water or preferences.animate_water())

            img_list = if is_background
                @images_background else @images_foreground

            for variant in ri.variants
                unless variant.has_flag
                    has_flag_match = true
                    for s in variant.has_flag
                        -- If a flag listed in "has_flag" is not present,
                        -- this variant does not match
                        if @flags.find(s) == @flags.end()
                            has_flag_match = false
                            break

                    unless has_flag_match
                        continue

                if (not variant.tods.empty() and variant.tods.find(tod) == variant.tods.end())
                    continue

                -- need to break parity pattern in RNG
                -- /** @todo improve this */
                rnd = @ri.rand / 7919 -- just the 1000th prime
                anim = variant.images[rnd % #variant.images]

                is_empty = true
                -- for(size_t i = 0; i < anim.get_frames_count(); ++i) {
                for i = 1, anim.get_frames_count()
                    if(not @image.is_empty_hex(anim.get_frame(i)))
                        is_empty = false
                        break

                if(is_empty)
                    continue

                table.insert(img_list, anim) -- img_list.push_back(anim)

                assert(anim.get_animation_duration() != 0)

                if variant.random_start < 0
                    img_list.back().set_animation_time(
                        ri.rand % img_list.back().get_animation_duration())
                elseif variant.random_start > 0
                    img_list.back().set_animation_time(
                        ri.rand % variant.random_start)

                unless animate
                    img_list.back().pause_animation()

                if log
                    log.emplace_back(ri, variant)

                break -- found a matching variant

    ----
    -- Clears all data in this tile, and resets the cache
    clear: =>
        @flags.clear()
        @images.clear()
        @sorted_images = false
        @images_foreground.clear()
        @images_background.clear()
        @last_tod = "invalid_tod"


    -- /** The list of flags present in this tile */
    -- std::set<std::string> flags;

    -- /** The list of rule_images and random seeds associated to this tile.
    --   */
    -- std::vector<rule_image_rand> images;

    -- /** The list of images which are in front of the unit sprites,
    --   * attached to this tile. This member is considered a cache:
    --   * it is built once, and on-demand.
    --   */
    -- imagelist images_foreground;
    -- /** The list of images which are behind the unit sprites,
    --   * attached to this tile. This member is considered a cache:
    --   * it is built once, and on-demand.
    --   */
    -- imagelist images_background;
    -- /**
    --   * The time-of-day to which the image caches correspond.
    --   */
    -- std::string last_tod;

    -- /** Indicates if 'images' is sorted */
    -- bool sorted_images;

