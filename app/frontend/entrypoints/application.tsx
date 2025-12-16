import "../styles/app.css";

import { createInertiaApp } from "@inertiajs/react";
import type React from "react";
import { createRoot } from "react-dom/client";

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
