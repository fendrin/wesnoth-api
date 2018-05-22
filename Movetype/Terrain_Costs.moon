dir = (...)\match"(.-)[^%.]+$"

Terrain_Info = require"#{dir}Terrain_Info"
-- Movetype  = require"#{dir}Movetype"

-- Magic value that signifies a hex is unreachable.
-- The UNREACHABLE macro in the data tree should match this value.
UNREACHABLE = 99


----
-- Stores a set of terrain costs (for movement, vision, or "jamming").
class Terrain_Costs extends Terrain_Info

    params: Terrain_Info.Parameters(1, UNREACHABLE)

    -- explicit terrain_costs(const terrain_costs * fallback=nullptr,
    --                           const terrain_costs * cascade=nullptr) :
    --     terrain_info(params_, fallback, cascade)
    -- explicit terrain_costs(const config & cfg,
    --                           const terrain_costs * fallback=nullptr,
    --                           const terrain_costs * cascade=nullptr) :
    --     terrain_info(cfg, params_, fallback, cascade)
    -- terrain_costs(const terrain_costs & that,
    --                 const terrain_costs * fallback=nullptr,
    --                 const terrain_costs * cascade=nullptr) :
    --     terrain_info(that, fallback, cascade)
    new: (cfg, terrain_types, fallback, cascade) =>
        assert(cfg, "no cfg")
        assert(@params, "no params")
        super(cfg, @params, terrain_types, fallback, cascade)

    ----
    -- Returns the cost associated with the given terrain.
    -- Costs are doubled when @a slowed is true.
    cost: (terrain, slowed=false) =>

        assert(terrain, 'no terrain arg')

        result = @\value(terrain)
        -- @todo
        -- return slowed and result != (if UNREACHABLE
            -- 2 * result else result)
        return result

return Terrain_Costs
