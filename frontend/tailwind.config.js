/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                // Deep Cosmic / Monochromatic Purple vibe
                primary: {
                    DEFAULT: '#6d28d9', // violet-700
                    light: '#8b5cf6', // violet-500
                    dark: '#4c1d95', // violet-900
                    glow: '#d8b4fe', // violet-300
                },
                dark: {
                    DEFAULT: '#020617', // slate-950
                    card: '#0f172a', // slate-900 
                    surface: '#1e293b', // slate-800
                },
                neon: {
                    blue: '#00f3ff',
                    pink: '#ff00ff',
                    purple: '#bc13fe',
                }
            },
            fontFamily: {
                sans: ['Outfit', 'sans-serif'],
            },
            boxShadow: {
                'glass': '0 8px 32px 0 rgba(0, 0, 0, 0.37)',
                'glass-hover': '0 8px 32px 0 rgba(109, 40, 217, 0.3)',
                'neon': '0 0 20px rgba(255, 255, 255, 0.3)',
                'neon-hover': '0 0 30px rgba(188, 19, 254, 0.5)',
            },
            animation: {
                'blob': 'blob 7s infinite',
                'fade-in': 'fadeIn 0.5s ease-out forwards',
                'slide-up': 'slideUp 0.5s ease-out forwards',
                'float': 'float 3s ease-in-out infinite',
                'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
            },
            keyframes: {
                blob: {
                    '0%': { transform: 'translate(0px, 0px) scale(1)' },
                    '33%': { transform: 'translate(30px, -50px) scale(1.1)' },
                    '66%': { transform: 'translate(-20px, 20px) scale(0.9)' },
                    '100%': { transform: 'translate(0px, 0px) scale(1)' },
                },
                fadeIn: {
                    '0%': { opacity: '0' },
                    '100%': { opacity: '1' },
                },
                slideUp: {
                    '0%': { transform: 'translateY(20px)', opacity: '0' },
                    '100%': { transform: 'translateY(0)', opacity: '1' },
                },
                float: {
                    '0%, 100%': { transform: 'translateY(0)' },
                    '50%': { transform: 'translateY(-10px)' },
                }
            }
        },
    },
    plugins: [],
}
