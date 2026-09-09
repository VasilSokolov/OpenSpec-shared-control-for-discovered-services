import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Tauri serves this build as static assets; no SSR/server runtime is involved.
export default defineConfig({
  plugins: [react()],
  clearScreen: false,
  server: { port: 5173, strictPort: true },
  build: { target: "es2021", outDir: "dist", emptyOutDir: true },
});
