// ===== SECUREME WEBSITE CONFIGURATION =====
// This file contains environment-specific configurations
// DO NOT commit sensitive paths or URLs to version control

const CONFIG = {
    // Development configuration
    development: {
        APK_PATH: 'C:/Users/soham/Desktop/GRIND/Codes/Firm/SecureMe/SecureMe/Frontend/secureme/build/app/outputs/flutter-apk/app-release.apk', // Local development path
        APK_FILENAME: 'SecureMe.apk',
        VERSION: '1.0.0',
        SIZE: '~15 MB',
        COMPATIBILITY: 'Android 6.0+ (API 23+)'
    },
    
    // Production configuration
    production: {
        APK_PATH: getAPKPath(), // Dynamic path from environment
        APK_FILENAME: 'SecureMe.apk',
        VERSION: '1.0.0',
        SIZE: '~15 MB',
        COMPATIBILITY: 'Android 6.0+ (API 23+)'
    }
};

// Function to get APK path from environment or fallback
function getAPKPath() {
    // Check if running in browser environment
    if (typeof window !== 'undefined') {
        // Try to get from meta tag (set by server/build process)
        const metaAPKPath = document.querySelector('meta[name="apk-path"]');
        if (metaAPKPath) {
            return metaAPKPath.getAttribute('content');
        }
        
        // Try to get from localStorage (for development)
        const localAPKPath = localStorage.getItem('SECUREME_APK_PATH');
        if (localAPKPath) {
            return localAPKPath;
        }
    }
    
    // Fallback to default path
    return 'app-release.apk';
}

// Function to get current environment
function getEnvironment() {
    if (typeof window !== 'undefined') {
        // Check if localhost or file protocol (development)
        if (window.location.hostname === 'localhost' || 
            window.location.hostname === '127.0.0.1' || 
            window.location.protocol === 'file:') {
            return 'development';
        }
    }
    return 'production';
}

// Get current configuration based on environment
function getConfig() {
    const env = getEnvironment();
    return CONFIG[env];
}

// Export configuration
window.SECUREME_CONFIG = getConfig();

// Helper functions for easy access
window.getAPKDownloadPath = function() {
    return window.SECUREME_CONFIG.APK_PATH;
};

window.getAPKFilename = function() {
    return window.SECUREME_CONFIG.APK_FILENAME;
};

window.getAppVersion = function() {
    return window.SECUREME_CONFIG.VERSION;
};

window.getAppSize = function() {
    return window.SECUREME_CONFIG.SIZE;
};

window.getAppCompatibility = function() {
    return window.SECUREME_CONFIG.COMPATIBILITY;
};

// Function to set APK path dynamically (for development)
window.setAPKPath = function(path) {
    if (getEnvironment() === 'development') {
        localStorage.setItem('SECUREME_APK_PATH', path);
        window.SECUREME_CONFIG.APK_PATH = path;
        updateDownloadLinks();
    } else {
        console.warn('APK path can only be set in development environment');
    }
};

// Function to update download links dynamically
function updateDownloadLinks() {
    const downloadLinks = document.querySelectorAll('a[data-apk-download]');
    downloadLinks.forEach(link => {
        link.href = getAPKDownloadPath();
        link.download = getAPKFilename();
    });
}

// Initialize on DOM load
document.addEventListener('DOMContentLoaded', function() {
    updateDownloadLinks();
    
    // Log configuration in development
    if (getEnvironment() === 'development') {
        console.log('SecureMe Config:', window.SECUREME_CONFIG);
        console.log('To set custom APK path: setAPKPath("path/to/your/secureme.apk")');
    }
});

// Export for Node.js environments (if needed)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        CONFIG,
        getConfig,
        getEnvironment
    };
}
