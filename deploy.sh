#!/usr/bin/env bash
set -euo pipefail

# 배포 소스(통합 HTML) -> Pages용 index.html 복사 후 커밋/푸시
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_HTML="${SCRIPT_DIR}/../주택관리사_기출문제_정답_25-28회.html"
TARGET_HTML="${SCRIPT_DIR}/index.html"

# 개별 기출문제를 기반으로 통합 HTML 파일(주택관리사_기출문제_정답_25-28회.html)을 자동 재생성합니다.
echo "기출문제 폴더의 개별 파일을 바탕으로 통합 HTML 파일을 재생성하는 중..."
python3 "${SCRIPT_DIR}/../regenerate.py"

if [[ ! -f "${SRC_HTML}" ]]; then
  echo "오류: 소스 파일을 찾을 수 없습니다: ${SRC_HTML}" >&2
  exit 1
fi

if [[ ! -d "${SCRIPT_DIR}/.git" ]]; then
  echo "오류: pages-site 폴더가 git 저장소가 아닙니다." >&2
  exit 1
fi

cd "${SCRIPT_DIR}"

cp "${SRC_HTML}" "${TARGET_HTML}"
echo "복사 완료: ${SRC_HTML} -> ${TARGET_HTML}"

if git diff --quiet -- "${TARGET_HTML}" && git diff --cached --quiet -- "${TARGET_HTML}"; then
  echo "변경사항이 없어 배포를 생략합니다."
  exit 0
fi

git add "${TARGET_HTML}"

COMMIT_MSG="${1:-Update GitHub Pages content ($(date '+%Y-%m-%d %H:%M:%S'))}"
git commit -m "${COMMIT_MSG}"
git push origin main

echo "배포 완료: https://sch0718.github.io/housing-manager-pages/"
