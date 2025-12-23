import { router, useForm } from "@inertiajs/react";
import { useEffect, useState, type ChangeEvent, type FormEvent } from "react";

import { FormErrorMessages } from "@/components/FormErrorMessages";
import { PublicShell } from "@/components/PublicShell";
import { Seo, type SeoMeta } from "@/components/Seo";
import { formatDate } from "@/lib/formatters";
import { routes } from "@/lib/routes";
import type { PageProps, SharedErrors } from "@/types/page";

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
  items_count: number;
  items: UserListItem[];
};

type Props = PageProps<{
  user_list: UserListDetail;
  fixed_notice: string;
  meta: SeoMeta;
  form_errors?: SharedErrors;
}>;

export default function UserListsShow({ user_list, fixed_notice, meta, form_errors }: Props) {
  const [items, setItems] = useState(user_list.items);
  const [deleteTarget, setDeleteTarget] = useState<UserListItem | null>(null);
  const { data, setData, post, processing, reset } = useForm({
    user_list_item: {
      title: "",
      description: ""
    }
  });
  const formErrors = form_errors ?? {};

  const handleFormChange = (
    event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = event.target;
    setData("user_list_item", {
      ...data.user_list_item,
      [name]: value
    });
  };

  useEffect(() => {
    setItems(user_list.items);
  }, [user_list.items]);

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    post(routes.userListItems(user_list.id), {
      preserveScroll: true,
      onSuccess: () => reset()
    });
  };

  const handleToggle = (itemId: number) => {
    const target = items.find((item) => item.id === itemId);
    if (!target) {
      return;
    }

    const previous = items;
    const nextCompleted = !target.completed;
    const nextItems = items.map((item) =>
      item.id === itemId ? { ...item, completed: nextCompleted } : item
    );
    setItems(nextItems);

    router.patch(
      routes.userListItem(user_list.id, itemId),
      { user_list_item: { completed: nextCompleted } },
      {
        preserveScroll: true,
        onError: () => setItems(previous)
      }
    );
  };

  const handleMove = (index: number, direction: number) => {
    const targetIndex = index + direction;
    if (targetIndex < 0 || targetIndex >= items.length) {
      return;
    }

    const previous = items;
    const nextItems = [...items];
    const [moved] = nextItems.splice(index, 1);
    nextItems.splice(targetIndex, 0, moved);
    setItems(nextItems);

    router.patch(
      routes.userListItemsReorder(user_list.id),
      { item_ids: nextItems.map((item) => item.id) },
      {
        preserveScroll: true,
        onError: () => setItems(previous)
      }
    );
  };

  const confirmDelete = (item: UserListItem) => {
    setDeleteTarget(item);
  };

  const handleDelete = () => {
    if (!deleteTarget) {
      return;
    }

    const previousItems = items;
    const targetId = deleteTarget.id;
    setItems((currentItems) =>
      currentItems.filter((item) => item.id !== targetId)
    );
    setDeleteTarget(null);

    router.delete(routes.userListItem(user_list.id, targetId), {
      preserveScroll: true,
      onError: () => {
        setItems(previousItems);
      }
    });
  };

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
              <dd>{user_list.items_count}件</dd>
            </div>
          </dl>
        </section>

        <section className="public-section">
          <header className="section-header">
            <p className="section-label">やることを追加</p>
            <h2>新しいやること</h2>
          </header>
          <form onSubmit={handleSubmit} className="item-form">
            <FormErrorMessages
              messages={formErrors.base}
              variant="form"
              keyPrefix="user-list-item-form"
            />
            <div className="form-field">
              <label htmlFor="user-list-item-title">やること</label>
              <input
                id="user-list-item-title"
                name="title"
                value={data.user_list_item.title}
                onChange={handleFormChange}
                placeholder="例：引越しの見積もりを取る"
              />
              <FormErrorMessages
                messages={formErrors.title}
                keyPrefix="user-list-item-title"
              />
            </div>
            <div className="form-field">
              <label htmlFor="user-list-item-description">補足（任意）</label>
              <textarea
                id="user-list-item-description"
                name="description"
                value={data.user_list_item.description}
                onChange={handleFormChange}
                placeholder="必要ならメモを残せます"
                rows={3}
              />
              <FormErrorMessages
                messages={formErrors.description}
                keyPrefix="user-list-item-description"
              />
            </div>
            <button type="submit" className="btn-primary btn-compact" disabled={processing}>
              {processing ? "追加中..." : "やることを追加"}
            </button>
          </form>
        </section>

        <section className="public-section">
          <header className="section-header">
            <p className="section-label">やること一覧</p>
            <h2>このリストの内容</h2>
          </header>
          <ol className="timeline-list user-list-items">
            {items.map((item, index) => (
              <li key={item.id} className={item.completed ? "is-completed" : undefined}>
                <div className="user-list-item__header">
                  <div>
                    <div className="timeline-step">STEP {index + 1}</div>
                    <p className="item-status">
                      {item.completed ? "完了" : "未完了"}
                    </p>
                    <h3>{item.title}</h3>
                  </div>
                  <div className="item-actions">
                    <button
                      type="button"
                      className="btn-secondary btn-compact"
                      onClick={() => handleToggle(item.id)}
                      aria-pressed={item.completed}
                    >
                      {item.completed ? "未完了に戻す" : "完了にする"}
                    </button>
                    <button
                      type="button"
                      className="btn-ghost btn-compact"
                      onClick={() => handleMove(index, -1)}
                      disabled={index === 0}
                    >
                      上へ
                    </button>
                    <button
                      type="button"
                      className="btn-ghost btn-compact"
                      onClick={() => handleMove(index, 1)}
                      disabled={index === items.length - 1}
                    >
                      下へ
                    </button>
                    <button
                      type="button"
                      className="btn-danger btn-compact"
                      onClick={() => confirmDelete(item)}
                    >
                      消す
                    </button>
                  </div>
                </div>
                {item.description && <p>{item.description}</p>}
              </li>
            ))}
          </ol>
          {items.length === 0 && (
            <p className="empty-text">やることの内容はまだありません。</p>
          )}
        </section>

        <section className="fixed-notice">
          <p>{fixed_notice}</p>
        </section>

        {deleteTarget && (
          <div className="dialog-overlay" role="dialog" aria-modal="true">
            <div className="dialog-card">
              <p className="dialog-title">このやることを消しますか？</p>
              <div className="dialog-actions">
                <button type="button" className="btn-danger" onClick={handleDelete}>
                  消す
                </button>
                <button
                  type="button"
                  className="btn-secondary"
                  onClick={() => setDeleteTarget(null)}
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
