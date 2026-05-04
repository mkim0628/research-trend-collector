---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-02
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-02)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview

---

## 1. Executive Summary

### 트렌드 1: 회전(Rotation) 기반 2-bit KV 양자화의 성숙
2025년 초~중반에 Hadamard/FWHT 회전 변환을 KV 텐서에 적용해 아웃라이어를 재분산한 뒤 2-bit 양자화를 수행하는 방법론이 복수의 독립 연구에서 동시에 등장했다. RotateKV([arXiv:2501.16383](https://arxiv.org/abs/2501.16383))는 채널 재정렬 기반 아웃라이어 인식 회전으로 WikiText-2 PPL 저하 0.3 이내(LLaMA-2-13B)를 달성했고, KVLinC([arXiv:2510.05373](https://arxiv.org/abs/2510.05373))는 Hadamard 회전과 선형 보정 어댑터를 결합해 기존 Flash Attention 대비 최대 2.55× 속도를 실현했다. AQUA-KV([arXiv:2501.19392, ICML 2025](https://arxiv.org/abs/2501.19392))는 레이어 간 K–V 의존성을 활용한 적응형 어댑터 방식으로 2~2.5bit에서 거의 무손실(perplexity 상대 오차 1% 미만)을 달성했다. 이들 기법은 2-bit KV 양자화를 실용적 수준으로 끌어올렸다.

### 트렌드 2: KV 축출 정책의 고도화 — OBD 이론·RL·시간 적응
단순 누적 어텐션 가중치 기반 축출에서 벗어나, (a) Optimal Brain Damage(OBD) 이론을 KV 단위 프루닝에 적용하거나(OBCache, [arXiv:2510.07651](https://arxiv.org/abs/2510.07651)), (b) RL 에이전트로 미래 유용성을 학습하거나(KV Policy/KVP, [arXiv:2602.10238](https://arxiv.org/abs/2602.10238)), (c) 레이어별·시간별 이중 적응을 수행(Lethe, [arXiv:2511.06029](https://arxiv.org/abs/2511.06029); CAKE, [arXiv:2503.12491](https://arxiv.org/abs/2503.12491))하는 연구가 쏟아졌다. PagedEviction([arXiv:2509.04377](https://arxiv.org/abs/2509.04377))은 vLLM PagedAttention과 직접 통합되는 블록 단위 구조화 프루닝으로 Full Cache 대비 37% 처리량 향상을 보고했다.

### 트렌드 3: 크로스 데이터센터 P/D 분리와 계층적 KV 스토어의 제품화
Prefill-as-a-Service([arXiv:2604.15039](https://arxiv.org/abs/2604.15039))가 Ethernet 기반 데이터센터 간 KVCache 전송을 실증하며 P/D 분리의 지리적 범위를 확장했다. SGLang HiCache([LMSYS Blog 2025-09](https://www.lmsys.org/blog/2025-09-10-sglang-hicache/))는 RadixAttention을 GPU(L1)·CPU(L2)·분산 스토리지(L3) 3계층으로 확장해 캐시 히트 시 TTFT 80% 감소·처리량 6×를 달성했다. vLLM V1([vLLM Blog 2025-01](https://blog.vllm.ai/2025/01/27/v1-alpha-release.html))은 KV 캐시 관리자 전면 재설계와 CPU 오프로딩, FP8·TurboQuant 2-bit 지원을 통합했다. CacheFlow([arXiv:2604.25080](https://arxiv.org/abs/2604.25080))는 토큰·레이어·GPU 3차원 병렬성으로 KV 캐시 복원 TTFT를 기존 대비 10~62% 단축했다.

### 트렌드 4: 아키텍처 수준 크로스 레이어 KV 공유의 다양화
Stochastic KV Routing([arXiv:2604.22782](https://arxiv.org/abs/2604.22782), Apple)은 학습 중 무작위 레이어 어텐션을 통해 배포 시 다양한 depth-wise 캐시 공유에 유연하게 적응하는 방법을 제안했다. CommonKV([arXiv:2508.16134](https://arxiv.org/abs/2508.16134))는 인접 레이어 파라미터의 SVD 공유로 훈련 없이 98%까지 압축 가능하다고 보고했다. 이로써 cross-layer KV 공유가 고정 topology(CLA, LCKV 등)에서 학습 시 확률적 방법으로 진화하는 패턴이 나타나고 있다.

### 트렌드 5: Reasoning 모델 특화 KV 관리와 장문맥 오프로딩 다변화
Long-CoT(Chain-of-Thought) 모델의 KV 폭증에 대응하는 전문 기법이 등장했다. Crystal-KV([arXiv:2601.16986](https://arxiv.org/abs/2601.16986))는 '답 우선 원칙'으로 추론 체인 토큰과 최종 답 토큰의 KV 예산을 차등 관리한다. Lethe([arXiv:2511.06029](https://arxiv.org/abs/2511.06029))는 추론 집약적 서빙에서 레이어별·시간별 이중 적응으로 KV 90% 절감과 2.56× 처리량 향상을 달성했다. 오프로딩 측에서는 에지 디바이스를 위한 NVMe-Direct 이중 경로(Dual-Blade, [arXiv:2604.26557](https://arxiv.org/abs/2604.26557))와 디스크 인식 KVSwap([arXiv:2511.11907, MobiSys 2026](https://arxiv.org/abs/2511.11907))이 모바일·임베디드 환경까지 영역을 넓혔다.

---

## 2. Landscape — 분야 지형도

직전 보고서(2026-04-30)와 비교해, 이번 기간에 주목할 구조적 변화는 다음과 같다.

```
LLM KV 캐시 최적화 (2026-05 업데이트)
├── A. 서빙 시스템·메모리 관리
│   ├── vLLM V1 재설계 (KV 관리자 전면 리빌드, CPU 오프로딩 통합)
│   ├── SGLang HiCache (3계층 RadixAttention → GPU/CPU/분산 스토리지)
│   ├── ContiguousKV (프리픽스 오프로딩 + 비동기 프리페치)
│   └── CacheFlow (3D-병렬 KV 복원 스케줄러)
│
├── B. KV 양자화·압축
│   ├── 회전 기반 2-bit (RotateKV, KVLinC, AQUA-KV)   ← 신규 집단
│   ├── 멀티 에이전트 공유 압축 풀 (PolyKV)
│   └── CommonKV (SVD 크로스 레이어 파라미터 공유)
│
├── C. 토큰 축출·희소 어텐션
│   ├── OBD 이론 기반 (OBCache)
│   ├── RL 학습 축출 (KV Policy/KVP)
│   ├── 레이어별·시간 이중 적응 (Lethe, CAKE)
│   ├── 블록 구조화 축출 (PagedEviction)
│   ├── 깊이별 예산 차등 (DepthKV)
│   ├── 구조 보존 (StructKV)
│   └── Reasoning 특화 (Crystal-KV)
│
├── D. 분산·분리 서빙 및 KV 전송
│   ├── 크로스 데이터센터 PD 분리 (Prefill-as-a-Service)
│   ├── 3D-병렬 KV 복원 (CacheFlow)
│   └── 멀티 에이전트 집합 KV 공유 (TokenDance)
│
├── E. 아키텍처 수준 KV 절감
│   ├── Stochastic KV Routing (학습 시 확률적 레이어 공유)
│   └── CommonKV (훈련 없는 SVD 레이어 파라미터 공유)
│
└── F. 장문맥·계층적 오프로딩
    ├── 시간 계층 KV 관리 (TTKV)
    ├── NVMe-Direct 에지 오프로딩 (Dual-Blade)
    ├── 디스크 인식 on-device 오프로딩 (KVSwap)
    ├── 컨텍스트 집약 태스크 오프로딩 평가 (KV Cache Offloading for Context-Intensive Tasks)
    ├── 프리픽스 오프로딩 + 비동기 프리페치 (ContiguousKV)
    └── 예측형 멀티 티어 메모리 관리 (Predictive Multi-Tier)
```

### 주요 흐름 간 신규 상호작용

- **B 회전 양자화 + C 축출 결합**: KVzap([arXiv:2601.07891](https://arxiv.org/abs/2601.07891), NVIDIA)은 KVpress 리더보드에서 2~4× 압축 SOTA를 달성하며 양자화+프루닝의 통합 접근이 경쟁력을 가짐을 재확인했다.
- **D 다중 에이전트 + D 전송**: TokenDance([arXiv:2604.03143](https://arxiv.org/abs/2604.03143))는 에이전트 집합 실행에서 KV diff 블록 공유로 11~17× 압축, 2.7× 더 많은 동시 에이전트를 지원한다.
- **A SGLang HiCache + F 오프로딩**: 계층적 KV 스토어가 서빙 시스템 안으로 내재화되면서, 기존 "별도 오프로딩 라이브러리" 패러다임이 "서빙 엔진 내장 계층 관리"로 이동하는 추세가 뚜렷하다.
- **C Reasoning 특화**: Crystal-KV, Lethe 등이 CoT/Reasoning 모델의 KV 관리를 독립 서브필드로 확립하고 있다.

---

## 3. Recent Work

> 아래 표에 수록된 논문은 직전 보고서(2026-04-30)의 `KNOWN_URLS`/`KNOWN_TITLES`/`KNOWN_METHODS` 집합과 대조 후 **신규**로 확인된 항목만 포함한다.

### A. 서빙 시스템·메모리 관리

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [vLLM V1: A Major Upgrade to vLLM's Core Architecture](https://blog.vllm.ai/2025/01/27/v1-alpha-release.html) | vLLM Team | vLLM Blog 2025-01 | KV 관리자·스케줄러·워커 전면 재설계; CPU 오프로딩, FP8·TurboQuant 2-bit KV, 멀티모달 prefix caching 통합 | Blog |
| 2025 | [SGLang HiCache: Fast Hierarchical KV Caching](https://www.lmsys.org/blog/2025-09-10-sglang-hicache/) | SGLang/LMSYS Team | LMSYS Blog 2025-09 | RadixAttention을 GPU(L1)·CPU(L2)·분산 스토리지(L3) 3계층으로 확장; TTFT 80%↓, 처리량 6×↑ | Blog |
| 2026 | [ContiguousKV: Accelerating LLM Prefill with Granularity-Aligned KV Cache Management](https://arxiv.org/abs/2601.13631) | Jing Zou et al. | arXiv 2026-01 | 프리픽스 KV 오프로딩 시 청크 단위 정렬 + 비동기 프리페치; 최신 오프로딩 대비 Re-Prefill 3.85×↑ | arXiv:2601.13631 |
| 2026 | [CacheFlow: Efficient LLM Serving with 3D-Parallel KV Cache Restoration](https://arxiv.org/abs/2604.25080) | Sean Nian et al. (UIUC, NUS) | arXiv 2026-04 | 토큰·레이어·GPU 3차원 병렬 KV 복원; 배치 인식 투포인터 스케줄러로 TTFT 10~62%↓ | arXiv:2604.25080 |
| 2026 | [Prefill-as-a-Service: KVCache of Next-Generation Models Could Go Cross-Datacenter](https://arxiv.org/abs/2604.15039) | Ruoyu Qin et al. | arXiv 2026-04 | 크로스 데이터센터 P/D 분리; Ethernet 기반 KVCache 전송 + bandwidth-aware 스케줄링; 처리량 54%↑, P90 TTFT 64%↓ | arXiv:2604.15039 |
| 2026 | [TokenDance: Scaling Multi-Agent LLM Serving via Collective KV Cache Sharing](https://arxiv.org/abs/2604.03143) | — | arXiv 2026-04 | 멀티 에이전트 All-Gather 패턴 KV diff 공유; 11~17× 압축, vLLM 대비 2.7× 더 많은 동시 에이전트 지원 | arXiv:2604.03143 |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [RotateKV: Accurate and Robust 2-Bit KV Cache Quantization via Outlier-Aware Adaptive Rotations](https://arxiv.org/abs/2501.16383) | Zunhai Su et al. | arXiv 2025-01 | 채널 재정렬 아웃라이어 인식 FWHT 회전 + Pre-RoPE 그룹헤드 회전 + 어텐션 싱크 인식 양자화; 2-bit PPL 저하 0.3↓ (LLaMA-2-13B) | arXiv:2501.16383 |
| 2025 | [Cache Me If You Must: Adaptive Key-Value Quantization (AQUA-KV)](https://arxiv.org/abs/2501.19392) | Alina Shutova et al. | ICML 2025 | K–V 의존성 활용 적응형 어댑터; 2~2.5bit에서 LongBench perplexity 상대 오차 1% 미만; 단일 GPU 1~6h 보정 | arXiv:2501.19392 |
| 2025 | [KVLinC: KV Cache Quantization with Hadamard Rotation and Linear Correction](https://arxiv.org/abs/2510.05373) | Utkarsh Saxena, Kaushik Roy | arXiv 2025-10 (Under Review) | Hadamard 회전 + 선형 보정 어댑터; FA 대비 최대 2.55× 추론 가속 | arXiv:2510.05373 |
| 2025 | [CommonKV: Compressing KV Cache with Cross-layer Parameter Sharing](https://arxiv.org/abs/2508.16134) | Yixuan Wang et al. | arXiv 2025-08 | SVD 인접 레이어 파라미터 공유; 이기종 기법과 결합 시 98% 압축 가능 | arXiv:2508.16134 |
| 2026 | [KVzap: Fast, Adaptive, and Faithful KV Cache Pruning](https://arxiv.org/abs/2601.07891) | Simon Jegou, Maximilian Jeblick (NVIDIA) | arXiv 2026-01 | KVzip 경량 근사 + 입력 밀도 적응 임계치; KVpress 리더보드 2~4× 압축 SOTA | arXiv:2601.07891 |
| 2026 | [PolyKV: A Shared Asymmetrically-Compressed KV Cache Pool for Multi-Agent LLM Inference](https://arxiv.org/abs/2604.24971) | Ishan Patel, Ishan Joshi | arXiv 2026-04 | K int8 + V TurboQuant 3-bit 비대칭 압축 풀 공유; 15에이전트 4K 컨텍스트 KV 97.7%↓ | arXiv:2604.24971 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [OBCache: Optimal Brain KV Cache Pruning for Efficient Long-Context LLM Inference](https://arxiv.org/abs/2510.07651) | Yuzhe Gu et al. | arXiv 2025-10 | OBD 이론 적용; K·V·KV 쌍 토큰 현저성 closed-form 점수, 어텐션 출력 섭동 최소화 | arXiv:2510.07651 |
| 2025 | [PagedEviction: Structured Block-wise KV Cache Pruning for Efficient LLM Inference](https://arxiv.org/abs/2509.04377) | Krishna Teja Chitty-Venkata et al. | EACL 2026 Findings | vLLM PagedAttention 블록 단위 구조화 프루닝; Full Cache 대비 처리량 37%↑ | arXiv:2509.04377 |
| 2025 | [Lethe: Layer- and Time-Adaptive KV Cache Pruning for Reasoning-Intensive LLM Serving](https://arxiv.org/abs/2511.06029) | Hui Zeng et al. | arXiv 2025-11 | 레이어별 희소성 인식 예산 + RASR 시간 적응; Full Cache 대비 KV 91.7%↓, 처리량 2.56×↑ | arXiv:2511.06029 |
| 2025 | [CAKE: Cascading and Adaptive KV Cache Eviction with Layer Preferences](https://arxiv.org/abs/2503.12491) | Ziran Qin et al. | arXiv 2025-03 | 공간·시간 어텐션 동역학 기반 레이어별 캐시 크기 결정; KV 3.2%에서 성능 유지, 128K 컨텍스트 10×↑ | arXiv:2503.12491 |
| 2025 | [DepthKV: Layer-Dependent KV Cache Pruning for Long-Context LLM Inference](https://arxiv.org/abs/2604.24647) | Zahra Dehghanighobadi, Asja Fischer | arXiv 2026-04 | 레이어 민감도 기반 비균일 KV 예산 할당; 균일 할당 대비 장문맥 태스크 전반 일관적 성능 향상 | arXiv:2604.24647 |
| 2025 | [StructKV: Preserving the Structural Skeleton for Scalable Long-Context Inference](https://arxiv.org/abs/2604.06746) | Zhirui Chen et al. | arXiv 2026-04 | 글로벌 In-Degree Centrality로 정보 허브 보존; LongBench·RULER에서 극단적 압축률에서도 near-lossless | arXiv:2604.06746 |
| 2026 | [Learning to Evict from Key-Value Cache (KV Policy / KVP)](https://arxiv.org/abs/2602.10238) | Luca Moschella et al. | arXiv 2026-02 | 헤드별 경량 RL 에이전트; 생성 트레이스에서 미래 유용성 학습; RULER·LongBench 제로샷 일반화 | arXiv:2602.10238 |
| 2026 | [Crystal-KV: Efficient KV Cache Management for Chain-of-Thought LLMs via Answer-First Principle](https://arxiv.org/abs/2601.16986) | Zihan Wang et al. | arXiv 2026-01 | 답 우선 원칙으로 CoT 추론·답변 토큰 KV 예산 차등 관리; Long-CoT 모델 특화 | arXiv:2601.16986 |

### D. 분산·분리 서빙 및 KV 전송

(이 서브토픽의 신규 논문은 A 서빙 시스템 표와 일부 중복되므로, A 표의 Prefill-as-a-Service, TokenDance, CacheFlow를 함께 참조)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Prefill-as-a-Service: KVCache of Next-Generation Models Could Go Cross-Datacenter](https://arxiv.org/abs/2604.15039) | Ruoyu Qin et al. | arXiv 2026-04 | 크로스 데이터센터 P/D 분리; 이종 배포에서 처리량 54%↑, P90 TTFT 64%↓ | arXiv:2604.15039 |
| 2026 | [CacheFlow: Efficient LLM Serving with 3D-Parallel KV Cache Restoration](https://arxiv.org/abs/2604.25080) | Sean Nian et al. | arXiv 2026-04 | 3D-병렬 KV 복원 + 배치 인식 스케줄링; TTFT 10~62%↓ | arXiv:2604.25080 |
| 2026 | [TokenDance: Scaling Multi-Agent LLM Serving via Collective KV Cache Sharing](https://arxiv.org/abs/2604.03143) | — | arXiv 2026-04 | 멀티 에이전트 집합 KV diff 압축 공유; 2.7× 동시 에이전트↑ | arXiv:2604.03143 |

### E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [CommonKV: Compressing KV Cache with Cross-layer Parameter Sharing](https://arxiv.org/abs/2508.16134) | Yixuan Wang et al. | arXiv 2025-08 | SVD로 인접 레이어 파라미터 공유 + 코사인 유사도 기반 적응 예산 할당; 기존 저랭크·크로스레이어 대비 전반적 우위 | arXiv:2508.16134 |
| 2026 | [Stochastic KV Routing: Enabling Adaptive Depth-Wise Cache Sharing](https://arxiv.org/abs/2604.22782) | Anastasiia Filippova et al. (Apple) | arXiv 2026-04 | 훈련 중 무작위 크로스 레이어 어텐션으로 배포 시 임의 depth-wise 공유에 강건한 모델 학습 | arXiv:2604.22782 |

### F. 장문맥·계층적 오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [TTKV: Temporal-Tiered KV Cache for Long-Context LLM Inference](https://arxiv.org/abs/2604.19769) | Gradwell Dzikanyanga et al. (HIT Shenzhen, GDPU) | arXiv 2026-04 | 인간 기억 시스템 영감; HBM(고속·고정밀)과 DRAM(저속·저정밀) 시간 계층 분할; 크로스 티어 트래픽 최대 5.94×↓, 지연 76%↓ | arXiv:2604.19769 |
| 2025 | [KVSwap: Disk-aware KV Cache Offloading for Long-Context On-device Inference](https://arxiv.org/abs/2511.11907) | Huawei Zhang et al. | MobiSys 2026 | NVMe·UFS·eMMC 디스크 특성 인식 교체 정책; 저예산 메모리에서 품질 유지 처리량 향상 | arXiv:2511.11907 |
| 2026 | [Dual-Blade: Dual-Path NVMe-Direct KV-Cache Offloading for Edge LLM Inference](https://arxiv.org/abs/2604.26557) | Bodon Jeong et al. | arXiv 2026-04 | 페이지 캐시 경로 + NVMe-Direct 경로 이중 경로; 런타임 메모리 가용성 기반 동적 배치 + 파이프라인 병렬성 | arXiv:2604.26557 |
| 2026 | [KV Cache Offloading for Context-Intensive Tasks](https://arxiv.org/abs/2604.08426) | Andrey Bocharnikov et al. (HSE, Yandex) | arXiv 2026-04 | Text2JSON 벤치마크 제안; 컨텍스트 집약 태스크에서 기존 KV 오프로딩의 성능 저하 실증 | arXiv:2604.08426 |
| 2026 | [ContiguousKV: Accelerating LLM Prefill with Granularity-Aligned KV Cache Management](https://arxiv.org/abs/2601.13631) | Jing Zou et al. | arXiv 2026-01 | 프리픽스 KV 오프로딩 시 청크 정렬 + 레이어 간 유사 인덱스 활용 비동기 프리페치; IMPRESS 대비 Re-Prefill 3.85×↑ | arXiv:2601.13631 |
| 2026 | [Predictive Multi-Tier Memory Management for KV Cache in Large-Scale GPU Inference](https://arxiv.org/abs/2604.26968) | Sanjeev Rao Ganjihal | arXiv 2026-04 | 아키텍처 변형 인식 사이징 엔진; 배치 크기 최대 7.4×↑ | arXiv:2604.26968 |

---

## 4. Open Problems

### 문제 1: 회전 기반 2-bit 양자화와 토큰 축출의 통합
RotateKV, KVLinC, AQUA-KV 등 회전 기반 2-bit 양자화는 개별 토큰의 채널 분포를 균일하게 만들지만, 이 변환 후의 KV에 기존 어텐션 가중치 기반 중요도 점수(SnapKV, H2O 등)를 그대로 적용할 수 있는지는 검증되지 않았다. 회전 변환 후 공간에서 토큰 축출 정책을 재설계하거나, 원본 공간의 중요도 점수를 회전 공간으로 매핑하는 방법론이 필요하다.

### 문제 2: Reasoning 모델 KV 관리의 평가 표준 부재
Crystal-KV, Lethe, ForesightKV(직전 보고서)가 각기 다른 벤치마크(AIME, LongBench, RULER, OASST)를 사용해 Reasoning 특화 KV 관리 기법을 평가하고 있어 직접 비교가 불가능하다. 추론 체인 보존 능력(논리적 연결고리 유지), 중간 추론 토큰의 KV 재사용률, 답 품질 대비 메모리 절감 등을 통합 측정하는 Reasoning-aware KV 벤치마크가 부재하다.

### 문제 3: 계층적 KV 스토어의 일관성·보안
SGLang HiCache, vLLM V1 CPU 오프로딩, LMCache 등이 GPU/CPU/디스크 계층을 혼용하는 서빙 환경이 일반화되었으나, (a) 멀티테넌트 환경에서 KV 캐시 세그먼트 간 데이터 잔류·혼선, (b) 계층 간 이동 중 메모리 오염(corruption) 복구 정책, (c) 계층 간 이동이 출력 결정론성에 미치는 영향이 체계적으로 다뤄지지 않았다.

### 문제 4: 크로스 데이터센터 KV 전송의 QoS 보장
Prefill-as-a-Service가 Ethernet 기반 크로스 데이터센터 KVCache 전송의 가능성을 보였지만, (a) 네트워크 혼잡 시 SLO(TTFT) 보장, (b) 1T+ 파라미터 모델에서 KVCache 크기(MLA 미사용 시 수 GB)를 Ethernet으로 전송하는 비용 대비 효익, (c) 모델 아키텍처(MLA vs. GQA)에 따른 적용 가능성 차이 등이 미해결 상태이다.

### 문제 5: NVMe 오프로딩의 에지 디바이스 일반화
KVSwap, Dual-Blade는 에지 디바이스의 NVMe/UFS/eMMC 다양성을 인식하는 오프로딩을 제안하지만, 실제 Android/iOS 디바이스 OS의 스토리지 I/O 스케줄러, 저전력 모드에서의 SSD 특성 변동, 스토리지 수명(내구성) 소모 문제 등 실운영 변수가 충분히 검증되지 않았다.

---

## 5. Notable Researchers / Groups

이번 수집에서 새로 확인된 주요 연구자·그룹을 추가한다. (기존 인물은 직전 보고서 참조)

| 이름/그룹 | 소속 | 대표 기여 (이번 수집 기준) |
|-----------|------|--------------------------|
| **Kaushik Roy 그룹** | Purdue University | KVLinC (Hadamard 회전 + 선형 보정 KV 양자화) |
| **Dan Alistarh 그룹** | IST Austria / Neural Magic | AQUA-KV (적응형 K–V 어댑터 양자화), ICML 2025 |
| **NVIDIA Research (Simon Jegou 등)** | NVIDIA | KVzap (kvpress 리더보드 SOTA 2~4× 압축) |
| **Apple ML Research (Marco Cuturi 등)** | Apple | Stochastic KV Routing (depth-wise 캐시 공유 학습) |
| **Fan Lai 그룹** | UIUC | CacheFlow (3D-병렬 KV 복원 스케줄링) |
| **Jidong Zhai 그룹** | Tsinghua University | Lethe (Reasoning 집약적 서빙 레이어·시간 적응 축출) |
| **Weikuan Yu 그룹** | Florida State University | Dual-Blade (NVMe-Direct 에지 KV 오프로딩) |
| **Zheng Wang 그룹** | University of Leeds | KVSwap (디스크 인식 on-device KV 오프로딩, MobiSys 2026) |

---

## 6. Resources

### 신규 오픈소스 프레임워크 및 라이브러리

| 자원 | URL | 설명 |
|------|-----|------|
| kvpress (NVIDIA) | https://github.com/NVIDIA/kvpress | LLM KV 캐시 압축 통합 라이브러리; KVzap, RotateKV 등 수록 |
| SGLang HiCache | https://docs.sglang.io/docs/advanced_features/hicache_design | SGLang 계층적 KV 캐싱 설계 문서 |
| vLLM V1 Guide | https://docs.vllm.ai/en/stable/usage/v1_guide/ | vLLM V1 엔진 사용 가이드 |
| KVSwap Code | https://github.com/hwhwz23/KVSWAP-CODE | 디스크 인식 on-device KV 오프로딩 구현 |

### 신규 벤치마크

| 자원 | URL/arXiv | 설명 |
|------|----------|------|
| Text2JSON | arXiv:2604.08426 | 컨텍스트 집약 KV 오프로딩 평가 벤치마크; Yandex/HSE 제공 |
| KVpress Leaderboard | https://github.com/NVIDIA/kvpress | KV 압축 기법 통합 비교 리더보드 (NVIDIA) |

---

## 7. Reading List

직전 보고서의 리딩 리스트를 보완하는 **신규** 추천 자료이다.

### 최신 핵심 (2025~2026)

1. **[RotateKV](https://arxiv.org/abs/2501.16383)** (Su et al., 2025) — 회전 기반 2-bit KV 양자화 입문; 아웃라이어 처리 방법론의 기준점.
2. **[AQUA-KV / Cache Me If You Must](https://arxiv.org/abs/2501.19392)** (Shutova et al., ICML 2025) — K–V 의존성 활용 적응형 어댑터; 2-bit 근무손실 달성 방법론.
3. **[SGLang HiCache Blog](https://www.lmsys.org/blog/2025-09-10-sglang-hicache/)** (SGLang Team, 2025) — 계층적 KV 스토어 시스템 설계 원리.
4. **[vLLM V1 Blog](https://blog.vllm.ai/2025/01/27/v1-alpha-release.html)** (vLLM Team, 2025) — 서빙 엔진 KV 관리 재설계 아키텍처 결정 근거.
5. **[Lethe](https://arxiv.org/abs/2511.06029)** (Zeng et al., 2025) — Reasoning 집약 서빙 KV 관리; 레이어·시간 이중 적응 설계.
6. **[KVzap](https://arxiv.org/abs/2601.07891)** (Jegou & Jeblick, NVIDIA, 2026) — kvpress 리더보드 기준 현 SOTA 압축; 양자화+프루닝 통합 접근.
7. **[Prefill-as-a-Service](https://arxiv.org/abs/2604.15039)** (Qin et al., 2026) — 크로스 데이터센터 P/D 분리; 인프라 확장 방향 이해.
8. **[Crystal-KV](https://arxiv.org/abs/2601.16986)** (Wang et al., 2026) — CoT LLM KV 관리의 구조적 접근; Reasoning 특화 연구 입문.

---

## 8. Methodology

### 검색 쿼리

```
KV cache quantization LLM 2025 2026 arxiv new
KV cache eviction token pruning LLM arxiv 2025 new methods
prefill decode disaggregation KV cache transfer arxiv 2025 2026 new
vLLM SGLang KV cache update new features 2025 2026
MLA cross-layer KV sharing architecture arxiv 2025 2026 new papers
KV cache offloading CPU NVMe long context LLM arxiv 2025 2026 new
long context KV cache 100k tokens new methods arxiv 2025 2026
KV cache quantization RotateKV AQUA-KV KVLinC arxiv 2025
arxiv 2604.15039 "Prefill-as-a-Service" KVCache cross-datacenter
arxiv 2509.04377 PagedEviction block-wise KV cache pruning
arxiv 2510.07651 OBCache optimal brain KV cache pruning
arxiv 2601.16383 RotateKV 2-bit quantization outlier rotation
arxiv 2511.06029 Lethe layer time-adaptive KV cache reasoning
arxiv 2601.07891 KVzap fast adaptive KV cache pruning
arxiv 2508.16134 CommonKV cross-layer parameter sharing
arxiv 2604.22782 Stochastic KV Routing adaptive depth-wise
arxiv 2604.06746 StructKV structural skeleton long-context
SGLang HiCache hierarchical KV caching blog 2025
vLLM V1 engine rewrite 2025 KV cache updates blog
TokenDance multi-agent LLM serving collective KV cache sharing
```

### 수집 출처

- arXiv (cs.LG, cs.CL, cs.DC, cs.AR, cs.OS): 2025-01 ~ 2026-04
- 학회: ICML 2025, EACL 2026 Findings, MobiSys 2026
- 프레임워크 블로그: vLLM Blog, LMSYS Blog (SGLang)
- 논문 메타데이터: arXiv HTML 페이지, ResearchGate, EmergentMind, AlphaXiv

### 신규성 필터링

- 기준: 직전 보고서(2026-04-30)의 `KNOWN_URLS` 96개 URL 집합과 대조.
- 제외된 기존 항목: 96건 (직전 보고서에 이미 수록된 모든 URL).
- 신규 포함 항목: 아래 URL 집합 (총 29건).
  - `arXiv:2501.16383`, `arXiv:2501.19392`, `arXiv:2510.05373`, `arXiv:2508.16134`, `arXiv:2601.07891`, `arXiv:2604.24971`, `arXiv:2510.07651`, `arXiv:2509.04377`, `arXiv:2511.06029`, `arXiv:2503.12491`, `arXiv:2604.24647`, `arXiv:2604.06746`, `arXiv:2602.10238`, `arXiv:2601.16986`, `arXiv:2604.15039`, `arXiv:2604.25080`, `arXiv:2604.03143`, `arXiv:2604.19769`, `arXiv:2511.11907`, `arXiv:2604.26557`, `arXiv:2604.08426`, `arXiv:2601.13631`, `arXiv:2604.26968`, `arXiv:2604.22782`, vLLM V1 Blog, SGLang HiCache Blog.

### 가정 및 한계

- arXiv 2025~2026 논문 중 동료 심사가 완료된 것은 ICML 2025(AQUA-KV), EACL 2026 Findings(PagedEviction), MobiSys 2026(KVSwap) 외 다수가 프리프린트 상태이다. 최종 출판본에서 결과 수치가 변경될 수 있다.
- KVLinC(arXiv:2510.05373)는 "Under Review"로 표기되어 있으며 최종 게재지가 확정되지 않았다.
- TokenDance(arXiv:2604.03143) 저자 목록이 검색 결과에서 확인되지 않아 기재를 생략했다. 확인 필요.
- PolyKV의 결과는 소규모 독립 연구자의 프리프린트로, 재현 검증이 권고된다.
- 수치(배속, 압축률)는 각 논문이 자체 보고한 값이며 하드웨어·기준선이 상이하여 직접 비교에 주의가 필요하다.
- 검색 쿼리 특성상 비영어권(중국어, 일본어 등) 학회·저널의 관련 논문은 일부 누락되었을 수 있다.
