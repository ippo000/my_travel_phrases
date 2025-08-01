# iOS ビルド手順（Mac環境用）

## 前提条件
- Xcode 最新版インストール済み
- Apple Developer アカウント登録済み
- 本プロジェクトをMacにクローン済み

## 1. プロジェクト設定

### Bundle Identifier設定
```bash
# ios/Runner.xcworkspace を Xcode で開く
open ios/Runner.xcworkspace
```

Xcodeで以下を設定：
- **Bundle Identifier**: `com.ireland.travel.phrases`
- **Display Name**: `Ireland Travel Phrases`
- **Version**: `1.0.0`
- **Build**: `1`

### Team設定
- Signing & Capabilities タブ
- Team を自分のApple Developer アカウントに設定
- Automatically manage signing にチェック

## 2. アプリアイコン設定

### アイコンファイル配置
```bash
# 1024x1024px のアイコンを以下に配置
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

### 必要なサイズ
- 1024x1024px (App Store用)
- 180x180px (iPhone用)
- 167x167px (iPad Pro用)
- 152x152px (iPad用)
- その他各サイズ

## 3. Info.plist設定

`ios/Runner/Info.plist` に以下を追加：

```xml
<key>CFBundleDisplayName</key>
<string>Ireland Travel Phrases</string>
<key>CFBundleLocalizations</key>
<array>
    <string>ja</string>
    <string>en</string>
</array>
<key>NSSpeechRecognitionUsageDescription</key>
<string>音声再生機能のためにシステム音声エンジンを使用します</string>
```

## 4. ビルドとアーカイブ

### デバッグビルド確認
```bash
flutter build ios --debug
```

### リリースビルド
```bash
flutter build ios --release
```

### Xcodeでアーカイブ
1. Xcode で Product → Archive
2. Organizer でアーカイブ確認
3. "Distribute App" をクリック
4. "App Store Connect" を選択
5. アップロード完了まで待機

## 5. App Store Connect設定

### アプリ情報入力
- アプリ名: Ireland Travel Phrases
- サブタイトル: アイルランド旅行英会話フレーズ集
- カテゴリ: Travel
- 年齢制限: 4+

### スクリーンショット
- iPhone 6.7": 1290x2796px
- iPhone 6.5": 1242x2688px
- iPad Pro 12.9": 2048x2732px

### アプリの説明
`app_store_info.md` の内容を使用

### プライバシー情報
- データ収集: なし
- 第三者との共有: なし
- 追跡: なし

## 6. 審査提出

### 最終チェック
- [ ] アプリ情報すべて入力済み
- [ ] スクリーンショット全サイズアップロード済み
- [ ] アプリアイコン1024x1024pxアップロード済み
- [ ] ビルドが正常にアップロード済み
- [ ] プライバシー情報入力済み

### 審査提出
1. "Submit for Review" をクリック
2. 審査質問に回答
3. 提出完了

## 7. 審査期間
- 通常1-7日
- 初回審査は時間がかかる場合あり
- リジェクトされた場合は修正して再提出

## トラブルシューティング

### 証明書エラー
```bash
# 証明書を再生成
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
```

### ビルドエラー
```bash
# Flutter クリーン
flutter clean
flutter pub get
cd ios
pod install
```

## 参考リンク
- [Flutter iOS deployment](https://docs.flutter.dev/deployment/ios)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)