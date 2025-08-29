'use client'

import { useState } from 'react'
import { 
  Shield, 
  Lock, 
  Key, 
  Search, 
  Download, 
  Smartphone, 
  Eye, 
  EyeOff,
  CheckCircle,
  AlertTriangle,
  Users,
  Globe,
  Fingerprint,
  Database,
  Zap,
  ChevronDown,
  ChevronUp
} from 'lucide-react'
import { AnimatedSection } from '@/components/AnimatedSection'
import { AnimatedText, GradientText } from '@/components/AnimatedText'

export default function Home() {
  const [expandedFaq, setExpandedFaq] = useState<number | null>(null)

  const toggleFaq = (index: number) => {
    setExpandedFaq(expandedFaq === index ? null : index)
  }

  const features = [
    {
      icon: <Lock className="w-8 h-8 text-primary-600" />,
      title: "Password Manager",
      description: "Securely store and manage all your passwords with biometric authentication and PBKDF2-HMAC-SHA256 encryption."
    },
    {
      icon: <Key className="w-8 h-8 text-primary-600" />,
      title: "Password Generator",
      description: "Generate strong, unique passwords with customizable length and complexity requirements."
    },
    {
      icon: <Search className="w-8 h-8 text-primary-600" />,
      title: "Link Analysis",
      description: "Analyze URLs and links for potential threats including phishing, malware, and suspicious content."
    },
    {
      icon: <Fingerprint className="w-8 h-8 text-primary-600" />,
      title: "Biometric Security",
      description: "Use fingerprint, face ID, or device passcode for secure authentication and access control."
    },
    {
      icon: <Database className="w-8 h-8 text-primary-600" />,
      title: "Local Storage",
      description: "All sensitive data is stored locally on your device using Android Keystore and iOS Keychain."
    },
    {
      icon: <Zap className="w-8 h-8 text-primary-600" />,
      title: "Real-time Protection",
      description: "Instant threat detection and analysis to keep you protected from emerging cyber threats."
    }
  ]

  const securityFeatures = [
    {
      title: "PBKDF2-HMAC-SHA256 Encryption",
      description: "Industry-standard key derivation with 150,000 iterations and random salt generation"
    },
    {
      title: "Local Data Storage",
      description: "No cloud transmission - all passwords and sensitive data stay on your device"
    },
    {
      title: "Biometric Authentication",
      description: "Fingerprint, Face ID, and device passcode support for secure access"
    },
    {
      title: "Session Management",
      description: "Automatic timeout and manual lock functionality for enhanced security"
    }
  ]

  const faqs = [
    {
      question: "How secure is my data in SecureMe?",
      answer: "SecureMe uses military-grade PBKDF2-HMAC-SHA256 encryption with 150,000 iterations. All data is stored locally on your device using Android Keystore or iOS Keychain, ensuring no sensitive information is transmitted to external servers."
    },
    {
      question: "What types of threats can the Link Analysis feature detect?",
      answer: "Our Link Analysis feature can detect phishing websites, malware distribution sites, suspicious redirects, known malicious domains, and potentially harmful content. It analyzes URL patterns, domain reputation, and content characteristics to provide comprehensive protection."
    },
    {
      question: "Can I access my passwords without biometric authentication?",
      answer: "Yes, SecureMe provides a master password fallback option. If biometric authentication fails or is unavailable, you can use your master password to access your stored credentials securely."
    },
    {
      question: "How does the password generator ensure strong passwords?",
      answer: "Our password generator uses cryptographically secure random number generation with customizable parameters including length, uppercase/lowercase letters, numbers, and special characters. It also provides real-time strength indicators to help you create optimal passwords."
    },
    {
      question: "Is my data synchronized across devices?",
      answer: "No, SecureMe prioritizes security by storing all data locally on each device. This ensures maximum privacy and eliminates the risk of data breaches from cloud storage. You'll need to set up the app individually on each device."
    },
    {
      question: "What happens if I forget my master password?",
      answer: "Due to our zero-knowledge security model, we cannot recover your master password. However, if you have biometric authentication enabled, you can continue accessing the app and change your master password from within the security settings."
    },
    {
      question: "How often should I update my passwords?",
      answer: "We recommend updating passwords every 3-6 months for critical accounts, or immediately if you suspect a security breach. SecureMe's password generator makes it easy to create and store new strong passwords whenever needed."
    },
    {
      question: "Does SecureMe work offline?",
      answer: "Yes, the password manager and password generator work completely offline. The Link Analysis feature requires an internet connection to check URLs against threat databases and perform real-time analysis."
    }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-gray-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-2">
              <Shield className="w-6 h-6 sm:w-8 sm:h-8 text-primary-600" />
              <span className="text-lg sm:text-xl font-bold"><GradientText>SecureMe</GradientText></span>
            </div>
            <div className="hidden sm:flex space-x-4 md:space-x-8">
              <a href="#features" className="text-sm md:text-base text-gray-700 hover:text-primary-600 transition-colors">Features</a>
              <a href="#security" className="text-sm md:text-base text-gray-700 hover:text-primary-600 transition-colors">Security</a>
              <a href="#download" className="text-sm md:text-base text-gray-700 hover:text-primary-600 transition-colors">Download</a>
              <a href="#faq" className="text-sm md:text-base text-gray-700 hover:text-primary-600 transition-colors">FAQ</a>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="text-center">
            <div className="flex justify-center mb-8">
              <div className="relative">
                <div className="w-32 h-32 bg-gradient-to-br from-primary-500 to-primary-700 rounded-3xl flex items-center justify-center shadow-2xl">
                  <Shield className="w-16 h-16 text-white" />
                </div>
                <div className="absolute -top-2 -right-2 w-8 h-8 bg-secondary-500 rounded-full flex items-center justify-center">
                  <CheckCircle className="w-5 h-5 text-white" />
                </div>
              </div>
            </div>
            
            <h1 className="text-4xl md:text-6xl font-bold text-gray-900 mb-6">
              Advanced <GradientText>Cybersecurity</GradientText>
              <br />Protection
            </h1>
            
            <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
              Protect yourself from cyber threats with SecureMe&apos;s comprehensive security suite featuring 
              password management, link analysis, and advanced threat detection.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <a 
                href="#download" 
                className="bg-primary-600 text-white px-8 py-4 rounded-lg font-semibold hover:bg-primary-700 transition-colors flex items-center space-x-2"
              >
                <Download className="w-5 h-5" />
                <span>Download APK</span>
              </a>
              <a 
                href="#features" 
                className="border border-primary-600 text-primary-600 px-8 py-4 rounded-lg font-semibold hover:bg-primary-50 transition-colors"
              >
                Learn More
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-12 sm:py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection direction="up" className="text-center mb-16">
            <AnimatedText>
              <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-4">
                Comprehensive Security Features
              </h2>
            </AnimatedText>
            <AnimatedText delay={200}>
              <p className="text-lg sm:text-xl text-gray-600 max-w-3xl mx-auto">
                SecureMe provides a complete cybersecurity solution with advanced features 
                designed to protect your digital life.
              </p>
            </AnimatedText>
          </AnimatedSection>
          
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8">
            {features.map((feature, index) => (
              <AnimatedSection key={index} direction="up" delay={index * 100}>
                <div className="feature-card bg-gray-50 p-6 sm:p-8 rounded-xl border border-gray-200 hover:shadow-xl hover:scale-105 transition-all duration-300 h-full">
                  <div className="mb-4 transform hover:scale-110 transition-transform duration-300">{feature.icon}</div>
                  <h3 className="text-lg sm:text-xl font-semibold text-gray-900 mb-3">{feature.title}</h3>
                  <p className="text-gray-600 text-sm sm:text-base leading-relaxed">{feature.description}</p>
                </div>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* Security Section */}
      <section id="security" className="py-12 sm:py-20 security-gradient">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection direction="up" className="text-center mb-16">
            <AnimatedText>
              <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold text-white mb-4">
                Military-Grade Security
              </h2>
            </AnimatedText>
            <AnimatedText delay={200}>
              <p className="text-lg sm:text-xl text-blue-100 max-w-3xl mx-auto">
                Built with industry-leading security standards to ensure your data remains 
                protected against all types of cyber threats.
              </p>
            </AnimatedText>
          </AnimatedSection>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 sm:gap-8">
            {securityFeatures.map((feature, index) => (
              <AnimatedSection key={index} direction="left" delay={index * 150}>
                <div className="bg-white/10 backdrop-blur-sm p-6 sm:p-8 rounded-xl border border-white/20 hover:bg-white/20 hover:scale-105 transition-all duration-300 h-full">
                  <h3 className="text-lg sm:text-xl font-semibold text-white mb-3">{feature.title}</h3>
                  <p className="text-blue-100 text-sm sm:text-base leading-relaxed">{feature.description}</p>
                </div>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* Download Section */}
      <section id="download" className="py-12 sm:py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <AnimatedSection direction="up" className="mb-16">
            <AnimatedText>
              <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-4">
                Download SecureMe
              </h2>
            </AnimatedText>
            <AnimatedText delay={200}>
              <p className="text-lg sm:text-xl text-gray-600 max-w-3xl mx-auto mb-8">
                Get started with SecureMe today. Download the APK file and install it on your Android device 
                to begin protecting yourself from cyber threats.
              </p>
            </AnimatedText>
          </AnimatedSection>
          
          <AnimatedSection direction="up" delay={400}>
            <div className="bg-white p-6 sm:p-8 rounded-2xl shadow-lg max-w-md mx-auto hover:shadow-xl transition-shadow duration-300">
              <div className="mb-6">
                <div className="animate-bounce-slow">
                  <Smartphone className="w-12 h-12 sm:w-16 sm:h-16 text-primary-600 mx-auto mb-4" />
                </div>
                <h3 className="text-xl sm:text-2xl font-semibold text-gray-900 mb-2">Android APK</h3>
                <p className="text-gray-600 text-sm sm:text-base">Compatible with Android 6.0 and above</p>
              </div>
              
              <div className="space-y-4">
                <a 
                  href="/secureme.apk" 
                  download="SecureMe.apk"
                  className="w-full bg-primary-600 text-white px-6 sm:px-8 py-3 sm:py-4 rounded-lg font-semibold hover:bg-primary-700 hover:scale-105 transition-all duration-300 flex items-center justify-center space-x-2 animate-glow"
                >
                  <Download className="w-4 h-4 sm:w-5 sm:h-5" />
                  <span className="text-sm sm:text-base">Download SecureMe.apk</span>
                </a>
                
                <div className="text-xs sm:text-sm text-gray-500">
                  <p className="mb-2">File size: ~25 MB</p>
                  <p>Version: 1.0.0</p>
                </div>
              </div>
              
              <div className="mt-6 p-3 sm:p-4 bg-amber-50 border border-amber-200 rounded-lg">
                <div className="flex items-start space-x-2">
                  <AlertTriangle className="w-4 h-4 sm:w-5 sm:h-5 text-amber-600 mt-0.5 flex-shrink-0" />
                  <div className="text-xs sm:text-sm text-amber-800">
                    <p className="font-medium mb-1">Installation Note:</p>
                    <p>You may need to enable &quot;Install from Unknown Sources&quot; in your device settings to install the APK.</p>
                  </div>
                </div>
              </div>
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* FAQ Section */}
      <section id="faq" className="py-20 bg-white">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Frequently Asked Questions
            </h2>
            <p className="text-xl text-gray-600">
              Get answers to common questions about SecureMe&apos;s security features and functionality.
            </p>
          </div>
          
          <div className="space-y-4">
            {faqs.map((faq, index) => (
              <div key={index} className="border border-gray-200 rounded-lg">
                <button
                  onClick={() => toggleFaq(index)}
                  className="w-full px-6 py-4 text-left flex justify-between items-center hover:bg-gray-50 transition-colors"
                >
                  <span className="font-semibold text-gray-900">{faq.question}</span>
                  {expandedFaq === index ? (
                    <ChevronUp className="w-5 h-5 text-gray-500" />
                  ) : (
                    <ChevronDown className="w-5 h-5 text-gray-500" />
                  )}
                </button>
                {expandedFaq === index && (
                  <div className="px-6 pb-4">
                    <p className="text-gray-600 leading-relaxed">{faq.answer}</p>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <div className="flex items-center justify-center space-x-2 mb-4">
              <Shield className="w-8 h-8 text-primary-400" />
              <span className="text-xl font-bold">SecureMe</span>
            </div>
            <p className="text-gray-400 mb-6">
              Advanced cybersecurity protection for the modern digital world.
            </p>
            <div className="flex justify-center space-x-8 text-sm text-gray-400">
              <a href="#" className="hover:text-white transition-colors">Privacy Policy</a>
              <a href="#" className="hover:text-white transition-colors">Terms of Service</a>
              <a href="#" className="hover:text-white transition-colors">Support</a>
            </div>
            <div className="mt-8 pt-8 border-t border-gray-800 text-sm text-gray-500">
              <p>&copy; 2024 SecureMe. All rights reserved.</p>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
