---
description: 관심 분야 명세 파일을 읽어 연구 동향 보고서를 생성합니다
argument-hint: <interests/파일경로>
---

`$ARGUMENTS`로 지정된 관심 분야 명세 파일을 읽고, 아래 **8단계 순차 파이프라인**으로 연구 동향 보고서를 생성하세요.

## 준비

1. `$ARGUMENTS`가 비어 있거나 파일이 존재하지 않으면 `ls interests/`로 목록을 보여주고 중단하세요.
2. 명세 파일을 읽어 topic, slug, keywords, subtopics, time_range, venues, language를 파악합니다.
3. 오늘 날짜(`date +%Y-%m-%d`)와 slug로 출력 파일 경로를 결정합니다: `reports/<slug>-<YYYY-MM-DD>.md`
4. **기존 보고서에서 이미 수집된 논문 목록을 추출합니다.**
   - `reports/<slug>-*.md` 파일을 모두 읽어, `## 3. Recent Work` 섹션 마크다운 표에서 `[논문명](URL)` 패턴의 URL을 전부 수집합니다.
   - 이 URL 목록을 `KNOWN_URLS`로 정의합니다.
   - `KNOWN_URLS`가 비어 있으면 "첫 수집"으로 간주하고 제외 없이 진행합니다.

## Phase 1: 수집 (R1~R6, 반드시 순차 실행)

각 단계는 `general-purpose` 에이전트를 개별 호출합니다. **에이전트 하나 = 검색 주제 하나**. 보고서 작성은 하지 않으며, 찾은 논문 목록(제목·URL·Venue/Year·기여·수치)만 텍스트로 반환합니다. 에이전트 결과를 다음 단계로 전달하기 위해 메인 컨텍스트에 누적합니다.

R1이 끝난 뒤 R2, R2가 끝난 뒤 R3 순서로 하나씩 실행합니다.

**각 R 에이전트 프롬프트에 반드시 포함할 내용**:
- `KNOWN_URLS` 목록을 전달하며 "이 URL들은 이미 수집됨 — 제외하고 새 논문만 반환하세요"라고 명시합니다.
- `KNOWN_URLS`가 비어 있으면 해당 지시 생략.

**R1** — 서빙 시스템 최신 논문: vLLM·SGLang 업데이트, chunked prefill, prefix caching, speculative decoding, SLO-aware scheduling (time_range 기간, 면밀히 검색)

**R2** — KV 양자화·압축 최신 논문: 2-bit/1-bit KV quantization, low-rank SVD, mixed-precision, training-free compression (time_range 기간, 면밀히 검색)

**R3** — 토큰 축출·희소 어텐션 최신 논문: eviction policy, query-aware sparse attention, layer-wise/head-wise budget, RL-based eviction (time_range 기간, 면밀히 검색)

**R4** — 분산·분리 서빙 최신 논문: prefill-decode disaggregation, KV cache transfer, distributed KV pool, CXL/RDMA KV (time_range 기간, 면밀히 검색)

**R5** — 아키텍처 수준 KV 절감 최신 논문: MLA 및 변환 기법, cross-layer KV sharing, YOCO, NSA, TPA (time_range 기간, 면밀히 검색)

**R6** — 장문맥·오프로딩 최신 논문: 100K+ context KV 전략, CPU/NVMe KV offload, async prefetch, RAG×KV (time_range 기간, 면밀히 검색)

## Phase 2: 보고서 작성 (W1)

R1~R6 결과를 모두 프롬프트에 포함하여 `general-purpose` 에이전트를 한 번 호출합니다.
- CLAUDE.md의 "보고서 표준 형식" 8개 섹션을 작성합니다.
- **기존 보고서(`reports/<slug>-*.md` 중 가장 최근 파일)가 있으면 해당 파일을 읽어 기존 논문 표와 병합합니다.** 신규 논문은 각 서브섹션 표 상단에 추가합니다.
- 파일 저장 경로: `reports/<slug>-<YYYY-MM-DD>.md` (오늘 날짜로 새 파일 생성)
- Recent Work 표는 서브토픽별(A~G) 소제목 + 마크다운 표, Title 셀에 `[논문명](URL)` 링크 필수
- 기존 논문과 신규 논문을 합산한 총 논문 수를 완료 메시지에 포함합니다.

## Phase 3: 인덱스 갱신 (I1)

`report-indexer` 서브에이전트(`subagent_type: report-indexer`)를 호출해 README의 `<!-- BEGIN: AUTO-INDEX -->` ~ `<!-- END: AUTO-INDEX -->` 구간을 갱신합니다.

## 완료 보고

- 생성된 보고서 경로
- 신규 논문 수 / 기존 논문 수 / 총 논문 수
- README 인덱스 갱신 항목 수
- 추가 조사가 필요한 영역 (있다면)

## 주의

- R1~R6를 **동시에 실행하지 말고** 반드시 순차적으로 하나씩 실행하세요.
- 각 R 에이전트는 **검색만** 수행하고 파일을 저장하지 않습니다.
- W1만 보고서 파일을 저장합니다.
- 명세 파일을 수정하지 마세요.
- `KNOWN_URLS` 추출 시 URL 정규화(trailing slash 제거, http/https 통일)를 수행해 중복을 정확히 탐지합니다.
