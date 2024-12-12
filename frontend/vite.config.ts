import { defineConfig } from 'vite'
import { resolve } from 'path'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  root: resolve('./src'),
  base: '/staticfiles/',
  server: {
    host: 'localhost',
    port: 5173,
    open: false,
    watch: {
      usePolling: true,
      disableGlobbing: false,
    },
  },
  build: {
    // コンパイル後の出力先。DJANGO_VITE_ASSET_PATHと一致させる
    outDir: resolve('./dist'),
    assetsDir: '',
    manifest: true,
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: resolve('./src/main.tsx'),
      },
      output: {
        chunkFileNames: undefined,
      },
    },
    assetsInlineLimit: 10240,
  },
})