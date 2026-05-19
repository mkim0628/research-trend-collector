---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-19
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-19)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview

## 1. Executive Summary

- **정적 그래프 서빙 시스템의 KV 캐시 운동 정규화** — Static-graph LLM 디코더의 불규칙한 KV 캐시 접근 패턴을 블록 페이저와 병합 스테이지 전송으로 제어하는 KV-RM이 제안됨 [2605.09735]
- **추측 디코딩 지연 모델화** — Little's Law 기반의 해석 가능한 지연 모델이 vLLM 실제 서빙 환경에서의 투기적 디코딩 동작을 정확히 예측함 [2605.15051]
- **헤드 재정렬·오프라인 캘리브레이션 기반 저랭크 KV 압축** — Key·Value의 역할 차이를 반영해 Key는 HSR(헤드 유사도 기반 재정렬+그룹 SVD), Value는 OVC(오프라인 캘리브레이션)로 각각 압축하는 ReCalKV가 기존 저랭크 방법을 압도 [2505.24357]
- **다중 에이전트 온-디바이스 KV 핸드오프** — 에이전트 간 전체 재prefill 없이 혼합 정밀도 KV 캐시를 CacheCard 형태로 전달하는 QKVShare로 멀티홉 추론 TTFT 단축 [2605.03884]
- **다계층 KV 캐시 관리로 장문맥 서빙 확장** — GPU HBM · CPU DRAM · NVMe SSD를 포괄하는 KVDrive가 파이프라인 재구성과 교차 계층 조율로 최대 1.74× 처리량 향상 달성 [2605.18071]
- **추론 체인-of-thought KV 오프로딩의 제로-근사-오류** — HBM 부족분을 CPU DDR에 전달하고 매 어텐션 전 prefetch하면 영구 축출 없이 정확도를 완전 보존한다는 수학적 증명 [2605.09490]

## 2. Landscape

### 분야 지형도

KV 캐시 최적화 연구는 2026년 5월 현재 여섯 개의 방향으로 분화되어 있으며 서로 보완 관계를 형성한다.

**A. 서빙 시스템 레이어**

정적 그래프(CUDA Graph) 실행 모델에서 동적인 KV 캐시 관리를 결합하는 문제가 새로운 과제로 부상했다. KV-RM [2605.09735]은 PagedAttention 방식의 논리-물리 분리를 정적 그래프 환경에 적용하며, 추측 디코딩(speculative decoding)의 지연 특성을 실측 기반으로 모델화하는 연구 [2605.15051]도 등장했다. vLLM v1, SGLang 등 주요 프레임워크들이 이미 chunked prefill, prefix caching, P/D 분리 등을 지원하면서 시스템 레이어의 경쟁이 격화되고 있다.

**B. KV 양자화·압축**

스칼라 양자화(INT8/FP8/INT4)와 벡터 양자화(VQ) 외에 저랭크 SVD 기반 압축이 2026년 들어 활성화되었다. 특히 Key와 Value가 어텐션 메커니즘에서 다른 역할을 한다는 점에 착안한 비대칭 압축 방식(ReCalKV, SVDq 등)이 주목받고 있다.

**C. 토큰 축출·희소 어텐션**

중요도 기반 축출 연구는 포화 상태에 근접했으며, 이제는 단순 attention score 합산을 넘어 value projection 출력 오류(LaProx, CAOTE), 학습 기반 정책(LKV, RL eviction) 등 더 정확한 중요도 측정 방법이 경쟁하고 있다. 이번 주기에는 KNOWN_URLS 포함 논문 외 별도의 신규 진입이 확인되지 않았다.

**D. 분산·분리 서빙**

Prefill-Decode(P/D) 분리가 표준 아키텍처로 정착되면서 멀티 에이전트, 멀티 모델, 크로스-데이터센터로 분리 범위가 확장되고 있다. QKVShare [2605.03884]는 엣지 디바이스의 멀티 에이전트 시나리오로 분리 서빙 개념을 확장한다.

**E. 아키텍처 수준 KV 절감**

DeepSeek-V2 MLA, YOCO, Cross-Layer Attention(CLA), Tensor Product Attention(TPA) 등이 2025년에 집중 발표된 후 이번 주기(2026-05-16 ~ 2026-05-19)에는 E 영역의 신규 arXiv 논문이 확인되지 않았다.

**F. 장문맥·오프로딩**

100K+ 컨텍스트에서 GPU HBM 한계를 넘기 위한 CPU/NVMe 오프로딩 연구가 활발하다. KVDrive [2605.18071]는 시스템 관점에서 세 계층을 통합 조율하고, Not All Thoughts Need HBM [2605.09490]은 추론(reasoning) 체인-of-thought KV를 CPU DDR로 이동해도 정확도가 보존된다는 이론적 근거를 제시한다.

## 3. Recent Work

### A. 서빙 시스템

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|--------------|------|
| 2026 | [KV-RM: Regularizing KV-Cache Movement for Static-Graph LLM Serving](https://arxiv.org/abs/2605.09735) | Zhiqing Zhong et al. | arXiv | 정적 그래프 디코더에서 블록 페이저와 병합 스테이지 전송 경로로 불규칙한 KV 접근을 정규화, 고정 형상 어텐션 커널과 호환 | arXiv:2605.09735 |
| 2026 | [An Interpretable Latency Model for Speculative Decoding in LLM Serving](https://arxiv.org/abs/2605.15051) | (저자 미확인) | arXiv | Little's Law로 유효 배치 크기를 추론하고 prefill·draft·verification 수요를 분해, vLLM 실측으로 검증한 해석 가능 지연 모델 | arXiv:2605.15051 |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|--------------|------|
| 2026 | [ReCalKV: Low-Rank KV Cache Compression via Head Reordering and Offline Calibration](https://arxiv.org/abs/2505.24357) | Xianglong Yan et al. (Shanghai Jiao Tong Univ.) | arXiv | Key에 HSR(헤드 유사도 재정렬+그룹 SVD), Value에 OVC(오프라인 캘리브레이션) 적용; LLaMA-2-7B 50% 압축 시 정확도 하락 2% 미만 | arXiv:2505.24357 |

### C. 토큰 축출·희소 어텐션

이번 보고서 기간(2026-05-16 ~ 2026-05-19) 중 KNOWN_URLS/KNOWN_TITLES에 포함되지 않는 신규 논문은 확인되지 않았다. 직전 보고서에서 다룬 LaProx [2605.07234], LKV [2605.06676], Make Each Token Count [2605.09649], Louver [2605.06763] 등이 이 영역의 최신 상태를 대표한다.

### D. 분산·분리 서빙

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|--------------|------|
| 2026 | [QKVShare: Quantized KV-Cache Handoff for Multi-Agent On-Device LLMs](https://arxiv.org/abs/2605.03884) | Pratik Honavar, Tejpratap GVSL | arXiv | 엣지 멀티 에이전트에서 전체 재prefill 없이 토큰별 혼합 정밀도 KV를 CacheCard로 전달; Llama-3.1-8B GSM8K에서 TTFT 단축 | arXiv:2605.03884 |

### E. 아키텍처 수준 KV 절감

이번 보고서 기간(2026-05-16 ~ 2026-05-19) 중 E 영역의 신규 arXiv 논문은 확인되지 않았다. YOCO++ [2604.13556], Latent-Condensed Transformer [2604.12452] 등 4월 논문이 이 영역의 최신 상태를 대표한다.

### F. 장문맥·오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|--------------|------|
| 2026 | [KVDrive: A Holistic Multi-Tier KV Cache Management System for Long-Context LLM Inference](https://arxiv.org/abs/2605.18071) | Jian Lin et al. | arXiv | GPU HBM·CPU DRAM·NVMe SSD 세 계층을 어텐션 패턴 적응·파이프라인 재구성·교차 계층 조율로 통합, 최대 1.74× 처리량 향상 | arXiv:2605.18071 |
| 2026 | [Not All Thoughts Need HBM: Semantics-Aware Memory Hierarchy for LLM Reasoning](https://arxiv.org/abs/2605.09490) | Aojie Yuan, Tianqi Shen, Dajun Zhang | arXiv | 추론 CoT KV를 HBM·DDR·압축·축출 4계층으로 분류; 영구 축출 비율만이 정확도를 결정한다는 제로-근사-오류 오프로딩 이론 수립 | arXiv:2605.09490 |

## 4. Open Problems

- **정적 그래프와 동적 KV 관리의 공존**: KV-RM은 한 방향을 제시했지만 PagedAttention 수준의 범용 해결책은 아직 부재. CUDA Graph 환경에서 가변 길이 요청을 처리하는 통합 프레임워크가 필요하다.
- **추측 디코딩 + KV 압축의 결합 효과**: 추측 디코딩은 초안(draft) 모델의 별도 KV 캐시를 필요로 하므로, target 모델 KV를 압축했을 때 검증(verification) 단계에서 오차가 어떻게 누적되는지에 대한 연구가 부족하다.
- **CoT 추론에서의 KV 오프로딩 한계**: Not All Thoughts Need HBM은 정확도 보존을 증명했지만 PCIe 대역폭 병목 문제는 여전히 남아 있다. CPU DDR 용량도 수백만 토큰 컨텍스트에서는 한계에 도달할 수 있다.
- **멀티 에이전트 KV 핸드오프 표준화**: QKVShare는 HuggingFace 호환 경로를 제시했으나, 서로 다른 모델 아키텍처(GQA vs. MLA 등) 간 KV 형식 변환 없는 핸드오프는 미해결 문제다.
- **아키텍처 수준 KV 절감의 서빙 시스템 통합**: MLA, YOCO 등 새 아키텍처가 확산됨에 따라 vLLM·SGLang 등 기존 프레임워크가 MHA와 MLA를 동시에 효율적으로 지원하는 방법에 대한 연구가 필요하다.

## 5. Notable Researchers / Groups

- **Jian Lin et al.** — KVDrive 저자; GPU-DRAM-SSD 통합 계층 관리 시스템 연구
- **Zhiqing Zhong, Xiaodong Yu et al.** — KV-RM 저자; 정적 그래프 서빙 시스템 내 KV 캐시 운동 정규화 연구
- **Xianglong Yan, Yulun Zhang (Shanghai Jiao Tong Univ.)** — ReCalKV 저자; 저랭크 KV 압축 및 SVD 기반 비대칭 압축 연구
- **Aojie Yuan, Tianqi Shen, Dajun Zhang** — Not All Thoughts Need HBM 저자; 추론 LLM KV 오프로딩의 이론적 기반 구축
- **Pratik Honavar, Tejpratap GVSL** — QKVShare 저자; 엣지 멀티 에이전트 KV 핸드오프 연구

## 6. Resources

- **Datasets / Benchmarks**:
  - RULER (장문맥 평가 벤치마크) — KV 축출·압축 평가에 광범위하게 활용
  - LongBench — 장문맥 이해 태스크 모음
  - GSM8K — 수학 추론, 멀티 에이전트 KV 핸드오프 평가에 사용 (QKVShare)
  - Needle-In-A-Haystack — 장문맥 검색 정확도 평가
  - OASST2-4k — 멀티턴 대화 평가

- **Code**:
  - KVDrive: 코드 미공개(확인 필요)
  - ReCalKV: arXiv 논문 참조, 코드 링크 미확인
  - QKVShare: HuggingFace 호환 cache injection path 제공 (코드 링크 확인 필요)
  - Not All Thoughts Need HBM: 코드 미공개(확인 필요)
  - KV-RM: 코드 미공개(확인 필요)

- **관련 프레임워크**:
  - [vLLM](https://github.com/vllm-project/vllm) — PagedAttention·추측 디코딩 구현의 실측 환경 (2605.15051)
  - [SGLang](https://github.com/sgl-project/sglang) — RadixAttention 기반 prefix caching

## 7. Reading List

1. (입문) Kwon et al., "Efficient Memory Management for Large Language Model Serving with PagedAttention," SOSP 2023 — KV 캐시 가상 메모리의 출발점
2. (입문) Zheng et al., "SGLang: Efficient Execution of Structured Language Model Programs," 2024 — RadixAttention 기반 prefix 캐시 재사용
3. (중간) ReCalKV [arXiv:2505.24357] — Key·Value 비대칭 저랭크 압축의 최신 접근
4. (중간) KV-RM [arXiv:2605.09735] — 정적 그래프 서빙 환경의 KV 관리 정규화
5. (심화) KVDrive [arXiv:2605.18071] — GPU·DRAM·SSD 통합 계층 KV 관리의 시스템 설계
6. (심화) Not All Thoughts Need HBM [arXiv:2605.09490] — 제로-근사-오류 오프로딩의 이론적 증명과 4계층 분류

## 8. Methodology

### 사용한 검색 쿼리

```
1. arxiv KV cache LLM inference serving system 2026 May site:arxiv.org
2. arxiv KV cache quantization compression LLM 2026 May new
3. arxiv token eviction sparse attention KV cache LLM May 2026
4. arxiv disaggregated prefill decode KV cache distributed serving 2026 May
5. arxiv KV cache architecture MLA cross-layer sharing long context May 2026
6. arxiv 2605 KV cache offloading long context CPU NVMe LLM inference May 2026
7. arxiv 2605 LLM serving vLLM SGLang prefill chunked speculative decoding May 2026
8. "KV cache" arxiv 2605 2026 new paper LLM attention
9. arxiv 2605.18071 KVDrive multi-tier KV cache management long-context
10. arxiv 2605 KV cache budget allocation head-wise layer-wise LLM 2026 new paper
11. arxiv 2605 KV cache quantization vector quantization LLM inference 2026 new
12. arxiv 2605 KV cache disaggregated serving distributed KV pool RDMA 2026
13. arxiv 2605 KV cache new paper May 16 17 18 19 2026 LLM inference optimization
14. arxiv 2605 KV cache mixed precision training-free low-rank SVD compression LLM 2026
15. arxiv 2605 LLM speculative decoding KV cache optimization 2026 May
16. arxiv 2605 KV cache LLM new submission week May 12-19 2026
17. arxiv 2605 KV cache prefill decode disaggregation distributed system new paper 2026
```

### 스캔 출처

- arXiv (cs.LG, cs.CL, cs.DC, cs.AR, cs.OS)
- 웹 검색 기반 최신 논문 발굴
- 직전 보고서(`reports/kv-cache-optimization-2026-05-18.md`) KNOWN_URLS 집합 대조

### 신규성 필터링 적용

- 필터링 기준: 직전까지의 보고서에서 수집된 URL 집합(KNOWN_URLS, 196건+)과 매칭된 항목을 제외하고 신규 항목만 보고서에 포함
- 신규 논문 6건 / 필터링으로 제외된 기존 항목 다수(LaProx, LKV, Louver, Tutti, SpecKV, FibQuant 등)

### 가정 및 한계

- **time_range**: 명세에 `2023-01 ~ 2026-04`로 명시되어 있으나, 신규성 우선 원칙에 따라 2026-05-16~19 기간 신규 논문을 중심으로 수집
- **C 영역(토큰 축출·희소 어텐션)**: 이번 주기에 신규 arXiv 논문이 식별되지 않음; 직전 보고서의 LaProx, LKV, Make Each Token Count 등이 최신 상태
- **E 영역(아키텍처 수준 KV 절감)**: 이번 주기에 신규 arXiv 논문이 식별되지 않음; YOCO++, MHA2MLA 등 이전 보고서 항목이 최신 상태
- **저자 정보**: 2605.15051 저자는 WebFetch 403 오류로 직접 확인 불가, 재검색 결과에서도 명시적 확인이 이루어지지 않아 "저자 미확인"으로 표기
- **코드 공개 여부**: KVDrive, KV-RM, Not All Thoughts Need HBM의 코드 링크는 확인 필요 표시
- **학회 심사 여부**: 모든 신규 논문이 현재 arXiv 프리프린트 단계; 동료 심사 완료 여부 미확인
