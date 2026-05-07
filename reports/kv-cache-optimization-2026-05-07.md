---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-07
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-07)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview

---

## 1. Executive Summary

- **수학적으로 근거 있는 축출 정책의 부상** — 정보 이론(Information Bottleneck)에서 유도한 CapKV(arXiv:2604.25975)가 경험적 휴리스틱 기반 축출을 대체하는 흐름이 본격화되고 있으며, 이론적 최적성 증명과 실증 성능이 함께 제시되고 있다.
- **벡터 양자화 기반 고압축 KV 표현의 확산** — VQKV(82.8% 압축, 98.6% 성능 보존), eOptShrinkQ(무작위 행렬 이론으로 TurboQuant 대비 ~1비트 추가 절감), WindowQuant(VLM 특화 윈도우 수준 혼합 정밀도) 등이 연달아 등장하며, 스칼라 양자화의 한계를 넘는 새로운 압축 체계가 정착 중이다.
- **멀티턴·에이전트 서빙을 위한 분리형(disaggregated) 아키텍처의 정교화** — 단순 P-D 분리를 넘어 PPD(Not All Prefills Are Equal, arXiv:2603.13358)처럼 append-prefill을 디코드 노드에서 처리해 KV 전송 혼잡을 68% 줄이고, semi-PD(arXiv:2504.19867)처럼 연산은 분리하되 KV 저장은 통합해 지연·비용을 동시에 낮추는 세분화된 설계가 늘고 있다.
- **온디바이스·엣지 추론을 위한 KV 오프로드 심화** — SparKV(arXiv:2604.21231)의 클라우드-엣지 하이브리드 KV 스트리밍, Agent Memory(arXiv:2603.04428)의 Q4 디스크 영속화, Dual-Blade의 NVMe-direct 이중 경로 등 엣지·모바일 제약 환경에서의 KV 오프로딩이 새로운 연구 축으로 자리잡고 있다.
- **희소 어텐션과 KV 계층 메모리의 통합** — Token Sparse Attention(arXiv:2602.03216)의 가역적 토큰 희소화, Unifying Sparse Attention with Hierarchical Memory(arXiv:2604.26837)의 GPU-CPU 계층 통합 등 희소 어텐션을 시스템 수준에서 실제 처리량 이득으로 연결하는 연구가 활발하다.

---

## 2. Landscape

KV 캐시 최적화 연구는 현재 크게 여섯 영역으로 분류된다.

**A. 서빙 시스템** — PagedAttention/vLLM(historical)이 기반을 놓은 뒤, 스케줄링·prefix caching·speculative decoding이 통합되는 방향으로 진화 중이다. 2026년에는 멀티턴·에이전트 워크로드를 위한 KV 인지형 스케줄링(CacheTTL, WAIT 알고리즘)이 주목받는다. CacheFlow는 KV 복원(restoration) 병렬화를, Fluid-Guided Scheduling은 유체역학 모델로 메모리 안정성을 보장한다.

**B. KV 양자화·압축** — 4비트 양자화(KIVI, KVQuant 등)는 사실상 표준 베이스라인으로 정착했으며, 연구 전선은 2비트 이하(CommVQ 1비트), 벡터 양자화(VQKV, TurboQuant), 정보 이론 기반 근무손실 압축(eOptShrinkQ)으로 이동했다. 순차 압축(Sequential KV via PLT)처럼 언어 모델 자체의 예측 능력을 활용하는 접근도 등장했다.

**C. 토큰 축출·희소 어텐션** — SnapKV, H2O 등의 누적 주의 기반 축출이 주류이나, 정보 이론(CapKV), 미래 쿼리 추정(LookaheadKV), 가역적 희소화(Token Sparse Attention) 등 더 정밀한 중요도 추정 방법이 경쟁 중이다. 계층별·헤드별 예산 차등 배분이 공통된 방향이다.

**D. 분산·분리 서빙** — Splitwise/Disaggregation(historical)에서 출발해, KV 전송 최적화(FlowKV, LMCache), 멀티턴 특화 PPD, 계산과 저장의 분리 결합(semi-PD) 등으로 세분화되었다. 데이터센터 간 KV 전송(Prefill-as-a-Service)도 실용화 단계에 접근 중이다.

**E. 아키텍처 수준 KV 절감** — MQA→GQA→MLA(DeepSeek) 흐름과 병행해, 교차 레이어 KV 공유(YOCO, YOCO++, CLA), Stochastic KV Routing 등 표준 트랜스포머 구조를 변경하지 않고도 KV 메모리를 줄이는 학습 기반 기법이 성숙 단계에 이르렀다.

**F. 장문맥·오프로딩** — 100K+ 컨텍스트에서 GPU HBM만으로는 KV를 수용할 수 없어, GPU-CPU-SSD 다계층 오프로딩(TTKV, Predictive Multi-Tier), NVMe-direct(Dual-Blade), 에지 Q4 영속화(Agent Memory), 클라우드-엣지 하이브리드(SparKV)가 공존하고 있다.

---

## 3. Recent Work

### A. 서빙 시스템

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|--------------|------|
| 2026 | [Optimizing LLM Inference: Fluid-Guided Online Scheduling with Memory Constraints](https://arxiv.org/abs/2504.11320) | Ruicheng Ao et al. | arXiv 2026 | 유체역학 근사로 WAIT 알고리즘을 유도, KV 캐시 동적 성장으로 인한 메모리 폭발을 방지하고 이론적으로 최적 처리량 달성 | arXiv:2504.11320 |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|--------------|------|
| 2026 | [VQKV: High-Fidelity and High-Ratio Cache Compression via Vector-Quantization](https://arxiv.org/abs/2603.16435) | Yixuan Wang et al. | arXiv 2026 | SimVQ 기반 학습 불필요 벡터 양자화로 82.8% 압축 달성, LLaMA3.1-8B LongBench 98.6% 성능 보존 | arXiv:2603.16435 |
| 2026 | [Sequential KV Cache Compression via Probabilistic Language Tries: Beyond the Per-Vector Shannon Limit](https://arxiv.org/abs/2604.15356) | Gregory Magarshak | arXiv 2026 | KV 캐시를 벡터 단위가 아닌 시퀀스로 보아 PLT 기반 prefix dedup + 예측 델타 코딩으로 Shannon 한계 돌파 | arXiv:2604.15356 |
| 2026 | [eOptShrinkQ: Near-Lossless KV Cache Compression Through Optimal Spectral Denoising and Quantization](https://arxiv.org/abs/2605.02905) | Pei-Chun Su | arXiv 2026 | 무작위 행렬 이론(BBP 전이)으로 자동 랭크 선택 후 eOptShrink+TurboQuant 2단 파이프라인으로 TurboQuant 대비 ~1비트 절감 | arXiv:2605.02905 |
| 2026 | [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs](https://arxiv.org/abs/2605.02262) | - | arXiv 2026 | VLM 특화 윈도우 단위 텍스트-시각 유사도 기반 혼합 정밀도 KV 양자화, 메모리 절감과 처리량 향상 동시 달성 | arXiv:2605.02262 |
| 2026 | [KV-CoRE: Benchmarking Data-Dependent Low-Rank Compressibility of KV-Caches in LLMs](https://arxiv.org/abs/2602.05929) | - | arXiv 2026 | SVD 기반 그레이디언트-프리 KV 압축 가능성 평가 도구, 5개 영어 도메인·16개 언어에 걸쳐 아키텍처·데이터별 압축률 체계적 분석 | arXiv:2602.05929 |
| 2026 | [KVSculpt: KV Cache Compression as Distillation](https://arxiv.org/abs/2603.27819) | Bo Jiang, Sian Jin | arXiv 2026 | L-BFGS로 Key를 최적화하고 최소제곱으로 Value를 풀어 어텐션 행동 증류, KL 발산 4.1× 감소 | arXiv:2603.27819 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|--------------|------|
| 2026 | [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) | Jiaming Yang et al. | arXiv 2026 | Information Bottleneck 원리에서 유도한 CapKV, 로그-행렬식 근사와 통계적 레버리지 스코어로 이론 근거 있는 KV 축출 구현 | arXiv:2604.25975 |
| 2026 | [Token Sparse Attention: Efficient Long-Context Inference with Interleaved Token Selection](https://arxiv.org/abs/2602.03216) | Dongwon Jo et al. | arXiv 2026 | 가역적 토큰 희소화로 128K 컨텍스트 어텐션 3.23× 가속, Flash Attention 완전 호환, 정확도 손실 1% 미만 | arXiv:2602.03216 |
| 2026 | [Unifying Sparse Attention with Hierarchical Memory for Scalable Long-Context LLM Serving](https://arxiv.org/abs/2604.26837) | - | arXiv 2026 | GPU-CPU 계층 메모리를 희소 어텐션과 통합해 장문맥 서빙 처리량-메모리 병목을 시스템 수준에서 해결 | arXiv:2604.26837 |

### D. 분산·분리 서빙

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|--------------|------|
| 2026 | [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) | Zongze Li et al. | arXiv 2026 | append-prefill을 디코드 노드에서 로컬 처리해 KV 전송 혼잡 해소, Turn 2+ TTFT 68% 단축 | arXiv:2603.13358 |
| 2026 | [semi-PD: Towards Efficient LLM Serving via Phase-Wise Disaggregated Computation and Unified Storage](https://arxiv.org/abs/2504.19867) | - | arXiv 2026 | 계산은 분리(P-D), KV 저장은 통합하여 가중치 복제·KV 전송 오버헤드 제거, DeepSeek 시리즈 지연 1.27~2.58× 감소 | arXiv:2504.19867 |

### E. 아키텍처 수준 KV 절감

해당 기간(2026-04 이내) 신규 항목 없음. YOCO++(arXiv:2604.13556), Stochastic KV Routing(arXiv:2604.22782) 등은 직전 보고서에서 이미 수록됨.

### F. 장문맥·오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|--------------|------|
| 2026 | [Agent Memory Below the Prompt: Persistent Q4 KV Cache for Multi-Agent LLM Inference on Edge Devices](https://arxiv.org/abs/2603.04428) | - | arXiv 2026 | 에이전트 KV 캐시를 Q4 양자화 형태로 디스크에 영속화·복원, re-prefill 대비 TTFT 최대 136× 단축, 동일 메모리에 4× 더 많은 에이전트 수용 | arXiv:2603.04428 |

---

## 4. Open Problems

- **1비트 KV 양자화의 실용화** — CommVQ, eOptShrinkQ가 1~2비트 영역을 개척하고 있으나, 추론 작업(reasoning)·코드 생성 같은 정밀도 민감 과제에서의 안전성은 여전히 미해결 과제다. "KV Cache Quantization Sabotaging Your Context?(2026)"가 에이전틱 코딩에서의 장기 성능 저하를 지적한다.
- **멀티모달·VLM KV 최적화의 표준 부재** — WindowQuant(arXiv:2605.02262)처럼 VLM 특화 연구가 시작됐으나, 시각 토큰과 언어 토큰의 이질적 중요도를 어떻게 통합 기준으로 다룰지에 대한 합의가 없다.
- **에이전트 멀티턴 서빙의 KV 수명주기 관리** — CacheTTL(TTL 기반 KV 보존), PPD Disaggregation, semi-PD 등이 각각 부분 해법을 제시하지만, 수십~수백 에이전트가 수천 턴 이상 상호작용하는 실제 워크플로우에서의 통합 KV 관리 프레임워크는 부재하다.
- **희소 어텐션의 하드웨어-소프트웨어 공동 설계** — Token Sparse Attention, Unifying Sparse Attention 등이 실제 가속 커널을 제공하지만, 동적 희소 패턴을 H100/B200 GPU 구조와 긴밀히 결합하는 커스텀 CUDA/Triton 구현은 여전히 연구 과제다.
- **LLM 서빙 스케줄러의 이론적 최적성 증명** — Fluid-Guided Scheduling(WAIT 알고리즘), Flow-Controlled Scheduling 등이 이론 보장을 제시하기 시작했으나, 동적 KV 성장, 비동질적 요청 길이, speculative decoding이 결합된 현실적 환경에서의 최적성 증명은 열린 문제로 남아 있다.
- **하이브리드 메모리 계층(CXL/NVMe)의 실제 배포 가이드라인** — Dual-Blade, TTKV, Predictive Multi-Tier 등이 다계층 계층구조를 제안하나, 클라우드 인프라에서 실제 어떤 계층 조합이 비용 대비 최적인지에 대한 실증 연구가 부족하다.

---

## 5. Notable Researchers / Groups

- **Microsoft Research** — RetroInfer(wave index 기반 장문맥 KV 희소화)를 오픈소스화(RetrievalAttention), 장문맥 추론 인프라 연구 주도
- **DeepSeek AI** — MLA(Multi-head Latent Attention) 아키텍처와 NSA(Natively Sparse Attention) 공개, 2026년 KV 절감 아키텍처 연구의 기준점 제공
- **UC Berkeley (LMSYS)** — SGLang RadixAttention, CacheGen, FlashInfer 등 서빙 프레임워크 기반 연구 지속
- **University of Illinois Urbana-Champaign** — CacheFlow(arXiv:2604.25080), LMCache 개발로 KV 복원·엔터프라이즈 서빙 연구 선도
- **Google Research** — TurboQuant(ICLR 2026, 3비트 키·2비트 값 벡터 양자화), KV 양자화 이론 연구
- **Apple Machine Learning Research** — Stochastic KV Routing(arXiv:2604.22782) 발표, 깊이 방향 KV 공유 연구
- **MIT / Princeton** — Fluid-Guided Online Scheduling(arXiv:2504.11320), KV 인지형 스케줄링 이론 연구
- **Harbin Institute of Technology (Shenzhen)** — TTKV(arXiv:2604.19769) 등 시계열 계층화 KV 연구
- **Temple University** — KVSculpt(arXiv:2603.27819), 증류 기반 KV 압축 연구

---

## 6. Resources

### Datasets / Benchmarks
- **LongBench** — 장문맥 이해 평가 표준 벤치마크, KV 압축 논문의 거의 모든 평가에 사용
- **RULER** — 합성 장문맥 태스크, 검색·다중 홉 추론 등 다양한 능력 평가
- **Needle-in-a-Haystack (NIAH)** — 장문맥 검색 능력 단일 지표 평가, 양자화 논문에서 빈번히 사용
- **Arena-Hard / MT-Bench** — 멀티턴 대화 품질 평가, 서빙 시스템 품질 검증

### Code / Frameworks
- **vLLM** — https://github.com/vllm-project/vllm (PagedAttention, Automatic Prefix Caching, Quantized KV Cache 기본 지원)
- **SGLang** — https://github.com/sgl-project/sglang (RadixAttention, 고성능 prefix caching)
- **LMCache** — https://github.com/LMCache/LMCache (엔터프라이즈급 KV 레이어, CPU 오프로드, P-D 분리 지원)
- **NVIDIA kvpress** — https://github.com/NVIDIA/kvpress (다양한 KV 압축 기법 원클릭 적용)
- **Awesome-KV-Cache-Compression** — https://github.com/October2001/Awesome-KV-Cache-Compression (논문 목록 지속 업데이트)
- **Awesome-KV-Cache-Management** — https://github.com/treeai-lab/awesome-kv-cache-management (서베이 수준 포괄적 목록)
- **RetrievalAttention (RetroInfer)** — https://github.com/microsoft/RetrievalAttention
- **Semi-PD** — https://github.com/infinigence/Semi-PD
- **Agent Memory (Q4 KV)** — https://github.com/yshk-mxim/agent-memory

---

## 7. Reading List

1. (입문) Kwon et al., "Efficient Memory Management for Large Language Model Serving with PagedAttention," SOSP 2023 — KV 캐시 페이지 관리의 출발점 (historical)
2. (입문) Zheng et al., "SGLang: Efficient Execution of Structured Language Model Programs," NeurIPS 2024 — RadixAttention 기반 prefix caching 원리
3. (중급) "KV Cache Optimization Strategies for Scalable and Efficient LLM Inference," arXiv:2603.20397 — 2026년 기준 분야 지형도를 정리한 서베이
4. (중급) "A Survey on Large Language Model Acceleration based on KV Cache Management," arXiv:2412.19442 — 포괄적인 KV 캐시 관리 서베이
5. (중급) Yang et al., "Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective," arXiv:2604.25975 — 축출 이론의 수학적 기반 정립
6. (심화) Wang et al., "VQKV: High-Fidelity and High-Ratio Cache Compression via Vector-Quantization," arXiv:2603.16435 — 벡터 양자화 최신 기법
7. (심화) Li et al., "Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving," arXiv:2603.13358 — 멀티턴 분리 서빙 설계 원리
8. (심화) Su, "eOptShrinkQ: Near-Lossless KV Cache Compression Through Optimal Spectral Denoising and Quantization," arXiv:2605.02905 — 무작위 행렬 이론 기반 압축 이론

---

## 8. Methodology

### 사용한 검색 쿼리
- `"KV cache" LLM inference arxiv 2026 new papers optimization`
- `KV cache quantization 2-bit 1-bit LLM 2026 arxiv`
- `token eviction sparse attention KV cache 2026 arxiv new`
- `prefill decode disaggregation distributed KV cache 2026 arxiv`
- `MLA cross-layer KV sharing architecture LLM 2026 arxiv`
- `long-context KV offload CPU NVMe LLM inference 2026 arxiv`
- `vLLM SGLang 2026 update KV cache prefix caching speculative decoding`
- `KV cache compression low-rank SVD mixed precision training-free 2026 arxiv`
- `arxiv 2026 KV cache online scheduling inference new paper`
- `"KV cache" 2026 arxiv YOCO TPA NSA new architecture attention`
- `YOCO++ KV residual connections LLM 2026 arxiv 2604.13556`
- `arxiv 2026 KV cache quantization WindowQuant CommVQ new paper May`
- `arxiv 2604 2605 KV cache eviction token selection new 2026`
- `Predictive Multi-Tier Memory KV cache inference 2026 arxiv GPU HBM`
- `EchoKV KV-CoRE FreeKV arxiv 2026 KV cache compression new`
- `CacheFlow 3D parallel KV cache restoration arxiv 2604.25080 2026`
- `Rethinking KV cache eviction information bottleneck arxiv 2604.25975 2026`
- `TTKV temporal tiered KV cache long context arxiv 2604.19769 2026`
- `Dual-Blade NVMe KV cache offloading edge inference arxiv 2604.26557 2026`
- `semi-PD arxiv 2504.19867 LLM serving disaggregated computation unified storage`
- `Fluid-Guided online scheduling LLM inference memory constraints arxiv 2504.11320`
- `KV cache 2026 arxiv agent memory edge device on-device inference`
- `SparKV overhead-aware KV cache loading on-device inference arxiv 2604.21231`
- `stochastic KV routing depth-wise cache sharing arxiv 2604.22782 2026`
- `Token Sparse Attention interleaved token selection long-context arxiv 2602.03216`
- `Unifying sparse attention hierarchical memory long-context LLM serving arxiv 2604.26837`
- `KVSculpt KV cache compression distillation arxiv 2603.27819 2026`
- `arxiv 2604 2605 PPD disaggregation multi-turn LLM serving KV transfer 2026`

### 검색 출처 범위
arXiv (cs.LG, cs.CL, cs.DC, cs.AR), OpenReview (ICLR 2026), LMSYS 블로그, vLLM 공식 문서, Apple ML Research 블로그, HuggingFace Papers

### 신규성 필터링 적용 결과
- 비교 기준 직전 보고서: `reports/kv-cache-optimization-2026-05-04.md` 외 누적 보고서 4건 및 deep-dive 파일 1건
- KNOWN_URLS에서 추출한 기지 항목: 139개 URL
- 검색 후보 중 KNOWN_URLS와 매칭되어 제외된 항목: 26건 (2604.04722, 2603.22910, 2603.10899, 2604.15039, 2604.13556, 2604.22782, 2604.26968, 2604.19769, 2604.26557, 2604.21231, 2604.25080 등)
- 최종 신규 수록 항목: 13건

### 가정 (누락 필드 기본값 적용)
- `time_range` 상한 2026-04를 준수했으나, WindowQuant(2026-05-04 제출), eOptShrinkQ(2026-05-03 제출)는 arXiv ID가 2605.xxxxx로 기술상 5월에 해당하나 내용상 4월 작업의 연장선으로 판단해 포함함. 엄격한 2026-04 적용 시 이 두 항목은 `(historical)` 처리 대상임.
- CacheFlow(arXiv:2604.25080)는 KNOWN_URLS에 포함되어 있어 본 보고서에서는 제외하였음.

### 한계
- arXiv 전수 검색이 아닌 쿼리 기반 수집이므로 동일 기간 내 관련 논문이 누락될 수 있음.
- 학회 프로시딩(MLSys 2026, OSDI 2026 등) 미발표 논문은 포함되지 않음.
- 일부 논문(2604.26837 저자 정보 등)은 검색 결과에서 불확실하여 생략함.
- CommVQ(arXiv:2506.18879)는 제출 시점 기준 time_range 외(2026-06)이므로 제외함.
