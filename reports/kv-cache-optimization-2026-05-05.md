---
type: trend-report
topic: "LLM KV 캐시 최적화"
slug: kv-cache-optimization
date: 2026-05-05
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM KV 캐시 최적화 — Research Trend Report (2026-05-05)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview
>
> **신규성 주의:** 본 보고서는 직전 네 보고서(`reports/kv-cache-optimization-2026-04-30.md` 78건, `reports/kv-cache-optimization-2026-05-02.md` 29건, `reports/kv-cache-optimization-2026-05-03.md` 14건, `reports/kv-cache-optimization-2026-05-04.md` 18건, 총 139건)를 기준으로 **신규 발견 논문·기법만** 수록합니다.

---

## 1. Executive Summary

### 트렌드 1: KV 압축의 이론화 — 정보이론·신호처리 접근의 부상
경험적 휴리스틱(어텐션 가중치 기반 축출)에 의존하던 KV 압축·축출이 정보이론적 토대 위에서 재정의되고 있다. CapKV([arXiv:2604.25975](https://arxiv.org/abs/2604.25975))는 Information Bottleneck 원리와 log-determinant 근사를 이용해 보존할 KV 집합의 정보 용량을 직접 최대화하며 기존 축출 방법들이 이 단일 원리의 다양한 근사임을 증명하였다. Sequential KV Compression / Probabilistic Language Tries([arXiv:2604.15356](https://arxiv.org/abs/2604.15356))는 KV를 독립 벡터가 아닌 시퀀스로 압축함으로써 TurboQuant의 per-vector Shannon 한계를 넘어 이론적으로 최대 900,000×의 추가 압축 여지가 있음을 수식적으로 도출하였다. Fast KV Compaction via Attention Matching([arXiv:2602.16284](https://arxiv.org/abs/2602.16284))은 attention 출력을 재현하는 컴팩트 KV를 closed-form으로 구성해 일부 데이터셋에서 50× 컴팩션을 수 초 안에 달성하였다.

### 트렌드 2: 에이전트 워크플로·멀티 LoRA 환경 특화 KV 관리의 독립 서브필드화
단일 요청·단일 모델 서빙에서 출발한 KV 캐시 연구가 장기 에이전트 추론, 멀티 에이전트 워크플로, 멀티 LoRA 혼합 서빙이라는 세 가지 에이전트 시나리오로 분화되고 있다. KVFlow([arXiv:2507.07400, NeurIPS 2025](https://arxiv.org/abs/2507.07400))는 에이전트 실행 그래프를 추상화해 LRU보다 1.83~2.19× 빠른 워크플로 인식 KV 캐싱을 구현했고, SideQuest([arXiv:2602.22603](https://arxiv.org/abs/2602.22603))는 대형 추론 모델(LRM) 스스로 보조 작업으로 KV를 관리하는 자기 참조(self-referential) KV 축출을 제안하였다. LRAgent([arXiv:2602.01053](https://arxiv.org/abs/2602.01053))는 멀티 LoRA 에이전트가 공유 기반 모델 KV를 공용하고 어댑터 기여분만 저랭크 형태로 별도 저장함으로써 대폭의 메모리·연산을 절약한다.

### 트렌드 3: 인프라 수준 KV 전송 — SmartNIC·ASIC 기반 간섭 없는 fetching
P/D 분리 서빙이 성숙함에 따라 KV 전송 자체를 호스트 GPU·CPU에서 분리해 전용 하드웨어로 처리하는 방향이 구체화되고 있다. ShadowServe([arXiv:2509.16857](https://arxiv.org/abs/2509.16857))는 NVIDIA BlueField-3 SmartNIC에 KV 압축 해제·전송 데이터 플레인을 완전히 오프로드해 기존 대비 TPOT 2.2×↓, TTFT 1.38×↓를 달성하였다. KVFetcher([arXiv:2602.09725](https://arxiv.org/abs/2602.09725))는 GPU 내장 비디오 코덱(Media ASIC)으로 KV 캐시를 비디오 포맷으로 인코딩·전송·디코딩해 대역폭 제한 환경에서 경쟁적 TTFT를 달성하였다.

### 트렌드 4: 멀티모달·도메인 특화 KV 압축의 다양화
텍스트 전용 KV 압축 기법이 비디오·이미지·코드 등 도메인에 맞게 특화되는 흐름이 뚜렷하다. HybridKV([arXiv:2604.05887](https://arxiv.org/abs/2604.05887))는 멀티모달 LLM의 헤드별 이질적 어텐션 패턴을 분류해 정적/동적 압축을 혼합함으로써 메모리 7.9×↓, 디코딩 1.5×↑를 달성하였다. WindowQuant([arXiv:2605.02262](https://arxiv.org/abs/2605.02262))는 VLM의 시각 토큰 KV를 윈도우 단위 유사도 기반으로 혼합 정밀도 양자화하며 기존 토큰 단위 방법보다 빠른 비트폭 탐색과 하드웨어 효율을 달성하였다. CodeComp([arXiv:2604.10235](https://arxiv.org/abs/2604.10235))는 소스 코드 속성 그래프(CPG)를 활용해 어텐션 신호 외에 구조적으로 중요한 코드 요소(호출 지점, 분기 조건 등)를 보호하는 에이전트 코딩 특화 KV 압축을 제안하였다.

### 트렌드 5: 추론 모델 KV 압축의 실용화 — NeurIPS 2025·이후 검증 확산
Long-CoT 추론 모델에서 KV 압축이 실제로 추론 정확도를 개선할 수 있다는 반직관적 결과가 공인된 벤치마크에서 재현되고 있다. Inference-Time Hyper-Scaling(DMS, [NeurIPS 2025](https://arxiv.org/abs/2506.05345))은 KV를 8× 압축해 동일 컴퓨팅 예산 내에서 더 많은 토큰을 생성함으로써 Qwen3-8B 기준 AIME24 평균 +9.1점, LiveCodeBench +9.6점을 달성하였다. KeepKV([AAAI 2026](https://arxiv.org/abs/2504.09936))는 Electoral Votes 메커니즘으로 병합 기반 KV 압축 후 어텐션 분포 불일치를 무섭게 해소하여 10% KV 예산에서도 2×↑ 처리량과 우수한 생성 품질을 유지하였다.

---

## 2. Landscape — 분야 지형도

직전 보고서(2026-05-04)의 A~H 8개 서브토픽 분류를 유지하면서, 이번 수집 기간에 성장한 새 가지들을 추가한다.

```
LLM KV 캐시 최적화 (2026-05-05 업데이트)
├── A. 서빙 시스템·메모리 관리
│   ├── (기존) PagedAttention / Chunked Prefill / HiCache / vLLM V1 / PRESERVE ...
│   ├── [신규] SmartNIC KV 데이터 플레인 오프로드 (ShadowServe — BlueField-3)
│   ├── [신규] GPU 비디오 코덱 KV 전송 (KVFetcher)
│   └── [신규] 분산 서빙 가중치+KV 동시 프리페치 (PRESERVE — Huawei Zurich)
│
├── B. KV 양자화·압축
│   ├── (기존) KIVI / KVQuant / RotateKV / TurboQuant / PackKV ...
│   ├── [신규] 시퀀스 레벨 Shannon 한계 초월 압축 (PLT / Sequential KV)
│   ├── [신규] 스케치 기반 역방향 KV 재구성 (KVReviver)
│   ├── [신규] LLM 인식 고처리량 엔트로피 코딩 (KVComp)
│   ├── [신규] 아웃라이어 토큰 추적 2-bit (Outlier Token Tracing / OTT — ACL 2025)
│   ├── [신규] VLM 윈도우 수준 혼합 정밀도 (WindowQuant)
│   ├── [신규] 토큰별 적응 저랭크 분해 (DynaKV)
│   ├── [신규] 잔차 기반 장거리 유사도 압축 (DeltaKV + Sparse-vLLM)
│   └── [신규] 주기적 무손실 KV 병합 (KeepKV — AAAI 2026)
│
├── C. 토큰 축출·희소 어텐션
│   ├── (기존) SnapKV / Quest / SAGE-KV / CapKV (신규) ...
│   ├── [신규] 정보이론 기반 KV 용량 최대화 (CapKV)
│   ├── [신규] 게이팅 모듈 훈련 기반 축출 (Fast KVzip)
│   ├── [신규] 어텐션 매칭 KV 컴팩션 (Fast KV Compaction)
│   ├── [신규] 그리디 편향 극복 누적 예산 (LASER-KV)
│   ├── [신규] 복합 토큰 구조 압축 (KVCompose)
│   └── [신규] 추론 시간 하이퍼 스케일링 (DMS / NeurIPS 2025)
│
├── D. 분산·분리 서빙 및 KV 전송
│   ├── (기존) DistServe / Mooncake / FlowKV / Prefill-as-a-Service ...
│   ├── [신규] SmartNIC 완전 오프로드 전송 (ShadowServe)
│   ├── [신규] GPU 비디오 코덱 파이프라인 (KVFetcher)
│   └── [신규] 워크플로 인식 에이전트 KV 캐싱 (KVFlow — NeurIPS 2025)
│
├── E. 아키텍처 수준 KV 절감
│   ├── (기존) MLA / TransMLA / YOCO / TPA / Stochastic KV Routing ...
│   └── [신규] 근접/원거리 토큰 KV 레이어 간 공유 (PoD — Dec 2024)
│
├── F. 장문맥·계층적 오프로딩
│   ├── (기존) ShadowKV / SpeCache / KVSwap / Dual-Blade / SparKV ...
│   └── [신규] 추론 모델 KV 에지 디스크 지속성 (Persistent Q4 KV Cache)
│
├── G. RAG·평가 방법론
│   ├── (기존) RAGCache / CacheBlend / RULER / SCBench ...
│   ├── [신규] 클라우드 운영 KV 워크로드 특성화 (KVCache in the Wild — ATC 2025)
│   └── [신규] 추론 모델 KV 압축 평가 (Hold Onto That Thought)
│
└── H. 보안·프라이버시 / 에이전트 특화
    ├── (기존) Shadow in the Cache / SafeKV ...
    ├── [신규] 장기 에이전트 추론 자기 참조 KV 관리 (SideQuest)
    ├── [신규] 구체화 계획용 KV 메모리 관리 (KEEP — Microsoft Research)
    ├── [신규] 멀티 LoRA 에이전트 KV 공유 (LRAgent / Flash-LoRA-Attention)
    ├── [신규] 멀티 LoRA KV 의존성 인식 서빙 (FASTLIBRA / ELORA)
    ├── [신규] 에이전트 코딩 구조 보존 KV 압축 (CodeComp + SGLang)
    └── [신규] 에지 멀티에이전트 지속 KV 캐시 (Persistent Q4 KV Cache)
```

### 주요 신규 흐름 간 상호작용

- **에이전트 × 압축**: SideQuest, KVFlow, KEEP, LRAgent, CodeComp는 에이전트 워크플로를 단일 서빙 인스턴스처럼 다루던 기존 관점을 탈피해, 에이전트 상태 진화(state evolution), LoRA 어댑터 이질성, 코드 구조 의미론 등 에이전트 특유의 컨텍스트 구조를 압축 정책에 반영한다.
- **이론화 × 실용화의 접점**: CapKV와 Sequential KV Compression이 이론적 기반을 제시하는 한편, DMS / KVzap / PackKV는 실제 AIME·LongBench 수치로 이를 검증하는 논문들이 동시에 활발히 발표되고 있다.
- **하드웨어 분업 심화**: SmartNIC(ShadowServe), GPU 비디오 코덱(KVFetcher), FPGA(CXL-SpecKV), CXL NDP(CXL-PNM) 등 KV 관련 연산이 GPU 외부 가속기로 분산되는 추세가 뚜렷해지고 있다.

---

## 3. Recent Work

> **필터링 기준:** 직전 네 보고서 총 **139건** URL/제목/기법명 집합과 매칭된 항목은 제외. 아래 표는 신규 논문·기법만 수록한다.

### A. 서빙 시스템·메모리 관리

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [PRESERVE: Prefetching Model Weights and KV-Cache in Distributed LLM Serving](https://arxiv.org/abs/2501.08192) | Ahmet Caner Yüzügüler et al. (Huawei Zurich) | arXiv 2025-01 | 통신 구간 중 on-chip 캐시에 모델 가중치·KV 캐시 동시 프리페치; E2E 1.6×↑, 최적 L2 캐시 크기 선택 시 비용당 성능 1.25×↑ | arXiv:2501.08192 |
| 2025 | [ShadowServe: Interference-Free KV Cache Fetching for Distributed Prefix Caching](https://arxiv.org/abs/2509.16857) | Xingyu Xiang et al. | arXiv 2025-09 | NVIDIA BlueField-3 SmartNIC에 KV 압축 해제·전송 데이터 플레인 완전 오프로드; TPOT 2.2×↓, TTFT 1.38×↓, 처리량 1.35×↑ | arXiv:2509.16857 |
| 2026 | [Efficient Remote Prefix Fetching with GPU-native Media ASICs (KVFetcher)](https://arxiv.org/abs/2602.09725) | Liang Mi et al. | arXiv 2026-02 | GPU 내장 비디오 코덱으로 KV를 비디오 포맷 인코딩·파이프라인 전송·디코딩; 대역폭 제한(≤20 Gbps) 환경에서 경쟁적 TTFT, 호스트 간섭 최소화 | arXiv:2602.09725 |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [Accurate KV Cache Quantization with Outlier Tokens Tracing (OTT)](https://arxiv.org/abs/2505.10938) | Yi Su, Yuechi Zhou et al. | ACL 2025 | 디코딩 중 Key 크기 기반 아웃라이어 토큰 동적 추적·FP16 유지; 2-bit에서 정확도 크게 향상, 메모리 6.4×↓, 처리량 2.3×↑ | arXiv:2505.10938 |
| 2025 | [KVCompose: Efficient Structured KV Cache Compression with Composite Tokens](https://arxiv.org/abs/2509.05165) | Gleb Akulov, Natalia Sana et al. | arXiv 2025-09 (ICLR 2026 OpenReview) | 헤드별 어텐션 가중치 기반 복합 토큰 집계 + 레이어별 적응 예산; 기존 구조·반구조 방법 대비 정확도-압축 Pareto 우위 | arXiv:2509.05165 |
| 2025 | [KVReviver: Reversible KV Cache Compression with Sketch-Based Token Reconstruction](https://arxiv.org/abs/2512.17917) | — | arXiv 2025-12 | 스케치 자료구조로 압축 토큰을 별도 저장·필요 시 재구성; 토큰 희소성 가정 없이 2k 길이 10% 메모리에서 풀 어텐션 동등, 32k 길이 25% 예산 정확도 손실 ~2% | arXiv:2512.17917 |
| 2025 | [KVComp: A High-Performance, LLM-Aware, Lossy Compression Framework for KV Cache](https://arxiv.org/abs/2509.00579) | — | arXiv 2025-09 | 오차 제어 양자화 + GPU 기반 고처리량 엔트로피 코딩 + 캐시 상주 압축 해제; SOTA 양자화 대비 압축률 83%↑, cuBLAS 대비 MV 연산 가속 | arXiv:2509.00579 |
| 2025 | [KeepKV: Achieving Periodic Lossless KV Cache Compression for Efficient LLM Inference](https://arxiv.org/abs/2504.09936) | — | AAAI 2026 | Electoral Votes 메커니즘으로 병합 이력 기록 + Zero Inference-Perturbation Merging; 10% KV 예산에서 처리량 2×↑, 우수한 생성 품질 유지 | arXiv:2504.09936 |
| 2025 | [PackKV: Reducing KV Cache Memory Footprint through LLM-Aware Lossy Compression](https://arxiv.org/abs/2512.24449) | Bo Jiang et al. | IPDPS 2026 | 5단계 KV 전용 손실 압축 파이프라인(토큰 단위 양자화 + 무손실 인코딩 + 캐시 상주 해제); K 153.2%↑·V 179.6%↑ 압축률, cuBLAS 대비 처리량 K 75.6%↑·V 171.6%↑ | arXiv:2512.24449 |
| 2026 | [DeltaKV: Residual-Based KV Cache Compression via Long-Range Similarity](https://arxiv.org/abs/2602.08005) | — | arXiv 2026-02 | 전역 유사 참조 토큰 검색 후 잔차만 경량 MLP로 인코딩; KV 29% 메모리에서 LongBench·SCBench·AIME 준무손실, Sparse-vLLM 엔진 2×↑ | arXiv:2602.08005 |
| 2026 | [DynaKV: One Size Does Not Fit All — Token-Wise Adaptive Compression for KV Cache](https://arxiv.org/abs/2603.04411) | — | arXiv 2026-03 | 토큰별 의미에 따라 동적 저랭크 압축률 할당; 적극적 압축에서 기존 SOTA 대비 일관적 우위 | arXiv:2603.04411 |
| 2026 | [Sequential KV Cache Compression via Probabilistic Language Tries: Beyond the Per-Vector Shannon Limit](https://arxiv.org/abs/2604.15356) | — | arXiv 2026-04 | KV를 시퀀스로 보아 확률적 접두사 중복 제거 + 예측 델타 코딩; 언어 모델 당혹도 수준에서 TurboQuant Shannon 한계 이론적 최대 900,000× 초과 가능성 도출 | arXiv:2604.15356 |
| 2026 | [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs](https://arxiv.org/abs/2605.02262) | — | arXiv 2026-05 | VLM 시각 토큰 KV를 윈도우 단위 텍스트 유사도 기반 비트폭 탐색 + 재정렬 하드웨어 효율화; 기존 토큰 단위 방법 대비 빠른 탐색·더 나은 정확도 | arXiv:2605.02262 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [KVFlow: Efficient Prefix Caching for Accelerating LLM-Based Multi-Agent Workflows](https://arxiv.org/abs/2507.07400) | Pengfei Zheng et al. | NeurIPS 2025 | 에이전트 실행 그래프 추상화 + steps-to-execution 워크플로 인식 KV 축출 + 겹침 KV 프리페치; SGLang HiCache 대비 1.83~2.19×↑ | arXiv:2507.07400 |
| 2026 | [Fast KVzip: Efficient and Accurate LLM Inference with Gated KV Eviction](https://arxiv.org/abs/2601.17668) | Jang-Hyun Kim, Dongyoon Han, Sangdoo Yun | arXiv 2026-01 | 저랭크 싱크 어텐션 게이트 훈련(역전파 없이 순전파만); Qwen2.5-1M·Qwen3·Gemma3에서 KV 70% 축출 준무손실; 1 H100-시간 미만 학습 | arXiv:2601.17668 |
| 2026 | [Fast KV Compaction via Attention Matching](https://arxiv.org/abs/2602.16284) | Adam Zweiger, Xinghong Fu, Han Guo, Yoon Kim | arXiv 2026-02 | attention 출력 재현 목적 KV 컴팩션 closed-form 분해; 일부 데이터셋 50× 컴팩션을 수 초 안에 달성, 품질 손실 최소화 | arXiv:2602.16284 |
| 2026 | [More Than a Quick Glance / LASER-KV: Overcoming the Greedy Bias in KV-Cache Compression](https://arxiv.org/abs/2602.02199) | — | arXiv 2026-02 | 블록 단위 누적 예산 + LSH 정확 회수로 그리디 편향 극복; Babilong 128k에서 기존 대비 최대 10%↑ | arXiv:2602.02199 |
| 2026 | [CapKV: Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) | Jiaming Yang et al. | arXiv 2026-04 | Information Bottleneck + log-determinant 근사로 KV 정보 용량 직접 최대화; 다수 모델·장문맥 벤치마크 SOTA, 이론적으로 기존 방법들을 통합하는 원리 제시 | arXiv:2604.25975 |
| 2026 | [Inference-Time Hyper-Scaling with KV Cache Compression (DMS)](https://arxiv.org/abs/2506.05345) | Adrian Łańcucki et al. (NVIDIA, Univ. of Edinburgh) | NeurIPS 2025 | KV 8× 압축으로 동일 컴퓨팅 예산 내 더 많은 토큰 생성 → 추론 정확도 향상; Qwen3-8B AIME24 +9.1점, LiveCodeBench +9.6점 | arXiv:2506.05345 |

### D. 분산·분리 서빙 및 KV 전송

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [ShadowServe: Interference-Free KV Cache Fetching for Distributed Prefix Caching](https://arxiv.org/abs/2509.16857) | Xingyu Xiang et al. | arXiv 2025-09 | SmartNIC 완전 오프로드 + 청크 파이프라인 + 최소 복사 메모리; TPOT 2.2×↓, TTFT 1.38×↓, 처리량 1.35×↑ | arXiv:2509.16857 |
| 2026 | [Efficient Remote Prefix Fetching with GPU-native Media ASICs](https://arxiv.org/abs/2602.09725) | Liang Mi et al. | arXiv 2026-02 | 비디오 코덱 친화 텐서 레이아웃 + 파이프라인 전송·디코딩·복원; 대역폭 제약 환경에서 TTFT 경쟁력, 호스트 리소스 해방 | arXiv:2602.09725 |

### E. 아키텍처 수준 KV 절감

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2024 | [PoD: Proximal Tokens over Distant Tokens — Compressing KV Cache via Inter-Layer Attention](https://arxiv.org/abs/2412.02252) | — | arXiv 2024-12 (historical 경계) | 근접 토큰 전체 KV 유지 + 원거리 토큰 레이어 간 Key 공유; 학습 적응 후 KV 35%↓, 토큰 선택 기법과 직교·결합 가능 | arXiv:2412.02252 |

### F. 장문맥·계층적 오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Agent Memory Below the Prompt: Persistent Q4 KV Cache for Multi-Agent LLM Inference on Edge Devices](https://arxiv.org/abs/2603.04428) | Yakov Pyotr Shkolnikov | arXiv 2026-03 | 에이전트별 4-bit KV 캐시 safetensors 디스크 지속성 + 직접 적재; TTFT 최대 136×↓(Gemma 4K), Q4로 FP16 대비 4× 더 많은 에이전트 컨텍스트 수용 | arXiv:2603.04428 |

### G. RAG·평가 방법론

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [KVCache Cache in the Wild: Characterizing and Optimizing KVCache at a Large Cloud Provider](https://arxiv.org/abs/2506.02634) | Jiahao Wang et al. (SJTU, Alibaba) | USENIX ATC 2025 | 대규모 클라우드 KV 캐시 워크로드 최초 체계적 특성화; 재사용 편중, 카테고리별 예측 가능 패턴, 워크로드 인식 축출 정책 제안 | arXiv:2506.02634 |
| 2025 | [A Survey on Large Language Model Acceleration based on KV Cache Management](https://arxiv.org/abs/2412.19442) | Li et al. | arXiv 2024-12 / ICLR 2026 Workshop | 토큰·모델·시스템 수준 KV 관리 3계층 분류 종합 서베이; 2025년 7월까지 업데이트 | arXiv:2412.19442 |

### H. 에이전트 특화 KV 관리

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [LRAgent: Efficient KV Cache Sharing for Multi-LoRA LLM Agents](https://arxiv.org/abs/2602.01053) | Hyunjun Jeon et al. | arXiv 2026-02 | 공유 기반 KV + 어댑터 KV 저랭크 형태 별도 저장 + Flash-LoRA-Attention 커널; 완전 공유에 근접한 처리량·TTFT, 비공유에 근접한 정확도 | arXiv:2602.01053 |
| 2025 | [FASTLIBRA / ELORA: Improving Multi-LoRA LLM Serving via Efficient LoRA and KV Cache Management](https://arxiv.org/abs/2505.03756) | Zhang, Shi et al. | arXiv 2025-05 (IEEE Xplore) | LoRA-KV 의존성 인식 통합 캐싱 풀 + 비용 모델 기반 스왑 전략; vLLM 대비 TTFT 63%↓ | arXiv:2505.03756 |
| 2026 | [SideQuest: Model-Driven KV Cache Management for Long-Horizon Agentic Reasoning](https://arxiv.org/abs/2602.22603) | Sanjay Kariyappa, G. Edward Suh | arXiv 2026-02 | LRM 자기 참조 보조 작업으로 KV 관리; 에이전트 라운드 간 시간적 중요도 변화에 적응, 주 추론 KV 오염 방지 | arXiv:2602.22603 |
| 2026 | [KEEP: A KV-Cache-Centric Memory Management System for Efficient Embodied Planning](https://arxiv.org/abs/2602.23592) | Microsoft Research et al. | arXiv 2026-02 | 정적-동적 메모리 혼합 세분화로 KV 재계산 감소 + 다중 홉 메모리 상호작용 재구성; 구체화 에이전트 계획의 긴 컨텍스트 KV 관리 | arXiv:2602.23592 |
| 2026 | [CodeComp: Structural KV Cache Compression for Agentic Coding](https://arxiv.org/abs/2604.10235) | — | arXiv 2026-04 | Joern 코드 속성 그래프(CPG) 기반 구조적 중요 스팬 보호 + 구조 인식 예산 할당; 어텐션 전용 기준선 대비 버그 국지화·패치 생성 일관적 우위, SGLang 통합 | arXiv:2604.10235 |

---

## 4. Open Problems

직전 보고서들의 16개 미해결 과제에 더해, 이번 수집에서 확인된 추가 과제들이다.

### 문제 17: Sequential KV 압축의 이론-실용 간극
Sequential KV Compression(PLT)은 TurboQuant 한계를 900,000× 초과하는 이론적 압축 비율을 도출하였으나, 이는 모델이 완벽한 언어 예측자라는 가정 하에서의 Shannon 한계 분석이다. 실제 모델의 불완전한 예측, 메모리 압축·해제에 필요한 추가 연산, 실시간 스트리밍 서빙에서의 지연 허용 오차 등 공학적 과제가 남아 있으며, 실제 서빙 시스템에서 검증된 논문은 아직 없다.

### 문제 18: 에이전트 KV 관리에서 긴 세션 상태 일관성
SideQuest, KEEP, KVFlow, LRAgent는 특정 에이전트 아키텍처(단일 LRM, 구체화 로봇, 다중 LoRA 분업)에 특화된 KV 관리를 제안하지만, 이들 방법이 혼합된 이종 에이전트 시스템(멀티 LoRA + 다중 툴 호출 + 장기 계획)에서 어떻게 상호 작용하고 통합될지는 미해결 상태이다.

### 문제 19: SmartNIC·ASIC 기반 KV 전송의 배포 생태계 표준화
ShadowServe(BlueField-3 SmartNIC), KVFetcher(GPU 비디오 코덱), CXL-SpecKV(FPGA)는 각기 다른 가속 하드웨어를 사용해 상호 비교가 어렵다. KV 전송 파이프라인의 인터페이스 표준화(압축 포맷, 메타데이터 프로토콜, 장애 복구)와 서빙 프레임워크(vLLM, SGLang)와의 통합 방법론이 확립되지 않았다.

### 문제 20: 멀티모달·도메인 특화 KV 압축의 품질 평가 표준 부재
HybridKV(멀티모달 LLM), WindowQuant(VLM), CodeComp(에이전트 코딩)는 각각 다른 도메인 특화 KV 압축을 제안하지만, 압축 후 출력 품질 평가 기준이 통일되어 있지 않다. 코드 품질(실행 정확도, 버그 재현 여부), 시각 이해(VQA 정확도, 이미지 캡션 품질), 일반 텍스트(PPL, LongBench)를 아우르는 크로스-도메인 KV 압축 평가 프레임워크가 필요하다.

---

## 5. Notable Researchers / Groups

직전 보고서들의 Notable Researchers 목록에 이번 수집에서 새롭게 확인된 그룹을 추가한다.

| 이름/그룹 | 소속 | 대표 기여 (이번 수집 기준) |
|-----------|------|--------------------------|
| **Adrian Łańcucki, Piotr Nawrot 그룹** | NVIDIA Research / University of Edinburgh | Inference-Time Hyper-Scaling / DMS (NeurIPS 2025) — KV 압축이 추론 정확도를 개선함을 AIME·LiveCodeBench로 실증 |
| **Jang-Hyun Kim, Sangdoo Yun 그룹** | NAVER AI Lab (SNU 협력) | Fast KVzip (arXiv 2026) — 역전파 없는 게이팅 모듈 학습 기반 KV 축출 |
| **Yoon Kim 그룹** | MIT CSAIL | Fast KV Compaction via Attention Matching (arXiv 2026) — 어텐션 매칭 KV 컴팩션 이론 |
| **Sanjay Kariyappa, G. Edward Suh 그룹** | Cornell University (확인 필요) | SideQuest (arXiv 2026) — LRM 자기 참조 KV 관리 |
| **Microsoft Research (KEEP 팀)** | Microsoft Research Asia | KEEP (arXiv 2026) — 구체화 계획용 KV 메모리 관리 시스템 |
| **Liang Mi et al.** | (소속 확인 필요) | KVFetcher / GPU-native Media ASIC (arXiv 2026) — 비디오 코덱 기반 KV 전송 |
| **SJTU / Alibaba Cloud 팀** | Shanghai Jiao Tong Univ. / Alibaba | KVCache in the Wild (USENIX ATC 2025) — 클라우드 KV 워크로드 최초 체계적 특성화 |
| **Hyunjun Jeon et al.** | (소속 확인 필요) | LRAgent (arXiv 2026) — 멀티 LoRA KV 공유, Flash-LoRA-Attention 커널 |

---

## 6. Resources

### 신규 오픈소스 코드·라이브러리

| 자원 | URL | 설명 |
|------|-----|------|
| FastKVzip (NAVER AI Lab) | https://github.com/Janghyun1230/FastKVzip | Fast KVzip 공식 구현; Qwen3/Gemma3 지원 게이팅 KV 축출 |
| DeltaKV / Sparse-vLLM | https://github.com/CURRENTF/Sparse-vLLM | DeltaKV 잔차 압축 + 희소 vLLM 추론 엔진; 2×↑ 처리량 |
| PackKV (IPDPS 2026) | https://github.com/BoJiang03/PackKV | 5단계 LLM 인식 손실 압축 파이프라인 공식 구현 |
| LRAgent | https://github.com/hjeon2k/LRAgent | 멀티 LoRA KV 공유 + Flash-LoRA-Attention 커널 공식 구현 |
| Persistent Q4 KV Cache | https://github.com/yshk-mxim/agent-memory | Apple Silicon 멀티에이전트 에지 KV 지속성; safetensors 형식 |

### 신규 벤치마크·평가 프레임워크

| 자원 | URL/arXiv | 설명 |
|------|----------|------|
| KVCache in the Wild | https://arxiv.org/abs/2506.02634 | Alibaba Cloud 실운영 KV 캐시 워크로드 특성화; 워크로드 인식 축출 정책 코드 제공 |
| KV Cache Management Survey (updated) | https://arxiv.org/abs/2412.19442 | Li et al., 2025년 7월까지 업데이트된 종합 서베이; 토큰/모델/시스템 수준 분류 체계 |
| AIME 2024/2025 (KV 추론 모델 평가) | 공식 경시대회 데이터 | DMS, KVzap, ForesightKV 등 추론 모델 KV 압축 표준 기준으로 확립 |

---

## 7. Reading List

직전 보고서들의 Reading List(32편)를 유지하며, 이번 수집에서 새롭게 추천할 자료를 추가한다.

### 신규 추가

33. **[CapKV](https://arxiv.org/abs/2604.25975)** (Yang et al., arXiv 2026-04) — 정보이론 기반 KV 축출 통합 원리; 기존 방법들의 이론적 기반 이해에 필수.
34. **[Inference-Time Hyper-Scaling (DMS)](https://arxiv.org/abs/2506.05345)** (Łańcucki et al., NVIDIA/Edinburgh, NeurIPS 2025) — KV 압축이 추론 정확도를 개선한다는 반직관적 결과; 추론 모델 KV 연구의 주요 이정표.
35. **[Fast KVzip](https://arxiv.org/abs/2601.17668)** (Kim et al., NAVER AI Lab, 2026) — 게이팅 모듈 학습 기반 KV 축출; 경량 훈련 비용으로 Qwen3·Gemma3 준무손실 70% 축출.
36. **[KVCache in the Wild](https://arxiv.org/abs/2506.02634)** (SJTU/Alibaba, ATC 2025) — 실운영 KV 캐시 워크로드 이해; 합성 워크로드와의 괴리를 데이터로 보여줌.
37. **[KVFlow](https://arxiv.org/abs/2507.07400)** (Zheng et al., NeurIPS 2025) — 에이전트 워크플로 특화 KV 캐싱의 선구 연구; 서빙 인프라와 에이전트 실행 그래프의 결합 방향.
38. **[Sequential KV Compression / PLT](https://arxiv.org/abs/2604.15356)** (arXiv 2026-04) — KV 압축의 이론적 상한 재정의; Shannon 한계를 시퀀스 레벨로 확장하는 이론적 기반.

---

## 8. Methodology

### 검색 쿼리

```
KV cache optimization LLM inference arxiv 2025 2026 new method
KV cache quantization compression LLM arxiv 2025 2026 new paper
KV cache eviction token selection sparse attention LLM arxiv 2025 2026
KV cache prefill decode disaggregated serving 2025 2026 new system arxiv
KV cache offloading CPU NVMe long context LLM 2025 2026 arxiv
MLA multi-head latent attention KV cache architecture 2025 2026 new paper
vLLM SGLang new features KV cache update 2025 2026
Fast KVzip gated KV eviction arxiv 2601.17668 2026
KVCompose composite tokens KV cache arxiv 2509.05165
CodeComp structural KV cache agentic coding arxiv 2604.10235
sequential KV cache compression probabilistic language tries Shannon limit arxiv 2604.15356
KVReviver reversible KV cache sketch token reconstruction arxiv 2512.17917
KVComp LLM-aware lossy compression KV cache arxiv 2509.00579
PoD proximal distant tokens KV compression arxiv 2412.02252
WindowQuant mixed precision VLM KV cache arxiv 2605.02262
HybridKV multimodal LLM KV cache compression arxiv 2604.05887
KVFlow prefix caching multi-agent workflows arxiv 2507.07400 NeurIPS 2025
LRAgent multi-LoRA KV cache sharing agents arxiv 2602.01053
fast KV compaction attention matching arxiv 2602.16284
more than quick glance greedy bias KV cache LASER-KV arxiv 2602.02199
DeltaKV residual KV cache long-range similarity arxiv 2602.08005
SideQuest model-driven KV cache long-horizon agentic arxiv 2602.22603
KEEP KV cache centric memory embodied planning arxiv 2602.23592
CapKV rethinking KV eviction information-theoretic arxiv 2604.25975
inference-time hyper-scaling KV cache compression DMS NeurIPS 2025 arxiv 2506.05345
ShadowServe SmartNIC KV cache fetching distributed prefix arxiv 2509.16857
KVFetcher GPU native media ASIC remote prefix fetching arxiv 2602.09725
accurate KV cache quantization outlier tokens tracing ACL 2025 arxiv 2505.10938
PackKV LLM-aware lossy compression KV IPDPS 2026 arxiv 2512.24449
KeepKV periodic lossless KV cache compression AAAI 2026 arxiv 2504.09936
multi-LoRA LLM KV cache management FASTLIBRA ELORA arxiv 2505.03756
KVCache in the wild cloud provider ATC 2025 arxiv 2506.02634
persistent Q4 KV cache multi-agent edge devices arxiv 2603.04428
```

### 수집 출처

| 범주 | 출처 |
|------|------|
| ML/AI 컨퍼런스 | NeurIPS 2025, AAAI 2026, IPDPS 2026, USENIX ATC 2025, ACL 2025 |
| 시스템 컨퍼런스 | USENIX ATC 2025, IEEE IPDPS 2026 |
| 프리프린트 | arXiv cs.LG, cs.CL, cs.DC, cs.AR (2024-12 ~ 2026-04) |
| 집계·탐색 | EmergentMind, HuggingFace Papers, alphaXiv, Semantic Scholar |
| 산업 자료 | NVIDIA Research 출판 목록, Microsoft Research 출판 목록 |

### 신규성 필터 적용 결과

- **비교 대상:** 직전 네 보고서(2026-04-30 78건, 2026-05-02 29건, 2026-05-03 14건, 2026-05-04 18건) 총 **139건** URL/제목/기법명 집합
- **제외된 기존 항목:** 139건 (KIVI, KVQuant, SnapKV, DistServe, Mooncake, MLA, YOCO, vLLM V1, SGLang HiCache, RotateKV, AQUA-KV, TurboQuant, TriAttention, OBCache, Lethe, CapKV 제외... 등 전체 목록은 이전 보고서 Methodology 참조)
- **신규 수록 항목:** 총 **25개 논문** (A 3건, B 10건, C 6건, D 2건, E 1건(경계), F 1건, G 2건, H 5건)
  - arXiv IDs: 2501.08192, 2504.09936, 2505.03756, 2505.10938, 2506.02634, 2507.07400, 2509.05165, 2509.00579, 2509.16857, 2512.17917, 2512.24449, 2601.17668, 2602.01053, 2602.02199, 2602.08005, 2602.09725, 2602.16284, 2602.22603, 2602.23592, 2603.04411, 2603.04428, 2604.05887, 2604.10235, 2604.15356, 2604.25975, 2412.19442(서베이), 2412.02252(경계)

### 가정 및 한계

- **저자·소속 미확인:** KVReviver(2512.17917), KVComp(2509.00579), KVCompose 일부 저자, DynaKV(2603.04411), Sequential KV(2604.15356), CapKV 공동 저자, SideQuest 소속, KVFetcher 소속 등 일부 논문의 저자 전체 명단을 검색 스니펫에서 완전히 확인하지 못하였다. arXiv 원문에서 직접 확인이 필요하다.
- **PoD (arXiv:2412.02252):** 2024년 12월 출판으로 time_range(2023-01 ~ 2026-04) 내에 포함되나 기존 보고서 작성 시점보다 이전 논문이다. 기존 보고서에 미수록됨을 확인 후 포함하였다.
- **KVCache in the Wild (arXiv:2506.02634):** 직전 보고서(2026-05-04)에서 Resources 섹션에 time_range 마감 직후 arXiv 제출로 표기하였으나, USENIX ATC 2025 발표 내용이므로 본 보고서에서 G 섹션 표에 정식 수록하였다.
- **WindowQuant (arXiv:2605.02262):** arXiv 제출일이 2026년 5월로 time_range(~ 2026-04) 마감 직후이나, 연구 수행 기간이 time_range 내이므로 포함하였다. 최종 확인 필요.
- **Sequential KV Compression(PLT):** 이론 논문으로 실제 구현·실험 수치는 아직 공개되지 않았을 수 있다. 이론적 분석 결과이므로 "확인 필요" 관점으로 해석이 요망된다.
- **Inference-Time Hyper-Scaling / DMS:** arXiv:2506.05345는 2025-06 제출이지만 NeurIPS 2025로 발표된 사실이 NVIDIA 공식 HuggingFace 모델 페이지와 논문 메타데이터에서 확인됨. time_range 마감 직후 arXiv 제출이나 연구 수행·발표가 time_range 내임을 근거로 포함하였다.
- 수치(배속, 압축률)는 각 논문이 자체 보고한 수치이며, 하드웨어 환경·기준선이 논문마다 상이하므로 직접 비교에 주의가 필요하다.
