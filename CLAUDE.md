# Research Trend Collector

연구 동향을 체계적으로 조사·수집하기 위한 리포지토리입니다. 사용자는 관심 연구 분야를 기술한 명세 파일(YAML 또는 Markdown)을 작성하고, Claude는 해당 파일을 입력으로 받아 동향 조사 보고서를 생성합니다.

## 디렉터리 구조

- `interests/` — 사용자가 작성한 관심 분야 명세 파일 (YAML/MD)
- `reports/` — 일일 동향 보고서 (`<topic-slug>-<YYYY-MM-DD>.md`)
- `reports/deep-dives/` — 특정 논문·연구의 심층 분석 보고서 (`<paper-slug>.md`)
- `README.md` — 누적 결과를 주제별로 보여주는 자동 인덱스 (마커 사이만 갱신됨)
- `.claude/agents/`
  - `research-trend-collector.md` — 일일 동향 조사 에이전트
  - `paper-deep-dive.md` — 단일 논문 심층 분석 에이전트
  - `report-indexer.md` — README 인덱스 재생성 에이전트
- `.claude/commands/`
  - `collect-trends.md` — `/collect-trends`
  - `deep-dive.md` — `/deep-dive`
  - `index-reports.md` — `/index-reports`

## 워크플로우

### 일일 동향 조사
1. `interests/` 아래에 관심 분야 명세 파일을 작성한다 (`interests/example.yaml` 참고).
2. 다음 중 한 가지 방법으로 조사를 시작한다.
   - 슬래시 커맨드: `/collect-trends interests/<파일명>`
   - 자연어: "interests/foo.yaml 에 적힌 주제로 동향 조사해줘"
3. Claude는 `research-trend-collector` 서브에이전트에게 작업을 위임한다.
4. 결과는 `reports/<topic-slug>-<YYYY-MM-DD>.md`로 저장되고, 이어서 `report-indexer`가 README의 인덱스 영역을 자동 갱신한다.

### 특정 논문 심층 분석
1. `/deep-dive <논문 제목 | URL | arXiv ID | reports 항목 인용>` 또는 자연어로 "이 논문 자세히 분석해줘".
2. Claude는 `paper-deep-dive` 서브에이전트에게 작업을 위임한다.
3. 결과는 `reports/deep-dives/<paper-slug>.md`로 저장되고, 이어서 `report-indexer`가 README를 갱신한다.

### 인덱스만 재생성
- `/index-reports` 또는 자연어로 "README 인덱스 다시 만들어줘".
- `reports/`와 `reports/deep-dives/`를 스캔해 README의 마커 영역만 다시 그린다(보고서 본문은 변경하지 않음).

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

### 일일 동향 보고서 (`reports/<topic-slug>-<YYYY-MM-DD>.md`)

다음 YAML front matter로 시작한다(README 인덱서가 이 메타데이터를 파싱한다).

```yaml
---
type: trend-report
topic: "사람이 읽을 수 있는 토픽명"
slug: <topic-slug>
date: <YYYY-MM-DD>
source: interests/<file>
time_range: "<range>"
depth: <overview|deep>
language: <ko|en>
---
```

본문은 다음 섹션을 포함한다.

1. **Executive Summary** — 핵심 동향 3~5개
2. **Landscape** — 분야 지형도와 주요 접근법 분류
3. **Recent Work** — 시간 범위 내 주요 논문/프로젝트 표 (Title 셀에 마크다운 링크, Contribution 셀에 한 줄 설명을 둔다 — 인덱서가 이 두 셀을 파싱한다)
4. **Open Problems** — 미해결 과제·논쟁점
5. **Notable Researchers / Groups** — 주도 연구자와 기관
6. **Resources** — 데이터셋, 코드, 벤치마크
7. **Reading List** — 입문 → 심화 순 추천 자료
8. **Methodology** — 사용한 검색 쿼리·출처 범위 (재현성)

### 심층 분석 보고서 (`reports/deep-dives/<paper-slug>.md`)

다음 front matter로 시작한다.

```yaml
---
type: deep-dive
title: "<논문 정식 제목>"
slug: <paper-slug>
authors: ["<First Author>", "..."]
venue: "<NeurIPS 2025 등>"
year: <YYYY>
source_url: "<공식 PDF/arXiv abs URL>"
code_url: "<GitHub URL 또는 빈 값>"
parent_topic: "<관련 일반 토픽>"
date: <YYYY-MM-DD>
one_line_summary: "<한 줄 요약>"
---
```

본문은 다음 섹션을 포함한다(상세는 `paper-deep-dive` 에이전트 정의 참고).

1. TL;DR
2. 문제 정의
3. 핵심 아이디어
4. 방법 (모델/구조, 학습·추론 절차, 의사 코드)
5. 실험 (세팅, 주요 결과, Ablation)
6. 한계와 가정
7. 선행/경쟁 연구와의 차별점
8. 재현성 (코드, 데이터, 하드웨어, 라이선스)
9. 확장 아이디어 — 분석자 의견은 명시적으로 분리
10. 참고 문헌
11. Methodology — 인용한 페이지/섹션, 미확인 자료

## README 자동 인덱스

- README의 다음 마커 사이만 `report-indexer`가 자동으로 갱신한다. 마커 밖의 사용자 콘텐츠는 절대 변경되지 않는다.

  ```
  <!-- BEGIN: AUTO-INDEX -->
  ...
  <!-- END: AUTO-INDEX -->
  ```

- 인덱스는 토픽별로 묶이며 각 항목은 `[Paper Title](link) — 한 줄 설명` 형식이다. Deep-dive는 별도 섹션으로 분리해 표기한다.
- 동일 논문이 여러 보고서에 등장하면 가장 최근 보고서의 항목으로 통일하고 중복 제거한다.

## 작업 원칙

- 모든 사실 주장에는 출처(URL, arXiv ID, DOI 등)를 명시한다.
- `time_range` 밖의 자료를 인용할 때는 `(historical)` 등으로 표기한다.
- 확신이 없는 정보는 "확인 필요" 또는 추정 표시를 단다 — 환각을 만들지 않는다.
- 한 보고서는 단일 주제에 집중한다. 여러 분야가 섞이면 보고서를 분리한다.
- 경쟁·대안 접근도 균형 있게 다룬다.
