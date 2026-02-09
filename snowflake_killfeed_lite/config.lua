Config = Config or {}

-- =============================================
-- Snowflake Studios - Killfeed Lite Configuration
-- Free Edition | v1.0.0
-- =============================================

Config.DedupWindowMs = 250
Config.Debug = false
Config.WeaponFallback = 'Unknown'
Config.WeaponHashFallback = 'Firearm'
Config.EnablePedKillTest = false

-- =============================================
-- Name Display Mode
-- 'character' (default) uses Qbox/QBCore character names
-- 'steam' uses Steam persona names (requires Steam API key)
-- =============================================
Config.NameMode = 'character'
Config.SteamApiKey = ''

-- =============================================
-- UI Color Customization
-- =============================================
Config.Colors = {
    killer = '#00F0FC',      -- Killer name color (Cyan)
    victim = '#FF1493',      -- Victim name color (Magenta)
    weapon = '#FFFFFF',      -- Weapon text color (White)
    background = '#0F0F14'   -- Card background color (Dark)
}

-- =============================================
-- Layout Customization
-- =============================================
Config.Layout = {
    primaryGlow = '#00F0FC', -- Main glow color (border + accents)
    posX = 0.8,              -- 0.8vw from right edge (≈15px at 1920px)
    posY = 50,               -- 50vh (vertically centered)
    borderRadius = 0         -- Border radius in px
}

-- =============================================
-- Animation & Timing
-- =============================================
Config.MessageDuration = 5000  -- How long each message stays (ms)
Config.FadeDuration = 500       -- Fade-out duration (ms)
Config.MaxMessages = 7         -- Maximum messages on screen

-- =============================================
-- Export Gating
-- Add resource names here to allow them to send custom killfeed messages via exports.
-- Example: Config.AllowedExportResources['my_robbery_script'] = true
-- =============================================
Config.AllowedExportResources = {
    ['snowflake_killfeed_lite'] = true
}

Config.WeaponLabels = {
    WEAPON_UNARMED = 'Unarmed',
    WEAPON_KNIFE = 'Knife',
    WEAPON_NIGHTSTICK = 'Nightstick',
    WEAPON_HAMMER = 'Hammer',
    WEAPON_BAT = 'Bat',
    WEAPON_GOLFCLUB = 'Golf Club',
    WEAPON_CROWBAR = 'Crowbar',
    WEAPON_BOTTLE = 'Bottle',
    WEAPON_DAGGER = 'Dagger',
    WEAPON_HATCHET = 'Hatchet',
    WEAPON_MACHETE = 'Machete',
    WEAPON_SWITCHBLADE = 'Switchblade',
    WEAPON_BATTLEAXE = 'Battle Axe',
    WEAPON_POOLCUE = 'Pool Cue',
    WEAPON_WRENCH = 'Wrench',
    WEAPON_FLASHLIGHT = 'Flashlight',
    WEAPON_KNUCKLE = 'Knuckle Duster',
    WEAPON_STONE_HATCHET = 'Stone Hatchet',
    WEAPON_PISTOL = 'Pistol',
    WEAPON_PISTOL_MK2 = 'Pistol Mk II',
    WEAPON_COMBATPISTOL = 'Combat Pistol',
    WEAPON_APPISTOL = 'AP Pistol',
    WEAPON_PISTOL50 = 'Pistol .50',
    WEAPON_SNSPISTOL = 'SNS Pistol',
    WEAPON_SNSPISTOL_MK2 = 'SNS Pistol Mk II',
    WEAPON_HEAVYPISTOL = 'Heavy Pistol',
    WEAPON_VINTAGEPISTOL = 'Vintage Pistol',
    WEAPON_MARKSMANPISTOL = 'Marksman Pistol',
    WEAPON_REVOLVER = 'Revolver',
    WEAPON_REVOLVER_MK2 = 'Revolver Mk II',
    WEAPON_DOUBLEACTION = 'Double Action Revolver',
    WEAPON_NAVYREVOLVER = 'Navy Revolver',
    WEAPON_CERAMICPISTOL = 'Ceramic Pistol',
    WEAPON_PISTOLXM3 = 'WM 29 Pistol',
    WEAPON_FLAREGUN = 'Flare Gun',
    WEAPON_MICROSMG = 'Micro SMG',
    WEAPON_SMG = 'SMG',
    WEAPON_SMG_MK2 = 'SMG Mk II',
    WEAPON_ASSAULTSMG = 'Assault SMG',
    WEAPON_MINISMG = 'Mini SMG',
    WEAPON_MACHINEPISTOL = 'Machine Pistol',
    WEAPON_COMBATPDW = 'Combat PDW',
    WEAPON_PUMPSHOTGUN = 'Pump Shotgun',
    WEAPON_PUMPSHOTGUN_MK2 = 'Pump Shotgun Mk II',
    WEAPON_SAWNOFFSHOTGUN = 'Sawed-Off Shotgun',
    WEAPON_BULLPUPSHOTGUN = 'Bullpup Shotgun',
    WEAPON_ASSAULTSHOTGUN = 'Assault Shotgun',
    WEAPON_MUSKET = 'Musket',
    WEAPON_HEAVYSHOTGUN = 'Heavy Shotgun',
    WEAPON_DBSHOTGUN = 'Double Barrel Shotgun',
    WEAPON_AUTOSHOTGUN = 'Auto Shotgun',
    WEAPON_COMBATSHOTGUN = 'Combat Shotgun',
    WEAPON_SWEEPERSHOTGUN = 'Sweeper Shotgun',
    WEAPON_MG = 'MG',
    WEAPON_MG_MK2 = 'MG Mk II',
    WEAPON_COMBATMG = 'Combat MG',
    WEAPON_COMBATMG_MK2 = 'Combat MG Mk II',
    WEAPON_GUSENBERG = 'Gusenberg',
    WEAPON_ASSAULTRIFLE = 'Assault Rifle',
    WEAPON_ASSAULTRIFLE_MK2 = 'Assault Rifle Mk II',
    WEAPON_CARBINERIFLE = 'Carbine Rifle',
    WEAPON_CARBINERIFLE_MK2 = 'Carbine Rifle Mk II',
    WEAPON_ADVANCEDRIFLE = 'Advanced Rifle',
    WEAPON_SPECIALCARBINE = 'Special Carbine',
    WEAPON_SPECIALCARBINE_MK2 = 'Special Carbine Mk II',
    WEAPON_BULLPUPRIFLE = 'Bullpup Rifle',
    WEAPON_BULLPUPRIFLE_MK2 = 'Bullpup Rifle Mk II',
    WEAPON_COMPACTRIFLE = 'Compact Rifle',
    WEAPON_MILITARYRIFLE = 'Military Rifle',
    WEAPON_HEAVYRIFLE = 'Heavy Rifle',
    WEAPON_TACTICALRIFLE = 'Tactical Rifle',
    WEAPON_SERVICECARBINE = 'Service Carbine',
    WEAPON_MARKSMANRIFLE = 'Marksman Rifle',
    WEAPON_MARKSMANRIFLE_MK2 = 'Marksman Rifle Mk II',
    WEAPON_SNIPERRIFLE = 'Sniper Rifle',
    WEAPON_HEAVYSNIPER = 'Heavy Sniper',
    WEAPON_HEAVYSNIPER_MK2 = 'Heavy Sniper Mk II',
    WEAPON_GRENADELAUNCHER = 'Grenade Launcher',
    WEAPON_RPG = 'RPG',
    WEAPON_MINIGUN = 'Minigun',
    WEAPON_COMPACTLAUNCHER = 'Compact Launcher',
    WEAPON_RAYPISTOL = 'Up-n-Atomizer',
    WEAPON_RAYCARBINE = 'Unholy Hellbringer',
    WEAPON_RAYMINIGUN = 'Widowmaker',
    WEAPON_GRENADE = 'Grenade',
    WEAPON_STICKYBOMB = 'Sticky Bomb',
    WEAPON_SMOKEGRENADE = 'Smoke Grenade',
    WEAPON_BZGAS = 'BZ Gas',
    WEAPON_MOLOTOV = 'Molotov',
    WEAPON_PROXMINE = 'Proximity Mine',
    WEAPON_PIPEBOMB = 'Pipe Bomb',
    WEAPON_SNOWBALL = 'Snowball',
    WEAPON_BALL = 'Ball',
    WEAPON_FIREEXTINGUISHER = 'Fire Extinguisher',
    WEAPON_PETROLCAN = 'Jerry Can',
    WEAPON_HAZARDCAN = 'Hazardous Jerry Can',
    WEAPON_FERTILIZERCAN = 'Fertilizer Can',
    WEAPON_FLARE = 'Flare',
    WEAPON_STUNGUN = 'Stun Gun',
    WEAPON_STUNGUN_MP = 'Stun Gun (MP)',
    WEAPON_FIREWORK = 'Firework Launcher',
    WEAPON_RAILGUN = 'Railgun',
    WEAPON_HOMINGLAUNCHER = 'Homing Launcher'
}
