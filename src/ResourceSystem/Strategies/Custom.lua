local Custom = {}
local types = require(script.Parent.Parent.Config.ResourceTypes)

Custom.type = types.Custom

function Custom.canAfford(ctx)
	if not ctx.resource.canAfford then return true end
	return ctx.resource.canAfford(ctx.entity)
end

function Custom.spend(ctx)
	if not ctx.resource.spend then return end
	ctx.resource.spend(ctx.entity)
end

function Custom.restore(ctx)
	if not ctx.resource.restore then return end
	ctx.resource.restore(ctx.entity)
end

return Custom

--[[ resource config shape:
{
    type      = Resources.Custom,
    id        = string,                        -- required, unique identifier
    canAfford = (entity) -> boolean,           -- optional, assumes true if missing
    spend     = (entity) -> (),               -- optional
    restore   = (entity) -> (),               -- optional
}
--]]