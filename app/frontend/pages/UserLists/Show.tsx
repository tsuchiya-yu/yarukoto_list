import { PublicShell } from "@/components/PublicShell";
import { Seo, type SeoMeta } from "@/components/Seo";
import { formatDate } from "@/lib/formatters";
import type { PageProps } from "@/types/page";

type UserListItem = {
  id: number;
  title: string;
  description?: string | null;
  completed: boolean;
  position: number;
};

type UserListDetail = {
  id: number;
  title: string;
  description?: string | null;
  created_at: string;
  items: UserListItem[];
};

type Props = PageProps<{
  user_list: UserListDetail;
  fixed_notice: string;
  meta: SeoMeta;
}>;

export default function UserListsShow({ user_list, fixed_notice, meta }: Props) {
  return (
    <>
      <Seo meta={meta} />
      <PublicShell>
        <section className="public-section">
          <header className="section-header">
            <div>
              <p className="section-label">自分用リスト</p>
              <h1>{user_list.title}</h1>
            </div>
          </header>
          {user_list.description && (
            <p className="hero-subcopy">{user_list.description}</p>
          )}
          <dl className="template-card__meta">
            <div>
              <dt>作成日時</dt>
              <dd>{formatDate(user_list.created_at)}</dd>
            </div>
            <div>
              <dt>やること</dt>
              <dd>{user_list.items.length}件</dd>
            </div>
          </dl>
        </section>

        <section className="public-section">
          <header className="section-header">
            <p className="section-label">やること一覧</p>
            <h2>このリストの内容</h2>
          </header>
          <ol className="timeline-list">
            {user_list.items.map((item, index) => (
              <li key={item.id}>
                <div className="timeline-step">STEP {index + 1}</div>
                <h3>{item.title}</h3>
                {item.description && <p>{item.description}</p>}
              </li>
            ))}
          </ol>
          {user_list.items.length === 0 && (
            <p className="empty-text">やることの内容はまだありません。</p>
          )}
        </section>

        <section className="fixed-notice">
          <p>{fixed_notice}</p>
        </section>
      </PublicShell>
    </>
  );
}
