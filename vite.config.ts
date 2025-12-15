import { fileURLToPath, URL } from "node:url";

import react from "@vitejs/plugin-react";
import RubyPlugin from "vite-plugin-ruby";
import { defineConfig } from "vite";

const frontendDir = fileURLToPath(new URL("./app/frontend", import.meta.url));

export default defineConfig(() => {
  return {
    plugins: [
      react(),
      RubyPlugin({
        entrypointsDir: "app/frontend/entrypoints"
      })
    ],
    resolve: {
      alias: {
        "@": frontendDir
      }
    },
    server: {
      host: "0.0.0.0",
      port: Number(process.env.VITE_DEV_SERVER_PORT || 5173)
    },
    ssr: {
      noExternal: ["@inertiajs/server"]
    }
  };
});
