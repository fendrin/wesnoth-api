movetype = nil
resources = nil
enemy_zoc = nil
VALIDATE = "whatever"

class Cost_Calculator

    getNoPathValue: -> return 42424242.0


class Shortest_Path_Calculator extends Cost_Calculator

    ----
    -- shortest_path_calculator(unit const &u, team const &t, std::vector<team> const &teams, gamemap const &map, bool ignore_unit, bool ignore_defense, bool see_all)
    new: (u, t, teams, map, ignore_unit = false, ignore_defense = false, see_all = false) =>
        @unit_ = u
        @viewing_team_ = t
        @teams_ = teams
        @map_ = map
        @movement_left_  = @unit_.movement_left
        @total_movement_ = @unit_.total_movement
        @ignore_unit_    = ignore_unit
        @ignore_defense_ = ignore_defense
        @see_all_        = see_all


    -- virtual double cost(const map_location& loc, const double so_far) const;
    -- double shortest_path_calculator::cost(const map_location& loc, const double so_far) const
    cost: (loc, so_far) =>

        assert(@map_.on_board(loc))

        -- loc is shrouded, consider it impassable
        -- NOTE: This is why AI must avoid to use shroud
        return @getNoPathValue! if not @see_all_ and @viewing_team_.shrouded(loc)

        terrain = @map_[loc]
        terrain_cost = @unit_.movement_cost(terrain)
        -- Pathfinding heuristic: the cost must be at least 1
        VALIDATE(terrain_cost >= 1, "Terrain with a movement cost less than 1 encountered.")

        -- Compute how many movement points are left in the game turn needed to reach the previous hex.
        -- total_movement_ is not zero, thanks to the pathfinding heuristic
        remaining_movement = @movement_left_ - so_far -- static_cast<int>(so_far)
        if remaining_movement < 0
            remaining_movement = @total_movement_ - (-remaining_movement) % @total_movement_

        if (terrain_cost >= movetype.UNREACHABLE or (@total_movement_ < terrain_cost and
            remaining_movement < terrain_cost))
            return @getNoPathValue!

        other_unit_subcost = 0
        unless @ignore_unit_
            other_unit = resources.gameboard\get_visible_unit(loc, @viewing_team_, @see_all_)

            -- We can't traverse visible enemy and we also prefer empty hexes
            -- (less blocking in multi-turn moves and better when exploring fog,
            -- because we can't stop on a friend)

            if other_unit
                if (@teams_[@unit_.side].is_enemy(other_unit.side))
                    return @getNoPathValue!
                else
                    -- This value will be used with the defense_subcost (see below)
                    -- The 1 here means: consider occupied hex as a -1% defense
                    -- (less important than 10% defense because friends may move)
                    other_unit_subcost = 1

        -- this will sum all different costs of this move
        move_cost = 0

        -- Suppose that we have only 2 remaining MP and want to move onto a hex
        -- costing 3 MP. We don't have enough MP now, so we must end our turn here,
        -- thus spend our remaining MP by waiting (next turn, with full MP, we will
        -- be able to move on that hex)
        if remaining_movement < terrain_cost
            move_cost += remaining_movement
            remaining_movement = @total_movement_ -- we consider having full MP now

        -- check ZoC
        if (not @ignore_unit_ and remaining_movement != terrain_cost and
            enemy_zoc(@teams_[@unit_.side], loc, @viewing_team_, @see_all_) and
            not @unit_.get_ability_bool("skirmisher", loc, resources.gameboard))
            -- entering ZoC cost all remaining MP
            move_cost += remaining_movement
        else -- empty hex, pay only the terrain cost
            move_cost += terrain_cost

        -- We will add a tiny cost based on terrain defense, so the pathfinding
        -- will prefer good terrains between 2 with the same MP cost
        -- Keep in mind that defense_modifier is inverted (= 100 - defense%)
        defense_subcost = if @ignore_defense_ then 0 else @unit_.defense_modifier(terrain)

        -- We divide subcosts by 100 * 100, because defense is 100-based and
        -- we don't want any impact on move cost for less then 100-steps path
        -- (even ~200 since mean defense is around ~50%)
        return move_cost + (defense_subcost + other_unit_subcost) / 10000.0


class Move_Type_Path_Calculator extends Cost_Calculator

    ----
    -- @param mt
    -- @param movement_left
    -- @param total_movement
    -- @param t
    -- @param map
    new: (mt, movement_left, total_movement, t, map) =>
        @movement_type_  = mt
        @movement_left_  = movement_left
        @total_movement_ = total_movement
        @viewing_team_   = t
        @map_ = map


    ----
    -- This is an simplified version of shortest_path_calculator (see above for explanation)
    -- move_type_path_calculator::cost(const map_location& loc, const double so_far) const
    -- @param Location loc
    -- @param double so_far
    -- @return double the cost
    cost: (loc, so_far) =>

        assert(@map_\on_board(loc))
        if @viewing_team_.shrouded(loc)
            return @getNoPathValue!

        terrain = @map_[loc]
        terrain_cost = @movement_type_.movement_cost(terrain)

        if @total_movement_ < terrain_cost
            return @getNoPathValue!

        remaining_movement = @movement_left_ - so_far --static_cast<int>(so_far);
        if remaining_movement < 0
            remaining_movement = @total_movement_ - (-remaining_movement) % @total_movement_

        move_cost = 0

        if remaining_movement < terrain_cost
            move_cost += remaining_movement

        move_cost += terrain_cost

        return move_cost


----
-- Function which only uses terrain, ignoring shroud, enemies, etc.
-- Required by move_unit_fake if the normal path fails.
class Emergency_Path_Calculator extends Cost_Calculator

    -- emergency_path_calculator(const unit& u, const gamemap& map)
    new: (u, map) =>
        @unit_ = u
        @map_  = map


    -- virtual double cost(const map_location& loc, const double so_far) const;
    -- double emergency_path_calculator::cost(const map_location& loc, const double) const
    cost: (loc, so_far) =>
        assert(@map_.on_board(loc))
        return @unit_.movement_cost(@map_[loc])


----
-- Doesn't take anything into account. Used by
-- move_unit_fake for the last-chance case.
class Dummy_Path_Calculator extends Cost_Calculator

    cost: (loc, so_far) => return 1.0


{
    :Shortest_Path_Calculator
    :Move_Type_Path_Calculator
    :Emergency_Path_Calculator
    :Dummy_Path_Calculator
}
