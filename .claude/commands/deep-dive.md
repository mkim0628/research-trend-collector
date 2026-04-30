---
description: 특정 논문/연구를 심층 분석해 reports/deep-dives 아래 저장하고 README 인덱스를 갱신합니다
argument-hint: <논문 제목 | arXiv ID | URL | reports 항목 인용>
---

`$ARGUMENTS`로 지정된 논문 또는 연구물을 심층 분석하세요.

## 절차

1. `$ARGUMENTS`가 비어 있으면 사용자에게 어떤 논문/URL을 분석할지 물어보고 중단하세요.
2. `paper-deep-dive` 서브에이전트(Agent 도구, `subagent_type: paper-deep-dive`)를 호출하면서 입력 인자를 그대로 전달하세요. 분석 보고서는 `reports/deep-dives/<slug>.md` 에 저장됩니다.
3. 보고서 작성이 끝나면 `report-indexer` 서브에이전트(`subagent_type: report-indexer`)를 호출해 README의 인덱스 영역을 갱신하세요.
4. 사용자에게 다음을 한국어로 간결히 보고하세요.
   - 생성된 deep-dive 보고서 경로
   - 한 줄 요약 + 가장 흥미로운 발견 1~2가지
   - README 인덱스 갱신 결과(추가/변경된 항목 수)

## 주의
- 본문 작성·인덱스 갱신을 직접 하지 말고 반드시 서브에이전트에 위임하세요(메인 컨텍스트 보호).
- 동일 슬러그의 분석이 이미 존재하면 paper-deep-dive 에이전트가 사용자에게 덮어쓰기/새 버전 여부를 물을 것이니 그 흐름을 그대로 전달하세요.
