import { Head } from "@inertiajs/react";

type TemplateSummary = {
  id: number;
  title: string;
  description: string;
  author_name: string;
  updated_at: string;
  average_score: number;
  ratings_count: number;
  reviews_count: number;
  copies_count: number;
};

type HeroContent = {
  badge: string;
  title: string;
  lead: string;
  subcopy: string;
  cta: {
    href: string;
    label: string;
  };
  secondary_cta: {
    href: string;
    label: string;
  };
  highlights: string[];
};

type Meta = {
  title: string;
  description: string;
  og_title: string;
  og_description: string;
  og_image: string;
};

type Props = {
  hero: HeroContent;
  featured_templates: TemplateSummary[];
  meta: Meta;
};

const formatDate = (value: string) =>
  new Date(value).toLocaleDateString("ja-JP", { year: "numeric", month: "short", day: "numeric" });

const formatScore = (value: number) => value.toFixed(1);

export default function Home({ hero, featured_templates, meta }: Props) {
  return (
    <>
      <Head title={meta.title}>
        <meta name="description" content={meta.description} />
        <meta property="og:title" content={meta.og_title} />
        <meta property="og:description" content={meta.og_description} />
        <meta property="og:image" content={meta.og_image} />
        <meta property="twitter:card" content="summary_large_image" />
      </Head>
      <main className="public-shell">
        <section className="public-hero">
          <div className="public-hero__copy">
            <p className="hero-badge">{hero.badge}</p>
            <h1>{hero.title}</h1>
            <p className="hero-lead">{hero.lead}</p>
            <p className="hero-subcopy">{hero.subcopy}</p>
            <div className="hero-actions">
              <a className="btn-primary" href={hero.cta.href}>
                {hero.cta.label}
              </a>
              <a className="btn-secondary" href={hero.secondary_cta.href}>
                {hero.secondary_cta.label}
              </a>
            </div>
            <ul className="hero-highlights">
              {hero.highlights.map((highlight) => (
                <li key={highlight}>{highlight}</li>
              ))}
            </ul>
          </div>
          <div className="public-hero__panel">
            <p className="panel-heading">人気のやることリスト</p>
            <p className="panel-text">
              公式のやることリストを人気順に表示しています。気になる内容を開いて、引越し当日までの流れをすぐに確認できます。
            </p>
          </div>
        </section>

        <section className="public-section">
          <header className="section-header">
            <div>
              <p className="section-label">公式リスト</p>
              <h2>今チェックされているやること</h2>
            </div>
            <a className="link-more" href="/lists">
              一覧を見る
            </a>
          </header>
          <div className="template-grid">
            {featured_templates.map((template) => (
              <article key={template.id} className="template-card">
                <div className="template-card__stats">
                  <span className="template-card__score">★ {formatScore(template.average_score)}</span>
                  <span className="template-card__reviews">レビュー {template.reviews_count}件</span>
                  <span className="template-card__copies">自分用 {template.copies_count}件</span>
                </div>
                <h3>{template.title}</h3>
                <p className="template-card__description">{template.description}</p>
                <dl className="template-card__meta">
                  <div>
                    <dt>作成</dt>
                    <dd>{template.author_name}</dd>
                  </div>
                  <div>
                    <dt>更新日</dt>
                    <dd>{formatDate(template.updated_at)}</dd>
                  </div>
                </dl>
                <div className="template-card__actions">
                  <a href={`/lists/${template.id}`} className="btn-ghost">
                    このリストを見る
                  </a>
                </div>
              </article>
            ))}
          </div>
          {featured_templates.length === 0 && (
            <p className="empty-text">公開中のやることリストはまだありません。</p>
          )}
        </section>
      </main>
    </>
  );
}
