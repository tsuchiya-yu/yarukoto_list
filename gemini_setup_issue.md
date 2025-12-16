## 背景
Rails + Inertia.js + React で実装している「やることリスト」は、MVP要件を満たしながら短期間で改善サイクルを回す必要がある。現状は人力レビューに依存しており、UI文言やSSR品質、日本語コメントの徹底など Codex 憲法・AGENTS.md 固有のルールがレビュアーの属人化を招いている。Gemini Code Assist を導入し、一次情報（docs/requirements.md / docs/codex-constitution.md / AGENTS.md）を踏まえた自動レビューを整備して品質とスピードを両立させたい。

## 目的
- `Gemini Code Assist` を `yarukoto_list` に導入し、Pull Request 作成時に日本語の自動レビューを実行する体制を整える。
- プロジェクト固有の UI 表記ルールとアーキテクチャ方針（Rails + Inertia + React + SSR）を `.gemini/styleguide.md` に集約し、Gemini の指摘精度を高める。
- 重大度の高い論点（正確性、セキュリティ、UX崩れ、SSR品質）に集中し、軽微な好みの指摘を抑制する設定を `.gemini/config.yaml` に反映する。

## スコープ（入れる）
- `.gemini/` ディレクトリの新規作成。
- `Gemini Code Assist` GitHub App を `yarukoto_list` リポジトリにインストールし、必要な権限を付与。
- `.gemini/config.yaml` を作成し、レビューイベント・severity・ignore_paths・focus_areas を本リポジトリ向けに設定。
- `.gemini/styleguide.md` を作成し、一次情報を踏まえたレビュー観点（UI文言、Rails/React/TypeScript方針、SSR/SEO重視、MVPスコープの明記）を記述。

## スコープ（入れない）
- Rails/React アプリケーションコードの修正や機能追加。
- CI/CD（GitHub Actions 等）の大幅な改修。必要に応じたステータスチェック追加のみ行う。
- Gemini 以外の Bot 導入や複数 LLM の組み合わせ。

## 受け入れ条件（Acceptance Criteria）
- Pull Request 作成時に `Gemini Code Assist` が自動でレビューを実行し、結果が GitHub 上で確認できる。
- `.gemini/styleguide.md` に記載した禁止ワード（「TODO」「タスク」「テンプレート」「実行」「登録」等）や UI 固定文言の順守がレビューで確認される。
- `.gemini/config.yaml` の `ignore_paths` に設定した生成物（例：`node_modules/**`、`public/**`、`log/**` 等）がレビュー対象から除外される。
- 既存 CI・ブランチ保護ルールと競合せず、main ブランチへのマージフローに影響しない。

## 手動テスト手順
1. `yarukoto_list` リポジトリに `Gemini Code Assist` GitHub App をインストールし、読み取り/書き込み権限を付与する。
2. `.gemini/config.yaml` と `.gemini/styleguide.md` を追加したブランチを作成し、main ブランチに対して Pull Request を作成する。
3. Pull Request 作成直後に `Gemini Code Assist` のレビューコメント／サマリが表示されることを確認する。
4. `.gemini/styleguide.md` で禁止した UI 文言（例：「TODO」）を意図的に含む差分を追加し、Push 後の再レビューで指摘されることを確認する。
5. `ignore_paths` に含めたファイル（例：`public/**`）のみを変更したコミットでは、Gemini が指摘を出さないことを確認する。

## 依存関係
- `Gemini Code Assist` GitHub App へのインストール権限と `yarukoto_list` への書き込み権限。
- docs/requirements.md / docs/codex-constitution.md / AGENTS.md の内容を参照できること。
- main ブランチ保護ルールを変更できる管理者（Gemini のステータスを必須チェックに追加する場合）。

---

## 参考情報: やることリスト向け設定案

### `.gemini/config.yaml`（案）
重大度閾値は `MEDIUM` に設定し、LOW に分類される好み・軽微な指摘は抑制しつつも、保守性や品質に影響する指摘を確実に拾う。`ignore_paths` は生成物と巨大ディレクトリのみに絞り、テストコードや設定ファイルをレビュー対象に残す。
```yaml
have_fun: false
language: ja
code_review:
  disable: false
  comment_severity_threshold: MEDIUM
  max_review_comments: 6
  auto_approve: false
  pull_request_opened:
    help: true
    summary: true
    code_review: true
    generate_summary: true
  pull_request_updated:
    code_review: true
    incremental_review: true
  ignore_paths:
    - "coverage/**"
    - "node_modules/**"
    - "public/**"
    - "storage/**"
    - "tmp/**"
    - "log/**"
    - "vendor/**"
    - "ssr/dist/**"
    - "dist/**"
    - "*.snap"
  focus_areas:
    - correctness
    - accessibility
    - security
    - performance
    - ux_copy_consistency
  review_scope:
    - code_quality
    - architecture
    - naming_conventions
    - error_handling
    - seo
```
補足方針：
- テストコードはアプリケーション品質に直結するためレビュー対象に含める。
- スナップショットのような自動生成物のみ除外し、設定ファイル（Vite / PostCSS など）もレビュー対象に残す。
- Vite や PostCSS などの設定ファイルはプロダクトの挙動へ直結するため、原則レビュー対象とする。

### `.gemini/styleguide.md`（案）
```markdown
# やることリスト - Gemini Code Assist レビューガイドライン

## プロジェクト概要
日本の生活イベント「引越し」に特化したやることリストを Rails + Inertia.js + React で提供する。非ログインでも閲覧できる SEO 対象ページ（トップ / リスト一覧 / リスト詳細）と、ログイン後の自分用リスト管理が同居する。一次情報：docs/requirements.md、docs/codex-constitution.md、AGENTS.md。

## レビュー基本方針
- コメントは必ず日本語で、根拠→影響→最小修正案→（可能なら）サンプル差分の順で記述する。
- 重大度の高い指摘（正確性、セキュリティ、UX崩れ、SSR/SEO退行）を優先し、スタイルや個人の好みはまとめて提案。
- 同じ論点の蒸し返しや未変更行への重複指摘は禁止。

## UI文言・コピー運用
- docs/requirements.md の表記ルールを前提とし、ユーザー向け UI 文言では曖昧・内部用語的な単語の使用を避ける。
- 特に以下の単語は、**単独での使用を禁止**する。

  - 登録
  - 実行
  - TODO
  - タスク
  - テンプレート

- ただし、要件上・意味上必要な正式表現は例外として許容する。

  - 許容例:
    - 新規登録
    - 会員登録
  - 禁止例:
    - ボタン文言としての「登録」「登録する」

- 単独の「登録」が必要に見える場合は、文脈に応じて以下のように置き換える。
  - 作成
  - 追加
  - 保存
  - 申し込み

- 本ルールの目的は、ユーザーにとって意味が曖昧な操作名を排除し、行動内容が直感的に伝わる UI を維持することである。
- 固定文言（例：`自分用にする`、`やることを追加`、削除確認メッセージ）は変更しない。
- 注意書きは要件定義の文面を改変せずに表示する。

## 言語ルール
- コードコメント・コミットメッセージ・PR テンプレートは日本語（ライブラリ由来の英語コメントを除く）。
- 画面テキストも 40〜60 代ユーザーに伝わる語彙で統一。専門用語は補足する。

## Rails（バックエンド）
- Inertia レスポンスで必要なデータのみを渡す。不要な N+1 を避ける。
- Strong Parameters とモデルバリデーションでユーザー入力を検証する。
- 自分用リストの操作は current_user 限定で認可する。
- Service / Presenter を導入する場合は単一責任を保ち、fat controller を防ぐ。

## React / TypeScript（フロントエンド）
- 画面は関数コンポーネント + Hooks で実装し、Props の型定義を必須とする（`any` 禁止）。
- SSR 対象ページは初期データの null を避け、meta title/description を設定する。
- Loading / Error 状態を明示し、フォーム送信にはエラーハンドリングと disable 制御を入れる。
- UI 表記で禁止ワードを使用しないことを確認する。

## スタイリング・UX
- パステル調のグリーン/イエローを基調にし、余白多め・1画面1目的の原則に従う。
- 「自分用にする」ボタンなど主要な操作は視認性・アクセシビリティ（aria属性、キーボード操作）を確保。
- 削除ダイアログは指定文言（`このやることを消しますか？` 等）を使用。

## SEO / SSR
- トップ / リスト一覧 / リスト詳細の SSR を維持し、meta 情報、OGP を設定。
- Inertia の Head コンポーネント等で title/description を重複なく管理する。

## テスト
- Rails: RSpec 等でモデル・サービスの主要ロジックを検証し、コピー時の初期値（全件未完了）を担保する。
- React: vitest / Testing Library でフォーム入力、状態切り替え、アクセシビリティ属性をテスト。
- テストデータは実際のユースケース（引越しやること）に即した値を使う。

## セキュリティ
- CSRF 対策とセッション認証を尊重し、API を通じてユーザー ID を信頼しない。
- フォーム入力はサーバ側で再検証する。XSS・SQLインジェクションに注意。

## レビュー重点チェックリスト
- [ ] UI 文言が禁止ワードを含まず、固定文言と一致している。
- [ ] 公開リスト→自分用リストのコピー仕様（全件未完了、構成保持）が守られている。
- [ ] SSR 対象ページでメタ情報と Inertia SSR の動線が破壊されていない。
- [ ] Rails コントローラ/モデルで認可漏れ・Strong Parameters 漏れがない。
- [ ] React コンポーネントで未使用 Props/State や暗黙 any がない。
- [ ] エラー・ローディング状態、Form バリデーション、アクセシビリティ属性が実装されている。
- [ ] MVP スコープ外（通知/期日/共有/課金/AI 等）の機能が混入していない。
```
