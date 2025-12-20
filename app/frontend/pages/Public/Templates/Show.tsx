import { Link, router, usePage } from "@inertiajs/react";
import { useState } from "react";

import { PublicShell } from "@/components/PublicShell";
import { Seo } from "@/components/Seo";
import { formatDate, formatScore } from "@/lib/formatters";
import { routes } from "@/lib/routes";
import type { PageProps } from "@/types/page";

type TimelineItem = {
  id: number;
  title: string;
  description?: string | null;
};

type Review = {
  id: number;
  user_name: string;
  content: string;
  created_at: string;
};

type CTA = {
  message: string;
  button_label: string;
  href: string;
};

type TemplateDetail = {
  id: number;
  title: string;
  description: string;
  author: {
    name: string;
  };
  updated_at: string;
  average_score: number;
  ratings_count: number;
  reviews_count: number;
  copies_count: number;
  author_notes?: string | null;
  timeline: TimelineItem[];
  reviews: Review[];
  cta: CTA;
};

type Meta = {
  title: string;
  description: string;
  og_title: string;
  og_description: string;
  og_image: string;
};

type Props = PageProps<{
  template: TemplateDetail;
  fixed_notice: string;
  meta: Meta;
}>;

export default function TemplateShow({ template, fixed_notice, meta }: Props) {
  const { auth } = usePage<PageProps>().props;
  const isLoggedIn = Boolean(auth?.user);
  const [isCopying, setIsCopying] = useState(false);
  const ctaMessage = isLoggedIn
    ? "このリストを自分用にコピーして、やることの進捗を記録できます。"
    : template.cta.message;

  return (
    <>
      <Seo meta={meta} />
      <PublicShell className="detail-shell">
        <article className="detail-hero">
          <p className="section-label">公開リスト</p>
          <h1>{template.title}</h1>
          <p className="hero-subcopy">{template.description}</p>
          <div className="detail-meta">
            <span>作成: {template.author.name}</span>
            <span>更新日: {formatDate(template.updated_at)}</span>
          </div>
          <div className="detail-rating">
            <span className="detail-score">★ {formatScore(template.average_score)}</span>
            <span>レビュー {template.reviews_count}件</span>
            <span>自分用 {template.copies_count}件</span>
          </div>
        </article>

        {template.author_notes && (
          <section className="public-section">
            <h2>作成者からの注意書き</h2>
            <p className="author-notes">{template.author_notes}</p>
          </section>
        )}

        <section className="public-section">
          <header className="section-header">
            <p className="section-label">やること時系列</p>
            <h2>このリストの流れ</h2>
          </header>
          <ol className="timeline-list">
            {template.timeline.map((item, index) => (
              <li key={item.id}>
                <div className="timeline-step">STEP {index + 1}</div>
                <h3>{item.title}</h3>
                {item.description && <p>{item.description}</p>}
              </li>
            ))}
          </ol>
          {template.timeline.length === 0 && (
            <p className="empty-text">やることの詳細は準備中です。</p>
          )}
        </section>

        <section className="public-section">
          <header className="section-header">
            <p className="section-label">レビュー</p>
            <h2>利用者の声</h2>
          </header>
          <div className="review-list">
            {template.reviews.map((review) => (
              <article key={review.id} className="review-card">
                <p className="review-content">{review.content}</p>
                <div className="review-meta">
                  <span>{review.user_name}</span>
                  <span>{formatDate(review.created_at)}</span>
                </div>
              </article>
            ))}
            {template.reviews.length === 0 && (
              <p className="empty-text">レビューはまだありません。</p>
            )}
          </div>
        </section>

        <section className="cta-panel">
          <div>
            <h2>自分用にする</h2>
            <p>{ctaMessage}</p>
          </div>
          {isLoggedIn ? (
            <button
              type="button"
              className="btn-primary"
              disabled={isCopying}
              onClick={() => {
                setIsCopying(true);
                router.post(
                  routes.userLists(),
                  { template_id: template.id },
                  {
                    preserveScroll: true,
                    onFinish: () => setIsCopying(false)
                  }
                );
              }}
            >
              {isCopying ? "コピー中..." : "自分用にする"}
            </button>
          ) : (
            <Link className="btn-primary" href={routes.login()}>
              {template.cta.button_label}
            </Link>
          )}
        </section>

        <section className="fixed-notice">
          <p>{fixed_notice}</p>
        </section>
      </PublicShell>
    </>
  );
}
