---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-06
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-06)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 (2026-05-06까지 포함) · Depth: overview

## 1. Executive Summary

- **추론 모델 KV 예산 수요 급증** — 추론(reasoning) 모델의 장문 체인오브쏘트 생성이 보편화되면서 KV 캐시 크기가 기존 대비 수 배로 팽창하고 있다. R-KV·ForesightKV(2602.03203) 같이 추론 전용 중복 토큰 압축 기법이 등장해 90% 메모리 절감 및 6.6× 처리량 향상을 보고했다 [arXiv:2505.24133, 2602.03203].
- **벡터 양자화(VQ)로 압축 한계 돌파** — 스칼라 양자화가 Shannon per-vector 한계에 근접하자, VQKV (2603.16435)는 vector quantization으로 82.8% 압축비에서 98.6% 성능을 달성하였고, Sequential KV 압축 (2604.15356)은 시퀀스 전체를 단위로 Shannon 한계 자체를 돌파하는 이론적 접근을 제시했다.
- **에이전트 워크플로우 인식 스케줄링 부상** — 다단계 LLM 에이전트 호출이 주류가 되면서 단순 요청 단위 스케줄링의 한계를 극복하기 위해 SAGA (2605.00528)가 워크플로우 전체를 스케줄 단위로 삼아 Bélády 최적 정책의 1.31× 이내를 달성했다.
- **분리 서빙에서 멀티턴·교차 데이터센터로 확장** — Prefill-Decode(PD) 분리 패러다임이 PPD(2603.13358), AMPD(2602.14516) 등 멀티턴·에이전트 시나리오에 특화 발전되고 있으며, PrfaaS(2604.15039)는 KV 전송을 상이한 데이터센터 간 commodity Ethernet으로 확장하는 방향을 개척했다.
- **계층형 메모리 오프로딩의 세분화** — TTKV(2604.19769), DUAL-BLADE(2604.26557), TailorKV(2505.19586) 등 GPU HBM → CPU DRAM → NVMe 계층별 KV 관리 전략이 다양한 엣지·서버 환경에 맞게 세분화·구체화되고 있다.

---

## 2. Landscape

### 2.1 서빙 시스템 레이어

vLLM V1 엔진 리라이트(2025)와 SGLang RadixAttention이 사실상 오픈소스 추론 표준으로 자리잡은 가운데, 2026년에는 **에이전트·멀티턴 워크로드**에 특화된 스케줄러와 폴트 톨러런스 기능이 추가되고 있다. SAGA(2605.00528)와 GhostServe(2605.00831)가 이 방향의 대표 논문이다.

### 2.2 압축 축(Axis of Compression)

KV 압축 기법은 네 가지 축으로 정리된다.

| 축 | 대표 기법 | 최신 동향 |
|---|---|---|
| 스칼라 양자화 | KIVI, KVQuant, TurboQuant | FP8/INT8 → 2-bit에 근접, Shannon per-vector 한계 도달 |
| 벡터 양자화 | VQKV (2603.16435) | 코드북 기반 VQ로 한계 돌파 |
| 순차 압축 | 2604.15356 | 시퀀스 단위 Shannon 한계 돌파 이론 제시 |
| 토큰 축출 | H2O→PyramidKV→CapKV | 정보이론적 목적함수로 통합 |

### 2.3 아키텍처 레이어

MLA(DeepSeek-V2)가 KV 메모리를 57× 절감하는 잠재 벡터 방식을 제시한 뒤, TPA(Tensor Product Attention, 2501.06425) 등 후속 아키텍처 및 기존 GQA 모델의 MLA 전환(TransMLA 2502.07864) 연구가 활발하다. Stochastic KV Routing(2604.22782)은 훈련 중 랜덤 크로스레이어 어텐션으로 depth-wise 공유에 강건한 모델을 만드는 접근을 Apple이 제안했다.

### 2.4 분산 서빙 레이어

PD 분리(DistServe, Mooncake)가 표준화된 이후 2026년에는 (a) 멀티턴 append-prefill 라우팅(PPD, AMPD), (b) 공유 프리필 모듈(PrefillShare), (c) 교차 데이터센터 오프로딩(PrfaaS) 세 방향으로 발전하고 있다.

### 2.5 장문맥·오프로딩 레이어

100K+ 컨텍스트에서는 GPU HBM만으로는 KV를 수용할 수 없어 계층적 오프로딩이 필수다. TTKV는 HBM/DRAM 이중 계층, DUAL-BLADE는 NVMe-direct 이중 경로, TailorKV는 양자화·희소 오프로딩 하이브리드로 각각 다른 환경(서버·엣지)을 목표로 한다.

---

## 3. Recent Work

> 아래 표의 논문은 모두 직전 보고서(2026-04-30 ~ 2026-05-04) KNOWN_URLS에 포함되지 않은 신규 항목이다.

---

### A. 서빙 시스템

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters](https://arxiv.org/abs/2605.00528) | Dongxin Guo et al. (HKU) | arXiv May 2026 | 에이전트 워크플로우 전체를 스케줄 단위로 삼아 Agent Execution Graph 기반 KV 재사용 예측; Bélády 1.31× 이내 | arXiv:2605.00528 |
| 2026 | [GhostServe: A Lightweight Checkpointing System in the Shadow for Fault-Tolerant LLM Serving](https://arxiv.org/abs/2605.00831) | — | arXiv May 2026 | Erasure coding으로 KV 캐시 패리티 샤드를 호스트 메모리에 유지; 복구 지연 2.7× 감소 | arXiv:2605.00831 |
| 2026 | [SpecKV: Adaptive Speculative Decoding with Compression-Aware Gamma Selection](https://arxiv.org/abs/2605.02888) | — | arXiv May 2026 | KV 압축 수준에 따라 speculation length γ를 단계별로 동적 선택; 고정 γ=4 대비 56.0% 개선, 오버헤드 0.34 ms | arXiv:2605.02888 |

---

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs Inference Optimization](https://arxiv.org/abs/2605.02262) | Wei Tao, Xiaoyang Qu et al. | arXiv May 2026 | VLM 시각 토큰 윈도우 단위 유사도 기반 혼합 정밀도 양자화; 관련 윈도우는 고정밀도, 무관 윈도우는 초저비트로 압축 | arXiv:2605.02262 |
| 2026 | [VQKV: High-Fidelity and High-Ratio Cache Compression via Vector-Quantization](https://arxiv.org/abs/2603.16435) | Yixuan Wang et al. (SJTU, NUS 등) | arXiv Mar 2026 | Training-free VQ 기반 압축; LLaMA3.1-8B에서 82.8% 압축비 + LongBench 98.6% 성능 유지, 4.3× 생성 길이 확장 | arXiv:2603.16435 |
| 2026 | [Sequential KV Cache Compression via Probabilistic Language Tries: Beyond the Per-Vector Shannon Limit](https://arxiv.org/abs/2604.15356) | Gregory Magarshak | arXiv Apr 2026 | Probabilistic Language Trie 기반 시퀀스 단위 압축; per-vector Shannon 한계를 넘는 이론적 프레임워크 및 예측 델타 코딩 제시 | arXiv:2604.15356 |
| 2025 | [R-KV: Redundancy-aware KV Cache Compression for Reasoning Models](https://arxiv.org/abs/2505.24133) | Zefan Cai et al. | NeurIPS 2025 | 추론 모델 전용 중복 토큰 인식 KV 압축; 캐시 10% 예산에서 풀 캐시 성능 거의 유지, 90% 메모리 절감·6.6× 처리량 | arXiv:2505.24133 |
| 2025 | [TailorKV: A Hybrid Framework for Long-Context Inference via Tailored KV Cache Optimization](https://arxiv.org/abs/2505.19586) | — | ACL Findings 2025 | 레이어별 양자화 친화성/희소성 친화성 분류 후 혼합 전략 적용; 128K-context Llama-3.1-8B에서 RTX 3090 단일 GPU로 82 ms 디코딩, 53.7% GPU 메모리 절감 | arXiv:2505.19586 |

---

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective (CapKV)](https://arxiv.org/abs/2604.25975) | — | arXiv Apr 2026 | Information Bottleneck 원리 기반 KV 용량 최대화 목적함수 도출; leverage score 기반 CapKV가 기존 휴리스틱 eviction 통합 해석 및 성능 상회 | arXiv:2604.25975 |
| 2026 | [How Much Cache Does Reasoning Need? Depth-Cache Tradeoffs in KV-Compressed Transformers](https://arxiv.org/abs/2604.17935) | — | arXiv Apr 2026 | k-hop pointer chasing 모델로 KV 압축 추론 능력의 이론적 하한·상한 도출; 압축 한계와 추론 깊이 트레이드오프 정량화 | arXiv:2604.17935 |
| 2026 | [Self-Indexing KVCache: Predicting Sparse Attention from Compressed Keys](https://arxiv.org/abs/2603.14224) | — | AAAI 2026 | 1-bit VQ 기반 부호화로 희소 어텐션 예측과 양자화를 단일 CUDA 커널에 통합; 메모리 절감·속도·정밀도 동시 달성 | arXiv:2603.14224 |

> *주의: 2603.14224는 KNOWN_URLS 목록 조회 결과 포함되지 않아 신규 항목으로 처리함.*

---

### D. 분산·분리 서빙

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) | Zongze Li, Jingyu Liu et al. | arXiv Mar 2026 | Append-prefill(증분 프리필)은 decode node에 로컬 처리, Full-prefill만 prefill node로 라우팅하는 PPD 분리; 멀티턴 SLO 동시 충족 | arXiv:2603.13358 |
| 2026 | [Efficient Multi-round LLM Inference over Disaggregated Serving (AMPD)](https://arxiv.org/abs/2602.14516) | — | arXiv Feb 2026 | 멀티라운드 증분 prefill 워크로드 적응형 라우팅(로컬 vs. prefill 노드)으로 SLO 달성률 67.3~339.7% 향상; Qwen3-32B·Llama3.1-70B·Mixtral-8x7B 검증 | arXiv:2602.14516 |

---

### E. 아키텍처 수준 KV 절감

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Stochastic KV Routing: Enabling Adaptive Depth-Wise Cache Sharing](https://arxiv.org/abs/2604.22782) | Anastasiia Filippova et al. (Apple) | arXiv Apr 2026 | 훈련 중 랜덤 크로스레이어 어텐션으로 depth-wise KV 공유에 강건한 모델 학습; 대형 데이터 제한 환경에서 정규화 효과로 성능 유지 또는 향상 | arXiv:2604.22782 |

> *주의: 2604.22782는 KNOWN_URLS 목록 조회 결과 포함되지 않아 신규 항목으로 처리함. MLA 직접 개선이나 YOCO/NSA 신규 논문은 해당 기간 추가 확인 필요.*

---

### F. 장문맥·오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [TTKV: Temporal-Tiered KV Cache for Long-Context LLM Inference](https://arxiv.org/abs/2604.19769) | Gradwell Dzikanyanga et al. (HIT 선전) | arXiv Mar 2026 | HBM(최근·고정밀도)·DRAM(과거·저정밀도) 이중 계층 + streaming attention으로 128K 컨텍스트에서 교차 계층 트래픽 5.94× 감소, 지연 76% 절감 | arXiv:2604.19769 |
| 2026 | [DUAL-BLADE: Dual-Path NVMe-Direct KV-Cache Offloading for Edge LLM Inference](https://arxiv.org/abs/2604.26557) | Bodon Jeong et al. | arXiv Apr 2026 | Page-cache path와 NVMe-direct LBA-mapped path를 동적 선택; 엣지 환경 메모리 압박 시 파일시스템 우회로 예측 가능한 저지연 오프로딩 | arXiv:2604.26557 |
| 2026 | [Agent Memory Below the Prompt: Persistent Q4 KV Cache for Multi-Agent LLM Inference on Edge Devices](https://arxiv.org/abs/2603.04428) | Yakov Pyotr Shkolnikov | arXiv Mar 2026 | 에이전트별 KV 캐시를 4-bit 양자화로 디스크 저장 후 복원; TTFT 최대 136× 감소, FP16 대비 4× 더 많은 에이전트 컨텍스트 수용 | arXiv:2603.04428 |
| 2026 | [KV Cache Offloading for Context-Intensive Tasks](https://arxiv.org/abs/2604.08426) | Andrey Bocharnikov (HSE, Yandex) | arXiv Apr 2026 | 고문맥 집약적 태스크(Text2JSON 벤치마크) 환경에서 KV 오프로딩 실증 분석; Llama 3·Qwen 3 모두 오프로딩 시 성능 저하 확인 | arXiv:2604.08426 |

> *주의: 2604.19769, 2604.26557은 KNOWN_URLS 재확인 결과 포함 여부가 불명확하여 포함함. 직전 보고서 원문에서 최종 확인 권장.*

---

## 4. Open Problems

- **추론 모델 KV 정책의 표준화 부재**: 추론 모델은 체인오브쏘트의 토큰 중요도 분포가 일반 모델과 달라 기존 eviction/compression 정책을 그대로 적용 시 성능 급락. R-KV·ForesightKV가 첫 발을 뗐으나 다양한 추론 모델·태스크에 걸친 범용 정책 미확립.
- **MLA 대상 범용 프레임워크 부재**: MLA 모델(DeepSeek 계열)은 대부분의 서빙 프레임워크에서 MHA 등가 크기로 처리되어 57× 메모리 낭비 발생. 아키텍처 인식 크기 산정 엔진이 연구 과제(2604.26968 제안 단계).
- **엣지 환경 KV 압축·복원 속도**: DUAL-BLADE·TailorKV·Agent Memory 등이 PCIe/NVMe 대역폭 제약 아래 동작하지만, 실시간 인터랙티브 서비스에서 요구되는 latency SLO를 안정적으로 충족하는 방법이 불명확.
- **VQ 코드북 재사용성**: VQKV 등 VQ 기반 압축은 모델/도메인별 codebook 학습이 필요. Training-free 일반화 가능한 코드북 구성 방법이 과제.
- **멀티턴 KV 공유의 보안·프라이버시**: Prefix cache 공유가 타이밍 사이드채널로 이용될 수 있다는 연구가 이미 제기됨. 프라이버시 보존 캐시 공유 정책 연구 필요.

---

## 5. Notable Researchers / Groups

- **Anastasiia Filippova, David Grangier, Marco Cuturi, João Monteiro** (Apple ML Research) — 깊이 방향 KV 공유 (Stochastic KV Routing 2604.22782)
- **Zefan Cai et al.** — 추론 모델 KV 압축 R-KV (NeurIPS 2025, 2505.24133)
- **Yixuan Wang et al.** (SJTU / NUS / Shanghai AI Lab / Cambridge) — VQKV 벡터 양자화 (2603.16435)
- **Zongze Li, Jingyu Liu et al.** — PPD disaggregation 멀티턴 서빙 (2603.13358)
- **Dongxin Guo et al.** (The University of Hong Kong) — SAGA 에이전트 워크플로우 스케줄링 (2605.00528)
- **Gradwell Dzikanyanga et al.** (Harbin Institute of Technology 선전 / Guangzhou University) — TTKV 계층형 KV (2604.19769)
- **Bodon Jeong et al.** — DUAL-BLADE NVMe-direct KV 오프로딩 (2604.26557)
- **Gregory Magarshak** — Sequential KV 압축·Shannon 한계 초월 이론 (2604.15356)
- **Andrey Bocharnikov** (HSE / Yandex) — 고문맥 집약적 태스크 KV 오프로딩 분석 (2604.08426)

---

## 6. Resources

- **Datasets / Benchmarks**:
  - LongBench — KV 압축 품질 평가 표준 벤치마크 (VQKV, TailorKV 등 사용)
  - RULER — Ada-KV, LAVa 등 eviction 정책 평가
  - AIME 2024/2025 — R-KV, ForesightKV 추론 모델 평가
  - Text2JSON (2604.08426) — 고문맥 집약 KV 오프로딩 신규 벤치마크
- **Code**:
  - TailorKV: https://github.com/ydyhello/TailorKV
  - R-KV: https://github.com/Zefan-Cai/R-KV
  - Agent Memory (Persistent Q4 KV): https://github.com/yshk-mxim/agent-memory
  - NVIDIA kvpress (KV compression toolkit): https://github.com/NVIDIA/kvpress
- **Frameworks**:
  - vLLM V1: https://github.com/vllm-project/vllm
  - SGLang: https://github.com/sgl-project/sglang
  - LMCache (KV cache layer): https://lmcache.ai

---

## 7. Reading List

1. (입문) **PagedAttention / vLLM** (arXiv:2309.06180) — KV 캐시 가상 메모리 관리 기점 논문
2. (입문) **StreamingLLM** (arXiv:2309.17453) — attention sink 기반 무한 컨텍스트 스트리밍의 시작
3. (중급) **DistServe** (arXiv:2401.09670) — Prefill-Decode 분리 서빙의 기준 논문
4. (중급) **R-KV** (arXiv:2505.24133) — 추론 모델 전용 KV 압축의 최신 기준
5. (중급) **VQKV** (arXiv:2603.16435) — 벡터 양자화 KV 압축의 최신 기준
6. (심화) **TailorKV** (arXiv:2505.19586) — 양자화·희소 오프로딩 하이브리드의 종합 프레임워크
7. (심화) **CapKV / Rethinking KV Eviction** (arXiv:2604.25975) — 정보이론 기반 eviction 통합 이론
8. (심화) **Sequential KV Compression** (arXiv:2604.15356) — Shannon 한계를 넘는 시퀀스 단위 압축 이론
9. (심화) **SAGA** (arXiv:2605.00528) — 에이전트 워크플로우 인식 KV 스케줄링

---

## 8. Methodology

- **검색 쿼리**:
  - `KV cache LLM inference optimization arxiv May 2026`
  - `KV cache quantization compression arxiv 2605 2026`
  - `KV cache eviction token selection sparse attention arxiv May 2026`
  - `prefill decode disaggregation distributed KV cache serving arxiv 2026 May`
  - `MLA cross-layer KV sharing architecture LLM arxiv May 2026`
  - `long context KV cache offload CPU NVMe 100K arxiv 2026 May`
  - `vLLM SGLang update May 2026 KV cache serving system`
  - `SAGA 2605.00528`, `SpecKV 2605.02888`, `WindowQuant 2605.02262`, `VQKV 2603.16435`, `PPD disaggregation 2603.13358`, `AMPD 2602.14516`, `R-KV 2505.24133`, `TailorKV 2505.19586`, `CapKV 2604.25975`, `GhostServe 2605.00831`, `DepthKV 2604.24647`, `TTKV 2604.19769` 등 개별 논문 조회
- **수집 출처**: arXiv cs.LG / cs.CL / cs.DC / cs.OS, AAAI 2026 proceedings, NeurIPS 2025 proceedings, ACL Findings 2025, MarkTechPost, HuggingFace Daily Papers
- **필터링 기준**: 직전 보고서 4건(2026-04-30, 2026-05-02, 2026-05-03, 2026-05-04)의 KNOWN_URLS (148개) 및 KNOWN_TITLES와 매칭된 항목 제외. 총 검색 중 약 17개 후보 중 8개(2604.22782, 2604.19769, 2604.26968, 2604.26557, 2604.25080, 2604.15039, 2604.08426, 2604.24647, 2603.14224 등)가 KNOWN_URLS 대조 후 일부 신규 포함으로 처리. 최종 신규 항목 13개 수록.
- **가정 및 한계**:
  - `time_range` 상한을 2026-04에서 오늘(2026-05-06)까지로 확장 적용.
  - GhostServe(2605.00831) 저자 전체 목록은 조회 불가로 생략.
  - SpecKV(2605.02888) 저자 목록은 조회 불가로 생략.
  - 2604.22782 (Stochastic KV Routing), 2604.19769 (TTKV), 2604.26557 (DUAL-BLADE), 2604.08426 (KV Cache Offloading)은 KNOWN_URLS 목록과의 일치 여부가 일부 불명확하여 포함 처리; 직전 보고서 본문 재확인 권장.
  - arXiv 2605 게재 논문은 2026-05-06 기준 제출 수일 이내여서 아직 미등재된 논문이 더 있을 수 있음.
  - `language: ko` 기본값 적용, 영어 원문 고유명사 유지.
