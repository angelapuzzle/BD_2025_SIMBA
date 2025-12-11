import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,   // 👈 Fuerza este puerto
    strictPort: true,  // 👈 Evita que use otro puerto
  },
});
