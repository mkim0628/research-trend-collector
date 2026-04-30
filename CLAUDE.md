# Research Trend Collector

연구 동향을 체계적으로 조사·수집하기 위한 리포지토리입니다. 사용자는 관심 연구 분야를 기술한 명세 파일(YAML 또는 Markdown)을 작성하고, Claude는 해당 파일을 입력으로 받아 동향 조사 보고서를 생성합니다.

## 디렉터리 구조

- `interests/` — 사용자가 작성한 관심 분야 명세 파일 (YAML/MD)
- `reports/` — 에이전트가 생성한 조사 보고서 (자동 생성)
- `.claude/agents/research-trend-collector.md` — 동향 조사 에이전트 정의
- `.claude/commands/collect-trends.md` — 슬래시 커맨드 정의

## 워크플로우

1. `interests/` 아래에 관심 분야 명세 파일을 작성한다 (`interests/example.yaml` 참고).
2. 다음 중 한 가지 방법으로 조사를 시작한다.
   - 슬래시 커맨드: `/collect-trends interests/<파일명>`
   - 자연어: "interests/foo.yaml 에 적힌 주제로 동향 조사해줘"
3. Claude는 `research-trend-collector` 서브에이전트에게 작업을 위임한다.
4. 결과는 `reports/<topic-slug>-<YYYY-MM-DD>.md` 로 저장된다.

## 관심 분야 명세 파일 권장 필드

YAML과 Markdown 모두 지원한다. 형식이 자유롭더라도 가능하면 다음 필드를 포함한다.

| 필드 | 설명 |
| --- | --- |
| `topic` | 핵심 주제 (한 줄 요약) |
| `keywords` | 검색에 사용할 키워드 목록 |
| `subtopics` | 세부 관심 갈래 |
| `time_range` | 조사 대상 기간 (예: `2024-01 ~ 2026-04`) |
| `venues` | 우선 참고할 학회/저널 (NeurIPS, ICML, CVPR 등) |
| `exclusions` | 제외할 하위 주제 |
| `depth` | `overview` 또는 `deep` |
| `language` | 보고서 언어 (`ko` 또는 `en`) |

Markdown 명세 파일이라면 위 항목을 헤더와 불릿으로 자유롭게 기술해도 무방하다.

## 보고서 표준 형식

생성되는 보고서는 다음 섹션을 포함한다.

1. **Executive Summary** — 핵심 동향 3~5개
2. **Landscape** — 분야 지형도와 주요 접근법 분류
3. **Recent Work** — 시간 범위 내 주요 논문/프로젝트 (저자, 기관, 발표처, 핵심 기여, 링크)
4. **Open Problems** — 미해결 과제·논쟁점
5. **Notable Researchers / Groups** — 주도 연구자와 기관
6. **Resources** — 데이터셋, 코드, 벤치마크
7. **Reading List** — 입문 → 심화 순 추천 자료
8. **Methodology** — 사용한 검색 쿼리·출처 범위 (재현성)

## 작업 원칙

- 모든 사실 주장에는 출처(URL, arXiv ID, DOI 등)를 명시한다.
- `time_range` 밖의 자료를 인용할 때는 `(historical)` 등으로 표기한다.
- 확신이 없는 정보는 "확인 필요" 또는 추정 표시를 단다 — 환각을 만들지 않는다.
- 한 보고서는 단일 주제에 집중한다. 여러 분야가 섞이면 보고서를 분리한다.
- 경쟁·대안 접근도 균형 있게 다룬다.
