import { Link, useForm } from "@inertiajs/react";
import type { ChangeEvent, FormEvent } from "react";

import { PublicShell } from "@/components/PublicShell";
import { Seo } from "@/components/Seo";
import { routes } from "@/lib/routes";
import type { PageProps } from "@/types/page";

type Meta = {
  title: string;
  description: string;
  og_title: string;
  og_description: string;
  og_image: string;
};

type Props = PageProps<{
  meta: Meta;
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

  const renderErrors = (messages?: string[]) =>
    messages?.map((message, index) => (
      <p key={`${message}-${index}`} className="input-error">
        {message}
      </p>
    ));

  return (
    <>
      <Seo meta={meta} />
      <PublicShell>
        <section className="auth-card">
          <p className="section-label">はじめての方</p>
          <h1>{meta.title}</h1>
          <p className="auth-description">{meta.description}</p>
          <form onSubmit={handleSubmit}>
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
              {renderErrors(errors.name)}
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
              {renderErrors(errors.email)}
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
              {renderErrors(errors.password)}
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
              {renderErrors(errors.password_confirmation)}
            </div>
            <div className="auth-actions">
              <button type="submit" className="btn-primary" disabled={processing}>
                はじめて使う
              </button>
            </div>
          </form>
          <p className="auth-links">
            すでにアカウントをお持ちの方は <Link href="/login">ログインする</Link>
          </p>
        </section>
      </PublicShell>
    </>
  );
}
