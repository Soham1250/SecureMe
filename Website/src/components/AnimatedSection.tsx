import { ReactNode } from 'react'
import { useScrollAnimation } from '../hooks/useScrollAnimation'

interface AnimatedSectionProps {
  children: ReactNode
  className?: string
  delay?: number
  direction?: 'up' | 'down' | 'left' | 'right' | 'fade'
}

export const AnimatedSection = ({ 
  children, 
  className = '', 
  delay = 0,
  direction = 'up'
}: AnimatedSectionProps) => {
  const { ref, isVisible } = useScrollAnimation(0.1)

  const getAnimationClass = () => {
    const baseClass = 'transition-all duration-700 ease-out'
    
    if (!isVisible) {
      switch (direction) {
        case 'up':
          return `${baseClass} translate-y-8 opacity-0`
        case 'down':
          return `${baseClass} -translate-y-8 opacity-0`
        case 'left':
          return `${baseClass} translate-x-8 opacity-0`
        case 'right':
          return `${baseClass} -translate-x-8 opacity-0`
        case 'fade':
          return `${baseClass} opacity-0`
        default:
          return `${baseClass} translate-y-8 opacity-0`
      }
    }
    
    return `${baseClass} translate-y-0 translate-x-0 opacity-100`
  }

  return (
    <div
      ref={ref}
      className={`${getAnimationClass()} ${className}`}
      style={{ transitionDelay: `${delay}ms` }}
    >
      {children}
    </div>
  )
}
