# 開発ガイド

## プロジェクト構造
```
my_travel_phrases/
├── lib/
│   ├── main.dart                    # アプリエントリーポイント
│   ├── config/
│   │   └── api_config.dart         # Gemini API設定
│   ├── models/
│   │   ├── phrase.dart             # フレーズモデル
│   │   └── category.dart           # カテゴリモデル
│   ├── services/
│   │   ├── tts_service.dart        # 音声合成サービス
│   │   ├── ai_service.dart         # AI翻訳・会話サービス
│   │   └── storage_service.dart    # ローカルストレージ
│   ├── screens/
│   │   ├── home_screen.dart        # ホーム画面
│   │   ├── phrase_list_screen.dart # フレーズ一覧
│   │   ├── ai_chat_screen.dart     # AI会話練習
│   │   └── settings_screen.dart    # 設定画面
│   ├── widgets/
│   │   ├── phrase_card.dart        # フレーズカード
│   │   ├── category_tile.dart      # カテゴリタイル
│   │   └── audio_button.dart       # 音声再生ボタン
│   └── utils/
│       ├── constants.dart          # 定数定義
│       └── helpers.dart            # ヘルパー関数
├── assets/
│   ├── data/
│   │   └── phrases.json           # フレーズデータ
│   └── images/
└── test/
```

## 開発フロー
1. `flutter pub get` - 依存関係インストール
2. `flutter run` - アプリ実行
3. `flutter test` - テスト実行

## API設定
環境変数でGemini APIキーを設定:
```bash
set GEMINI_API_KEY=your_api_key
flutter run --dart-define=GEMINI_API_KEY=%GEMINI_API_KEY%
```

## 主要機能
- **基本**: フレーズ表示、音声再生、検索、お気に入り
- **AI**: 翻訳、会話練習、発音ガイド
- **オフライン**: 基本機能はインターネット不要