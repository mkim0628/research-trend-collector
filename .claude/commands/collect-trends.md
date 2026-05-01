---
description: 관심 분야 명세 파일을 읽어 연구 동향 보고서를 생성합니다
argument-hint: <interests/파일경로>
---

`$ARGUMENTS`로 지정된 관심 분야 명세 파일을 읽고, 아래 **8단계 순차 파이프라인**으로 연구 동향 보고서를 생성하세요.

## 준비

1. `$ARGUMENTS`가 비어 있거나 파일이 존재하지 않으면 `ls interests/`로 목록을 보여주고 중단하세요.
2. 명세 파일을 읽어 topic, slug, keywords, subtopics, time_range, venues, language를 파악합니다.
3. 오늘 날짜(`date +%Y-%m-%d`)와 slug로 출력 파일 경로를 결정합니다: `reports/<slug>-<YYYY-MM-DD>.md`

## Phase 1: 수집 (R1~R6, 반드시 순차 실행)

각 단계는 `general-purpose` 에이전트를 개별 호출합니다. **에이전트 하나 = 검색 주제 하나**. 보고서 작성은 하지 않으며, 찾은 논문 목록(제목·URL·Venue/Year·기여·수치)만 텍스트로 반환합니다. 에이전트 결과를 다음 단계로 전달하기 위해 메인 컨텍스트에 누적합니다.

R1이 끝난 뒤 R2, R2가 끝난 뒤 R3 순서로 하나씩 실행합니다.

**R1** — 서빙 시스템 최신 논문: vLLM·SGLang 업데이트, chunked prefill, prefix caching, speculative decoding, SLO-aware scheduling (time_range 기간, 면밀히 검색)

**R2** — KV 양자화·압축 최신 논문: 2-bit/1-bit KV quantization, low-rank SVD, mixed-precision, training-free compression (time_range 기간, 면밀히 검색)

**R3** — 토큰 축출·희소 어텐션 최신 논문: eviction policy, query-aware sparse attention, layer-wise/head-wise budget, RL-based eviction (time_range 기간, 면밀히 검색)

**R4** — 분산·분리 서빙 최신 논문: prefill-decode disaggregation, KV cache transfer, distributed KV pool, CXL/RDMA KV (time_range 기간, 면밀히 검색)

**R5** — 아키텍처 수준 KV 절감 최신 논문: MLA 및 변환 기법, cross-layer KV sharing, YOCO, NSA, TPA (time_range 기간, 면밀히 검색)

**R6** — 장문맥·오프로딩 최신 논문: 100K+ context KV 전략, CPU/NVMe KV offload, async prefetch, RAG×KV (time_range 기간, 면밀히 검색)

## Phase 2: 보고서 작성 (W1)

R1~R6 결과를 모두 프롬프트에 포함하여 `general-purpose` 에이전트를 한 번 호출합니다.
- CLAUDE.md의 "보고서 표준 형식" 8개 섹션을 작성합니다.
- 파일 저장 경로: `reports/<slug>-<YYYY-MM-DD>.md`
- Recent Work 표는 서브토픽별(A~G) 소제목 + 마크다운 표, Title 셀에 `[논문명](URL)` 링크 필수, 최소 35개 이상
- 기존 파일이 있으면 덮어씁니다.

## Phase 3: 인덱스 갱신 (I1)

`report-indexer` 서브에이전트(`subagent_type: report-indexer`)를 호출해 README의 `<!-- BEGIN: AUTO-INDEX -->` ~ `<!-- END: AUTO-INDEX -->` 구간을 갱신합니다.

## 완료 보고

- 생성된 보고서 경로
- 수록 논문 수
- README 인덱스 갱신 항목 수
- 추가 조사가 필요한 영역 (있다면)

## 주의

- R1~R6를 **동시에 실행하지 말고** 반드시 순차적으로 하나씩 실행하세요.
- 각 R 에이전트는 **검색만** 수행하고 파일을 저장하지 않습니다.
- W1만 보고서 파일을 저장합니다.
- 명세 파일을 수정하지 마세요.
