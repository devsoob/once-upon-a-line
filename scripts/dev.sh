#!/bin/bash

# Firebase 개발 환경 자동화 스크립트
# 사용법: ./scripts/dev.sh

set -e

# Pre-build: generate launcher icons if missing (avoid committing generated PNGs)
if ! ls android/app/src/main/res/mipmap-*/ic_launcher.png >/dev/null 2>&1; then
  echo "[prebuild] Generating launcher icons..."
  dart run flutter_launcher_icons >/dev/null 2>&1 || true
fi

echo "🛠️  Firebase 개발 환경 시작"

# Firebase 에뮬레이터 시작
echo "🔥 Firebase 에뮬레이터 시작 중..."
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data &

# 에뮬레이터가 시작될 때까지 잠시 대기
sleep 5

echo "✅ 개발 환경 준비 완료!"
echo "🌐 Firebase UI: http://localhost:4000"
echo "🔥 Firestore: http://localhost:8080"
echo "🔐 Auth: http://localhost:9099"
echo ""
echo "Flutter 앱을 실행하려면: flutter run -d chrome"
echo "에뮬레이터를 중지하려면: Ctrl+C"
