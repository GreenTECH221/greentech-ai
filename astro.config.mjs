import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  site: 'https://greentech-ai.com',
  integrations: [tailwind()],
  output: 'static',
  redirects: {
    '/forkflex': '/rsa-x',  // platform renamed — ForkFlex became RSA X
    '/beyond': '/',         // RSA Beyond has no page on this hub — the home-page card links to rsa-beyond.web.app
  },
});
