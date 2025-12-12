/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                // Theme: "Obsidian Pro" - Dark, Clean, Rose Accents
                background: '#09090b', // Zinc 950
                surface: '#18181b',    // Zinc 900
                primary: {
                    DEFAULT: '#f43f5e', // Rose 500
                    dark: '#e11d48',    // Rose 600
                    light: '#fb7185',   // Rose 400
                },
                secondary: {
                    DEFAULT: '#8b5cf6', // Violet 500
                },
                accent: {
                    DEFAULT: '#06b6d4', // Cyan 500
                },
                // Text
                txt: {
                    main: '#fafafa',     // Zinc 50
                    muted: '#a1a1aa',    // Zinc 400
                    dim: '#52525b',      // Zinc 600
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
