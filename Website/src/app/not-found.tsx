import Link from 'next/link'
import { Metadata } from 'next'

export const metadata: Metadata = {
    title: '404 - Page Not Found | SecureMe',
    description: 'The page you are looking for could not be found.',
}

export const viewport = {
    width: 'device-width',
    initialScale: 1,
}

export default function NotFound() {
    return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100">
            <div className="max-w-md w-full mx-auto text-center px-6">
                <div className="mb-8">
                    <h1 className="text-9xl font-bold text-blue-600 mb-4">404</h1>
                    <h2 className="text-2xl font-semibold text-gray-800 mb-2">Page Not Found</h2>
                    <p className="text-gray-600 mb-8">
                        The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.
                    </p>
                </div>

                <div className="space-y-4">
                    <Link
                        href="/"
                        className="inline-block w-full bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
                    >
                        Return to Home
                    </Link>

                    <Link
                        href="/#download"
                        className="inline-block w-full border border-blue-600 text-blue-600 px-6 py-3 rounded-lg font-medium hover:bg-blue-50 transition-colors"
                    >
                        Download SecureMe
                    </Link>
                </div>

                <div className="mt-8 pt-8 border-t border-gray-200">
                    <p className="text-sm text-gray-500">
                        Need help? Contact our support team.
                    </p>
                </div>
            </div>
        </div>
    )
}
