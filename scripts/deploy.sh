#!/bin/bash

# Firebase CLI 자동화 스크립트
# 사용법: ./scripts/deploy.sh [environment]

set -e

# Pre-build: ensure launcher icons exist
if ! ls android/app/src/main/res/mipmap-*/ic_launcher.png >/dev/null 2>&1; then
  echo "[prebuild] Generating launcher icons..."
  dart run flutter_launcher_icons >/dev/null 2>&1 || true
fi

ENVIRONMENT=${1:-production}
PROJECT_ID="once-upon-a-line"

echo "🚀 Firebase 배포 시작 - Environment: $ENVIRONMENT"

# Flutter 빌드
echo "📱 Flutter 웹 빌드 중..."
flutter build web --release

# Firebase 배포
echo "🔥 Firebase 배포 중..."
firebase deploy --project $PROJECT_ID

echo "✅ 배포 완료!"
echo "🌐 앱 URL: https://$PROJECT_ID.web.app"
