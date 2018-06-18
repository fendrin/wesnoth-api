resources = nil

dir = (...)\match"(.-)[^%.]+$"
import enemy_zoc from require"#{dir}.pathfind"

-- Structure which holds a single route between one location and another.
class Plain_Route

    new: =>
        @steps = {} -- std::vector<map_location> steps;
        @move_cost = 0 -- Movement cost for reaching the end of the route.


----
-- Structure which holds a single route and marks for special events.
class Marked_Route

    new: (other) =>
        -- make steps and move_cost of the underlying plain_route directly accessible
        unless other
            @route = Plain_Route!
            @steps = @route.steps
            @move_cost = @route.move_cost
            @marks = {}
        else
            @route = other.route
            @steps = @route.steps
            @move_cost = @route.move_cost
            @marks = other.marks

    -- marked_route& operator=(const marked_route& rhs)
    __eq: (other) =>
        @route = other.route
        @steps = @route.steps
        @move_cost = @route.move_cost
        @marks = other.marks
        return @


class Mark
    new: (turns_number=0, in_zoc=false, do_capture=false, is_invisible=false) =>
        @turns = turns_number
        @zoc   = in_zoc
        @capture   = do_capture
        @invisible = is_invisible

    -- bool operator==(const mark& m) const
    __eq: (other) =>
        return @turns == other.turns and @zoc == other.zoc and @capture == other.capture and @invisible == other.invisible


----
-- Add marks on a route @a rt assuming that the unit located at the first hex of
-- rt travels along it.
--
-- @param plain_route rt
-- @return Marked_Route
mark_route = (rt) -> -- marked_route mark_route(const plain_route &rt)

	res = Marked_Route!

	return res if rt.steps.empty!
	res.route = rt

	u = resources.gameboard.units.find(rt.steps.front)
    return res unless u

	turns = 0
	movement = u.movement_left
	unit_team = resources.gameboard\get_team(u.side)
	zoc = false

    for i, step in rt.steps
		last_step = i == #rt.steps

        -- move_cost of the next step is irrelevant for the last step
		assert(last_step or resources.gameboard.map\on_board(step))
		move_cost = if last_step then 0
        else u.movement_cost((resources.gameboard.map)[step])

		viewing_team = resources.gameboard.teams[resources.screen.viewing_team]

		if (last_step or zoc or move_cost > movement)
            -- check if we stop an a village and so maybe capture it
            -- if it's an enemy unit and a fogged village, we assume a capture
            -- (if he already owns it, we can't know that)
            -- if it's not an enemy, we can always know if he owns the village
			capture = resources.gameboard.map.is_village(step) and
                ( not unit_team.owns_village(step) or
                (viewing_team.is_enemy(u.side()) and viewing_team.fogged(step)) )

            turns += 1

			invisible = u.invisible(step, resources.gameboard, false)

			res.marks[step] = Mark(turns, zoc, capture, invisible)

			break if last_step -- finished and we used dummy move_cost

			movement = u.total_movement
			return res if move_cost > movement -- we can't reach destination

		zoc = enemy_zoc(unit_team, rt.steps[i + 1], viewing_team) and
            not u.get_ability_bool("skirmisher", rt.steps[i+1], resources.gameboard)

		if zoc
			movement = 0
		else
			movement -= move_cost

	return res


{
    :Plain_Route
    :mark_route
}
