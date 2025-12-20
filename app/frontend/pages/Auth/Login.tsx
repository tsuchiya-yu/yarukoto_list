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
    email: string;
  };
}>;

export default function Login({ meta, form }: Props) {
  const { data, setData, post, processing, errors } = useForm({
    session: {
      email: form.email ?? "",
      password: ""
    }
  });

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    post("/login");
  };

  const handleSessionChange = (event: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = event.target;
    setData("session", { ...data.session, [name]: value });
  };

  return (
    <>
      <Seo meta={meta} />
      <PublicShell>
        <section className="auth-card">
          <p className="section-label">会員の方</p>
          <h1>{meta.title}</h1>
          <p className="auth-description">{meta.description}</p>
          <form onSubmit={handleSubmit}>
            <FormErrorMessages
              messages={errors.base}
              variant="form"
              keyPrefix="login-form"
            />
            <div className="form-field">
              <label htmlFor="login-email">メールアドレス</label>
              <input
                id="login-email"
                type="email"
                name="email"
                autoComplete="email"
                value={data.session.email}
                onChange={handleSessionChange}
                required
              />
              <FormErrorMessages messages={errors.email} keyPrefix="login-email" />
            </div>
            <div className="form-field">
              <label htmlFor="login-password">パスワード</label>
              <input
                id="login-password"
                type="password"
                name="password"
                autoComplete="current-password"
                value={data.session.password}
                onChange={handleSessionChange}
                required
              />
              <FormErrorMessages
                messages={errors.password}
                keyPrefix="login-password"
              />
            </div>
            <div className="auth-actions">
              <button type="submit" className="btn-primary" disabled={processing}>
                ログインする
              </button>
            </div>
          </form>
          <p className="auth-links">
            はじめての方は <Link href={routes.signup()}>はじめて使う</Link>
          </p>
        </section>
      </PublicShell>
    </>
  );
}
