import { Link } from "@inertiajs/react";

import { PublicShell } from "@/components/PublicShell";
import { Seo, type SeoMeta } from "@/components/Seo";
import { formatDate } from "@/lib/formatters";
import { routes } from "@/lib/routes";
import type { PageProps } from "@/types/page";

type UserListSummary = {
  id: number;
  title: string;
  created_at: string;
  items_count: number;
};

type Props = PageProps<{
  user_lists: UserListSummary[];
  fixed_notice: string;
  meta: SeoMeta;
}>;

export default function UserListsIndex({ user_lists, fixed_notice, meta }: Props) {
  return (
    <>
      <Seo meta={meta} />
      <PublicShell>
        <section className="public-section">
          <header className="section-header">
            <div>
              <p className="section-label">自分用リスト</p>
              <h1>自分用リスト一覧</h1>
            </div>
          </header>
          {user_lists.length > 0 ? (
            <div className="template-grid">
              {user_lists.map((list) => (
                <Link
                  href={routes.userList(list.id)}
                  key={list.id}
                  className="template-card-link"
                >
                  <article className="template-card">
                    <h2>{list.title}</h2>
                    <dl className="template-card__meta">
                      <div>
                        <dt>作成日時</dt>
                        <dd>{formatDate(list.created_at)}</dd>
                      </div>
                      <div>
                        <dt>やること</dt>
                        <dd>{list.items_count}件</dd>
                      </div>
                    </dl>
                  </article>
                </Link>
              ))}
            </div>
          ) : (
            <p className="empty-text">
              まだ自分用リストがありません。公開リストから「自分用にする」を押すと追加できます。
            </p>
          )}
        </section>

        <section className="fixed-notice">
          <p>{fixed_notice}</p>
        </section>
      </PublicShell>
    </>
  );
}
