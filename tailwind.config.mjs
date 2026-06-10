/** @type {import('tailwindcss').Config} */
// RSA X design tokens — source of truth: RSA Brand Guideline 2022-2023.
// Primary green #72BF44 (Pantone 368C); brand grey #58595B; Verdana for all text.
// Dark surfaces are green-tinted charcoal ("industrial glasshouse"), not blue-grey.
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        surface: {
          DEFAULT: '#060906',   // x-void
          raised: '#0E140C',    // x-surface
          elevated: '#161F12',  // x-surface-2
          highlight: '#22301B', // x-surface-3
        },
        accent: {
          DEFAULT: '#72BF44',   // RSA green, Pantone 368C
          light: '#A8E063',     // 375U bright
          dark: '#4C8A2B',      // gradient anchor
        },
        steel: '#58595B',       // brand grey
        line: '#243420',        // x-border
        // platform accents from the family the brand already owns
        altermarkt: '#109173',  // Federated Farmers teal
        rsax: '#72BF44',        // RSA green — the core ops platform (ex-ForkFlex)
      },
      fontFamily: {
        // the brand mandates Verdana for all text — system-installed, zero loading cost
        sans: ['Verdana', 'Geneva', 'DejaVu Sans', 'sans-serif'],
      },
      borderRadius: {
        // the leaf: rounded top-left + bottom-right, square opposites
        leaf: '20px 4px 20px 4px',
        'leaf-lg': '36px 5px 36px 5px',
      },
    },
  },
  plugins: [],
};
