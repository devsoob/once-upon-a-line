#!/bin/bash

# Firebase CLI 자동화 스크립트
# 사용법: ./scripts/deploy.sh [environment]

set -e

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
