---
description: 관심 분야 명세 파일을 읽어 연구 동향 보고서를 생성합니다
argument-hint: <interests/파일경로>
---

`$ARGUMENTS`로 지정된 관심 분야 명세 파일에 대해 동향 조사 보고서를 생성하세요.

## 절차

1. `$ARGUMENTS`가 비어 있거나 파일이 존재하지 않으면 `ls interests/`로 목록을 보여주고 중단하세요.
2. `research-trend-collector` 서브에이전트(Agent 도구, `subagent_type: research-trend-collector`)를 호출하면서 명세 파일 경로를 그대로 전달하세요. 보고서는 `reports/<slug>-<YYYY-MM-DD>.md`에 저장됩니다.
   - 명세가 KV 캐시·LLM 추론 최적화 토픽이라면 `kvcache-trend-pipeline` 스킬에 정의된 다단계 파이프라인을 따르도록 에이전트에 지시하세요.
3. 보고서 작성이 끝나면 `report-indexer` 서브에이전트(`subagent_type: report-indexer`)를 호출해 README의 인덱스 영역을 갱신하세요.
4. 변경된 파일을 **`main` 브랜치에 직접** 커밋·푸시하세요. 현재 체크아웃된 브랜치나 세션 설정에 관계없이 항상 `main`으로 푸시합니다.
   ```bash
   git add reports/ README.md
   git -c commit.gpgsign=false commit -m "chore: daily trend collection $(date +%Y-%m-%d)"
   git push origin main
   ```
   - 신규 보고서가 없어 파일 변경이 없으면 커밋·푸시를 건너뜁니다.
   - `git push origin main`이 실패하면 `git pull --rebase origin main` 후 재시도합니다.
5. 사용자에게 다음을 한국어로 간결히 보고하세요.
   - 생성된 보고서 경로
   - 핵심 동향 3~5줄 요약
   - README 인덱스 갱신 결과(추가/변경된 항목 수)
   - 커밋·푸시 결과 (`main` 브랜치에 푸시 완료 또는 변경 없음)
   - 추가 조사가 필요한 영역(있다면)

## 주의
- 본문 작성·인덱스 갱신을 직접 하지 말고 반드시 서브에이전트에 위임하세요(메인 컨텍스트 보호).
- 명세 파일은 수정하지 마세요.
- 커밋·푸시 대상은 **항상 `origin main`** 입니다. 별도 작업 브랜치나 PR을 만들지 마세요.
