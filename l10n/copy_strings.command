#!/bin/bash

# 현재 스크립트가 있는 위치로 이동
cd "$(dirname "$0")"

# 복사할 경로 설정
SRC_DIR="./strings_output"
DEST_DIR="../TimerStamp/Resources/L10N"

# 디렉토리 존재 여부 확인
if [ ! -d "$SRC_DIR" ]; then
  echo "❌ strings_output 폴더가 존재하지 않습니다: $SRC_DIR"
  exit 1
fi

mkdir -p "$DEST_DIR"

echo "📁 복사 중: $SRC_DIR → $DEST_DIR"
cp -R "$SRC_DIR/"* "$DEST_DIR/"

echo "✅ 복사 완료 (중복 파일은 덮어쓰기됨)"
