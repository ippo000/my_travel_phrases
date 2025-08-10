# セキュリティガイド

## APIキー管理

### 本番環境（推奨）
環境変数を使用してAPIキーを安全に管理:

```bash
# Windows
set GEMINI_API_KEY=your_actual_api_key
flutter run --dart-define=GEMINI_API_KEY=%GEMINI_API_KEY%

# macOS/Linux  
export GEMINI_API_KEY=your_actual_api_key
flutter run --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

### 開発環境のみ
`lib/config/api_config.dart`の`_debugApiKey`に直接設定可能。
**注意**: 本番では絶対に使用しない。

## プライバシー保護
- 個人情報収集なし
- フレーズデータはローカル保存
- AI機能使用時のみ外部通信
- ユーザーデータの暗号化不要（機密情報なし）

## セキュリティチェックリスト
- [ ] APIキーがソースコードにハードコードされていない
- [ ] 環境変数でAPIキーを管理
- [ ] HTTPSでAPI通信
- [ ] エラーメッセージに機密情報を含まない
- [ ] ローカルストレージのデータは非機密のみ