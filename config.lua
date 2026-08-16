-- =================================================================
-- D3XL FiveM Standalone Progress Bar Configuration File (Lua)
-- Author: d3xl
-- =================================================================

Config = {}

-- Screen Position: "center-bottom", "center", "bottom-right"
Config.Position = "center-bottom"

-- Accent Colors
Config.Color = "#36FF9F" -- tgiann Neon Mint

-- Sound Effect (true = enabled subtle tick sound, false = silent)
Config.EnableSound = true

-- Key to cancel progress (Default: X / Key 73)
Config.CancelKey = 73 

-- Framework Integration Toggles
Config.EnableQBCoreProgress = true -- Overrides progressbar:client:progress
Config.EnableOxLibProgress  = true -- Overrides ox_lib progress
Config.EnableTestCommand    = true -- Enables /testprogress command
