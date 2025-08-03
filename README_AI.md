# AI機能の設定方法

## Gemini API キーの取得

1. [Google AI Studio](https://makersuite.google.com/app/apikey) にアクセス
2. Googleアカウントでログイン
3. 「Create API Key」をクリック
4. APIキーをコピー

## 設定方法

1. `lib/main.dart` の `apiKey` 変数に取得したAPIキーを設定
```dart
static const String apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

2. パッケージをインストール
```bash
flutter pub get
```

## AI機能

### 🤖 AI翻訳
- フレーズ追加時に日本語を入力後、✨ボタンで自動翻訳
- アイルランド英語に特化した自然な翻訳
- カタカナ発音も自動生成

### 💬 AI会話練習
- AppBarの🤖ボタンから会話練習開始
- アイルランド人との実際の会話をシミュレーション
- 観光地や文化について学習可能

## 注意事項

- AI機能はインターネット接続が必要
- APIキーは安全に管理してください
- 無料枠を超えると課金が発生する場合があります