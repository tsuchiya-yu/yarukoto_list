import { router, useForm } from "@inertiajs/react";
import {
  useCallback,
  useEffect,
  useRef,
  useState,
  type ChangeEvent,
  type FormEvent,
  type RefObject
} from "react";

import { FormErrorMessages } from "@/components/FormErrorMessages";
import { PublicShell } from "@/components/PublicShell";
import { Seo, type SeoMeta } from "@/components/Seo";
import { formatDate } from "@/lib/formatters";
import { routes } from "@/lib/routes";
import { useFocusTrap } from "@/lib/useFocusTrap";
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
  items_count: number;
  items: UserListItem[];
};

type Props = PageProps<{
  user_list: UserListDetail;
  fixed_notice: string;
  meta: SeoMeta;
}>;

type FormErrors = Record<string, string | string[] | undefined>;

type AddItemFormProps = {
  data: {
    user_list_item: {
      title: string;
      description: string;
    };
  };
  errors: FormErrors;
  processing: boolean;
  onChange: (
    event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => void;
  onSubmit: (event: FormEvent<HTMLFormElement>) => void;
};

const AddItemForm = ({
  data,
  errors,
  processing,
  onChange,
  onSubmit
}: AddItemFormProps) => (
  <section className="public-section">
    <header className="section-header">
      <p className="section-label">やることを追加</p>
      <h2>新しいやること</h2>
    </header>
    <form onSubmit={onSubmit} className="item-form">
      <FormErrorMessages
        messages={errors.base}
        variant="form"
        keyPrefix="user-list-item-form"
      />
      <div className="form-field">
        <label htmlFor="user-list-item-title">やること</label>
        <input
          id="user-list-item-title"
          name="title"
          value={data.user_list_item.title}
          onChange={onChange}
          placeholder="例：引越しの見積もりを取る"
        />
        <FormErrorMessages
          messages={errors.title}
          keyPrefix="user-list-item-title"
        />
      </div>
      <div className="form-field">
        <label htmlFor="user-list-item-description">補足（任意）</label>
        <textarea
          id="user-list-item-description"
          name="description"
          value={data.user_list_item.description}
          onChange={onChange}
          placeholder="必要ならメモを残せます"
          rows={3}
        />
        <FormErrorMessages
          messages={errors.description}
          keyPrefix="user-list-item-description"
        />
      </div>
      <button type="submit" className="btn-primary btn-compact" disabled={processing}>
        {processing ? "追加中..." : "やることを追加"}
      </button>
    </form>
  </section>
);

type UserItemsListProps = {
  items: UserListItem[];
  isReordering: boolean;
  updatingItemIds: number[];
  deletingItemId: number | null;
  onToggle: (itemId: number) => void;
  onMove: (index: number, direction: number) => void;
  onDelete: (item: UserListItem) => void;
};

const UserItemsList = ({
  items,
  isReordering,
  updatingItemIds,
  deletingItemId,
  onToggle,
  onMove,
  onDelete
}: UserItemsListProps) => (
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
              <p className="item-status">{item.completed ? "完了" : "未完了"}</p>
              <h3>{item.title}</h3>
            </div>
            <div className="item-actions">
              <button
                type="button"
                className="btn-secondary btn-compact"
                onClick={() => onToggle(item.id)}
                aria-pressed={item.completed}
                disabled={updatingItemIds.includes(item.id) || deletingItemId !== null}
              >
                {item.completed ? "未完了に戻す" : "完了にする"}
              </button>
              <button
                type="button"
                className="btn-ghost btn-compact"
                onClick={() => onMove(index, -1)}
                disabled={isReordering || deletingItemId !== null || index === 0}
              >
                上へ
              </button>
              <button
                type="button"
                className="btn-ghost btn-compact"
                onClick={() => onMove(index, 1)}
                disabled={
                  isReordering || deletingItemId !== null || index === items.length - 1
                }
              >
                下へ
              </button>
              <button
                type="button"
                className="btn-danger btn-compact"
                onClick={() => onDelete(item)}
                disabled={deletingItemId !== null}
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
);

type DeleteConfirmationDialogProps = {
  isOpen: boolean;
  dialogRef: RefObject<HTMLDivElement>;
  isDeleting: boolean;
  onDelete: () => void;
  onCancel: () => void;
};

const DeleteConfirmationDialog = ({
  isOpen,
  dialogRef,
  isDeleting,
  onDelete,
  onCancel
}: DeleteConfirmationDialogProps) => {
  if (!isOpen) {
    return null;
  }

  return (
    <div className="dialog-overlay" role="dialog" aria-modal="true">
      <div className="dialog-card" ref={dialogRef}>
        <p className="dialog-title">このやることを消しますか？</p>
        <div className="dialog-actions">
          <button
            type="button"
            className="btn-danger"
            onClick={onDelete}
            disabled={isDeleting}
          >
            {isDeleting ? "消しています..." : "消す"}
          </button>
          <button
            type="button"
            className="btn-secondary"
            onClick={onCancel}
            disabled={isDeleting}
          >
            そのままにする
          </button>
        </div>
      </div>
    </div>
  );
};

export default function UserListsShow({ user_list, fixed_notice, meta }: Props) {
  const [items, setItems] = useState(user_list.items);
  const [deleteTarget, setDeleteTarget] = useState<UserListItem | null>(null);
  const [updatingItemIds, setUpdatingItemIds] = useState<number[]>([]);
  const [isReordering, setIsReordering] = useState(false);
  const [deletingItemId, setDeletingItemId] = useState<number | null>(null);
  const dialogRef = useRef<HTMLDivElement | null>(null);
  const { data, setData, post, processing, reset, errors } = useForm({
    user_list_item: {
      title: "",
      description: ""
    }
  });

  const handleFormChange = useCallback(
    (event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      const { name, value } = event.target;
      setData((currentData) => ({
        ...currentData,
        user_list_item: {
          ...currentData.user_list_item,
          [name]: value
        }
      }));
    },
    [setData]
  );

  useEffect(() => {
    setItems(user_list.items);
  }, [user_list.items]);

  const closeDeleteDialog = useCallback(() => setDeleteTarget(null), []);

  useFocusTrap(Boolean(deleteTarget), dialogRef, closeDeleteDialog);

  const handleSubmit = useCallback(
    (event: FormEvent<HTMLFormElement>) => {
      event.preventDefault();
      post(routes.userListItems(user_list.id), {
        preserveScroll: true,
        onSuccess: () => reset()
      });
    },
    [post, reset, user_list.id]
  );

  const handleToggle = useCallback(
    (itemId: number) => {
      const target = items.find((item) => item.id === itemId);
      if (!target) {
        return;
      }

      const nextCompleted = !target.completed;
      setItems((currentItems) =>
        currentItems.map((item) =>
          item.id === itemId ? { ...item, completed: nextCompleted } : item
        )
      );

      router.patch(
        routes.userListItem(user_list.id, itemId),
        { user_list_item: { completed: nextCompleted } },
        {
          preserveScroll: true,
          onStart: () => {
            setUpdatingItemIds((ids) => [...ids, itemId]);
          },
          onFinish: () => {
            setUpdatingItemIds((ids) => ids.filter((id) => id !== itemId));
          },
          onError: () => {
            setItems((currentItems) =>
              currentItems.map((item) =>
                item.id === itemId
                  ? { ...item, completed: !nextCompleted }
                  : item
              )
            );
          }
        }
      );
    },
    [items, user_list.id]
  );

  const handleMove = useCallback(
    (index: number, direction: number) => {
      const targetIndex = index + direction;
      if (targetIndex < 0 || targetIndex >= items.length) {
        return;
      }

      const previousItems = items;
      const nextItems = [...items];
      const [moved] = nextItems.splice(index, 1);
      nextItems.splice(targetIndex, 0, moved);
      setItems(nextItems);

      router.patch(
        routes.userListItemsReorder(user_list.id),
        { item_ids: nextItems.map((item) => item.id) },
        {
          preserveScroll: true,
          onStart: () => setIsReordering(true),
          onFinish: () => setIsReordering(false),
          onError: () => setItems(previousItems)
        }
      );
    },
    [items, user_list.id]
  );

  const confirmDelete = useCallback((item: UserListItem) => {
    setDeleteTarget(item);
  }, []);

  const handleDelete = useCallback(() => {
    if (!deleteTarget) {
      return;
    }

    const targetId = deleteTarget.id;
    const previousItems = items;

    setDeletingItemId(targetId);
    setItems((currentItems) =>
      currentItems.filter((item) => item.id !== targetId)
    );
    setDeleteTarget(null);

    router.delete(routes.userListItem(user_list.id, targetId), {
      preserveScroll: true,
      onError: () => setItems(previousItems),
      onFinish: () => setDeletingItemId(null)
    });
  }, [deleteTarget, items, user_list.id]);

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

        <AddItemForm
          data={data}
          errors={errors}
          processing={processing}
          onChange={handleFormChange}
          onSubmit={handleSubmit}
        />

        <UserItemsList
          items={items}
          isReordering={isReordering}
          updatingItemIds={updatingItemIds}
          deletingItemId={deletingItemId}
          onToggle={handleToggle}
          onMove={handleMove}
          onDelete={confirmDelete}
        />

        <section className="fixed-notice">
          <p>{fixed_notice}</p>
        </section>

        <DeleteConfirmationDialog
          isOpen={Boolean(deleteTarget)}
          dialogRef={dialogRef}
          isDeleting={deletingItemId !== null}
          onDelete={handleDelete}
          onCancel={closeDeleteDialog}
        />
      </PublicShell>
    </>
  );
}
