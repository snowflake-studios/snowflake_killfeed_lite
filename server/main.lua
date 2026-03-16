-- =============================================
-- Snowflake Studios - Killfeed Server (Lite)
-- Free Edition | v1.0.3
-- =============================================

local ResourceName = GetCurrentResourceName()
local EventPrefix = ResourceName or 'snowflake_killfeed_lite'
local Debug = (Config and Config.Debug) or false
local PedKillTestEnabled = (Config and Config.EnablePedKillTest) or false

local function debugPrint(message)
    if Debug then
        print(message)
    end
end

-- =============================================
-- Configuration Cache
-- =============================================
local KillDedupWindowMs = (Config and Config.DedupWindowMs) or 250
local LastKillByVictim = {}

local WeaponLabels = (Config and Config.WeaponLabels) or {}
local WeaponFallback = (Config and Config.WeaponFallback) or 'Unknown'
local WeaponHashFallback = (Config and Config.WeaponHashFallback) or WeaponFallback
local NameMode = (Config and Config.NameMode) or 'character'
local SteamApiKey = (Config and Config.SteamApiKey) or ''
local SteamPersonaCache = {}

if NameMode == 'steam' and SteamApiKey == '' then
    print('[snowflake_killfeed_lite] ^3Warning:^0 NameMode is set to steam but SteamApiKey is empty. Falling back to player names.')
end

-- Pre-compute weapon hash lookups for performance
local WeaponHashToLabel = {}
for weaponName, label in pairs(WeaponLabels) do
    WeaponHashToLabel[GetHashKey(weaponName)] = label
end

local function getNowMs()
    if type(GetGameTimer) == 'function' then
        return GetGameTimer()
    end

    return math.floor(os.clock() * 1000)
end

local function normalizeWeaponKey(weaponValue)
    if weaponValue == nil then
        return 0
    end

    if type(weaponValue) == 'number' then
        return weaponValue
    end

    if type(weaponValue) == 'string' then
        if weaponValue == '' then
            return 0
        end
        return GetHashKey(weaponValue)
    end

    return 0
end

local function scheduleDedupCleanup(key, timestamp)
    SetTimeout(KillDedupWindowMs + 100, function()
        if LastKillByVictim[key] == timestamp then
            LastKillByVictim[key] = nil
        end
    end)
end

local function shouldBroadcastForVictim(victimId, killerId, weaponKey)
    if not victimId then
        return false
    end

    local now = getNowMs()
    local key = ('%s:%s:%s'):format(victimId, killerId or 0, weaponKey or 0)
    local lastTime = LastKillByVictim[key]
    if lastTime and (now - lastTime) < KillDedupWindowMs then
        return false
    end

    LastKillByVictim[key] = now
    scheduleDedupCleanup(key, now)
    return true
end

local AllowedExportResources = (Config and Config.AllowedExportResources) or {
    ['snowflake_killfeed_lite'] = true
}

local function sanitizeText(value, fallback)
    if value == nil then
        return fallback
    end

    if type(value) ~= 'string' then
        value = tostring(value)
    end

    value = value:gsub("[\r\n\t]", " "):sub(1, 48)
    if value == '' then
        return fallback
    end

    return value
end

local function resolveWeaponLabel(weaponValue)
    if weaponValue == nil then
        return WeaponFallback
    end

    if type(weaponValue) == 'number' then
        return WeaponHashToLabel[weaponValue] or WeaponHashFallback
    end

    if type(weaponValue) == 'string' then
        if weaponValue == '' then
            return WeaponFallback
        end
        return weaponValue
    end

    return WeaponFallback
end

local function isResourceStarted(resourceName)
    return GetResourceState(resourceName) == 'started'
end

local function combineName(firstName, lastName)
    local fullName = ((firstName or '') .. ' ' .. (lastName or '')):gsub('^%s*(.-)%s*$', '%1')
    if fullName == '' then
        return nil
    end

    return fullName
end

local function getQboxCharacterName(playerId)
    if type(playerId) ~= 'number' then
        return nil
    end

    if not isResourceStarted('qbx_core') then
        return nil
    end

    local success, Player = pcall(function()
        return exports.qbx_core:GetPlayer(playerId)
    end)

    if not success then
        return nil
    end

    if not Player or not Player.PlayerData or not Player.PlayerData.charinfo then
        return nil
    end

    return combineName(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
end

local function getQbCoreCharacterName(playerId)
    if type(playerId) ~= 'number' then
        return nil
    end

    if not isResourceStarted('qb-core') then
        return nil
    end

    local coreSuccess, QBCore = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if not coreSuccess or not QBCore or not QBCore.Functions or not QBCore.Functions.GetPlayer then
        return nil
    end

    local playerSuccess, Player = pcall(function()
        return QBCore.Functions.GetPlayer(playerId)
    end)

    if not playerSuccess or not Player or not Player.PlayerData then
        return nil
    end

    local charInfo = Player.PlayerData.charinfo
    if charInfo then
        local fullName = combineName(charInfo.firstname, charInfo.lastname)
        if fullName then
            return fullName
        end
    end

    if type(Player.PlayerData.name) == 'string' and Player.PlayerData.name ~= '' then
        return Player.PlayerData.name
    end

    return nil
end

local function getEsxCharacterName(playerId)
    if type(playerId) ~= 'number' then
        return nil
    end

    if not isResourceStarted('es_extended') then
        return nil
    end

    local esxSuccess, ESX = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if not esxSuccess or not ESX or type(ESX.GetPlayerFromId) ~= 'function' then
        return nil
    end

    local playerSuccess, xPlayer = pcall(function()
        return ESX.GetPlayerFromId(playerId)
    end)

    if not playerSuccess or not xPlayer then
        return nil
    end

    if type(xPlayer.getName) == 'function' then
        local nameSuccess, fullName = pcall(function()
            return xPlayer.getName()
        end)

        if nameSuccess and type(fullName) == 'string' and fullName ~= '' then
            return fullName
        end
    end

    local variables = xPlayer.variables or {}
    local fullName = combineName(
        variables.firstName or variables.firstname or xPlayer.firstName or xPlayer.firstname,
        variables.lastName or variables.lastname or xPlayer.lastName or xPlayer.lastname
    )

    if fullName then
        return fullName
    end

    if type(xPlayer.name) == 'string' and xPlayer.name ~= '' then
        return xPlayer.name
    end

    return nil
end

local function getCharacterName(playerId)
    return getQboxCharacterName(playerId)
        or getQbCoreCharacterName(playerId)
        or getEsxCharacterName(playerId)
end

local function getSteamHex(playerId)
    if type(playerId) ~= 'number' then
        return nil
    end

    local identifiers = GetPlayerIdentifiers(playerId)
    for i = 1, #identifiers do
        local identifier = identifiers[i]
        if identifier and identifier:sub(1, 6) == 'steam:' then
            return identifier:sub(7)
        end
    end

    return nil
end

local function steamHexToSteamId64(steamHex)
    if not steamHex or steamHex == '' then
        return nil
    end

    local steamInt = tonumber(steamHex, 16)
    if not steamInt then
        return nil
    end

    return tostring(76561197960265728 + steamInt)
end

local function fetchSteamPersona(steamHex)
    if not steamHex or steamHex == '' then
        return
    end

    if SteamApiKey == '' then
        return
    end

    local cacheEntry = SteamPersonaCache[steamHex]
    if cacheEntry and cacheEntry.inflight then
        return
    end

    SteamPersonaCache[steamHex] = cacheEntry or {}
    SteamPersonaCache[steamHex].inflight = true

    local steamId64 = steamHexToSteamId64(steamHex)
    if not steamId64 then
        SteamPersonaCache[steamHex].inflight = false
        return
    end

    local url = ('https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s'):format(SteamApiKey, steamId64)
    PerformHttpRequest(url, function(status, body)
        local entry = SteamPersonaCache[steamHex] or {}
        entry.inflight = false

        if status ~= 200 or not body then
            SteamPersonaCache[steamHex] = entry
            return
        end

        local success, decoded = pcall(json.decode, body)
        local personaName = nil
        if success and decoded and decoded.response and decoded.response.players and decoded.response.players[1] then
            personaName = decoded.response.players[1].personaname
        end

        if personaName and personaName ~= '' then
            entry.name = sanitizeText(personaName, 'Unknown')
        end

        SteamPersonaCache[steamHex] = entry
    end, 'GET')
end

local function getSteamPersonaName(playerId)
    local steamHex = getSteamHex(playerId)
    if not steamHex then
        return nil
    end

    local cached = SteamPersonaCache[steamHex]
    if cached and cached.name then
        return cached.name
    end

    fetchSteamPersona(steamHex)
    return GetPlayerName(playerId)
end

local function getDisplayName(playerId)
    if NameMode == 'steam' then
        return getSteamPersonaName(playerId)
    end

    return getCharacterName(playerId) or GetPlayerName(playerId)
end

local function broadcastKill(killerName, victimName, weaponLabel)
    TriggerClientEvent(('%s:addKill'):format(EventPrefix), -1, killerName, victimName, weaponLabel)
end

-- Broadcast kill to all players (server-only)
RegisterNetEvent(('%s:broadcastKill'):format(EventPrefix), function(killer, victim, weaponLabel)
    if source ~= 0 then return end

    local killerName = (type(killer) == 'number') and getDisplayName(killer) or sanitizeText(killer, 'Unknown')
    local victimName = (type(victim) == 'number') and getDisplayName(victim) or sanitizeText(victim, 'Unknown')
    local weapon = resolveWeaponLabel(weaponLabel)

    broadcastKill(killerName or 'Unknown', victimName or 'Unknown', weapon)
end)

-- Export for other server resources
exports('AddKill', function(killer, victim, weaponLabel)
    local invokingResource = GetInvokingResource()
    if invokingResource and not AllowedExportResources[invokingResource] then
        print(('[snowflake_killfeed_lite] Unauthorized Export Attempt from %s'):format(invokingResource))
        return
    end

    local killerName = (type(killer) == 'number') and getDisplayName(killer) or sanitizeText(killer, 'Unknown')
    local victimName = (type(victim) == 'number') and getDisplayName(victim) or sanitizeText(victim, 'Unknown')
    local weapon = resolveWeaponLabel(weaponLabel)

    broadcastKill(killerName or 'Unknown', victimName or 'Unknown', weapon)
end)

-- Baseevents: native kill handling
AddEventHandler('baseevents:onPlayerKilled', function(killerId, data)
    local victimId = source
    if not victimId or victimId == 0 then return end
    local weaponKey = normalizeWeaponKey(data and (data.weapon or data.weaponhash))
    if not shouldBroadcastForVictim(victimId, killerId, weaponKey) then return end

    local killerName = getDisplayName(killerId) or 'Unknown'
    local victimName = getDisplayName(victimId) or 'Unknown'
    local weapon = resolveWeaponLabel(data and (data.weapon or data.weaponhash))

    broadcastKill(killerName, victimName, weapon)
end)

AddEventHandler('baseevents:onPlayerDied', function()
    local victimId = source
    if not victimId or victimId == 0 then return end
    if not shouldBroadcastForVictim(victimId, 0, 0) then return end

    local victimName = getDisplayName(victimId) or 'Unknown'
    broadcastKill('Unknown', victimName, 'Unknown')
end)

-- =============================================
-- Ped Kill Test (Temporary)
-- =============================================
RegisterNetEvent(('%s:pedKillTest'):format(EventPrefix), function(weaponHash)
    if not PedKillTestEnabled then
        return
    end

    local src = source
    if not src or src == 0 then
        return
    end

    if not shouldBroadcastForVictim(('ped:%s'):format(src), src, normalizeWeaponKey(weaponHash)) then
        return
    end

    local killerName = getDisplayName(src) or 'Unknown'
    local weapon = resolveWeaponLabel(weaponHash)
    broadcastKill(killerName, 'Ped', weapon)
end)

-- =============================================
-- Admin Commands (ACE Restricted)
-- Add to permissions.cfg:
--   add_ace group.admin command.killfeedtest allow
-- =============================================

RegisterCommand('killfeedtest', function(source, args)
    if not source or source == 0 then return end

    local count = tonumber(args[1]) or 3
    count = math.min(math.max(count, 1), 7)

    TriggerClientEvent(('%s:runTest'):format(EventPrefix), source, count)
end, true)

-- =============================================
-- Startup Message
-- =============================================
CreateThread(function()
    print('^2[Snowflake Studios]^0 Killfeed Lite v1.0.3 loaded successfully')
    print('^3[Snowflake Studios]^0 🔥 Upgrade to Premium for 104+ Weapon Icons, Headshots, Player Avatars, & Discord Webhooks: ^5https://snowflake-studios.tebex.io^0')
    debugPrint('^3[Snowflake Studios]^0 Commands: /killfeedtest')
end)
