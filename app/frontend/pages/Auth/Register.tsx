import { Link, useForm } from "@inertiajs/react";
import type { ChangeEvent, FormEvent } from "react";

import { PublicShell } from "@/components/PublicShell";
import { FormErrorMessages } from "@/components/FormErrorMessages";
import { Seo, type SeoMeta } from "@/components/Seo";
import { routes } from "@/lib/routes";
import type { PageProps } from "@/types/page";

type Props = PageProps<{
  meta: SeoMeta;
  form: {
    name: string;
    email: string;
  };
}>;

export default function Register({ meta, form }: Props) {
  const { data, setData, post, processing, errors } = useForm({
    user: {
      name: form.name ?? "",
      email: form.email ?? "",
      password: "",
      password_confirmation: ""
    }
  });

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    post(routes.signup());
  };

  const handleUserChange = (event: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target;
    setData("user", { ...data.user, [name]: value });
  };

  return (
    <>
      <Seo meta={meta} />
      <PublicShell>
        <section className="auth-card">
          <p className="section-label">はじめての方</p>
          <h1>{meta.title}</h1>
          <p className="auth-description">{meta.description}</p>
          <form onSubmit={handleSubmit}>
            <FormErrorMessages
              messages={errors.base}
              variant="form"
              keyPrefix="register-form"
            />
            <div className="form-field">
              <label htmlFor="register-name">お名前</label>
              <input
                id="register-name"
                type="text"
                name="name"
                autoComplete="name"
                value={data.user.name}
                onChange={handleUserChange}
                required
              />
              <FormErrorMessages messages={errors.name} keyPrefix="register-name" />
            </div>
            <div className="form-field">
              <label htmlFor="register-email">メールアドレス</label>
              <input
                id="register-email"
                type="email"
                name="email"
                autoComplete="email"
                value={data.user.email}
                onChange={handleUserChange}
                required
              />
              <FormErrorMessages messages={errors.email} keyPrefix="register-email" />
            </div>
            <div className="form-field">
              <label htmlFor="register-password">パスワード</label>
              <input
                id="register-password"
                type="password"
                name="password"
                autoComplete="new-password"
                value={data.user.password}
                onChange={handleUserChange}
                required
              />
              <FormErrorMessages
                messages={errors.password}
                keyPrefix="register-password"
              />
            </div>
            <div className="form-field">
              <label htmlFor="register-password-confirmation">パスワード（確認）</label>
              <input
                id="register-password-confirmation"
                type="password"
                name="password_confirmation"
                autoComplete="new-password"
                value={data.user.password_confirmation}
                onChange={handleUserChange}
                required
              />
              <FormErrorMessages
                messages={errors.password_confirmation}
                keyPrefix="register-password-confirmation"
              />
            </div>
            <div className="auth-actions">
              <button type="submit" className="btn-primary" disabled={processing}>
                アカウント登録
              </button>
            </div>
          </form>
          <p className="auth-links">
            すでにアカウントをお持ちの方は <Link href={routes.login()}>ログイン</Link>
          </p>
        </section>
      </PublicShell>
    </>
  );
}
