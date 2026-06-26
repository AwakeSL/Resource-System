--!strict

local Resources = {
	-- resource types are just strategies for how you manage cooldowns or wtv
	Cooldown = "Cooldown",  -- single timer, blocks until done
	Charges  = "Charges",   -- pool of uses, recharges over time
	Energy   = "Energy",    -- shared pool across abilities
	Item     = "Item",      -- items or currency stuff
	-- add more if needed, then create the strategies in the `strategies` folder 
	Custom   = "Custom",    -- delegates to ability's own canAfford/spend/restore functions, intended for only unique cases
}

export type ResourceTypes = typeof(Resources[string])

return Resources