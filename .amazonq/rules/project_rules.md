# Ireland Travel Phrases - Project Rules

## プロジェクト概要
アイルランド旅行用英会話フレーズアプリ。Flutter/Dart製、Gemini AI連携、オフライン音声対応。

## 技術スタック
- **Framework**: Flutter 3.8.1+, Dart 3.0+
- **AI**: Google Gemini Pro API
- **TTS**: flutter_tts (アイルランド英語 en-IE)
- **HTTP**: http package
- **Storage**: ローカルストレージ

## アーキテクチャ
```
lib/
├── main.dart                 # エントリーポイント
├── config/
│   └── api_config.dart      # API設定
├── models/                  # データモデル
├── services/               # ビジネスロジック
├── screens/                # UI画面
├── widgets/                # 再利用可能コンポーネント
└── utils/                  # ユーティリティ
```

## コーディング規則
- **言語**: 日本語コメント、英語変数名
- **状態管理**: StatefulWidget + setState
- **非同期**: async/await
- **エラーハンドリング**: try-catch必須
- **セキュリティ**: APIキーは環境変数使用

## 機能要件
### 基本機能
- カテゴリ別フレーズ表示
- アイルランド英語音声再生
- お気に入り機能
- 検索機能
- カスタムフレーズ追加

### AI機能
- 日本語→アイルランド英語翻訳
- 会話練習シミュレーション
- カタカナ発音生成

## 制約事項
- オフライン基本機能必須
- AI機能のみオンライン
- プライバシー重視（データローカル保存）
- Android 5.0+, iOS 12.0+対応