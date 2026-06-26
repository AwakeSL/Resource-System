local Energy = {}
local types = require(script.Parent.Parent.Config.ResourceTypes)
Energy.type = types.Energy

function Energy.canAfford(ctx)
	return ctx.resource.pool[ctx.resource.key] >= ctx.resource.cost
end

function Energy.spend(ctx)
	ctx.resource.pool[ctx.resource.key] -= ctx.resource.cost
end

function Energy.restore(ctx)
	ctx.resource.pool[ctx.resource.key] += ctx.resource.cost
end

return Energy
--[[ resource config shape:
{
    type  = Resources.Energy,
    id    = string,    -- required, shared pool name e.g. "Energy"
    cost  = number,    -- required, how much this ability costs
    pool  = {},        -- required, reference to the table which the "energy" value is stored on
    key   = string,  -- required, which field to read/write
}
--]]