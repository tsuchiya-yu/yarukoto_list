import { Link, useForm } from "@inertiajs/react";
import type { ChangeEvent, FormEvent } from "react";

import { PublicShell } from "@/components/PublicShell";
import { Seo } from "@/components/Seo";
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

  const renderInputErrors = (messages?: string[]) =>
    messages?.map((message, index) => (
      <p key={`${message}-${index}`} className="input-error">
        {message}
      </p>
    ));

  const renderFormErrors = (messages?: string[]) =>
    messages?.map((message, index) => (
      <p key={`form-${message}-${index}`} className="form-error">
        {message}
      </p>
    ));

  return (
    <>
      <Seo meta={meta} />
      <PublicShell>
        <section className="auth-card">
          <p className="section-label">会員の方</p>
          <h1>{meta.title}</h1>
          <p className="auth-description">{meta.description}</p>
          <form onSubmit={handleSubmit}>
            {renderFormErrors(errors.base)}
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
              {renderInputErrors(errors.email)}
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
              {renderInputErrors(errors.password)}
            </div>
            <div className="auth-actions">
              <button type="submit" className="btn-primary" disabled={processing}>
                ログインする
              </button>
            </div>
          </form>
          <p className="auth-links">
            はじめての方は <Link href="/signup">はじめて使う</Link>
          </p>
        </section>
      </PublicShell>
    </>
  );
}
