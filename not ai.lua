-- UsageExample.lua
-- This script demonstrates how to utilize the ResourceManager API to manage 
-- player abilities, currencies, and cooldowns dynamically.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 1. Import dependencies
local ResourceManager = require(path.to.ResourceManager)
local ResourceTypes = require(path.to.Config.ResourceTypes)

-- 2. Define our resource configurations
local GOLD_RESOURCE = {
    type = ResourceTypes.Item,
    id = "Gold",
    defaultAmount = 100,
    maxCapacity = 9999,
}

local FIREBALL_COOLDOWN = {
    type = ResourceTypes.Cooldown,
    id = "FireballCooldown",
    duration = 3.5, -- 3.5 seconds cooldown
}

-- 3. Simulate a player spawning and obtaining a ResourceManager
Players.PlayerAdded:Connect(function(player)
    -- Initialize the manager for this specific entity (the player instance)
    local playerResourceManager = ResourceManager.new(player)
    
    -- Optional: Connect to the signal wrapper to listen to state events globally
    playerResourceManager:ConnectOnCall(function(functionName, resource, ...)
        print(string.format("[API Event] Player called '%s' on Resource: %s", functionName, resource.id))
    end)

    -- 4. Hook the manager into the game loop so updates (like cooldown tick-downs) process
    local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
        playerResourceManager:update(dt)
    end)

    -- 5. Define a safe action wrapper using your API
    local function tryCastFireball()
        print("\n--- Attempting to cast Fireball ---")

        -- Check if we can afford both the gold cost and if the cooldown is ready
        local hasEnoughGold = playerResourceManager:canAfford(GOLD_RESOURCE, 25) -- Costs 25 gold
        local cooldownReady = playerResourceManager:canAfford(FIREBALL_COOLDOWN)

        if hasEnoughGold and cooldownReady then
            -- Deduct resources and trigger the cooldown
            playerResourceManager:spend(GOLD_RESOURCE, 25)
            playerResourceManager:spend(FIREBALL_COOLDOWN)
            
            print("🔥 Fireball successfully cast!")
            
            -- Fetch current balance directly using strategy specific custom calls
            local currentGold, _ = playerResourceManager:call(GOLD_RESOURCE, "getBalance")
            print(string.format("Remaining Gold: %d", currentGold))
        else
            -- Diagnostic warnings to the player
            if not hasEnoughGold then
                print("❌ Cannot cast: Not enough Gold.")
            end
            if not cooldownReady then
                print("❌ Cannot cast: Ability is on cooldown.")
            end
        end
    end

    -- --- SIMULATED GAMEPLAY FLOW ---
    
    -- Cast 1: Success (Costs 25 gold, sets 3.5s cooldown)
    tryCastFireball() 

    -- Cast 2: Fails immediately (On cooldown)
    task.wait(1)
    tryCastFireball() 

    -- Cast 3: Success again (After cooldown expires)
    task.wait(3) 
    tryCastFireball()

    -- Reward the player with some gold using resource restoration
    print("\n--- Player completes a quest! ---")
    playerResourceManager:restore(GOLD_RESOURCE, 50) -- Restores 50 gold

    -- Cleanup connection when player leaves
    player.AncestryChanged:Connect(function()
        if not player:IsDescendantOf(game) then
            heartbeatConnection:Disconnect()
            playerResourceManager:remove(GOLD_RESOURCE)
            playerResourceManager:remove(FIREBALL_COOLDOWN)
        end
    end)
end)