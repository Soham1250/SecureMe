# SecureMe Website

A modern, responsive website for the SecureMe cybersecurity application built with Next.js, TypeScript, and Tailwind CSS.

## Features

- **Hero Section**: Eye-catching introduction with app showcase
- **Features Overview**: Comprehensive display of SecureMe's capabilities
- **Security Highlights**: Military-grade security features explanation
- **APK Download**: Direct download section for Android APK
- **FAQ Section**: Real cybersecurity questions and answers
- **Responsive Design**: Mobile-first approach with modern UI/UX

## Technology Stack

- **Framework**: Next.js 14 with TypeScript
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Animations**: CSS transitions and hover effects

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Installation

1. Navigate to the project directory:
```bash
cd Website
```

2. Install dependencies:
```bash
npm install
```

3. Run the development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

### Build for Production

```bash
npm run build
```

## Project Structure

```
src/
├── app/
│   ├── globals.css      # Global styles and Tailwind imports
│   ├── layout.tsx       # Root layout with metadata
│   └── page.tsx         # Main homepage component
```

## Key Sections

### Hero Section
- App logo and branding
- Call-to-action buttons
- Key value proposition

### Features Section
- Password Manager with biometric auth
- Password Generator
- Link Analysis for threat detection
- Local storage security
- Real-time protection

### Security Section
- PBKDF2-HMAC-SHA256 encryption details
- Local data storage benefits
- Biometric authentication
- Session management

### Download Section
- APK download button
- Installation instructions
- System requirements

### FAQ Section
- 8 comprehensive security-related questions
- Expandable/collapsible interface
- Real-world cybersecurity concerns

## Customization

### Colors
The website uses a blue-based color scheme defined in `tailwind.config.ts`. Primary colors can be modified in the theme configuration.

### Content
All content is in the main `page.tsx` file and can be easily updated:
- Features array for the features section
- Security features array for security highlights
- FAQ array for questions and answers

### APK Download
The download button is currently a placeholder. To make it functional:
1. Upload your APK file to the `public` folder
2. Update the download button href to point to your APK file

## Deployment

The website is configured for static export and can be deployed to:
- Vercel (recommended for Next.js)
- Netlify
- GitHub Pages
- Any static hosting service

## License

This project is part of the SecureMe application suite.
