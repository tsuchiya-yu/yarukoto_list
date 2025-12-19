import { Link, usePage } from "@inertiajs/react";

import type { PageProps } from "@/types/page";

export function SiteHeader() {
  const { auth } = usePage<PageProps>().props;
  const user = auth?.user;

  return (
    <header className="site-header">
      <div className="site-header__inner">
        <Link href="/" className="site-logo">
          やることリスト
        </Link>
        <nav className="site-nav" aria-label="メイン">
          <Link href="/lists" className="nav-link">
            公開リスト
          </Link>
          {!user ? (
            <div className="nav-actions">
              <Link href="/login" className="btn-secondary btn-compact">
                ログインする
              </Link>
              <Link href="/signup" className="btn-primary btn-compact">
                はじめて使う
              </Link>
            </div>
          ) : (
            <div className="nav-user">
              <span className="nav-user__name">{user.name} さん</span>
              <Link href="/logout" method="delete" as="button" className="btn-secondary btn-compact">
                ログアウト
              </Link>
            </div>
          )}
        </nav>
      </div>
    </header>
  );
}
