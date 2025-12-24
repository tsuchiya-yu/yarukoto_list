import { Link, router, useForm, usePage } from "@inertiajs/react";
import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ChangeEvent,
  type FormEvent
} from "react";

import { FormErrorMessages } from "@/components/FormErrorMessages";
import { PublicShell } from "@/components/PublicShell";
import { Seo } from "@/components/Seo";
import { formatDate, formatScore } from "@/lib/formatters";
import { routes } from "@/lib/routes";
import { useFocusTrap } from "@/lib/useFocusTrap";
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
  current_review?: {
    id: number;
    content: string;
    score: number | null;
  } | null;
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
  review_notice: string;
  meta: Meta;
}>;

export default function TemplateShow({ template, fixed_notice, review_notice, meta }: Props) {
  const { auth, errors: sharedErrors } = usePage<PageProps>().props;
  const isLoggedIn = Boolean(auth?.user);
  const [isCopying, setIsCopying] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const currentReview = template.current_review ?? null;
  const isEditingReview = Boolean(currentReview);
  const { data, setData, post, patch, delete: destroy, processing, errors } = useForm({
    template_review: {
      score: currentReview?.score?.toString() ?? "5",
      content: currentReview?.content ?? ""
    }
  });
  const ctaMessage = isLoggedIn
    ? "このリストを自分用にコピーして、やることの進捗を記録できます。"
    : template.cta.message;
  const baseMessages = useMemo(() => {
    const base = errors.base || sharedErrors?.base;
    if (!base) {
      return [];
    }
    return Array.isArray(base) ? base : [base];
  }, [errors.base, sharedErrors?.base]);
  const dialogRef = useRef<HTMLDivElement | null>(null);

  useFocusTrap(isDeleteDialogOpen, dialogRef, () => setIsDeleteDialogOpen(false));

  useEffect(() => {
    setData({
      template_review: {
        score: currentReview?.score?.toString() ?? "5",
        content: currentReview?.content ?? ""
      }
    });
  }, [currentReview?.id, currentReview?.score, currentReview?.content, setData]);

  const handleReviewChange = useCallback(
    (event: ChangeEvent<HTMLSelectElement | HTMLTextAreaElement>) => {
      const { name, value } = event.target;
      setData((currentData) => ({
        ...currentData,
        template_review: {
          ...currentData.template_review,
          [name]: value
        }
      }));
    },
    [setData]
  );

  const handleReviewSubmit = useCallback(
    (event: FormEvent<HTMLFormElement>) => {
      event.preventDefault();
      const action = isEditingReview ? patch : post;
      action(routes.templateReview(template.id), {
        preserveScroll: true
      });
    },
    [isEditingReview, patch, post, template.id]
  );

  const handleReviewDelete = useCallback(() => {
    if (!isEditingReview) {
      return;
    }
    setIsDeleteDialogOpen(true);
  }, [isEditingReview]);

  const confirmReviewDelete = useCallback(() => {
    if (!isEditingReview) {
      return;
    }
    destroy(routes.templateReview(template.id), {
      preserveScroll: true,
      onFinish: () => setIsDeleteDialogOpen(false)
    });
  }, [destroy, isEditingReview, template.id]);

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
          {isLoggedIn && (
            <div className="review-form">
              <p className="review-notice">{review_notice}</p>
              <form onSubmit={handleReviewSubmit} className="item-form">
                <FormErrorMessages
                  messages={baseMessages}
                  variant="form"
                  keyPrefix="template-review-base"
                />
                <div className="form-field">
                  <label htmlFor="template-review-score">★評価</label>
                  <select
                    id="template-review-score"
                    name="score"
                    value={data.template_review.score}
                    onChange={handleReviewChange}
                  >
                    {[5, 4, 3, 2, 1].map((score) => (
                      <option key={score} value={score}>
                        {score}
                      </option>
                    ))}
                  </select>
                  <FormErrorMessages
                    messages={errors.score}
                    keyPrefix="template-review-score"
                  />
                </div>
                <div className="form-field">
                  <label htmlFor="template-review-content">レビュー</label>
                  <textarea
                    id="template-review-content"
                    name="content"
                    value={data.template_review.content}
                    onChange={handleReviewChange}
                    placeholder="このリストの感想を書いてください"
                    rows={4}
                  />
                  <FormErrorMessages
                    messages={errors.content}
                    keyPrefix="template-review-content"
                  />
                </div>
                <div className="review-actions">
                  <button type="submit" className="btn-primary btn-compact" disabled={processing}>
                    {processing
                      ? "送信中..."
                      : isEditingReview
                        ? "レビューを更新する"
                        : "レビューを投稿する"}
                  </button>
                  {isEditingReview && (
                    <button
                      type="button"
                      className="btn-danger btn-compact"
                      onClick={handleReviewDelete}
                      disabled={processing}
                    >
                      消す
                    </button>
                  )}
                </div>
              </form>
            </div>
          )}
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

        {isDeleteDialogOpen && (
          <div className="dialog-overlay" role="dialog" aria-modal="true">
            <div className="dialog-card" ref={dialogRef}>
              <p className="dialog-title">このレビューを消しますか？</p>
              <div className="dialog-actions">
                <button
                  type="button"
                  className="btn-danger"
                  onClick={confirmReviewDelete}
                  disabled={processing}
                >
                  {processing ? "消しています..." : "消す"}
                </button>
                <button
                  type="button"
                  className="btn-secondary"
                  onClick={() => setIsDeleteDialogOpen(false)}
                  disabled={processing}
                >
                  そのままにする
                </button>
              </div>
            </div>
          </div>
        )}
      </PublicShell>
    </>
  );
}
