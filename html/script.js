// =============================================
// Snowflake Studios - Killfeed NUI Script (Lite)
// Free Edition | v1.0.1
// 0.00ms resmon | Vanilla JS | Event-Driven
// =============================================

'use strict';

// =============================================
// Configuration (Loaded from Lua)
// =============================================
let CONFIG = {
    maxMessages: 7,
    messageDuration: 5000,
    fadeDuration: 500
};

// =============================================
// Color Utilities
// =============================================

/**
 * Converts a hex color to RGBA with specified alpha
 * @param {string} hex - Hex color code (#RRGGBB or #RGB)
 * @param {number} alpha - Alpha value (0-1)
 * @returns {string} RGBA color string
 */
function hexToRgba(hex, alpha) {
    if (!hex || typeof hex !== 'string') return 'rgba(0, 240, 252, ' + alpha + ')';

    // Remove # if present
    hex = hex.replace(/^#/, '');

    // Handle 3-character hex
    if (hex.length === 3) {
        hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }

    // Parse RGB values
    var r = parseInt(hex.substring(0, 2), 16);
    var g = parseInt(hex.substring(2, 4), 16);
    var b = parseInt(hex.substring(4, 6), 16);

    // Validate parsed values
    if (isNaN(r) || isNaN(g) || isNaN(b)) {
        return 'rgba(0, 240, 252, ' + alpha + ')';
    }

    return 'rgba(' + r + ', ' + g + ', ' + b + ', ' + alpha + ')';
}

/**
 * Applies initial layout + colors from config
 * @param {Object} payload - init payload containing colors/layout
 */
function applyInitStyles(payload) {
    if (!payload) return;

    var root = document.documentElement;
    var colors = payload.colors || {};
    var layout = payload.layout || {};

    if (layout.primaryGlow) {
        root.style.setProperty('--main-glow-color', layout.primaryGlow);
        root.style.setProperty('--main-glow-glow', hexToRgba(layout.primaryGlow, 0.5));
    }

    if (typeof layout.posY === 'number') {
        root.style.setProperty('--kf-top', layout.posY + 'vh');
    }

    if (typeof layout.posX === 'number') {
        root.style.setProperty('--kf-right', layout.posX + 'vw');
    }

    if (typeof layout.borderRadius === 'number') {
        root.style.setProperty('--kf-radius', layout.borderRadius + 'px');
    }

    if (colors.killer) {
        root.style.setProperty('--killer-color', colors.killer);
        root.style.setProperty('--killer-glow', hexToRgba(colors.killer, 0.5));
    }

    if (colors.victim) {
        root.style.setProperty('--victim-color', colors.victim);
        root.style.setProperty('--victim-glow', hexToRgba(colors.victim, 0.5));
    }

    if (colors.weapon) {
        root.style.setProperty('--weapon-color', colors.weapon);
    }

    if (colors.background) {
        root.style.setProperty('--background-color', colors.background);
        root.style.setProperty('--background-rgba', hexToRgba(colors.background, 0.75));
    }
}

// =============================================
// HTML Sanitization (Security)
// =============================================

/**
 * Escapes HTML entities to prevent XSS
 * @param {string} text - Raw text to escape
 * @returns {string} Escaped HTML-safe string
 */
function escapeHtml(text) {
    if (text === null || text === undefined) return '';

    var str = String(text);
    var map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };

    return str.replace(/[&<>"']/g, function(m) {
        return map[m];
    });
}

// =============================================
// Killfeed Entry Creation
// =============================================

/**
 * Creates and displays a new killfeed entry
 * @param {Object} data - Kill data { killer, victim, weapon }
 */
function addKillMessage(data) {
    var container = document.getElementById('killfeed-container');
    if (!container) return;

    // Enforce max message limit - remove oldest if at capacity
    var existingMessages = container.querySelectorAll('.killfeed-entry');
    if (existingMessages.length >= CONFIG.maxMessages) {
        var oldest = existingMessages[existingMessages.length - 1];
        oldest.classList.add('fade-out');

        (function(el) {
            window.setTimeout(function() {
                if (el.parentNode) el.parentNode.removeChild(el);
            }, CONFIG.fadeDuration);
        })(oldest);
    }

    // Sanitize input data
    var killerName = escapeHtml(data && data.killer ? data.killer : 'Unknown');
    var victimName = escapeHtml(data && data.victim ? data.victim : 'Unknown');
    var weaponLabel = escapeHtml(data && data.weapon ? data.weapon : 'Unknown');

    // Create entry element
    var entry = document.createElement('div');
    entry.className = 'killfeed-entry animate-in';

    // Build HTML structure
    entry.innerHTML =
        '<span class="killfeed-killer">' + killerName + '</span>' +
        '<span class="killfeed-icon">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">' +
                '<path d="M19.844 20.625v129.5l73.375 66.25c36.57 38.36 55.757 94.852 27.624 145.625l.72-.844-4.626 7.97 8.093 4.687 122.407 70.656 8.094 4.655 3.97-6.875c27.733-26.382 63.19-7.125 102.28 16.53l41.126 37.126h92.22V408.78l-44.063-43.967c-22.454-28.274-35.613-54.52-32.032-84.5 17.85-59.055-4.958-140.538-25.78-160.47-7.902-7.752-16.606-14.816-27.03-20.406-21.165-12.22-46.998-15.218-70.376-14.468-16.582.53-33.126 4.057-48.844 10.093-36.71 8.396-67.358-7.433-101.406-35.282l-39.22-39.155h-86.53zm280 83.313c2.78-.026 5.55.05 8.312.218-.036.097-.09.183-.125.28-6.752 18.694 38.538 37.97 49.126 14.97 55.007 34.127 69.07 117.013 36.063 174.188a55.735 55.735 0 0 1-2.22 3.53l-6.313 6.845c7.46 4.334 12.742 11.783 12.157 21.31-.003.043.002.084 0 .126 5.824.896 11.176 5.245 10.78 11.656-.795 12.97-13.8 14.244-20.655 8.875-15.525 11.663-43.697 1.44-43.595-19.343-1.955.698-3.88 1.38-5.875 2.094l-27.125-27.594-13.344 13.094 21.564 21.937c-10.82 4.87-21.477 11.133-30.875 20.53l-.876.876-.625 1.064-6.658 11.5-14.812-8.563 10.313-17.874-16.188-9.344-10.313 17.875-13.656-7.875 10.313-17.875-16.19-9.343-10.31 17.875-13.94-8.064 10.314-17.875-16.188-9.342-10.312 17.875-15.25-8.782 6.656-11.5c5.53-12.61 4.07-28.693 2.938-39.31l30.25 7.81 4.687-18.092-38.03-9.813c-.616-3.4-1.223-6.765-1.782-10.063-2.202-12.97-3.66-24.87-2-36.156l5.218-16.687c.482-.96.98-1.922 1.532-2.876 9.726-16.845 23.427-31.258 39.375-42.438 1.944 19.517 29.105 28.628 44.188 17.063 7.884 12.587 33.59 13.47 34.97-8.97.8-13.03-14.17-20.428-25.376-16.875-.847-5.087-3.442-9.416-7.064-12.78 8.94-2.295 18.048-3.697 27.125-4.064 1.272-.05 2.545-.08 3.814-.093zm6.22 57.343c-6.418-.064-12.71 3.813-13.283 13.157-.918 14.96 26.277 19.934 27.5 0 .49-7.946-6.946-13.082-14.217-13.156zm-81.783 4.782c-9.155.277-18.194 4.64-25.124 14.938-19.17 28.49 33.978 72.874 60.688 38.28 7.888 4.022 19.703 1.605 20.5-11.374.534-8.688-8.413-14.002-16.25-13.03-5.094-15.572-22.663-29.33-39.813-28.814zm115.25 66.094c-9.155.276-18.194 4.607-25.124 14.906-19.576 29.093 36.255 74.772 62.344 36 14.376-21.366-11.905-51.67-37.22-50.906zm-56.5 8.875-49.342 34.69 43.968 25.405 5.375-60.094zM164 324.97l15.25 8.78-11.156 19.313 16.187 9.343 11.157-19.312 13.938 8.062-11.156 19.313 16.186 9.342 11.156-19.312 13.657 7.875-11.157 19.313 16.187 9.343 11.156-19.31 14.813 8.56-21.564 37.314-106.22-61.313L164 324.97zm182.53 37.06c9.127-.25 17.758 10.78 12.19 19.19-3.474 5.245-8.023 6.81-12.22 6.155 2.446 6.643 2.232 14.06-2.156 20.688-21.842 32.983-63.58-2.503-47.188-27.25 10.818-16.336 26.53-15.88 37.625-8.25a10.306 10.306 0 0 1 1.626-4.22c2.904-4.384 6.554-6.213 10.125-6.312zm46.908.72c10.303.104 20.848 7.365 20.156 18.625-1.735 28.246-40.24 21.197-38.938 0 .813-13.24 9.69-18.717 18.78-18.625zm44.875 33.156c6.555.066 13.284 4.68 12.843 11.844-1.102 17.97-25.61 13.486-24.78 0 .516-8.42 6.153-11.902 11.937-11.844zm-59.407 15.875c6.555.067 13.285 4.682 12.844 11.845-1.103 17.97-25.642 13.486-24.813 0 .517-8.42 6.185-11.902 11.97-11.844z" fill="currentColor"/>' +
            '</svg>' +
        '</span>' +
        '<span class="killfeed-weapon">' + weaponLabel + '</span>' +
        '<span class="killfeed-victim">' + victimName + '</span>';

    // Insert at top (newest first)
    container.insertBefore(entry, container.firstChild);

    // Schedule auto-removal
    (function(el) {
        window.setTimeout(function() {
            el.classList.add('fade-out');

            window.setTimeout(function() {
                if (el.parentNode) el.parentNode.removeChild(el);
            }, CONFIG.fadeDuration);
        }, CONFIG.messageDuration);
    })(entry);
}

// =============================================
// NUI Message Handler (Event-Driven)
// =============================================

window.addEventListener('message', function(event) {
    var data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'init':
            // Initialize with colors/layout from config
            var container = document.getElementById('killfeed-container');
            if (container) container.innerHTML = '';

            applyInitStyles({
                colors: data.colors || {},
                layout: data.layout || {}
            });

            if (data.settings) {
                if (data.settings.duration) CONFIG.messageDuration = data.settings.duration;
                if (data.settings.maxMessages) CONFIG.maxMessages = data.settings.maxMessages;
                if (data.settings.fadeDuration) CONFIG.fadeDuration = data.settings.fadeDuration;
            }
            break;

        case 'addKill':
            if (data.data) addKillMessage(data.data);
            break;

        case 'clear':
            var cont = document.getElementById('killfeed-container');
            if (cont) cont.innerHTML = '';
            break;
    }
});

// =============================================
// Security: Disable Context Menu
// =============================================

document.addEventListener('contextmenu', function(e) {
    e.preventDefault();
    return false;
});
