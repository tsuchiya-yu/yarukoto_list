import { Head, Link, useForm } from "@inertiajs/react";
import type { ChangeEvent, FormEvent } from "react";

import { PublicShell } from "@/components/PublicShell";
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

  return (
    <>
      <Head title={meta.title}>
        <meta name="description" content={meta.description} />
        <meta property="og:title" content={meta.og_title} />
        <meta property="og:description" content={meta.og_description} />
        <meta property="og:image" content={meta.og_image} />
        <meta property="twitter:card" content="summary_large_image" />
      </Head>
      <PublicShell>
        <section className="auth-card">
          <p className="section-label">会員の方</p>
          <h1>{meta.title}</h1>
          <p className="auth-description">{meta.description}</p>
          <form onSubmit={handleSubmit}>
            {errors.base && <p className="form-error">{errors.base}</p>}
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
              {errors.email && <p className="input-error">{errors.email}</p>}
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
              {errors.password && <p className="input-error">{errors.password}</p>}
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
