import { Head } from "@inertiajs/react";

type Props = {
  message: string;
};

export default function Home({ message }: Props) {
  return (
    <>
      <Head title="トップ" />
      <main className="home-root">
        <section className="home-panel">
          <p className="home-badge">引越し準備の頼れる相棒</p>
          <h1>やることリスト</h1>
          <p className="home-lead">
            初めてでも「何をすればいいか」がすぐに分かるよう、
            引越し向けのやることを順番にまとめています。
          </p>
          <p className="home-message">{message}</p>
        </section>
      </main>
    </>
  );
}
