import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter'
})

export const metadata: Metadata = {
  title: 'SecureMe - Advanced Cybersecurity Protection',
  description: 'Protect yourself from cyber threats with SecureMe - featuring password management, link analysis, and advanced security tools.',
  keywords: 'cybersecurity, password manager, link analysis, phishing protection, security  App',
  authors: [{ name: 'SecureMe Team' }],
  openGraph: {
    title: 'SecureMe - Advanced Cybersecurity Protection',
    description: 'Protect yourself from cyber threats with SecureMe - featuring password management, link analysis, and advanced security tools.',
    type: 'website',
    locale: 'en_US',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'SecureMe - Advanced Cybersecurity Protection',
    description: 'Protect yourself from cyber threats with SecureMe - featuring password management, link analysis, and advanced security tools.',
  },
  robots: 'index, follow',
}

export const viewport = {
  width: 'device-width',
  initialScale: 1,
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="/favicon.svg" type="image/svg+xml" />
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
      </head>
      <body className={`${inter.className} ${inter.variable} antialiased`}>{children}</body>
    </html>
  )
}
