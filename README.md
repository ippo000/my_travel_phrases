# 🍀 Ireland Travel Phrases

アイルランド旅行で使える実用的な英会話フレーズ集アプリです。アイルランドなまりの音声再生、AI翻訳、会話練習機能を搭載しています。

## ✨ 主な機能

### 📱 基本機能
- **カテゴリ別フレーズ集**: 挨拶、パブ、観光、交通、ショッピング、緊急時など
- **音声再生**: アイルランドなまり（en-IE）対応、オフライン動作
- **お気に入り機能**: よく使うフレーズを保存
- **検索機能**: 日本語・英語で検索可能
- **カスタムフレーズ**: ユーザー独自のフレーズを追加

### 🤖 AI機能（Gemini API）
- **AI翻訳**: 日本語からアイルランド英語への自動翻訳
- **AI会話練習**: アイルランド人との会話シミュレーション

## 🚀 セットアップ

### 前提条件
- Flutter SDK 3.8.1+
- Dart 3.0+
- Android Studio / VS Code

### インストール
```bash
# リポジトリをクローン
git clone <repository-url>
cd my_travel_phrases

# 依存関係をインストール
flutter pub get

# アプリを実行
flutter run
```

### AI機能の設定
1. [Google AI Studio](https://makersuite.google.com/app/apikey)でAPIキーを取得
2. **安全な方法でAPIキーを設定**（詳細は[SECURITY.md](SECURITY.md)参照）

#### 環境変数を使用（推奨）
```bash
# Windows
set GEMINI_API_KEY=your_api_key
flutter run --dart-define=GEMINI_API_KEY=%GEMINI_API_KEY%

# macOS/Linux
export GEMINI_API_KEY=your_api_key
flutter run --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

#### 開発時のみ
`lib/config/api_config.dart`の`_debugApiKey`に設定

## 📦 使用技術

### フレームワーク・言語
- **Flutter**: クロスプラットフォームアプリ開発
- **Dart**: プログラミング言語

### 主要パッケージ
- `flutter_tts: ^4.0.2` - 音声合成（オフライン対応）
- `google_generative_ai: ^0.4.3` - Gemini API連携
- `http: ^1.1.0` - HTTP通信

### AI・音声技術
- **Gemini Pro**: Google の生成AI
- **Text-to-Speech**: アイルランド英語音声
- **オフライン音声**: インターネット不要

## 🎯 対象ユーザー
- アイルランド旅行予定者
- 英語学習者
- アイルランド文化に興味がある方

## 📱 動作環境
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **インターネット**: AI機能のみ必要（基本機能はオフライン動作）

## 🔒 プライバシー
- 個人情報の収集なし
- データはローカル保存
- AI機能使用時のみ外部通信

## 📄 ライセンス
MIT License

## 🤝 コントリビューション
プルリクエストやイシューの報告を歓迎します。

---

**Sláinte!** 🍺 アイルランド旅行を楽しんでください！
