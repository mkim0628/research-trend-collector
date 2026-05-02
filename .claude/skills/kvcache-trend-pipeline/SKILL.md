---
name: kvcache-trend-pipeline
description: KV 캐시·LLM 추론 최적화 분야의 동향 보고서를 만들 때 따르는 커버리지 가이드. 서빙 시스템, KV 양자화·압축, 토큰 축출·희소 어텐션, 분산·분리 서빙, 아키텍처 수준 KV 절감, 장문맥·오프로딩의 6개 서브토픽을 빠짐없이 다루도록 한다. `interests/kv-cache-*` 같은 KV 캐시 관련 명세로 `/collect-trends`가 호출되거나 `research-trend-collector` 에이전트가 KV 캐시 토픽을 감지했을 때 따르세요.
---

KV 캐시 관련 동향 보고서를 만들 때 이 스킬의 **커버리지 요구사항과 산출물 규약**을 따른다. 일반 토픽 명세라면 이 스킬은 적용하지 않는다.

> 이 스킬은 "어떤 주제를 빠짐없이 다뤄야 하는가"를 정의한다. 검색·작성을 어떻게 분할 실행할지(단일 에이전트, 병렬 서브에이전트, 메인 컨텍스트에서 직접 검색 등)는 호출자가 토픽 규모와 시간 예산에 맞춰 결정한다. 과거 버전의 R1~R6 → W1 → I1 순차 강제는 timeout 문제로 폐기되었다.

## 준비

1. 호출 시 전달된 명세 파일 경로(예: `interests/kv-cache-optimization.md`)가 비어 있거나 존재하지 않으면 `ls interests/`로 후보를 보여주고 중단한다.
2. 명세 파일을 읽어 `topic`, `slug`, `keywords`, `subtopics`, `time_range`, `venues`, `language`를 파악한다.
3. 오늘 날짜(`date +%Y-%m-%d`)와 slug로 출력 파일 경로를 결정한다: `reports/<slug>-<YYYY-MM-DD>.md`.
4. **기존 보고서에서 이미 수집된 논문 목록을 추출한다.**
   - `reports/<slug>-*.md` 파일을 모두 읽어, `## 3. Recent Work` 섹션 마크다운 표에서 `[논문명](URL)` 패턴의 URL을 전부 수집한다.
   - 이 URL 목록을 `KNOWN_URLS`로 정의한다.
   - URL 정규화(trailing slash 제거, http/https 통일)를 수행해 중복을 정확히 탐지한다.
   - `KNOWN_URLS`가 비어 있으면 "첫 수집"으로 간주하고 제외 없이 진행한다.

## 커버리지: 6개 서브토픽

보고서는 아래 여섯 영역을 **모두** 다뤄야 한다. 한 영역에서 신규 논문이 0건이라도 "해당 기간 신규 없음"을 명시한다. 영역 사이에 중복되는 논문이 있으면 가장 어울리는 한 곳에만 배치한다.

- **A. 서빙 시스템** — vLLM·SGLang 업데이트, chunked prefill, prefix caching, speculative decoding, SLO-aware scheduling
- **B. KV 양자화·압축** — 2-bit/1-bit KV quantization, low-rank SVD, mixed-precision, training-free compression
- **C. 토큰 축출·희소 어텐션** — eviction policy, query-aware sparse attention, layer-wise/head-wise budget, RL-based eviction
- **D. 분산·분리 서빙** — prefill-decode disaggregation, KV cache transfer, distributed KV pool, CXL/RDMA KV
- **E. 아키텍처 수준 KV 절감** — MLA 및 변환 기법, cross-layer KV sharing, YOCO, NSA, TPA
- **F. 장문맥·오프로딩** — 100K+ context KV 전략, CPU/NVMe KV offload, async prefetch, RAG×KV

## 검색 실행 (자유)

검색 분할 방식은 호출자가 정한다. 권장 옵션:

- **단일 에이전트 일괄 검색** — 메인 컨텍스트가 작고 빠른 결과가 필요할 때.
- **병렬 서브에이전트** — 6개 서브토픽을 동시에 한 메시지에서 띄워 시간 단축. timeout 위험이 가장 낮은 방식.
- **메인 컨텍스트에서 직접 WebSearch/WebFetch** — 결과가 적거나 명세가 좁을 때.

어느 방식이든 다음을 지킨다.

- `KNOWN_URLS`가 비어 있지 않다면 검색 단계에 "이 URL들은 이미 수집됨 — 제외하고 새 논문만 반환하세요"를 명시적으로 전달한다.
- 각 논문에 대해 제목·URL·Venue/Year·1줄 기여·핵심 수치를 확보한다.
- `time_range` 밖의 자료는 인용 시 `(historical)`로 표시한다.

## 보고서 작성

신규 논문이 1건 이상이면 `reports/<slug>-<YYYY-MM-DD>.md`를 새로 생성한다(기존 파일 병합 금지).

- `CLAUDE.md`의 "보고서 표준 형식" 8개 섹션을 작성한다.
- `## 3. Recent Work`는 위 6개 영역(A~F)을 소제목으로 두고 각 영역마다 마크다운 표를 둔다. Title 셀은 `[논문명](URL)` 링크 필수, Contribution 셀은 한 줄 설명.
- 신규 논문이 0건이면 파일을 생성하지 않고 "신규 논문 없음"을 보고한다.

## 인덱스 갱신

보고서 파일이 새로 생성된 경우에만 `report-indexer` 서브에이전트(`subagent_type: report-indexer`)를 호출해 README의 `<!-- BEGIN: AUTO-INDEX -->` ~ `<!-- END: AUTO-INDEX -->` 구간을 갱신한다.

## 완료 보고

- 생성된 보고서 경로 (또는 "신규 없음")
- 신규 논문 수 / 기존 논문 수 / 총 논문 수
- 6개 서브토픽 중 신규가 0건인 영역
- README 인덱스 갱신 항목 수 (호출했다면)
- 추가 조사가 필요한 영역 (있다면)

## 주의

- 검색·작성·인덱싱을 **반드시 순차로** 실행하라는 강제는 없다. 토픽 규모에 맞춰 병렬화·분할을 자유롭게 선택한다.
- 카테고리(A~F) 자체는 변경 금지 — 빠짐없이 다뤄야 한다.
- 명세 파일은 수정하지 않는다.
