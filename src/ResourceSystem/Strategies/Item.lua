local Item = {}
local types = require(script.Parent.Parent.Config.ResourceTypes)

Item.type = types.Item -- like currency

function Item.init(ctx)
	ctx.state.amount = ctx.resource.defaultAmount or 0
	ctx.state.maxCapacity = ctx.resource.maxCapacity or math.huge
end

function Item.canAfford(ctx, cost)
	local costAmount = cost or ctx.resource.cost or 0
	return ctx.state.amount >= costAmount
end

function Item.spend(ctx, cost)
	local costAmount = cost or ctx.resource.cost or 0

	if Item.canAfford(ctx, costAmount) then
		ctx.state.amount -= costAmount

		if ctx.entity:IsA("Instance") then
			ctx.entity:SetAttribute(ctx.resource.id, ctx.state.amount)
		end
	else
		warn("Cannot afford item spend for resource: " .. tostring(ctx.resource.id))
	end
end

function Item.restore(ctx, gainAmount)
	local amountToAdd = gainAmount or 1

	ctx.state.amount = math.clamp(ctx.state.amount + amountToAdd, 0, ctx.state.maxCapacity)

	if ctx.entity:IsA("Instance") then
		ctx.entity:SetAttribute(ctx.resource.id, ctx.state.amount)
	end
end

function Item.getBalance(ctx)
	return ctx.state.amount, ctx.state.maxCapacity
end

return Item

--[[ resource config shape:
{
    type          = Resources.Item,
    id            = string,    -- required, unique identifier (e.g., "Cash", "Gold")
    defaultAmount = number,    -- optional, baseline amount when initialized (defaults to 0)
    maxCapacity   = number,    -- optional, highest allowed value (defaults to math.huge)
    cost          = number,    -- optional, default quantity deducted when spend() is called without parameters
}
--]]