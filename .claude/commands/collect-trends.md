---
description: 관심 분야 명세 파일을 읽어 연구 동향 보고서를 생성합니다
argument-hint: <interests/파일경로>
---

`$ARGUMENTS`로 지정된 관심 분야 명세 파일을 읽고 연구 동향 조사를 수행하세요.

## 절차

1. `$ARGUMENTS`가 비어 있거나 파일이 존재하지 않으면, `Bash ls interests/`로 사용 가능한 명세 파일 목록을 사용자에게 보여주고 어떤 파일로 진행할지 묻고 중단하세요.
2. 파일이 존재하면 `research-trend-collector` 서브에이전트(Agent 도구, `subagent_type: research-trend-collector`)를 호출하면서 다음 정보를 전달하세요.
   - 명세 파일의 절대 경로 또는 리포 상대 경로
   - 출력은 `reports/<topic-slug>-<YYYY-MM-DD>.md` 규칙을 따라야 한다는 점
   - `CLAUDE.md`의 "보고서 표준 형식"을 준수해야 한다는 점
3. 보고서가 만들어지면 곧바로 `report-indexer` 서브에이전트(`subagent_type: report-indexer`)를 호출해 README의 인덱스 영역을 갱신하세요.
4. 두 단계가 끝나면 사용자에게 다음을 전달하세요.
   - 생성된 보고서 경로 (`reports/foo.md` 형식)
   - 핵심 동향 3~5줄 요약
   - README 인덱스 갱신 결과(추가/변경된 항목 수)
   - 추가 조사가 필요한 영역(있다면)

## 주의

- 보고서 작성·인덱스 갱신을 직접 하지 말고 반드시 서브에이전트에게 위임하세요(메인 컨텍스트 보호).
- 명세 파일을 임의로 수정하지 마세요. 사용자 의도가 모호하면 질문하세요.
