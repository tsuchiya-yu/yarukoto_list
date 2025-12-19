import type { ReactNode } from "react";

import { FlashMessages } from "./FlashMessages";
import { SiteHeader } from "./SiteHeader";

type Props = {
  children: ReactNode;
  className?: string;
};

export function PublicShell({ children, className }: Props) {
  const mainClassName = ["public-shell", className].filter(Boolean).join(" ");

  return (
    <>
      <SiteHeader />
      <FlashMessages />
      <main className={mainClassName}>{children}</main>
    </>
  );
}
