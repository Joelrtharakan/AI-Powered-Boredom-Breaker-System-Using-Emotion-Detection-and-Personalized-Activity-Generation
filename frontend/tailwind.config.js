/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                // Theme: "Midnight Velvet" - Dark, High Contrast, Premium
                background: '#020617', // Slate 950 - Deepest Blue/Black
                surface: '#0f172a',    // Slate 900 - Cards
                primary: {
                    DEFAULT: '#6366f1', // Indigo 500
                    dark: '#4338ca',    // Indigo 700
                    light: '#818cf8',   // Indigo 400
                },
                secondary: {
                    DEFAULT: '#d946ef', // Fuchsia 500
                },
                accent: {
                    DEFAULT: '#22d3ee', // Cyan 400
                },
                // Text
                txt: {
                    main: '#ffffff',     // Pure White
                    muted: '#94a3b8',    // Slate 400 - Readable on dark
                    dim: '#475569',      // Slate 600
                }
            },
            fontFamily: {
                sans: ['Outfit', 'sans-serif'],
            },
            boxShadow: {
                'neon': '0 0 20px -5px rgba(99, 102, 241, 0.4)',
                'neon-hover': '0 0 40px -10px rgba(99, 102, 241, 0.6)',
                'glass': '0 8px 32px 0 rgba(0, 0, 0, 0.3)',
            },
            animation: {
                'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                'float': 'float 6s ease-in-out infinite',
            },
            keyframes: {
                float: {
                    '0%, 100%': { transform: 'translateY(0)' },
                    '50%': { transform: 'translateY(-15px)' },
                }
            }
        },
    },
    plugins: [],
}
