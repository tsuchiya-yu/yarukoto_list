import path from "node:path";
import { pathToFileURL } from "node:url";
import { createRequire } from "node:module";

import fg from "fast-glob";
import { createInertiaApp } from "@inertiajs/react";
import { renderToString } from "react-dom/server";

const pagesRoot = path.resolve("app/frontend/pages");
const pageFiles = fg.sync("**/*.{tsx,jsx,ts,js}", {
  cwd: pagesRoot,
  absolute: true
});

const pageMap = Object.fromEntries(
  pageFiles.map((filePath) => {
    const relative = filePath
      .replace(`${pagesRoot}${path.sep}`, "")
      .replace(/\.(tsx|jsx|ts|js)$/, "")
      .replace(/\\/g, "/");
    return [relative, filePath];
  })
);

async function resolvePage(name: string) {
  const normalizedName = name.replace(/^\//, "");
  const filePath = pageMap[normalizedName];

  if (!filePath) {
    throw new Error(`SSRページが見つかりません: ${normalizedName}`);
  }

  const module = await import(pathToFileURL(filePath).href);
  return module.default;
}

type CreateServer = (
  callback: (page: unknown) => Promise<unknown>,
  port?: number
) => void;

const require = createRequire(import.meta.url);
const inertiaServer = require("@inertiajs/server");

const serverFactory: CreateServer =
  (inertiaServer.default as CreateServer) ?? (inertiaServer as CreateServer);

const port = Number(process.env.INERTIA_SSR_PORT || 13714);

serverFactory(
  (page) =>
    createInertiaApp({
      page,
      render: renderToString,
      resolve: resolvePage,
      setup: ({ App, props }) => <App {...props} />
    }),
  port
);
