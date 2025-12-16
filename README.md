# やることリスト（yarukoto_list）

初めての引越しでも「何からやればいいか」が分かるチェックリスト共有サービス向けのRails + Inertia + React構成です。詳細な仕様は `docs/requirements.md` と `docs/codex-constitution.md` を参照してください。

## 開発環境

- Ruby 3.3
- Node.js 20 + Vite
- PostgreSQL 16
- Docker / Docker Compose

## セットアップ

1. 環境変数をコピー  
   `cp .env.example .env`

2. イメージのビルド  
   `docker compose build`

3. 依存パッケージとDB初期化  
   `docker compose run --rm web bin/setup`

## 開発サーバーの起動

```
docker compose up web vite ssr
```

- Rails: http://localhost:3400
- Vite (HMR): http://localhost:5173
- Inertia SSR: http://localhost:13714

### Web Console の許可IP

開発環境では `config/environments/development.rb` で Web Console の許可IPを`127.0.0.1` や `172.16.0.0/12` などのプライベートレンジに限定しています。
Docker など別のレンジからアクセスしたい場合は、カンマ区切りで指定した`WEB_CONSOLE_ALLOWED_IPS` 環境変数を設定してください。

## 主要コマンド

- `docker compose run --rm web bin/rails db:migrate` : マイグレーション
- `docker compose run --rm web bin/rails db:seed` : seed投入
- `docker compose run --rm web bin/rails test` : テスト（未実装）

## フロントエンド構成

- `app/frontend/entrypoints` : Viteエントリーポイント
- `app/frontend/pages` : Inertiaページ（React + TypeScript）
- `ssr/server.tsx` : `@inertiajs/server` を使ったSSRサーバー

## ドキュメント

- `docs/requirements.md` : 要件定義
- `docs/codex-constitution.md` : 実装ルール
- `AGENTS.md` : 運用ルール
