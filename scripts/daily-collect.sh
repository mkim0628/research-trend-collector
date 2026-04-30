#!/usr/bin/env bash
# 매일 새벽 5시에 cron으로 호출되어 모든 interests/* 명세에 대해
# Claude Code의 /collect-trends 슬래시 커맨드를 비대화형으로 실행하는 러너.
#
# ──────────────────────────────────────────────────────────────────────────
# 설치 방법 (호스트에서 한 번만):
#   chmod +x scripts/daily-collect.sh
#   crontab -e
#   # 다음 한 줄 추가 (절대 경로!):
#   0 5 * * * /ABS/PATH/research-trend-collector/scripts/daily-collect.sh
#
# 환경 변수:
#   ANTHROPIC_API_KEY  — Claude Code가 인증에 사용 (또는 `claude` CLI에 미리 로그인)
#   BRANCH             — 푸시 대상 브랜치 (기본: claude/research-trend-agent-setup-dwP6M)
# ──────────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BRANCH="${BRANCH:-claude/research-trend-agent-setup-dwP6M}"
cd "$REPO_DIR"

LOG_DIR="$REPO_DIR/.logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/daily-$(date +%Y-%m-%d).log"
exec >>"$LOG_FILE" 2>&1

echo "=== $(date -Iseconds) daily collect start ==="

# 최신 상태 동기화 (충돌 시 그대로 진행하되 경고 로그 남김)
git fetch origin "$BRANCH" || echo "warn: fetch failed"
git checkout "$BRANCH" || echo "warn: checkout failed"
git pull --ff-only origin "$BRANCH" || echo "warn: pull failed"

# example.* 는 템플릿이므로 제외
shopt -s nullglob
specs=()
for spec in interests/*.yaml interests/*.md; do
  base="$(basename "$spec")"
  case "$base" in
    example.*) continue ;;
  esac
  specs+=("$spec")
done

if [[ ${#specs[@]} -eq 0 ]]; then
  echo "no interest specs found, exiting"
  exit 0
fi

# 비대화형 실행: Claude Code -p 모드 + 권한 우회
# (cron 환경에서는 권한 프롬프트에 응답할 수 없으므로 dangerously-skip-permissions 사용)
for spec in "${specs[@]}"; do
  echo "--- $(date -Iseconds) collecting: $spec ---"
  claude -p "/collect-trends $spec" \
    --dangerously-skip-permissions \
    || echo "FAILED: $spec"
done

# 산출물이 생겼으면 커밋·푸시
if [[ -n "$(git status --porcelain reports/ README.md 2>/dev/null)" ]]; then
  git add reports/ README.md
  git -c commit.gpgsign=false commit \
    -m "chore: daily trend collection $(date +%Y-%m-%d)" \
    || echo "warn: commit failed (no staged changes?)"
  git push origin "$BRANCH" || echo "warn: push failed"
else
  echo "no changes to commit"
fi

echo "=== $(date -Iseconds) done ==="
