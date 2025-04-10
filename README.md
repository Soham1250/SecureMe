# 🛡️ SecureMe

<div align="center">
  <img src="https://img.shields.io/badge/Platform-Cross--Platform-blue" alt="Platform">
  <img src="https://img.shields.io/badge/Frontend-Flutter-blue" alt="Frontend">
  <img src="https://img.shields.io/badge/Backend-Node.js-green" alt="Backend">
  <img src="https://img.shields.io/badge/Status-In%20Development-yellow" alt="Status">
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="License">
</div>

<p align="center">
  <b>Your personal security companion for safer web browsing</b>
</p>

## 📋 Overview

SecureMe is a comprehensive security application designed to help users identify and avoid potentially harmful websites. The application analyzes URLs using the VirusTotal API to detect phishing attempts, malware, and other security threats, providing users with a security score and detailed analysis.

## ✨ Features

- 🔍 **Link Analysis**: Scan URLs to check for security threats
- 🚦 **Security Rating**: Get a clear security score from 0-100
- 🔄 **Real-time Scanning**: Analyze links using the VirusTotal API
- ⚪ **Whitelist/Blacklist**: Maintain lists of trusted and blocked websites
- 🎮 **Distraction Game**: Play Tic-Tac-Toe while waiting for scan results
- 📱 **Cross-Platform**: Works on Android, iOS, and web platforms

## 🏗️ Architecture

SecureMe follows a client-server architecture:

### Frontend (Flutter)
- Cross-platform mobile and web application
- Material Design UI with responsive layouts
- State management for real-time updates

### Backend (Node.js)
- RESTful API built with Express.js
- MongoDB database for storing URL lists
- Integration with VirusTotal API for security analysis

## 🚀 Getting Started

### Prerequisites
- Node.js (v14+)
- MongoDB
- Flutter SDK (v3.0+)
- VirusTotal API key

### Backend Setup

1. Navigate to the Backend directory:
   ```bash
   cd Backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file with the following variables:
   ```
   PORT=4000
   MONGODB_URI=your_mongodb_connection_string
   VIRUSTOTAL_API_KEY=your_virustotal_api_key
   ```

4. Start the server:
   ```bash
   npm start
   ```

### Frontend Setup

1. Navigate to the Frontend/secureme directory:
   ```bash
   cd Frontend/secureme
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Update the API configuration in `lib/services/api_config.dart` with your backend URL

4. Run the application:
   ```bash
   flutter run
   ```

## 📱 Application Workflow

1. User enters a URL in the Link Analyzer screen
2. The application sends the URL to the backend for analysis
3. The backend checks if the URL is in the whitelist or blacklist
4. If not listed, the backend sends the URL to VirusTotal for analysis
5. Results are processed and a security score is calculated
6. The frontend displays the analysis results with detailed information

## 🔒 Security Features

- **Security Score**: A numerical score (0-100) indicating the safety level of a URL
- **Verdict Classification**: URLs are classified as:
  - ✅ **Safe**: No security issues detected
  - ⚠️ **Mildly Unsafe**: Some security concerns detected
  - ❌ **Unsafe**: Significant security threats detected
- **Detailed Analysis**: Information about specific security threats detected by various security engines

## 🧩 Project Structure

```
SecureMe/
├── Backend/                # Node.js backend
│   ├── src/
│   │   ├── config/         # Configuration files
│   │   ├── models/         # MongoDB models
│   │   ├── routes/         # API routes
│   │   └── index.js        # Entry point
│   ├── package.json        # Dependencies
│   └── render.yaml         # Deployment configuration
│
└── Frontend/               # Flutter frontend
    └── secureme/
        ├── lib/
        │   ├── models/     # Data models
        │   ├── screens/    # UI screens
        │   ├── services/   # API services
        │   ├── widgets/    # Reusable UI components
        │   └── main.dart   # Entry point
        └── pubspec.yaml    # Dependencies
```

## 🛠️ Technologies Used

- **Backend**:
  - Node.js & Express.js
  - MongoDB & Mongoose
  - Axios for HTTP requests
  - VirusTotal API

- **Frontend**:
  - Flutter
  - Dart
  - HTTP package for API calls
  - Material Design components

## 🔮 Future Enhancements

- 🔐 **Password Manager**: Securely store and manage passwords
- 📁 **Secure Storage**: Encrypted storage for sensitive files
- 🔍 **Security Check**: System-wide security assessment
- 🔔 **Real-time Alerts**: Notifications for security threats
- 🌐 **Browser Extension**: Direct integration with web browsers

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributors

- Soham Pansare - Project Lead & Developer

---

<p align="center">
  <i>Made with ❤️ for a safer internet experience</i>
</p>
