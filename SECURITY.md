# 🔒 APIキーの安全な管理方法

## 🚨 重要な注意事項
**APIキーは絶対にGitリポジトリにコミットしないでください！**

## 📋 推奨される管理方法

### 1. 環境変数を使用（推奨）
```bash
# Windows
set GEMINI_API_KEY=your_actual_api_key_here
flutter run --dart-define=GEMINI_API_KEY=%GEMINI_API_KEY%

# macOS/Linux
export GEMINI_API_KEY=your_actual_api_key_here
flutter run --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

### 2. 開発時の設定
`lib/config/api_config.dart`の`_debugApiKey`に一時的に設定：
```dart
static const String _debugApiKey = 'your_api_key_for_development_only';
```

### 3. 本番ビルド時
```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_production_api_key
```

## 🛡️ セキュリティベストプラクティス

### ✅ やるべきこと
- 環境変数でAPIキーを管理
- `.gitignore`でAPIキーファイルを除外
- 本番環境では必ず環境変数を使用
- APIキーの定期的な更新
- 使用量の監視

### ❌ やってはいけないこと
- ソースコードに直接APIキーを記述
- APIキーをGitにコミット
- APIキーをSlackやメールで共有
- 不要な権限を持つAPIキーの使用

## 🔧 トラブルシューティング

### APIキーが設定されていない場合
```
Exception: Gemini API key not configured
```
→ 環境変数または`_debugApiKey`を設定してください

### API使用量制限に達した場合
- [Google AI Studio](https://makersuite.google.com/)で使用量を確認
- 必要に応じて課金プランに変更

## 📞 サポート
APIキーの管理でお困りの場合は、プロジェクトのIssueで質問してください。
**ただし、実際のAPIキーは絶対に投稿しないでください！**