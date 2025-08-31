// ===== GLOBAL VARIABLES =====
let particles = [];
let matrixChars = [];
let mouseX = 0;
let mouseY = 0;

// ===== DOM CONTENT LOADED =====
document.addEventListener('DOMContentLoaded', function() {
    initializeWebsite();
});

// ===== INITIALIZE WEBSITE =====
function initializeWebsite() {
    setupCursorFollower();
    setupMatrixBackground();
    setupParticles();
    setupNavigation();
    setupFAQ();
    setupScrollAnimations();
    setupPremiumScrollAnimations();
    setupHoverEffects();
    setupSmoothScrolling();
}

// ===== CURSOR FOLLOWER =====
function setupCursorFollower() {
    const cursorFollower = document.getElementById('cursorFollower');
    
    if (!cursorFollower) return;
    
    document.addEventListener('mousemove', (e) => {
        mouseX = e.clientX;
        mouseY = e.clientY;
        
        cursorFollower.style.left = mouseX - 10 + 'px';
        cursorFollower.style.top = mouseY - 10 + 'px';
    });
    
    // Hide cursor follower on mobile
    if (window.innerWidth <= 768) {
        cursorFollower.style.display = 'none';
    }
}

// ===== MATRIX BACKGROUND =====
function setupMatrixBackground() {
    const matrixBg = document.getElementById('matrixBg');
    if (!matrixBg) return;
    
    // Create matrix characters
    const chars = '01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン';
    const columns = Math.floor(window.innerWidth / 20);
    
    for (let i = 0; i < columns; i++) {
        matrixChars.push({
            x: i * 20,
            y: Math.random() * window.innerHeight,
            char: chars[Math.floor(Math.random() * chars.length)],
            opacity: Math.random() * 0.5 + 0.1
        });
    }
    
    // Create matrix canvas
    const canvas = document.createElement('canvas');
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    canvas.style.position = 'absolute';
    canvas.style.top = '0';
    canvas.style.left = '0';
    canvas.style.pointerEvents = 'none';
    canvas.style.opacity = '0.1';
    matrixBg.appendChild(canvas);
    
    const ctx = canvas.getContext('2d');
    
    function animateMatrix() {
        ctx.fillStyle = 'rgba(10, 10, 10, 0.05)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        ctx.fillStyle = '#00ffff';
        ctx.font = '14px monospace';
        
        matrixChars.forEach(char => {
            ctx.globalAlpha = char.opacity;
            ctx.fillText(char.char, char.x, char.y);
            
            char.y += 1;
            if (char.y > canvas.height) {
                char.y = -20;
                char.char = chars[Math.floor(Math.random() * chars.length)];
            }
        });
        
        requestAnimationFrame(animateMatrix);
    }
    
    animateMatrix();
    
    // Resize handler
    window.addEventListener('resize', () => {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    });
}

// ===== PARTICLE SYSTEM =====
function setupParticles() {
    const heroParticles = document.getElementById('heroParticles');
    if (!heroParticles) return;
    
    // Create particle canvas
    const canvas = document.createElement('canvas');
    canvas.width = heroParticles.offsetWidth;
    canvas.height = heroParticles.offsetHeight;
    canvas.style.position = 'absolute';
    canvas.style.top = '0';
    canvas.style.left = '0';
    canvas.style.pointerEvents = 'none';
    heroParticles.appendChild(canvas);
    
    const ctx = canvas.getContext('2d');
    
    // Initialize particles
    for (let i = 0; i < 50; i++) {
        particles.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            size: Math.random() * 3 + 1,
            speedX: (Math.random() - 0.5) * 0.5,
            speedY: (Math.random() - 0.5) * 0.5,
            opacity: Math.random() * 0.5 + 0.2
        });
    }
    
    function animateParticles() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        particles.forEach(particle => {
            // Draw particle
            ctx.beginPath();
            ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
            ctx.fillStyle = `rgba(0, 255, 255, ${particle.opacity})`;
            ctx.fill();
            
            // Update position
            particle.x += particle.speedX;
            particle.y += particle.speedY;
            
            // Bounce off edges
            if (particle.x <= 0 || particle.x >= canvas.width) {
                particle.speedX *= -1;
            }
            if (particle.y <= 0 || particle.y >= canvas.height) {
                particle.speedY *= -1;
            }
            
            // Mouse interaction
            const distance = Math.sqrt(
                Math.pow(mouseX - particle.x, 2) + Math.pow(mouseY - particle.y, 2)
            );
            
            if (distance < 100) {
                particle.opacity = Math.min(1, particle.opacity + 0.02);
                particle.size = Math.min(5, particle.size + 0.1);
            } else {
                particle.opacity = Math.max(0.2, particle.opacity - 0.01);
                particle.size = Math.max(1, particle.size - 0.05);
            }
        });
        
        // Draw connections
        particles.forEach((particle, i) => {
            particles.slice(i + 1).forEach(otherParticle => {
                const distance = Math.sqrt(
                    Math.pow(particle.x - otherParticle.x, 2) + 
                    Math.pow(particle.y - otherParticle.y, 2)
                );
                
                if (distance < 100) {
                    ctx.beginPath();
                    ctx.moveTo(particle.x, particle.y);
                    ctx.lineTo(otherParticle.x, otherParticle.y);
                    ctx.strokeStyle = `rgba(0, 255, 255, ${0.1 * (1 - distance / 100)})`;
                    ctx.lineWidth = 1;
                    ctx.stroke();
                }
            });
        });
        
        requestAnimationFrame(animateParticles);
    }
    
    animateParticles();
    
    // Resize handler
    window.addEventListener('resize', () => {
        canvas.width = heroParticles.offsetWidth;
        canvas.height = heroParticles.offsetHeight;
    });
}

// ===== NAVIGATION =====
function setupNavigation() {
    const navToggle = document.getElementById('navToggle');
    const navMenu = document.getElementById('navMenu');
    const navbar = document.getElementById('navbar');
    const navLinks = document.querySelectorAll('.nav-link');
    
    // Mobile menu toggle
    if (navToggle && navMenu) {
        navToggle.addEventListener('click', () => {
            navToggle.classList.toggle('active');
            navMenu.classList.toggle('active');
        });
        
        // Close menu when clicking on links
        navLinks.forEach(link => {
            link.addEventListener('click', () => {
                navToggle.classList.remove('active');
                navMenu.classList.remove('active');
            });
        });
    }
    
    // Navbar scroll effect
    if (navbar) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 100) {
                navbar.style.background = 'rgba(10, 10, 10, 0.98)';
                navbar.style.backdropFilter = 'blur(20px)';
            } else {
                navbar.style.background = 'rgba(10, 10, 10, 0.95)';
                navbar.style.backdropFilter = 'blur(10px)';
            }
        });
    }
    
    // Active link highlighting
    window.addEventListener('scroll', () => {
        const sections = document.querySelectorAll('section[id]');
        const scrollPos = window.scrollY + 100;
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.offsetHeight;
            const sectionId = section.getAttribute('id');
            
            if (scrollPos >= sectionTop && scrollPos < sectionTop + sectionHeight) {
                navLinks.forEach(link => {
                    link.classList.remove('active');
                    if (link.getAttribute('href') === `#${sectionId}`) {
                        link.classList.add('active');
                    }
                });
            }
        });
    });
}

// ===== FAQ FUNCTIONALITY =====
function setupFAQ() {
    const faqItems = document.querySelectorAll('.faq-item');
    
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        
        question.addEventListener('click', () => {
            const isActive = item.classList.contains('active');
            
            // Close all other FAQ items
            faqItems.forEach(otherItem => {
                otherItem.classList.remove('active');
            });
            
            // Toggle current item
            if (!isActive) {
                item.classList.add('active');
            }
        });
    });
}

// ===== PREMIUM SCROLL ANIMATIONS =====
function setupPremiumScrollAnimations() {
    const observerOptions = {
        threshold: 0.15,
        rootMargin: '0px 0px -100px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const delay = entry.target.getAttribute('data-delay') || 0;
                setTimeout(() => {
                    entry.target.classList.add('animate');
                }, delay);
            }
        });
    }, observerOptions);
    
    // Observe all animation elements
    const animatedElements = document.querySelectorAll('.fade-in-up, .fade-in-left, .fade-in-right, .scale-in');
    animatedElements.forEach(el => {
        observer.observe(el);
    });
    
    // Staggered animations for feature cards
    const featureCards = document.querySelectorAll('.feature-card');
    featureCards.forEach((card, index) => {
        card.style.transitionDelay = `${index * 0.15}s`;
    });
}

// ===== LEGACY SCROLL ANIMATIONS =====
function setupScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    // Observe elements with data-aos attributes
    const animatedElements = document.querySelectorAll('[data-aos]');
    animatedElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
}

// ===== PREMIUM HOVER EFFECTS =====
function setupHoverEffects() {
    // Feature cards hover effect
    const featureCards = document.querySelectorAll('.feature-card');
    featureCards.forEach(card => {
        card.addEventListener('mouseenter', () => {
            card.style.transform = 'translateY(-15px) scale(1.03)';
            card.style.boxShadow = '0 25px 50px rgba(255, 107, 107, 0.3)';
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'translateY(0) scale(1)';
            card.style.boxShadow = '';
        });
    });
    
    // Premium button hover effects
    const buttons = document.querySelectorAll('.btn');
    buttons.forEach(button => {
        button.addEventListener('mouseenter', () => {
            if (button.classList.contains('btn-primary')) {
                button.style.transform = 'translateY(-4px) scale(1.02)';
                button.style.boxShadow = '0 25px 50px rgba(255, 107, 107, 0.6)';
            } else {
                button.style.transform = 'translateY(-4px) scale(1.02)';
                button.style.boxShadow = '0 15px 30px rgba(255, 107, 107, 0.3)';
            }
        });
        
        button.addEventListener('mouseleave', () => {
            button.style.transform = 'translateY(0) scale(1)';
            button.style.boxShadow = '';
        });
    });
    
    // Download card premium hover effect
    const downloadCard = document.querySelector('.download-card');
    if (downloadCard) {
        downloadCard.addEventListener('mouseenter', () => {
            downloadCard.style.transform = 'translateY(-8px) scale(1.01)';
            downloadCard.style.boxShadow = '0 30px 60px rgba(255, 107, 107, 0.2)';
        });
        
        downloadCard.addEventListener('mouseleave', () => {
            downloadCard.style.transform = 'translateY(0) scale(1)';
            downloadCard.style.boxShadow = '';
        });
    }
    
    // Security items premium hover effect
    const securityItems = document.querySelectorAll('.security-item');
    securityItems.forEach(item => {
        item.addEventListener('mouseenter', () => {
            const icon = item.querySelector('.security-icon');
            if (icon) {
                icon.style.transform = 'scale(1.3) rotate(8deg)';
                icon.style.filter = 'drop-shadow(0 0 15px rgba(255, 107, 107, 0.6))';
            }
            item.style.transform = 'translateX(10px)';
        });
        
        item.addEventListener('mouseleave', () => {
            const icon = item.querySelector('.security-icon');
            if (icon) {
                icon.style.transform = 'scale(1) rotate(0deg)';
                icon.style.filter = 'none';
            }
            item.style.transform = 'translateX(0)';
        });
    });
    
    // Phone mockup interaction
    const phoneMockup = document.querySelector('.phone-mockup');
    if (phoneMockup) {
        phoneMockup.addEventListener('mouseenter', () => {
            phoneMockup.style.transform = 'perspective(1200px) rotateY(-15deg) rotateX(5deg) scale(1.05)';
        });
        
        phoneMockup.addEventListener('mouseleave', () => {
            phoneMockup.style.transform = 'perspective(1200px) rotateY(-20deg) rotateX(8deg) scale(1)';
        });
    }
}

// ===== SMOOTH SCROLLING =====
function setupSmoothScrolling() {
    const links = document.querySelectorAll('a[href^="#"]');
    
    links.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            
            const targetId = link.getAttribute('href');
            const targetSection = document.querySelector(targetId);
            
            if (targetSection) {
                const offsetTop = targetSection.offsetTop - 80; // Account for fixed navbar
                
                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// ===== TYPING ANIMATION =====
function typeWriter(element, text, speed = 100) {
    let i = 0;
    element.innerHTML = '';
    
    function type() {
        if (i < text.length) {
            element.innerHTML += text.charAt(i);
            i++;
            setTimeout(type, speed);
        }
    }
    
    type();
}

// ===== GLITCH EFFECT =====
function addGlitchEffect(element) {
    const originalText = element.textContent;
    const glitchChars = '!@#$%^&*()_+-=[]{}|;:,.<>?';
    
    let glitchInterval = setInterval(() => {
        let glitchedText = '';
        
        for (let i = 0; i < originalText.length; i++) {
            if (Math.random() < 0.1) {
                glitchedText += glitchChars[Math.floor(Math.random() * glitchChars.length)];
            } else {
                glitchedText += originalText[i];
            }
        }
        
        element.textContent = glitchedText;
        
        setTimeout(() => {
            element.textContent = originalText;
        }, 50);
    }, 2000);
    
    // Stop glitch after 10 seconds
    setTimeout(() => {
        clearInterval(glitchInterval);
        element.textContent = originalText;
    }, 10000);
}

// ===== SCAN LINE EFFECT =====
function createScanLine(container) {
    const scanLine = document.createElement('div');
    scanLine.style.position = 'absolute';
    scanLine.style.top = '0';
    scanLine.style.left = '0';
    scanLine.style.width = '100%';
    scanLine.style.height = '2px';
    scanLine.style.background = 'linear-gradient(90deg, transparent, #00ffff, transparent)';
    scanLine.style.animation = 'scan 3s ease-in-out infinite';
    scanLine.style.zIndex = '10';
    
    container.style.position = 'relative';
    container.appendChild(scanLine);
    
    // Add scan keyframe if not exists
    if (!document.querySelector('#scan-keyframes')) {
        const style = document.createElement('style');
        style.id = 'scan-keyframes';
        style.textContent = `
            @keyframes scan {
                0% { transform: translateY(0); opacity: 0; }
                50% { opacity: 1; }
                100% { transform: translateY(${container.offsetHeight}px); opacity: 0; }
            }
        `;
        document.head.appendChild(style);
    }
}

// ===== PERFORMANCE OPTIMIZATION =====
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// ===== WINDOW RESIZE HANDLER =====
window.addEventListener('resize', debounce(() => {
    // Update particle canvas
    const heroParticles = document.getElementById('heroParticles');
    if (heroParticles) {
        const canvas = heroParticles.querySelector('canvas');
        if (canvas) {
            canvas.width = heroParticles.offsetWidth;
            canvas.height = heroParticles.offsetHeight;
        }
    }
    
    // Update matrix background
    const matrixBg = document.getElementById('matrixBg');
    if (matrixBg) {
        const canvas = matrixBg.querySelector('canvas');
        if (canvas) {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }
    }
    
    // Hide/show cursor follower based on screen size
    const cursorFollower = document.getElementById('cursorFollower');
    if (cursorFollower) {
        if (window.innerWidth <= 768) {
            cursorFollower.style.display = 'none';
        } else {
            cursorFollower.style.display = 'block';
        }
    }
}, 250));

// ===== EASTER EGGS =====
document.addEventListener('keydown', (e) => {
    // Konami code: ↑↑↓↓←→←→BA
    const konamiCode = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65];
    if (!window.konamiSequence) window.konamiSequence = [];
    
    window.konamiSequence.push(e.keyCode);
    
    if (window.konamiSequence.length > konamiCode.length) {
        window.konamiSequence.shift();
    }
    
    if (window.konamiSequence.join(',') === konamiCode.join(',')) {
        // Activate matrix mode
        document.body.style.filter = 'hue-rotate(120deg)';
        setTimeout(() => {
            document.body.style.filter = 'none';
        }, 5000);
        
        window.konamiSequence = [];
    }
});

// ===== PREMIUM LOADING ANIMATION =====
window.addEventListener('load', () => {
    // Hide loading screen if exists
    const loader = document.querySelector('.loader');
    if (loader) {
        loader.style.opacity = '0';
        setTimeout(() => {
            loader.remove();
        }, 500);
    }
    
    // Premium hero entrance animation
    const heroTitle = document.querySelector('.hero-title');
    if (heroTitle) {
        heroTitle.style.opacity = '0';
        heroTitle.style.transform = 'translateY(50px)';
        setTimeout(() => {
            heroTitle.style.transition = 'all 1.2s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
            heroTitle.style.opacity = '1';
            heroTitle.style.transform = 'translateY(0)';
        }, 300);
    }
    
    const heroSubtitle = document.querySelector('.hero-subtitle');
    if (heroSubtitle) {
        heroSubtitle.style.opacity = '0';
        heroSubtitle.style.transform = 'translateY(30px)';
        setTimeout(() => {
            heroSubtitle.style.transition = 'all 1s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
            heroSubtitle.style.opacity = '1';
            heroSubtitle.style.transform = 'translateY(0)';
        }, 600);
    }
    
    const heroButtons = document.querySelector('.hero-buttons');
    if (heroButtons) {
        heroButtons.style.opacity = '0';
        heroButtons.style.transform = 'translateY(20px)';
        setTimeout(() => {
            heroButtons.style.transition = 'all 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
            heroButtons.style.opacity = '1';
            heroButtons.style.transform = 'translateY(0)';
        }, 900);
    }
    
    // Add premium scan lines to security section
    const securitySection = document.querySelector('.security');
    if (securitySection) {
        setTimeout(() => {
            createPremiumScanLine(securitySection);
        }, 3000);
    }
});

// ===== PREMIUM SCAN LINE EFFECT =====
function createPremiumScanLine(container) {
    const scanLine = document.createElement('div');
    scanLine.style.position = 'absolute';
    scanLine.style.top = '0';
    scanLine.style.left = '0';
    scanLine.style.width = '100%';
    scanLine.style.height = '3px';
    scanLine.style.background = 'linear-gradient(90deg, transparent, rgba(255, 107, 107, 0.8), rgba(78, 205, 196, 0.8), transparent)';
    scanLine.style.animation = 'premium-scan 4s ease-in-out infinite';
    scanLine.style.zIndex = '10';
    scanLine.style.borderRadius = '2px';
    scanLine.style.boxShadow = '0 0 20px rgba(255, 107, 107, 0.5)';
    
    container.style.position = 'relative';
    container.appendChild(scanLine);
    
    // Add premium scan keyframe if not exists
    if (!document.querySelector('#premium-scan-keyframes')) {
        const style = document.createElement('style');
        style.id = 'premium-scan-keyframes';
        style.textContent = `
            @keyframes premium-scan {
                0% { transform: translateY(0); opacity: 0; }
                10% { opacity: 1; }
                90% { opacity: 1; }
                100% { transform: translateY(${container.offsetHeight}px); opacity: 0; }
            }
        `;
        document.head.appendChild(style);
    }
}

// ===== EXPORT FOR TESTING =====
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        setupCursorFollower,
        setupMatrixBackground,
        setupParticles,
        setupNavigation,
        setupFAQ,
        typeWriter,
        addGlitchEffect
    };
}
