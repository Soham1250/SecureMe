import { ReactNode } from 'react'
import { useScrollAnimation } from '../hooks/useScrollAnimation'

interface AnimatedTextProps {
    children: ReactNode
    className?: string
    delay?: number
    highlight?: boolean
}

export const AnimatedText = ({
    children,
    className = '',
    delay = 0,
    highlight = false
}: AnimatedTextProps) => {
    const { ref, isVisible } = useScrollAnimation(0.1)

    return (
        <div
            ref={ref}
            className={`
        transition-all duration-1000 ease-out
        ${isVisible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'}
        ${highlight ? 'animate-pulse' : ''}
        ${className}
      `}
            style={{ transitionDelay: `${delay}ms` }}
        >
            {children}
        </div>
    )
}

export const GradientText = ({ children, className = '' }: { children: ReactNode, className?: string }) => {
    return (
        <span className={`bg-gradient-to-r from-primary-600 via-purple-600 to-primary-800 bg-clip-text text-transparent animate-gradient-x ${className}`}>
            {children}
        </span>
    )
}