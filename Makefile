# Flutter Ireland Travel Phrases Makefile

.PHONY: help install clean build run emulator devices doctor

# デフォルトターゲット
help:
	@echo "利用可能なコマンド:"
	@echo "  make install    - 依存関係をインストール"
	@echo "  make clean      - ビルドキャッシュをクリア"
	@echo "  make build      - APKをビルド"
	@echo "  make run        - アプリを実行"
	@echo "  make emulator   - エミュレータを起動"
	@echo "  make devices    - 接続デバイスを確認"
	@echo "  make doctor     - Flutter環境を確認"

# 依存関係のインストール
install:
	flutter pub get

# ビルドキャッシュのクリア
clean:
	flutter clean
	flutter pub get

# APKビルド
build:
	flutter build apk --release

# アプリ実行
run:
	flutter run

# エミュレータ起動
emulator:
	flutter emulators --launch Medium_Phone_API_36.0

# 接続デバイス確認
devices:
	flutter devices

# Flutter環境確認
doctor:
	flutter doctor

# ログ確認
log:
# 	idevicesyslog.exe
	idevicesyslog.exe | findstr "com.ippo.my_travel_phrases"