/** @type {import('tailwindcss').Config} */
module.exports = {
  // Tous les fichiers contenant des classes Nativewind
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        // Palette FoodPad — mode clair
        background: {
          DEFAULT: '#ffffff',
          element: '#F0F0F3',
          selected: '#E0E1E6',
        },
        foreground: {
          DEFAULT: '#000000',
          secondary: '#60646C',
        },
        // Palette FoodPad — mode sombre (utilisée via la variante dark:)
        dark: {
          background: '#000000',
          element: '#212225',
          selected: '#2E3135',
          foreground: '#ffffff',
          secondary: '#B0B4BA',
        },
        primary: '#3c87f7',
        brand: '#208AEF',
      },
      fontFamily: {
        montserrat: ['Montserrat-Regular'],
        'montserrat-semibold': ['Montserrat-SemiBold'],
        'montserrat-bold': ['Montserrat-Bold'],
      },
    },
  },
  plugins: [],
};