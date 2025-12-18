import { Head, router } from "@inertiajs/react";
import type { FormEvent } from "react";
import { useEffect, useMemo, useState } from "react";

import { formatDate, formatScore } from "@/lib/formatters";

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

type Filters = {
  sort: string;
  keyword: string;
  page: number;
};

type SortOption = {
  value: string;
  label: string;
};

type Pagination = {
  page: number;
  per_page: number;
  total_count: number;
  total_pages: number;
  has_prev: boolean;
  has_next: boolean;
};

type Meta = {
  title: string;
  description: string;
  og_title: string;
  og_description: string;
  og_image: string;
};

type Props = {
  templates: TemplateSummary[];
  filters: Filters;
  pagination: Pagination;
  sort_options: SortOption[];
  meta: Meta;
};

export default function TemplateIndex({ templates, filters, pagination, sort_options, meta }: Props) {
  const [keyword, setKeyword] = useState(filters.keyword ?? "");

  useEffect(() => {
    setKeyword(filters.keyword ?? "");
  }, [filters.keyword]);

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    router.get(
      "/lists",
      {
        sort: filters.sort,
        q: keyword,
        page: 1
      },
      { replace: true }
    );
  };

  const handleSortChange = (value: string) => {
    router.get(
      "/lists",
      {
        sort: value,
        q: keyword,
        page: 1
      },
      {
        replace: true,
        preserveScroll: true
      }
    );
  };

  const handlePageChange = (page: number) => {
    router.get(
      "/lists",
      {
        sort: filters.sort,
        q: keyword,
        page
      },
      {
        replace: true,
        preserveScroll: true
      }
    );
  };

  const totalLabel = useMemo(() => {
    if (pagination.total_count === 0) {
      return "該当するやることリストは見つかりませんでした。";
    }
    return `全${pagination.total_count}件のやることリスト`;
  }, [pagination.total_count]);

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
        <header className="public-list-header">
          <p className="section-label">公開リスト</p>
          <h1>公式やることリスト一覧</h1>
          <p className="hero-subcopy">
            人気順・評価順・新着の3つの並び替えとキーワード検索で、目的に合うやることリストを見つけられます。
          </p>
        </header>

        <section className="list-controls">
          <div className="sort-tabs" role="tablist" aria-label="並び替え">
            {sort_options.map((option) => {
              const isActive = option.value === filters.sort;
              return (
                <button
                  type="button"
                  key={option.value}
                  className={isActive ? "sort-tab is-active" : "sort-tab"}
                  aria-pressed={isActive}
                  onClick={() => handleSortChange(option.value)}
                >
                  {option.label}
                </button>
              );
            })}
          </div>
          <form className="search-form" onSubmit={handleSubmit}>
            <label htmlFor="keyword">キーワード検索</label>
            <div className="search-input">
              <input
                id="keyword"
                name="q"
                type="search"
                placeholder="例：荷造り、ライフライン"
                value={keyword}
                onChange={(event) => setKeyword(event.target.value)}
              />
              <button type="submit">検索</button>
            </div>
          </form>
        </section>

        <p className="result-label">{totalLabel}</p>

        <div className="template-grid">
          {templates.map((template) => (
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
                <a href={`/lists/${template.id}`} className="btn-primary">
                  このリストを見る
                </a>
              </div>
            </article>
          ))}
        </div>

        {templates.length === 0 && <p className="empty-text">条件に一致するやることリストはありません。</p>}

        <div className="pagination">
          <button
            type="button"
            className="pagination-button"
            onClick={() => handlePageChange(filters.page - 1)}
            disabled={!pagination.has_prev}
          >
            前へ
          </button>
          <span className="pagination-status">
            {filters.page} / {pagination.total_pages}
          </span>
          <button
            type="button"
            className="pagination-button"
            onClick={() => handlePageChange(filters.page + 1)}
            disabled={!pagination.has_next}
          >
            次へ
          </button>
        </div>
      </main>
    </>
  );
}
