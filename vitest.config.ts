import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'dist/'],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@core': path.resolve(__dirname, './src/core'),
      '@plugins': path.resolve(__dirname, './src/plugins'),
      '@ai': path.resolve(__dirname, './src/ai'),
      '@api': path.resolve(__dirname, './src/api'),
      '@workers': path.resolve(__dirname, './src/workers'),
      '@config': path.resolve(__dirname, './config'),
    },
  },
});
