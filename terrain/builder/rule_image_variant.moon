----
-- An image variant. The in-memory representation of the [variant]
-- WML tag of the [image] WML tag. When an image only has one variant,
-- the [variant] tag may be omitted.
class Rule_Image_Variant

    -- /** Constructor for the normal default case */
    -- rule_image_variant(const std::string& image_string, const std::string& variations, int random_start = -1)
    --     : image_string(image_string)
    --     , variations(variations)
    --     , images()
    --     , tods()
    --     , has_flag()
    --     , random_start(random_start)
    -- /** Constructor for true [variant] cases */
    -- rule_image_variant(const std::string& image_string,
    --         const std::string& variations,
    --         const std::string& tod,
    --         const std::string& has_flag,
    --         int random_start = -1);

    -- /** A string representing either the filename for an image, or
    --   *  a list of images, with an optional timing for each image.
    --   *  Corresponds to the "name" parameter of the [variant] (or of
    --   *  the [image]) WML tag.
    --   *
    --   *  The timing string is in the following format (expressed in EBNF)
    --   *
    --   *@verbatim
    --   *  <timing_string> ::= <timed_image> ( "," <timed_image> ) +
    --   *
    --   *  <timed_image> ::= <image_name> [ ":" <timing> ]
    --   *
    --   *  Where <image_name> represents the actual filename of an image,
    --   *  and <timing> the number of milliseconds this image will last
    --   *  in the animation.
    --   *@endverbatim
    --   */
    -- std::string image_string;

    -- /** A semi-solon separated list of string used to replace
    --   * @verbatim <code>@V</code> @endverbatim in image_string (if present)
    --   */
    -- std::string variations;

    -- /** An animated image locator built according to the image string.
    --   * This will be the image locator which will actually
    --   * be returned to the user.
    --   */
    -- std::vector<animated<image::locator>> images;

    -- /** The Time of Day associated to this variant (if any)*/
    -- std::set<std::string> tods;

    -- std::vector<std::string> has_flag;

    -- /** Specify the allowed amount of random shift (in milliseconds) applied
    --   * to the animation start time, -1 for shifting without limitation.*/
    -- int random_start;
