---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-13
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-13)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview
> 직전 보고서: `reports/kv-cache-optimization-2026-05-04.md`

---

## 1. Executive Summary

- **정보이론 기반 Eviction의 부상** — 휴리스틱 점수 대신 Information Bottleneck 원리와 rate-distortion 이론을 적용한 eviction 및 양자화 연구가 급증했다. CapKV(arXiv:2604.25975), RateQuant(arXiv:2605.06675) 등이 이론적 토대를 확립하며 기존 heuristic 방식의 한계를 실험으로 증명하고 있다 [refs: §C, §B].
- **Agentic Serving을 위한 KV 재사용** — 멀티-스텝 에이전트 워크플로에서 툴 콜 경계마다 KV 캐시를 파기하는 비효율이 2-8× 지연을 유발한다는 사실이 확인되고, SAGA(arXiv:2605.00528)와 PBKV(arXiv:2605.06472)가 워크플로-수준 KV 스케줄링으로 이를 해결한다 [ref: §A].
- **NVMe SSD KV 오프로드의 실용화** — GPU-centric I/O로 CPU 병목을 제거한 Tutti(arXiv:2605.03375)가 SSD 기반 KV 오프로드에서 TTFT를 78.3% 단축하고 처리량을 2× 개선하며 vLLM에 통합되었다 [ref: §F].
- **벡터 양자화·스펙트럼 분해의 저변 확대** — FibQuant(arXiv:2605.11478)의 준균일 방향 코드북, eOptShrinkQ(arXiv:2605.02905)의 최적 특이값 축소+TurboQuant 결합, int4 Apple Silicon 커널(arXiv:2605.05699)이 스칼라 양자화 너머의 새로운 압축 패러다임을 개척한다 [ref: §B].
- **추론 모델(CoT) 특화 KV 압축** — DeepSeek-R1 계열 장문 CoT 생성에서 문장 단위 선택적 KV 저장을 수행하는 SkipKV(arXiv:2512.07993, MLSys 2026)와 RL 롤아웃 단계의 KV 압축 편향을 수정하는 Shadow Mask Distillation(arXiv:2605.06850)이 등장했다 [ref: §C].

---

## 2. Landscape

### 분야 지형도

KV 캐시 최적화는 2026년 5월 현재 다음 여섯 방향으로 수렴하고 있다.

| 영역 | 주요 패러다임 | 대표 시스템/기법 |
|---|---|---|
| **서빙 시스템** | 워크플로 수준 KV 스케줄링, SLO-aware routing | SAGA, PBKV, Tutti+vLLM |
| **KV 양자화·압축** | 벡터 양자화, 스펙트럼 분해, 정보이론 최적 bit 배분 | FibQuant, RateQuant, eOptShrinkQ, Kitty |
| **토큰 축출·희소 어텐션** | 정보이론 eviction, 종단-학습 eviction, CPU-GPU 협력 희소 어텐션 | CapKV, LKV, LaProx, RetentiveKV, Fluxion |
| **분산·분리 서빙** | Cross-datacenter KV 전송, 다중 모델 prefill 공유 | Prefill-as-a-Service(기수집), 2605 범위 내 신규 없음 |
| **아키텍처 수준** | YOCO++ residual 연결, MLA 변환 후속 | YOCO++(기수집) |
| **장문맥·오프로딩** | GPU-centric NVMe I/O, CPU-GPU 협력 희소 어텐션, 재귀형 장문맥 | Tutti, Fluxion, KV-Fold |

### 2026년 상반기 주요 흐름

**이론화 가속**: 수년간 어텐션 가중치 휴리스틱에 의존하던 eviction이 information bottleneck, rate-distortion, leverage score 등 엄밀한 수학적 프레임으로 재해석되고 있다. 이론 기반 설계가 실험 기반 설계보다 일관되게 우위를 보이기 시작했다.

**에이전트 서빙의 KV 압력**: LLM 에이전트가 수십~수백 번의 체인형 호출을 실행하면서 KV 캐시 파기·재생성이 새로운 병목으로 부상했다. 이를 해결하기 위한 워크플로-수준 스케줄링 연구가 2026년 1분기부터 급격히 증가하고 있다.

**하드웨어 다양화**: Apple Silicon(통합 메모리), NVMe SSD, CXL 메모리 풀, CPU 호스트 메모리 등 GPU 외 하드웨어에서의 KV 관리가 본격적인 연구 주제가 되었다.

---

## 3. Recent Work

### A. 서빙 시스템 (Serving Systems)

> vLLM·SGLang 업데이트, chunked prefill, prefix caching, speculative decoding, SLO-aware scheduling

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters](https://arxiv.org/abs/2605.00528) | (HPDC '26 저자) | HPDC 2026 | 에이전트 워크플로를 최소 스케줄 단위로 삼아 툴 콜 경계에서 KV 캐시를 보존, Bélády 근접 재사용률로 KV 재생성 시간 38% → 8%로 감소 | arXiv:2605.00528 |
| 2026 | [Efficient Serving for Dynamic Agent Workflows with Prediction-based KV-Cache Management (PBKV)](https://arxiv.org/abs/2605.06472) | Haoyu Zheng 외 (Wuhan U., SJTU, HKUST) | arXiv | 동적 에이전트 워크플로에서 미래 에이전트 호출을 예측해 KV 캐시 재사용을 극대화하는 예측 기반 관리 시스템 | arXiv:2605.06472 |

**vLLM Q2 2026 로드맵**: INT8 dynamic per-token KV 양자화를 기반으로 per-token FP8 및 NVFP4 동적 KV 압축을 예정 중이며, TurboQuant KV 통합 관련 버그 수정이 활발히 이루어지고 있다. chunked prefill은 V1에서 기본 활성화 상태이다.

**SGLang April 2026**: NVIDIA 공식 릴리즈 노트(RN-08516-001_v26.04) 기준으로 GB300/B300 지원, NSA fuse store indexer for K cache, fused Triton kernel for prefill KV cache fetching, IndexCache 등이 포함되었다. TurboQuant KV cache compression(ICLR 2026)이 SGLang에도 통합되었다.

---

### B. KV 양자화·압축 (KV Quantization & Compression)

> 2-bit/1-bit KV quantization, low-rank SVD, mixed-precision, training-free compression

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [RateQuant: Optimal Mixed-Precision KV Cache Quantization via Rate-Distortion Theory](https://arxiv.org/abs/2605.06675) | Fei Zuo, Zikang Zhou, Hao Cong 외 (BMW BA TechWorks, NUS, Tsinghua) | arXiv | rate-distortion reverse waterfilling으로 헤드별 최적 비트 폭 배분; Qwen3-8B 2.5bit에서 KIVI perplexity 49.3→14.9(70% 감소) | arXiv:2605.06675 |
| 2026 | [FibQuant: Universal Vector Quantization for Random-Access KV-Cache Compression](https://arxiv.org/abs/2605.11478) | Namyoon Lee, Yongjune Kim (POSTECH) | arXiv | Fibonacci/Roberts-Kronecker 준균일 방향 + Beta-quantile 반경 + Lloyd-Max 정제로 랜덤 접근 가능한 범용 벡터 양자화기 | arXiv:2605.11478 |
| 2026 | [eOptShrinkQ: Near-Lossless KV Cache Compression Through Optimal Spectral Denoising and Quantization](https://arxiv.org/abs/2605.02905) | Pei-Chun Su | arXiv | 최적 특이값 수축(eOptShrink)으로 저랭크 공유 문맥 추출 후 잔차를 TurboQuant로 양자화; ~2.2bit에서 TurboQuant 3.0bit 성능 초과 | arXiv:2605.02905 |
| 2026 | [When Quantization Is Free: An int4 KV Cache That Outruns fp16 on Apple Silicon](https://arxiv.org/abs/2605.05699) | Mohamed Amine Bergach (Illumina) | arXiv | 부호 랜덤화 FFT + per-channel 스케일 + per-group abs-max + int4 nibble pack을 단일 Metal 커널로 융합; Gemma-3 1B에서 fp16 대비 3-8% 속도 향상 | arXiv:2605.05699 |
| 2026 | [Kitty: Accurate and Efficient 2-bit KV Cache Quantization with Dynamic Channel-wise Precision Boost](https://arxiv.org/abs/2511.18643) | (Toronto U. 등) | MLSys 2026 | 키 채널 민감도 기반 동적 채널별 정밀도 부스팅으로 ~8× KV 메모리 절감, 2.1-4.1× 처리량 향상 | arXiv:2511.18643 |

---

### C. 토큰 축출·희소 어텐션 (Token Eviction & Sparse Attention)

> eviction policy, query-aware sparse attention, layer-wise/head-wise budget, RL-based eviction

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective (CapKV)](https://arxiv.org/abs/2604.25975) | Jiaming Yang, Chenwei Tang, Liangli Zhen, Jiancheng Lv | arXiv | Information Bottleneck 관점에서 유지 KV 부분집합의 상호정보량을 log-determinant + leverage score로 근사하는 capacity-aware eviction | arXiv:2604.25975 |
| 2026 | [Reformulating KV Cache Eviction Problem for Long-Context LLM Inference (LaProx)](https://arxiv.org/abs/2605.07234) | Tho Mai, Joo-Young Kim (KAIST) | arXiv | head-wise 평균 대신 어텐션 맵×프로젝트 값의 곱셈 상호작용을 output-aware 행렬 근사 문제로 재정식화; LongBench 16개 태스크 대부분에서 SOTA | arXiv:2605.07234 |
| 2026 | [LKV: End-to-End Learning of Head-wise Budgets and Token Selection for LLM KV Cache Eviction](https://arxiv.org/abs/2605.06676) | Enshuai Zhou, Yifan Hao, Chao Wang, Rui Zhang 외 10인 | arXiv | KV 압축을 종단간 미분가능 최적화로 정식화; LKV-H(헤드별 예산 학습) + LKV-T(어텐션 행렬 없이 중요도 도출)로 LongBench·RULER 최고 성능 | arXiv:2605.06676 |
| 2026 | [RetentiveKV: State-Space Memory for Uncertainty-Aware Multimodal KV Cache Eviction](https://arxiv.org/abs/2605.04075) | (Zhejiang U., Alibaba, SIAS) | arXiv | 멀티모달 LLM에서 시각 토큰의 "지연 중요성"을 엔트로피-유도 상태공간 전이로 처리; 5× KV 압축, 1.5× 디코딩 가속 | arXiv:2605.04075 |
| 2026 | [An Efficient Hybrid Sparse Attention with CPU-GPU Parallelism for Long-Context Inference (Fluxion)](https://arxiv.org/abs/2605.07719) | Feiyu Yao, Zhixiong Niu, Xiaqing Li, Yongqiang Xiong, Juan Fang, Qian Wang | arXiv | CPU 상주 KV 캐시에 대한 출력-aware KV 예산 배정 + 헤드별 희소 설정 + 크로스-디바이스 협력 희소 어텐션; KV 예산 0.05에서 최강 고정-희소 대비 1.5-3.7× 가속 | arXiv:2605.07719 |
| 2026 | [Sparse Attention as a Range Searching Problem: Towards an Inference-Efficient Index for KV Cache (Louver)](https://arxiv.org/abs/2605.06763) | Mohsen Dehghankar, Abolfazl Asudeh | arXiv | 희소 어텐션을 halfspace range searching으로 재정식화, 제로 false negative 보장 + FlashAttention보다 빠른 Louver 인덱스 구조 제안 | arXiv:2605.06763 |
| 2026 | [How to Compress KV Cache in RL Post-Training? Shadow Mask Distillation for Memory-Efficient Alignment](https://arxiv.org/abs/2605.06850) | Rui Zhu, Weiheng Bai, Qiushi Wu, Yang Ren 외 (Yale, UMN, Indiana U.) | arXiv | RL 롤아웃 중 KV 압축이 유발하는 off-policy 편향을 Shadow Mask Distillation로 교정; 메모리 효율적 RLHF/RLAIF 활성화 | arXiv:2605.06850 |
| 2026 | [SkipKV: Selective Skipping of KV Generation and Storage for Efficient Inference with Large Reasoning Models](https://arxiv.org/abs/2512.07993) | (다수 저자) | MLSys 2026 | 장문 CoT 추론 모델 전용 문장-1차 점수 + 적응형 스티어링으로 KV 저장·생성 선택적 생략; DeepSeek-R1 계열 모델 평가 | arXiv:2512.07993 |

---

### D. 분산·분리 서빙 (Disaggregated & Distributed Serving)

> prefill-decode disaggregation, KV cache transfer, distributed KV pool, CXL/RDMA KV

2026년 5월 초 기준으로 분산 서빙 신규 arXiv 논문은 이전 보고서에서 수집한 Prefill-as-a-Service(arXiv:2604.15039), FlowKV(arXiv:2504.03775), PrefillShare(arXiv:2602.12029), TraCT(arXiv:2512.18194) 등이 주를 이루며, 해당 기간 내 새로운 분산 KV 전송 논문은 확인되지 않았다.

**이 기간 동향 요약**: Cross-datacenter KV 전송의 실용화(PrfaaS), CXL 공유 메모리 기반 rack-scale KV 공유(TraCT), RDMA 대비 최대 9.8× TTFT 개선 등이 이미 직전 보고서에 수록된 상태이다. 차기 연구 방향은 MoE 모델의 희소 expert KV와 disaggregation 결합으로 이동하는 추세이다.

---

### E. 아키텍처 수준 KV 절감 (Architecture-Level KV Reduction)

> MLA 및 변환 기법, cross-layer KV sharing, YOCO, NSA, TPA

2026년 5월 초 신규 arXiv 논문(2605 범위) 내에서 순수한 아키텍처 수준 KV 절감 논문은 확인되지 않았다. 직전 보고서에 YOCO++(arXiv:2604.13556), TransMLA(arXiv:2502.07864), MHA2MLA-VLM(arXiv:2601.11464) 등이 수록되어 있다.

**vLLM Q2 로드맵 관련**: MLA를 활용하는 DeepSeek 모델 계열에 대한 지원이 강화되고 있으며, MLA의 latent 표현을 확장하는 Stochastic KV Routing(arXiv:2604.22782, 기수집) 등이 직전 보고서에 포함되어 있다. 이 서브토픽은 직전 보고서 이후 신규 진입 논문 없음.

---

### F. 장문맥·오프로딩 (Long-Context & Offloading)

> 100K+ context KV 전략, CPU/NVMe KV offload, async prefetch, RAG×KV

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Tutti: Making SSD-Backed KV Cache Practical for Long-Context LLM Serving](https://arxiv.org/abs/2605.03375) | Shi Qiu, Yifan Hu, Xintao Wang, Wenhao Zhu 외 | arXiv | GPU-centric KV 객체 저장소로 CPU를 I/O 경로에서 제거, GPU io_uring + slack-aware I/O 스케줄링; LMCache 대비 TTFT 78.3% 절감, 처리량 2× | arXiv:2605.03375 |
| 2026 | [KV-Fold: One-Step KV-Cache Recurrence for Long-Context Inference](https://arxiv.org/abs/2605.12471) | Alireza Nadali, Patrick Cooper, Ashutosh Trivedi, Alvaro Velasquez | arXiv | KV 캐시를 시퀀스 청크에 대한 left fold 누산기로 처리하는 훈련-free 장문맥 추론 프로토콜; per-step drift가 평탄한 plateau로 안정화 | arXiv:2605.12471 |
| 2026 | [AdapShot: Adaptive Many-Shot In-Context Learning with Semantic-Aware KV Cache Reuse](https://arxiv.org/abs/2605.03644) | Jie Ou, Jinyu Guo 외 (UESTC) | arXiv | 출력 엔트로피 기반 최적 shot 수 탐색 + RoPE 회전 속성을 활용한 위치 분리 재인코딩으로 KV 캐시 재사용; many-shot ICL의 KV 연산 비용 절감 | arXiv:2605.03644 |

**산업 동향**: NVIDIA ICMSP(Inference Context Memory Storage Platform, 일명 CMX)가 CES 2026에서 발표되었으며 NVMe SSD로의 KV 오프로드를 표준화하고 있다. H100에서 Llama 3.1 70B를 128K 컨텍스트로 서빙할 때 단일 사용자 KV 캐시가 ~40 GB이므로, 다수 동시 사용자 지원에는 NVMe 오프로드가 필수적이다.

---

## 4. Open Problems

- **이론과 구현의 간격**: CapKV, RateQuant 등 정보이론 기반 방법들이 이론적 최적성을 증명하지만, 실제 FlashAttention-3 커널과의 통합 시 오버헤드가 상쇄될 수 있는지 시스템 차원의 검증이 필요하다.
- **CoT/추론 모델 전용 KV 정책**: SkipKV와 Shadow Mask Distillation이 시작을 알렸지만, DeepSeek-R1·Qwen3 계열의 수만~수십만 CoT 토큰에서의 KV 예산 정책은 표준화되지 않았다.
- **에이전트 워크플로 KV 선점**: SAGA·PBKV는 단일 서버 또는 간단한 DAG 워크플로를 가정한다. 실제 프로덕션의 복잡한 멀티-에이전트 그래프에서 KV 선점과 재사용을 최적화하는 범용 프레임워크가 부재하다.
- **하드웨어-소프트웨어 공동 설계**: Tutti(NVMe GPU-centric), Fluxion(CPU-GPU 협력), CXL 풀(TraCT) 등 이질적 메모리 계층별 최적 정책을 단일 서빙 시스템에서 통합 관리하는 계층 지능형 KV 스케줄러가 아직 없다.
- **멀티모달 KV 최적화**: RetentiveKV가 시각 토큰의 "지연 중요성" 문제를 제기했지만, 비디오·오디오 포함 장문맥 멀티모달에서의 KV 관리는 거의 연구되지 않았다.
- **Sparse Attention 인덱스 표준화**: Louver가 halfspace range searching으로 희소 어텐션을 정식화했으나, 동적 KV 성장 환경에서의 인덱스 유지 비용 및 갱신 정책이 미해결이다.

---

## 5. Notable Researchers / Groups

- **Tho Mai, Joo-Young Kim** (KAIST) — 어텐션 출력-aware eviction(LaProx), KV 시스템 공동 연구
- **Namyoon Lee, Yongjune Kim** (POSTECH) — 벡터 양자화 이론 기반 KV 압축(FibQuant)
- **Fei Zuo 팀** (BMW BA TechWorks, NUS, Tsinghua) — rate-distortion 최적 혼합 정밀도 KV 양자화(RateQuant)
- **Rui Zhu 팀** (Yale, UMN, Indiana U.) — RL post-training 단계 KV 압축 연구(Shadow Mask Distillation)
- **Mohsen Dehghankar, Abolfazl Asudeh** (확인 필요, 저자 소속 미확인) — 희소 어텐션의 이론적 재정식화(Louver)
- **Jiawei Jiang 팀** (Wuhan U., SJTU, HKUST) — 에이전트 워크플로 KV 서빙(PBKV)
- **Shi Qiu 팀** (Kai Chen 그룹, 확인 필요) — GPU-centric NVMe KV 오프로드(Tutti)
- **Enshuai Zhou, Yunji Chen 팀** (중국과학원 등, 확인 필요) — 종단간 학습 기반 eviction(LKV)
- **Alireza Nadali 팀** (CU Boulder 등, 확인 필요) — 재귀형 장문맥 KV 프로토콜(KV-Fold)
- **Pei-Chun Su** — 스펙트럼 분해 + 양자화 파이프라인(eOptShrinkQ)

---

## 6. Resources

### Datasets & Benchmarks
- **LongBench v2** — 장문맥 이해 평가, KV eviction 품질 측정에 광범위하게 사용 ([GitHub](https://github.com/THUDM/LongBench))
- **RULER** — 다양한 길이에서의 장문맥 이해 벤치마크 (KV 압축 품질 평가 표준)
- **AIME-24, LiveCodeBench, MATH-500, GSM8K** — CoT/추론 모델 KV 압축 평가에 SkipKV 등이 사용

### Code & Frameworks
- **vLLM** ([github.com/vllm-project/vllm](https://github.com/vllm-project/vllm)) — Tutti NVMe 통합, TurboQuant KV, INT8 동적 양자화
- **SGLang** ([github.com/sgl-project/sglang](https://github.com/sgl-project/sglang)) — TurboQuant KV(ICLR 2026) 통합, NSA fuse store indexer, IndexCache
- **LMCache** ([github.com/LMCache/LMCache](https://github.com/LMCache/LMCache)) — KV 공유·오프로드 레이어, Tutti 비교 기준선
- **Kitty** ([github.com/Summer-Summer/Kitty](https://github.com/Summer-Summer/Kitty)) — 2-bit 동적 채널 정밀도 부스팅 구현

---

## 7. Reading List

1. **(입문)** "KV Cache Optimization Strategies for Scalable and Efficient LLM Inference" (arXiv:2603.20397) — 2026년 3월 서베이, 5대 최적화 방향 체계적 정리
2. **(입문)** "A Survey on Large Language Model Acceleration based on KV Cache Management" (arXiv:2412.19442) — 2024년 말 포괄적 서베이
3. **(심화-양자화)** RateQuant (arXiv:2605.06675) — rate-distortion 이론 기반 최적 bit 배분 이해
4. **(심화-eviction)** CapKV (arXiv:2604.25975) — Information Bottleneck 관점의 eviction 이론
5. **(심화-시스템)** Tutti (arXiv:2605.03375) — GPU-centric NVMe KV 오프로드 설계
6. **(심화-에이전트)** SAGA (arXiv:2605.00528) — 에이전트 워크플로 KV 스케줄링 시스템
7. **(심화-CoT)** Shadow Mask Distillation (arXiv:2605.06850) — RL 롤아웃의 KV 압축 편향 수정

---

## 8. Methodology

### 사용한 검색 쿼리
- `"KV cache" LLM optimization 2026 arxiv new`
- `KV cache quantization compression LLM 2026 arxiv`
- `prefill decode disaggregation KV cache distributed serving 2026`
- `token eviction sparse attention KV cache 2026 arxiv`
- `KV cache arxiv 2605 2026 May new papers`
- `MLA multi-head latent attention KV cache architecture 2026 arxiv`
- `long context KV cache offloading CPU NVMe 100K tokens 2026`
- `vLLM SGLang update release 2026 April May KV cache`
- `cross-layer KV sharing YOCO NSA TPA 2026 new arxiv`
- `ICLR 2026 accepted papers KV cache optimization LLM`
- `MLSys 2026 accepted papers KV cache LLM inference`
- 각 논문별 구체적 제목/arXiv ID 추가 검색 (총 20회 이상)

### 수집 출처
- arXiv cs.LG, cs.CL, cs.DC, cs.AR (2605.* 논문 중점 탐색)
- ICLR 2026, MLSys 2026 accepted paper lists
- SGLang NVIDIA 공식 릴리즈 노트 (RN-08516-001_v26.04)
- vLLM GitHub releases 및 Q2 2026 roadmap issue
- WebSearch + 개별 논문 추가 검색

### 신규성 필터링 적용
- 직전 보고서(`kv-cache-optimization-2026-05-04.md`) 포함 이전 보고서 전체에서 추출한 KNOWN_URLS 133건, KNOWN_TITLES 및 KNOWN_METHODS 집합과 대조
- 매칭된 기존 항목 제외 후 최종 신규 논문 **15건** 포함 (arXiv:2604.25975 포함)
- D(분산 서빙), E(아키텍처) 영역은 2026년 5월 초 기준 신규 arXiv 논문 없음으로 명시

### 가정·한계
- 기본값 적용: `depth=overview`, `language=ko` (명세 파일에 명시되어 있음)
- arXiv HTML 버전이 403 Forbidden 응답을 반환하여 일부 논문의 저자·소속을 WebSearch 보조 검색으로 확보; 소속 미확인 항목은 "확인 필요"로 표기
- arXiv 2605.* 범위(2026-05-05 ~ 2026-05-13)는 제출 후 아직 발표되지 않은 논문 포함; peer review 통과 여부 미확인
- MLSys 2026 목록 중 `MorphServe`(arXiv:2506.02006)는 2026-06 제출로 time_range 밖이어서 제외
- PBKV(arXiv:2605.06472), Fluxion(arXiv:2605.07719) 등의 전체 저자 소속 일부 미확인
- `SkipKV`(arXiv:2512.07993)는 2025-12 제출이나 MLSys 2026 채택 확인됨; time_range 내 자료로 포함
