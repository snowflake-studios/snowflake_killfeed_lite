# Snowflake Studios - Killfeed Lite

> **Version 1.0.0** | Free Edition | Unencrypted Source

---

A lightweight, high-performance killfeed notification system for FiveM servers keying in on performance and flexibility. This is the free, unencrypted edition of the Snowflake Killfeed suite, designed to be completely standalone while offering deep integration if you need it.

## ✨ Core Selling Points

- **⚡ 0.00ms Idle:** Fully event-driven architecture using `baseevents`. Zero resource consumption when inactive.
- **🔧 Standalone Ready:** Works on **any** server.
  - *Qbox Support:* Auto-detects `qbx_core` to fetch character names.
  - *Standalone:* Defaults to Steam/FiveM display names if no framework is present.
- **🔓 Unencrypted & Open:** Full source code access for maximum customization.
- **🎮 Steam Persona Support:** Built-in SteamID64 conversion to fetch and cache authentic Steam profile names (requires API Key).
- **🛡️ Safe & Stable:**
  - XSS-safe text rendering.
  - FiveM CEF-safe UI (no `backdrop-filter` crashes).
  - Smart deduplication to prevent kill spam.

## 📋 Requirements

Ensure these resources are started before the killfeed:

- **[ox_lib](https://github.com/overextended/ox_lib)** (Required)
- **[baseevents](https://github.com/citizenfx/fivem-data)** (Required - Standard FiveM Resource)
- **[qbx_core](https://github.com/Qbox-project/qbx_core)** (Optional - Auto-detected)

## 🚀 Installation

1.  **Download & Extract**
    - Place the `snowflake_killfeed_lite` folder into your server's `resources` directory.

2.  **Server Configuration**
    - Add the resource to your `server.cfg`. Ensure it starts *after* dependencies.
    ```cfg
    ensure ox_lib
    ensure baseevents
    ensure qbx_core # If using Qbox
    ensure snowflake_killfeed_lite
    ```

3.  **Restart Server**
    - Restart your server to load the resource.

## ⚙️ Configuration

All settings are managed in `config.lua`.

### 1. Visual Customization
Adjust colors and layout to match your server's UI theme.
```lua
Config.Colors = {
    killer = '#00F0FC',      -- Killer name (Cyan)
    victim = '#FF1493',      -- Victim name (Magenta)
    weapon = '#FFFFFF',      -- Weapon text (White)
    background = '#0F0F14'   -- Card background
}

Config.Layout = {
    posX = 0.8,              -- Horizontal position (0.8vw from right)
    posY = 50,               -- Vertical position (50vh center)
    borderRadius = 0         -- Corner roundness
}
```

### 2. Name Display Mode
Choose how player names are displayed in the feed.

- **Option A: Character Names (Default)**
  - Set `Config.NameMode = 'character'`
  - Automatically pulls First/Last references if `qbx_core` is running.

- **Option B: Steam Persona Names**
  - Set `Config.NameMode = 'steam'`
  - **Required:** You must provide a valid Steam Web API Key.
  - Get a key here: [https://steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey)
  - Paste the key into `Config.SteamApiKey` in `config.lua`:
    ```lua
    Config.SteamApiKey = 'YOUR_STEAM_WEB_API_KEY_HERE'
    ```

### 3. Testing Mode
If you are developing alone or need to test triggers without another player, enable the Ped Kill Test.
- When enabled, killing any NPC/Guard/Ped (on foot or in a vehicle) will trigger a killfeed notification.
- **Note:** Disable this for production servers to avoid spam from random ped deaths.
```lua
Config.EnablePedKillTest = true -- Set to false for production
```

## 💻 Usage

### Admin Commands
Commands are protected by ACE permissions. Add these to your `permissions.cfg`:

```cfg
add_ace group.admin command.killfeedtest allow
add_ace group.admin command.testkill allow
```

| Command | Usage | Description |
| :--- | :--- | :--- |
| `/killfeedtest` | `/killfeedtest [1-7]` | Spawns a specific number of test entries. |
| `/testkill` | `/testkill` | Simulates a live scenario with 5 random kills. |

### Developer Exports
Trigger the killfeed from your own scripts (e.g., robberies, drug wars).

**1. Whitelist Your Resource:**
Add your resource name to the allowed list in `config.lua`:
```lua
Config.AllowedExportResources['my_robbery_script'] = true
```

**2. Call the Export:**
```lua
-- Format: killerName, victimName, weaponLabel
exports.snowflake_killfeed_lite:AddKill('Officer John', 'Criminal Mike', 'Combat Pistol')

-- You can also pass Server IDs (auto-resolves names):
exports.snowflake_killfeed_lite:AddKill(source, targetId, 'Knife')
```

## 🆘 Support

Need help or want to check out the Premium version?

**Official Store:** [Snowflake Studios](https://snowflake-studios.tebex.io/)

For technical support and community access, please visit our official website to find the current Discord invitation link.

## 📄 License

**Snowflake Killfeed Lite** is free software. You are free to edit, modify, and use this script on your server.
*Re-selling or re-distributing this script as a paid standalone package is prohibited.*

---
**© 2026 Snowflake Studios - All Rights Reserved**

