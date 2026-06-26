local ResourceManager = require(path.to.ResourceManager)
local ResourceTypes = require(path.to.Config.ResourceTypes)

-- 1. Initialize a Manager instance for a specific player
local player = game.Players.LocalPlayer
local stats = ResourceManager.new(player)

-- 2. Initialize your configurations into interactive, dynamic proxies
local gold = stats:init({
    type = ResourceTypes.Item,
    id = "Gold",
    defaultAmount = 50,
})

local fireballCooldown = stats:init({
    type = ResourceTypes.Cooldown,
    id = "Fireball",
    duration = 3, -- 3-second cooldown duration
})

-- 3. Connect to a high-frequency engine loop for ticking updates (e.g., cooldown intervals)
game:GetService("RunService").Heartbeat:Connect(function(dt)
    stats:update(dt)
end)

-- 4. Clean, ergonomic gameplay implementation
local function tryCastFireball()
    -- Dynamic metatable proxies route these methods directly to strategy logic!
    if gold:canAfford(15) and fireballCooldown:canAfford() then
        
        gold:spend(15)
        fireballCooldown:spend()
        
        print("🔥 Fireball cast successfully!")
    else
        print("❌ Cannot cast: Insufficient gold or ability is still on cooldown.")
    end
end

-- --- Simulated Timeline Loop ---
tryCastFireball() -- Output: 🔥 Fireball cast successfully! (35 Gold remaining, CD active)
tryCastFireball() -- Output: ❌ Cannot cast... (Blocked by active cooldown)

task.wait(3)

tryCastFireball() -- Output: 🔥 Fireball cast successfully! (20 Gold remaining)