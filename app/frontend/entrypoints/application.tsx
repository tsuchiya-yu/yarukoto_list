import "../styles/app.css";

import { createInertiaApp } from "@inertiajs/react";
import type React from "react";
import { createRoot } from "react-dom/client";

declare global {
  interface Window {
    $RefreshReg$: (type?: unknown) => void;
    $RefreshSig$: () => (type: unknown) => unknown;
    __vite_plugin_react_preamble_installed__?: boolean;
  }
}

if (import.meta.hot && import.meta.env.DEV && typeof window !== "undefined") {
  import("/@react-refresh").then((RefreshRuntime) => {
    RefreshRuntime.default.injectIntoGlobalHook(window);
    window.$RefreshReg$ = () => {};
    window.$RefreshSig$ = () => (type: unknown) => type;
    window.__vite_plugin_react_preamble_installed__ = true;
  });
}

type PageModule = { default: React.ComponentType };

const pages = import.meta.glob<PageModule>("../pages/**/*.tsx");

createInertiaApp({
  title: (title) => (title ? `${title} | やることリスト` : "やることリスト"),
  resolve: async (name) => {
    const importPage = pages[`../pages/${name}.tsx`];
    if (!importPage) {
      throw new Error(`ページが見つかりません: ${name}`);
    }

    const page = await importPage();
    return page.default;
  },
  setup({ el, App, props }) {
    const root = createRoot(el);
    root.render(<App {...props} />);
  },
  progress: {
    color: "#84cc16",
  },
});
