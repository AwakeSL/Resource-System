local Charges = {}
local types = require(script.Parent.Parent.Config.ResourceTypes)

Charges.type = types.Charges

function Charges.init(ctx)    
    ctx.state.current = ctx.resource.max
    ctx.state.timer   = 0
end
function Charges.canAfford(ctx)
	return ctx.state.current >= (ctx.resource.cost or 1)
end

function Charges.spend(ctx)
	ctx.state.current -= (ctx.resource.cost or 1)
end

function Charges.restore(ctx)
	ctx.state.current = ctx.resource.max
end

function Charges.update(ctx, dt)
	if not ctx.resource.recharge then return end
	if ctx.state.current >= ctx.resource.max then return end

	-- threshold check, only recharge when below x
	if ctx.resource.recharge.threshold then
		if ctx.state.current >= ctx.resource.recharge.threshold then return end
	end

	ctx.state.timer = (ctx.state.timer or 0) + dt
	if ctx.state.timer >= ctx.resource.recharge.rate then
		ctx.state.timer = 0
		ctx.state.current = math.min(ctx.state.current + 1, ctx.resource.max)
	end
end

return Charges

--[[ resource config shape:
{
    type     = Resources.Charges,
    id       = string,        -- required, unique identifier
    max      = number,        -- required, max charges
    cost     = number?,       -- optional, defaults to 1
    recharge = {
        rate      = number,   -- seconds per charge
        threshold = number?,  -- optional, only recharge below this
    }?
}
--]] 