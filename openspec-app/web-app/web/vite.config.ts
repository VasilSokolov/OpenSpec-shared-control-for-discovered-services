import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Dev-only proxy: `yarn dev` serves the UI on 5174 and forwards /api to the
// local opsx-web-server (8787), so the browser talks same-origin and no CORS is
// needed. In docker-compose the nginx `web` service does the same proxying.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5174,
    proxy: {
      "/api": {
        target: process.env.OPSX_API_TARGET ?? "http://localhost:8787",
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: "dist",
  },
});
