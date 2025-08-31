# SecureMe Website

A cybersecurity-themed static website for the SecureMe application with advanced animations and secure APK download configuration.

## 🔒 Secure APK Configuration

The website now uses a secure configuration system to manage APK download paths without exposing sensitive information in version control.

### Configuration Files

- **`config.js`** - Main configuration handler with environment detection
- **`.env`** - Local environment variables (not committed to git)
- **`.gitignore`** - Prevents sensitive files from being committed

### Setting Up APK Download

#### For Development:
1. Copy your APK file to the Website directory:
   ```bash
   cp ../Frontend/secureme/build/app/outputs/flutter-apk/app-release.apk ./secureme.apk
   ```

2. Or set a custom path in browser console:
   ```javascript
   setAPKPath("path/to/your/secureme.apk")
   ```

#### For Production:
1. Set the APK path via meta tag in HTML:
   ```html
   <meta name="apk-path" content="https://your-cdn.com/releases/secureme.apk">
   ```

2. Or configure your hosting environment to set the path dynamically.

### Environment Detection

The configuration automatically detects:
- **Development**: localhost, 127.0.0.1, or file:// protocol
- **Production**: All other domains

### Security Features

✅ **APK paths not exposed in GitHub**  
✅ **Environment-specific configurations**  
✅ **Dynamic path loading**  
✅ **Fallback mechanisms**  
✅ **Development helper functions**  

### Available Helper Functions

```javascript
// Get current APK download path
getAPKDownloadPath()

// Get APK filename
getAPKFilename()

// Set custom APK path (development only)
setAPKPath("custom/path/secureme.apk")

// Get app version info
getAppVersion()
getAppSize()
getAppCompatibility()
```

## 🚀 Features

- **Matrix Background Animation** - Falling characters effect
- **Particle System** - Interactive floating particles
- **Cursor Follower** - Dynamic mouse tracking
- **Smooth Scrolling** - Navigation with offset
- **Mobile Responsive** - Optimized for all devices
- **FAQ Accordion** - Expandable Q&A sections
- **Hover Effects** - Enhanced interactions
- **Scan Line Effects** - Security-themed animations

## 📁 File Structure

```
Website/
├── index.html          # Main HTML file
├── styles.css          # CSS with animations
├── script.js           # JavaScript functionality
├── config.js           # Configuration system
├── .env               # Environment variables (not in git)
├── .gitignore         # Git ignore rules
├── favicon.svg        # Website icon
└── secureme.apk       # APK file (not in git)
```

## 🛠️ Development

1. **Clone the repository**
2. **Copy your APK file** to the Website directory
3. **Open `index.html`** in a browser
4. **Use browser console** to set custom paths if needed

## 🔧 Deployment

1. **Upload files** to your hosting provider
2. **Set APK path** via meta tag or environment variable
3. **Ensure APK file** is accessible at the configured path
4. **Test download functionality**

## 📱 Browser Support

- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

## 🔐 Security Notes

- APK files are excluded from version control
- Environment variables are not committed
- Paths can be configured per environment
- Fallback mechanisms prevent broken downloads
