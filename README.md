<div align="center">

# ⏳ D3XL Progress Bar System V1

### Ultra Modern Cyberpunk Segmented Slanted Progress Bar for FiveM
*Exact 1-to-1 Match to Slanted Parallelogram 15-Block Segment UI with `#36FF9F` Neon Mint & Failure Red Flash Feedback*

[![FiveM](https://img.shields.io/badge/FiveM-b3751%2B-brightgreen?style=for-the-badge&logo=fivem&logoColor=white)](https://fivem.net)
[![Framework](https://img.shields.io/badge/Framework-QBCore%20%7C%20Qbox%20%7C%20ESX%20%7C%20ox__lib%20%7C%20Standalone-00f0ff?style=for-the-badge)](https://github.com/d3xllive/d3xl-progressbar)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

---

</div>

## ✨ Key Features

- 📐 **Exact 1-to-1 Slanted Parallelogram UI**: `-25deg` skewed frame with top & bottom cutout extension lines and Bebas Neue condensed typography (`LOADING 57%`).
- 🔳 **15 Individual Block Segments**: 15 hollow outlined block boxes that illuminate one by one into solid Neon Mint (`#36FF9F`) as progress advances.
- 🔴 **Dynamic Failure / Lockpick Fail Flash**: When cancelled (`X` key) or when a minigame fails (e.g. wrong lockpick pin), the entire progress bar flashes bright Neon Red (`#ff0055`) with an error buzzer sound!
- 🟢 **Dynamic Success Finish Flash**: On successful completion, all 15 segments flash bright Neon Mint (`#36FF9F`) with a success chime before fading.
- 🔊 **Web Audio API Synthesizer**: Smooth ticking audio sound on segment fill + success chime + fail buzzer without any external MP3 files.
- ⚡ **Universal Framework Compatibility**: Out-of-the-box drop-in override for `progressbar:client:progress`, `exports['qb-core']:Progressbar`, and `ox_lib`.

---

## 🚀 Installation

1. Download or clone this repository:
   ```bash
   git clone https://github.com/d3xllive/d3xl-progressbar.git
   ```
2. Place the folder into your server's `resources` directory:
   ```
   resources/d3xl-progressbar
   ```
3. Add the resource to your `server.cfg`:
   ```cfg
   ensure d3xl-progressbar
   ```

---

## 💻 Export Usage

### 1. Basic Progress Bar Call
```lua
exports['d3xl-progressbar']:Progress(
    'lockpick_car',               -- Action Name
    'KİLİT MAYMUNCUKLANIYOR',      -- Label Header
    5000,                         -- Duration (ms)
    false,                        -- Use While Dead
    true,                         -- Can Cancel (X key)
    {                             -- Control Disables
        disableMovement = true,
        disableCombat = true
    },
    nil,                          -- Animation (dict, clip)
    nil,                          -- Prop
    nil,                          -- Prop 2
    function()                    -- On Success Callback (Green Flash)
        TriggerEvent('chat:addMessage', { args = { "BAŞARILI", "Araç kilidi açıldı!" } })
    end,
    function()                    -- On Cancel / Fail Callback (Red Flash)
        TriggerEvent('chat:addMessage', { args = { "İPTAL", "Maymuncuk kırıldı!" } })
    end
)
```

### 2. Trigger Lockpick Failure / Cancel (Red Flash)
```lua
-- Cancel active progress bar and trigger red error flash
exports['d3xl-progressbar']:Cancel('YANLIŞ PİN!')
```

---

## ⚙️ Configuration (`config.lua`)

```lua
Config = {}

-- Screen Position: "center-bottom", "center", "bottom-right"
Config.Position = "center-bottom"

-- Accent Color
Config.Color = "#36FF9F" -- Neon Mint

-- Subtle Audio Ticks & Sounds (true / false)
Config.EnableSound = true

-- Cancel Key (Default: X / Key 73)
Config.CancelKey = 73

-- Framework Overrides (true / false)
Config.EnableQBCoreProgress = true
Config.EnableOxLibProgress  = true
Config.EnableTestCommand    = true
```

---

## 🎮 In-Game Test Command

Type `/testprogress` in chat to trigger the progress bar! Press **`X`** during progress to test the red cancel flash animation!

---

<div align="center">

Developed with ❤️ by **d3xl / D3XL SCRIPTS**

</div>
