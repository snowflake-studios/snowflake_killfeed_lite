-- =============================================
-- Snowflake Studios - Killfeed Client (Lite)
-- Free Edition | v1.0.0
-- =============================================

local ResourceName = GetCurrentResourceName()
local EventPrefix = ResourceName or 'snowflake_killfeed_lite'
local PedKillTestEnabled = (Config and Config.EnablePedKillTest) or false
local LastPedKill = { entity = nil, time = 0 }
local PedKillDelayMs = 200

-- =============================================
-- Initialize NUI with Config Values
-- =============================================
local function initializeNUI()
    local colors = Config.Colors or {
        killer = '#00F0FC',
        victim = '#FF1493',
        weapon = '#FFFFFF',
        background = '#0F0F14'
    }

    local layout = Config.Layout or {}
    local primaryGlow = layout.primaryGlow or colors.killer or '#00F0FC'

    SendNUIMessage({
        action = 'init',
        colors = colors,
        layout = {
            primaryGlow = primaryGlow,
            posX = layout.posX or 0.8,
            posY = layout.posY or 50,
            borderRadius = layout.borderRadius or 0
        },
        settings = {
            duration = Config.MessageDuration or 5000,
            fadeDuration = Config.FadeDuration or 500,
            maxMessages = Config.MaxMessages or 7
        }
    })
end

CreateThread(function()
    Wait(1000)
    initializeNUI()
end)

-- =============================================
-- Add Killfeed Message
-- =============================================
RegisterNetEvent(('%s:addKill'):format(EventPrefix), function(killerName, victimName, weaponLabel)
    SendNUIMessage({
        action = 'addKill',
        data = {
            killer = killerName,
            victim = victimName,
            weapon = weaponLabel or 'Unknown'
        }
    })
end)

-- =============================================
-- Test Command (Admin Only)
-- =============================================
RegisterNetEvent(('%s:runTest'):format(EventPrefix), function(numMessages)
    local count = tonumber(numMessages) or 3
    count = math.min(math.max(count, 1), 7)

    local testMessages = {
        {killer = "Vesper Hale", victim = "Orion Knox", weapon = "Carbine Rifle"},
        {killer = "Nyx Calder", victim = "Juno Vale", weapon = "Combat Pistol"},
        {killer = "Rook Mercer", victim = "Mara Voss", weapon = "Heavy Sniper"},
        {killer = "Atlas Kade", victim = "Iris Quill", weapon = "Knife"},
        {killer = "Nova Pierce", victim = "Cai Rune", weapon = "SMG"},
        {killer = "Silas Crowe", victim = "Elara Finch", weapon = "Assault Rifle"},
        {killer = "Lyra Wren", victim = "Dax Rowan", weapon = "Shotgun"}
    }

    for i = 1, count do
        SetTimeout((i - 1) * 800, function()
            TriggerEvent(('%s:addKill'):format(EventPrefix), testMessages[i].killer, testMessages[i].victim, testMessages[i].weapon)
        end)
    end
end)

-- =============================================
-- Ped Kill Test (Temporary)
-- =============================================
AddEventHandler('gameEventTriggered', function(eventName, args)
    if not PedKillTestEnabled then
        return
    end

    if eventName ~= 'CEventNetworkEntityDamage' then
        return
    end

    local victim = args[1]
    local attacker = args[2]
    if not victim or not attacker then
        return
    end

    if not IsEntityAPed(victim) or IsPedAPlayer(victim) then
        return
    end

    local playerPed = PlayerPedId()
    local isPlayerAttacker = (attacker == playerPed)
    if not isPlayerAttacker and IsEntityAVehicle(attacker) then
        local driver = GetPedInVehicleSeat(attacker, -1)
        isPlayerAttacker = (driver == playerPed)
    end

    if not isPlayerAttacker then
        return
    end

    local function reportPedKill()
        if not DoesEntityExist(victim) then
            return
        end

        if not IsPedDeadOrDying(victim, true) then
            return
        end

        local now = GetGameTimer()
        if LastPedKill.entity == victim and (now - LastPedKill.time) < 1500 then
            return
        end

        LastPedKill.entity = victim
        LastPedKill.time = now

        local weaponHash = GetPedCauseOfDeath(victim)
        TriggerServerEvent(('%s:pedKillTest'):format(EventPrefix), weaponHash)
    end

    if IsPedDeadOrDying(victim, true) then
        reportPedKill()
    else
        SetTimeout(PedKillDelayMs, reportPedKill)
    end
end)

-- =============================================
-- Chat Suggestions
-- =============================================
CreateThread(function()
    Wait(1000)
    TriggerEvent('chat:addSuggestion', '/killfeedtest', 'Snowflake Studios: Test the killfeed UI (Admin Only)', {
        {name = 'count', help = 'Number of test messages (1-7)'}
    })
    TriggerEvent('chat:addSuggestion', '/testkill', 'Snowflake Studios: Showcase 5 random kills (Admin Only)', {})
end)
