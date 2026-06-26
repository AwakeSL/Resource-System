local Cooldown = {}
local types = require(script.Parent.Parent.Config.ResourceTypes)

Cooldown.type = types.Cooldown

function Cooldown.init(ctx)
	ctx.state.remaining = 0
	ctx.state.timeScale = 1
	ctx.state.paused = false
	ctx.state.onComplete = nil
end

function Cooldown.canAfford(ctx)
	return ctx.state.remaining <= 0 and not ctx.state.paused
end

function Cooldown.spend(ctx, duration)
	ctx.state.remaining = duration or ctx.resource.duration
end
function Cooldown.restore(ctx)
	ctx.state.remaining = 0
end

-- Advanced Feature Additions:
function Cooldown.pause(ctx)
	ctx.state.paused = true
end

function Cooldown.resume(ctx)
	ctx.state.paused = false
end

function Cooldown.setTimeScale(ctx, scale)
	ctx.state.timeScale = scale or 1
end

function Cooldown.adjustDuration(ctx, amount)
	ctx.state.remaining = math.max(0, ctx.state.remaining + amount)
end

function Cooldown.update(ctx, dt)
	if ctx.state.paused or ctx.state.remaining <= 0 then return end

	-- Apply time scaling features seamlessly
	local actualDt = dt * ctx.state.timeScale
	ctx.state.remaining -= actualDt

	if ctx.state.remaining <= 0 then
		Cooldown.restore(ctx)
	end
end

return Cooldown

--[[ resource config shape:
{
    type     = Resources.Cooldown,
    id       = string,   -- required, unique identifier
    duration = number,   -- required, seconds until ready again
}
--]] 