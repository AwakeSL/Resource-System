local ResourceManager = {}
ResourceManager.__index = ResourceManager

local Resources = require(script.Parent.Config.ResourceTypes)
local strategies = {}

-- default factory
ResourceManager.signalFactory = function()
	local bindable = Instance.new("BindableEvent")
	return {
		Fire = function(_, ...) bindable:Fire(...) end,
		Connect = function(_, callback) return bindable.Event:Connect(callback) end,
	}
end

function ResourceManager.setSignalFactory(factory)
	ResourceManager.signalFactory = factory
end

function ResourceManager.register(resourceType, strategy)
	strategies[resourceType] = strategy
end

function ResourceManager:getStrategy(resource)
	return assert(strategies[resource.type], "No strategy registered for resource type: " .. tostring(resource.type))
end

function ResourceManager.new(entity)
	local self = setmetatable({}, ResourceManager)
	self.entity = entity
	self.state = {}
	self._signalWrapper = ResourceManager.signalFactory()

	return self
end

function ResourceManager:ConnectOnCall(callback)
	return self._signalWrapper:Connect(callback)
end

function ResourceManager:init(resource)
	if self.state[resource.id] then return end

	self.state[resource.id] = {
		resource = resource,
		data = {},
	}

	local strategy = self:getStrategy(resource)
	if strategy.init then
		strategy.init({
			state = self.state[resource.id].data,
			resource = resource,
			entity = self.entity,
			manager = self,
		})
	end
end

function ResourceManager:call(resource, functionName, ...)
	assert(resource, "ResourceManager: resource is nil in call()")

	if not self.state[resource.id] then
		self:init(resource)
	end

	local strategy = self:getStrategy(resource)
	local func = strategy[functionName]
	if not func then
		warn(string.format("Strategy %s does not support: %s", tostring(resource.type), tostring(functionName)))
		return nil
	end

	self._signalWrapper:Fire(functionName, resource, ...)

	return func({
		state = self.state[resource.id].data,
		resource = resource,
		entity = self.entity,
		manager = self,
	}, ...)
end

function ResourceManager:canAfford(resource, ...)
	return self:call(resource, "canAfford", ...) ~= false
end

function ResourceManager:spend(resource, ...)
	self:call(resource, "spend", ...)
end

function ResourceManager:restore(resource, ...)
	self:call(resource, "restore", ...)
end

function ResourceManager:update(dt)
	for _, entry in pairs(self.state) do
		local resource = entry.resource
		local strategy = strategies[resource.type]

		if strategy and strategy.update then
			self._signalWrapper:Fire("update", resource, dt)
			strategy.update({
				state = entry.data,
				resource = resource,
				entity = self.entity,
				manager = self,
			}, dt)
		end
	end
end

function ResourceManager:remove(resource)
	if self.state[resource.id] then
		self:call(resource, "cleanup")
		self.state[resource.id] = nil
	end
end

-- Auto registration
for _, strategyModule in script.Parent.Strategies:GetChildren() do
	if strategyModule:IsA("ModuleScript") then
		local strategy = require(strategyModule)
		if strategy.type then
			ResourceManager.register(strategy.type, strategy)
		end
	end
end

return ResourceManager