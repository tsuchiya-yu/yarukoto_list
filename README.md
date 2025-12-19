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

### Makefile ヘルパー

- `make dev` : `docker compose up web vite ssr`
- `make dev-mcp` : `yarn mcp:playwright`
- `make up` : `bin/dev_with_mcp`（docker compose + MCP を同時起動）
- `make down` : `docker compose down`
- `make shell` : `docker compose run --rm web bash`
- `make bundle` : `docker compose run --rm web bundle install`
- `make db-migrate` : `docker compose run --rm web bin/rails db:migrate`

## Playwright MCP でのブラウザ操作

自動ブラウザ操作を行うため、`@playwright/mcp` を devDependencies に追加し、Codex などの MCP クライアントから呼び出せる設定を整備しています。

- 設定ファイル: `mcp/playwright.config.json`  
  - Chromium をヘッドレスでない状態で起動し、`localhost` 以外には接続しないよう制限。  
  - 取得したスナップショットやトレースは `tmp/playwright-mcp` に保存されます。
- 起動コマンド: `yarn mcp:playwright`  
  - `mcp-server-playwright --config mcp/playwright.config.json` をラップしています。
- MCP クライアントへの登録例（Codex CLI の場合）:

  ```toml
  # ~/.codex/config.toml
  [mcp_servers.playwright]
  command = "yarn"
  args = ["mcp:playwright"]
  ```

コマンドを起動したままにしておくと、MCP 対応エージェントから Playwright の各種ツール（`browser_navigate` や `browser_click` など）を利用できます。ご利用中の環境に合わせて、上記の設定例を参考に `~/.codex/config.toml` などの MCP クライアント設定を調整してください。

## ドキュメント

- `docs/requirements.md` : 要件定義
- `docs/codex-constitution.md` : 実装ルール
- `AGENTS.md` : 運用ルール
