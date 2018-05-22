----
-- These legacy map_location functions moved here from map_location.?pp.
-- We have refactored them out of everything but this class.
-- Hopefully the end is near...

--     // Adds an absolute location to a "delta" location
--     // This is not the mathematically correct behavior, it is neither
--     // commutative nor associative. Negative coordinates may give strange
--     // results. It is retained because terrain builder code relies in this
--     // broken behavior. Best avoid.
--     map_location legacy_negation() const;
--     map_location legacy_sum(const map_location &a) const;
--     map_location& legacy_sum_assign(const map_location &a);
--     map_location legacy_difference(const map_location &a) const;
--  *
--  */

-- static map_location legacy_negation(const map_location& me)
-- {
--     return map_location(-me.x, -me.y);
-- }

-- static map_location& legacy_sum_assign(map_location& me, const map_location& a)
-- {
--     bool parity = (me.x & 1) != 0;
--     me.x += a.x;
--     me.y += a.y;
--     if((a.x > 0) && (a.x % 2) && parity)
--         me.y++;
--     if((a.x < 0) && (a.x % 2) && !parity)
--         me.y--;

--     return me;
-- }

-- static map_location legacy_sum(const map_location& me, const map_location& a)
-- {
--     map_location ret(me);
--     legacy_sum_assign(ret, a);
--     return ret;
-- }

-- static map_location legacy_difference(const map_location& me, const map_location& a)
-- {
--     return legacy_sum(me, legacy_negation(a));
-- }
