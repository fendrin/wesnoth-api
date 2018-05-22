----
-- The in-memory representation of a [terrain_graphics] WML rule.
class Building_Rule

    new: =>
        -- : constraints()
        -- , location_constraints()
        -- , modulo_constraints()
        @probability = 100
        @precedence = 0
        @local = false
        -- , hash_(DUMMY_HASH)

--     /**
--       * The set of [tile] constraints of this rule.
--       */
--     constraint_set constraints;

--     /**
--       * The location on which this map may match.
--       * Set to a valid map_location if the "x" and "y" parameters
--       * of the [terrain_graphics] rule are set.
--       */
--     map_location location_constraints;

--     /**
--       * Used to constrain locations to ones with coordinates that are
--       * multiples of the "mod_x" and "mod_y" parameters. Doesn't actually
--       * refer to a real map location.
--       */
--     map_location modulo_constraints;

--     /**
--       * The probability of this rule to match, when all conditions
--       * are met. Defined if the "probability" parameter of the
--       * [terrain_graphics] element is set.
--       */
--     int probability;

--     /**
--       * Ordering relation between the rules.
--       */
--     int precedence;

--     /**
--       * Indicate if the rule is only for this scenario
--       */
--     bool local;

    -- bool operator<(const building_rule& that) const
    _lt: (that) =>
        return @precedence < that.precedence

--     unsigned int get_hash() const;

-- private:
--     mutable unsigned int hash_;



unsigned int terrain_builder::building_rule::get_hash() const
{
	if(hash_ != DUMMY_HASH)
		return hash_;

	for(const terrain_constraint& constraint : constraints) {
		for(const rule_image& ri : constraint.images) {
			for(const rule_image_variant& variant : ri.variants) {
				// we will often hash the same string, but that seems fast enough
				hash_ += hash_str(variant.image_string);
			}
		}
	}

	// don't use the reserved dummy hash
	if(hash_ == DUMMY_HASH)
		hash_ = 105533; // just a random big prime number

	return hash_;
}
