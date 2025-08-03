# 🚀 クイックリリースガイド

## Google Play Store リリース手順（承認後即実行）

### ステップ1: アプリ作成（5分）
1. [Google Play Console](https://play.google.com/console/) にログイン
2. 「アプリを作成」をクリック
3. アプリ名: `Ireland Travel Phrases`
4. デフォルト言語: 日本語
5. アプリまたはゲーム: アプリ
6. 無料または有料: 無料

### ステップ2: ストア掲載情報（10分）
**アプリの詳細**
- アプリ名: `Ireland Travel Phrases`
- 簡単な説明: `アイルランド旅行で使える実用的な英会話フレーズをオフラインで学習`
- 詳しい説明: `app_store_info.md`の日本語版をコピペ

**グラフィック**
- アプリアイコン: `ireland_travel_phrases_icon_512x512.png`
- スクリーンショット: `screenshots/`フォルダの画像をアップロード

### ステップ3: アプリのコンテンツ（5分）
- プライバシーポリシー: `https://[username].github.io/ireland-travel-phrases/privacy_policy.html`
- 対象年齢: すべての年齢
- コンテンツレーティング: Everyone

### ステップ4: リリース（5分）
1. 「本番環境」→「新しいリリースを作成」
2. `build/app/outputs/bundle/release/app-release.aab` をアップロード
3. リリース名: `1.0.0`
4. リリースノート: `初回リリース - アイルランド旅行英会話フレーズ集`
5. 「審査に送信」をクリック

---

## App Store リリース手順（Mac環境）

### 事前準備
- Apple Developer アカウント承認済み
- XCodeClub レンタル準備完了
- `ios_build_instructions.md` 印刷またはブックマーク

### Mac環境での作業（30分）
1. プロジェクトをMacにクローン
2. `ios_build_instructions.md` に従ってビルド
3. App Store Connect でアプリ作成・設定
4. ビルドアップロード・審査提出

---

## 📋 承認通知が来たら即実行チェックリスト

### Google Play Store
- [ ] 上記手順でアプリ作成・設定（25分）
- [ ] 審査提出完了

### App Store  
- [ ] XCodeClub レンタル開始
- [ ] Mac環境でビルド・アップロード（30分）
- [ ] 審査提出完了

### 両方完了後
- [ ] SNS告知
- [ ] ブログ記事公開
- [ ] プレスリリース送信