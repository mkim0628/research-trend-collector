---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-04
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-04)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview
>
> **신규성 주의:** 본 보고서는 직전 세 보고서(`reports/kv-cache-optimization-2026-04-30.md` 78건, `reports/kv-cache-optimization-2026-05-02.md` 29건, `reports/kv-cache-optimization-2026-05-03.md` 14건)를 기준으로 **신규 발견 논문·기법만** 수록합니다.

---

## 1. Executive Summary

### 트렌드 1: 의미 단위(Semantic-Unit) KV 선택의 다양화
토큰 단위 eviction을 넘어, 문장·청크·클러스터 등 의미 경계를 기반으로 KV를 관리하는 접근이 복수의 독립 연구에서 동시에 부상하였다. SentenceKV([COLM 2025](https://arxiv.org/abs/2504.00970))는 문장 단위 시맨틱 벡터를 GPU에 유지하면서 개별 KV 쌍을 CPU로 오프로드하는 방법으로 정확도를 유지한다. SemantiCache([arXiv 2026-03](https://arxiv.org/abs/2603.14303))는 의미 청킹 + GSC(Greedy Seed-Based Clustering) 병합으로 디코딩 2.61×를 달성하였다. LycheeCluster([arXiv 2026-03](https://arxiv.org/abs/2603.08453))는 계층적 인덱스를 활용해 KV 검색을 O(log n)으로 단축시켜 풀 어텐션 대비 3.6× 디코딩 가속을 실현하였다. 이 흐름은 "어떤 KV가 중요한가"가 아니라 "어떤 단위로 KV를 묶어야 하는가"로 연구 질문이 진화하고 있음을 보여준다.

### 트렌드 2: 압축·인덱스 통합 — 별도 구조 없이 압축키에서 직접 검색
기존 접근은 KV 압축과 희소 어텐션 검색을 별개 모듈로 처리하였다. 이제 이 두 기능을 단일 표현에 통합하는 방향이 등장하고 있다. Self-Indexing KVCache([AAAI 2026](https://arxiv.org/abs/2603.14224))는 1-bit 벡터 양자화(VQ) 스킴을 도입하여 압축된 키 표현 자체에서 코사인 유사도 기반 top-k 검색을 직접 수행한다. 별도의 보조 인덱스 구조 없이 정확도를 유지하면서 End-to-End 추론 효율을 높이는 방식이다. OjaKV([arXiv:2509.21623](https://arxiv.org/abs/2509.21623))는 온라인 Oja PCA로 압축 기저를 지속 갱신하여 정적 SVD 기반 기법이 AIME25에서 0%를 기록하는 상황에서도 13% 정확도를 유지하였다.

### 트렌드 3: P/D 분리 서빙 생태계의 이론화와 다각화
P/D 분리가 사실상 표준이 된 이후, 이를 분석·확장하는 이론 연구와 시스템 다각화가 동시에 진행 중이다. Theoretically Optimal Attention/FFN Ratios([arXiv:2601.21351](https://arxiv.org/abs/2601.21351))는 A/F 비율의 closed-form 최적 해를 제시하여 Attention-FFN 분리(AFD) 아키텍처 설계의 이론적 기반을 마련하였다. Revisiting Disaggregated LLM Serving([arXiv:2601.08833](https://arxiv.org/abs/2601.08833))은 P/D 분리가 요청 부하와 KV 전송 매체에 따라 성능 이점이 항상 보장되지 않으며 에너지 소비가 더 높을 수 있음을 실증적으로 경고하였다. Beluga([arXiv:2511.20172](https://arxiv.org/abs/2511.20172))는 CXL 스위치 기반 공유 메모리 풀로 RDMA 대비 TTFT 89.6%↓, 처리량 7.35×↑를 달성하였다.

### 트렌드 4: MLA·아키텍처 KV 절감의 확장 — VLM 및 MoE와의 결합
MLA 기반 KV 절감이 텍스트 전용 모델을 넘어 Vision-Language Model(VLM)과 Mixture-of-Experts(MoE)로 확장되고 있다. MHA2MLA-VLM([arXiv:2601.11464](https://arxiv.org/abs/2601.11464))은 시각·텍스트 KV 공간을 독립 압축하는 모달리티 분리형 MLA 변환 프레임워크를 제안하여 LLaVA-1.5/NeXT, Qwen2.5-VL에 적용하였다. MoE-MLA([arXiv:2508.01261](https://arxiv.org/abs/2508.01261))는 MoE 전문가 특화가 MLA의 정보 손실을 보완할 수 있음을 실험적으로 보여주며 68% KV 절감과 3.2× 추론 가속을 달성하였다. TPLA([arXiv:2508.15881](https://arxiv.org/abs/2508.15881))는 MLA의 텐서 병렬 분해 문제를 해결하여 DeepSeek-V3·Kimi-K2에서 32K 컨텍스트 기준 1.79~1.93× 가속을 달성하였다.

### 트렌드 5: 온디바이스·에지 KV 관리의 체계화와 클라우드-엣지 하이브리드
에지 기기에서의 KV 관리 연구가 단일 오프로딩 기법을 넘어 클라우드-에지 협력 아키텍처로 진화하고 있다. SparKV([arXiv:2604.21231](https://arxiv.org/abs/2604.21231))는 클라우드에서 KV를 스트리밍하거나 온디바이스에서 계산할지를 어텐션 희소성 기반 비용 모델로 동적 결정하여 TTFT 1.3~5.1×↓, 에너지 1.5~3.3×↓를 달성하였다. 한편 적응형 비트폭 양자화(Don't Waste Bits, [arXiv:2604.04722](https://arxiv.org/abs/2604.04722))와 적응형 저랭크 압축(ARKV, [arXiv:2603.08727](https://arxiv.org/abs/2603.08727))은 온디바이스 메모리 예산 하에서 정확도를 최대한 보존하는 접근으로 수렴하고 있다.

---

## 2. Landscape — 분야 지형도

직전 보고서(2026-05-03)에서 확립한 A~H 8개 서브토픽 분류가 유지되면서, 이번 기간(2026년 5월 기준)에 다음과 같은 새 세부 가지들이 성장하였다.

```
LLM KV 캐시 최적화 (2026-05-04 업데이트)
├── A. 서빙 시스템·메모리 관리
│   ├── (기존) PagedAttention / Chunked Prefill / HiCache / vLLM V1 ...
│   ├── [신규] 압축 인식 스토리지 계층 서빙 (AdaptCache — DRAM·SSD 혼합)
│   ├── [신규] P/D 분리 실증 재평가 (Revisiting Disaggregated LLM Serving)
│   └── [신규] 메모리 처리 파이프라인 가속 (GPU-FPGA 이종 처리)
│
├── B. KV 양자화·압축
│   ├── (기존) KIVI / KVQuant / RotateKV / KVzap / TurboQuant ...
│   ├── [신규] 온디바이스 적응 비트폭 제어 (Don't Waste Bits / ARKV)
│   ├── [신규] 청크 단위 혼합 정밀도 (Cocktail — DATE 2025)
│   ├── [신규] 온라인 저랭크 적응 (OjaKV — Oja PCA)
│   └── [신규] 유사도 기반 잔차 재구성 (EchoKV)
│
├── C. 토큰 축출·희소 어텐션
│   ├── (기존) SnapKV / Quest / ForesightKV / SAGE-KV / CAKE ...
│   ├── [신규] 의미 단위 KV 선택 (SemantiCache / LycheeCluster / IceCache)
│   ├── [신규] 문장 수준 시맨틱 캐싱 (SentenceKV — COLM 2025)
│   ├── [신규] 동적 의미 경계 분할 (DynSplit-KV)
│   └── [신규] 압축키 자기 인덱싱 검색 (Self-Indexing KVCache — AAAI 2026)
│
├── D. 분산·분리 서빙 및 KV 전송
│   ├── (기존) DistServe / Mooncake / FlowKV / CacheFlow / Prefill-as-a-Service ...
│   ├── [신규] CXL 스위치 공유 메모리 풀 (Beluga)
│   ├── [신규] A/F 비율 최적화 이론 (Theoretically Optimal A/F Ratios)
│   ├── [신규] P/D 분리 에너지·성능 재평가 (Revisiting Disaggregated)
│   └── [신규] 메모리 처리 파이프라인 이종 가속 (GPU-FPGA)
│
├── E. 아키텍처 수준 KV 절감
│   ├── (기존) MLA / TransMLA / MHA2MLA / YOCO / TPA / MTLA ...
│   ├── [신규] VLM용 MLA 변환 (MHA2MLA-VLM)
│   ├── [신규] MoE + MLA 결합 (MoE-MLA-RoPE)
│   └── [신규] 텐서 병렬 MLA 분해 (TPLA)
│
├── F. 장문맥·계층적 오프로딩
│   ├── (기존) ShadowKV / SpeCache / KVSwap / Dual-Blade ...
│   ├── [신규] 클라우드-에지 협력 KV 적응 로딩 (SparKV)
│   └── [신규] 압축 인식 스토리지 계층 (AdaptCache)
│
└── H. 보안·프라이버시
    └── (기존) Shadow in the Cache / SafeKV ...
        (이번 수집에서 신규 항목 없음)
```

### 주요 신규 흐름

- **의미적 일관성 vs. 어텐션 가중치**: 전통적 축출 정책(어텐션 스코어 기반)이 의미적 연결고리를 끊는다는 비판이 구체화되면서, 의미 단위(SemantiCache, LycheeCluster, SentenceKV, DynSplit-KV)로 KV를 조직하는 방향이 하나의 흐름으로 정착되고 있다.
- **압축의 이론화**: "Physics of KV Cache Compression"([arXiv:2603.01426](https://arxiv.org/abs/2603.01426))이 90% 압축 임계에서 발생하는 환각 위험의 "위상 전이(phase transition)"를 실증하며, 벤치마크 정확도와 내부 표현 분해 사이의 괴리를 이론적으로 분석하였다. 이는 "벤치마크 무손실 = 안전" 가정에 의문을 제기한다.
- **P/D 분리 재평가 시대**: P/D 분리가 성숙기에 접어들며 이를 맹목적으로 채택하기보다 어떤 상황에서 이점이 있는지를 정량적으로 분석하는 연구들(Revisiting Disaggregated, Theoretically Optimal A/F Ratios)이 등장하였다.

---

## 3. Recent Work

> **필터링 기준:** 직전 세 보고서(`kv-cache-optimization-2026-04-30.md` 78건 + `kv-cache-optimization-2026-05-02.md` 29건 + `kv-cache-optimization-2026-05-03.md` 14건, 총 121건)의 URL/제목/기법명 집합과 매칭된 항목은 제외하였다. 아래 표는 신규 논문·기법만 수록한다.

### A. 서빙 시스템·메모리 관리

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [AdaptCache: KV Cache Native Storage Hierarchy for Low-Delay and High-Quality Language Model Serving](https://arxiv.org/abs/2509.00105) | Shaoting Feng et al. (UChicago, Microsoft Research) | arXiv 2025-09 | 각 KV 항목별 압축 알고리즘·비율·배치 장치를 동적 결정; KIVI 대비 TTFT 69%↓, 정적 기준선 대비 1.43~2.4× 지연 절감, 6~55% 품질 향상 | arXiv:2509.00105 |
| 2026 | [Revisiting Disaggregated Large Language Model Serving for Performance and Energy Implications](https://arxiv.org/abs/2601.08833) | Jiaxi Li et al. (Illinois, IBM) | arXiv 2026-01 | KV 전송 매체·요청 부하에 따라 P/D 분리의 성능 이점이 보장되지 않으며 에너지 소비가 오히려 높을 수 있음을 DVFS 프로파일링으로 실증 | arXiv:2601.08833 |
| 2026 | [Understand and Accelerate Memory Processing Pipeline for Disaggregated LLM Inference](https://arxiv.org/abs/2603.29002) | Zifan He et al. | arXiv 2026-03 | Prepare→Relevancy→Retrieval→Apply 4단계 메모리 처리 파이프라인 통일 모델 제안; GPU-FPGA 이종 처리로 1.04~2.2×↑, 에너지 1.11~4.7×↓ | arXiv:2603.29002 |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [Cocktail: Chunk-Adaptive Mixed-Precision Quantization for Long-Context LLM Inference](https://arxiv.org/abs/2503.23294) | (저자 확인 필요) | DATE 2025 | 쿼리-청크 유사도 기반 비트폭 동적 선택 + 청크 재정렬로 하드웨어 비효율 방지; 장문맥 LLM 추론 SOTA 초과 | arXiv:2503.23294 |
| 2025 | [OjaKV: Context-Aware Online Low-Rank KV Cache Compression with Oja's Rule](https://arxiv.org/abs/2509.21623) | Yuxuan Zhu et al. (RPI, IBM Research) | arXiv 2025-09 | Oja 온라인 PCA로 압축 기저를 디코딩 중 지속 갱신; 정적 SVD 기법 AIME25 0% vs. OjaKV 13% 정확도 유지 | arXiv:2509.21623 |
| 2026 | [Don't Waste Bits! Adaptive KV-Cache Quantization for Lightweight On-Device LLMs](https://arxiv.org/abs/2604.04722) | Sayed Pedram Haeri Boroujeni et al. | arXiv 2026-04 | 토큰 빈도·품질·어텐션 분산·엔트로피 기반 경량 컨트롤러로 {2,4,8-bit, FP16} 동적 선택; 정적 양자화 대비 디코딩 지연 17.75%↓, 정확도 7.6점↑ | arXiv:2604.04722 |
| 2026 | [ARKV: Adaptive and Resource-Efficient KV Cache Management under Limited Memory Budget for Long-Context Inference in LLMs](https://arxiv.org/abs/2603.08727) | (저자 확인 필요) | arXiv 2026-03 | 어텐션 엔트로피·분산·첨도 기반 레이어별 OQ 비율 추정; 토큰별 Original·Quantize·Evict 3-상태 관리; 4× 메모리 절감에서 기준선 97% 정확도 유지 | arXiv:2603.08727 |
| 2026 | [EchoKV: Efficient KV Cache Compression via Similarity-Based Reconstruction](https://arxiv.org/abs/2603.22910) | (저자 확인 필요) | arXiv 2026-03 | 인터/인트라 레이어 헤드 유사도 활용 경량 재구성 네트워크; 7B 모델 기준 ~1 A100 GPU-시간 학습, LongBench·RULER 기준 SOTA 초과 | arXiv:2603.22910 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [SAGE-KV: LLMs Know What to Drop — Self-Attention Guided KV Cache Eviction for Efficient Long-Context Inference](https://arxiv.org/abs/2503.08879) | Wang et al. | ICLR 2025 | 프리필 후 1회 top-k 선택(토큰+헤드 수준); StreamLLM 대비 4× 메모리 효율, Quest 대비 2× 효율 | arXiv:2503.08879 |
| 2025 | [SentenceKV: Efficient LLM Inference via Sentence-Level Semantic KV Caching](https://arxiv.org/abs/2504.00970) | Zhao et al. | COLM 2025 | 문장 수준 시맨틱 벡터를 GPU 유지, 개별 KV 쌍은 CPU 오프로드; PG-19, LongBench, Needle-in-Haystack 전반 SOTA 대비 우위 | arXiv:2504.00970 |
| 2025 | [IceCache: Memory-efficient KV-cache Management for Long-Sequence LLMs](https://arxiv.org/abs/2604.10539) | (저자 확인 필요) | arXiv 2026-04 | 시맨틱 토큰 클러스터링으로 DCI-tree 구성 + ANN M-DCI 페이지 선택; 장문맥 정확도-지연 트레이드오프 개선 | arXiv:2604.10539 |
| 2026 | [DynSplit-KV: Dynamic Semantic Splitting for KVCache Compression in Efficient Long-Context LLM Inference](https://arxiv.org/abs/2602.03184) | Jiancai Ye et al. | arXiv 2026-02 | 동적 중요도 인식 구분자 선택 + 가변 길이 블록→고정 길이 매핑; 정확도 49.9%↑, FlashAttention 대비 2.2×↑, 메모리 2.6×↓ | arXiv:2602.03184 |
| 2026 | [SemantiCache: Efficient KV Cache Compression via Semantic Chunking and Clustered Merging](https://arxiv.org/abs/2603.14303) | (저자 확인 필요) | arXiv 2026-03 | 의미 청킹 + GSC 클러스터 병합 + 비례 어텐션 재균형; 디코딩 2.61×↑, 메모리 대폭 절감 | arXiv:2603.14303 |
| 2026 | [LycheeCluster: Efficient Long-Context Inference with Structure-Aware Chunking and Hierarchical KV Indexing](https://arxiv.org/abs/2603.08453) | (저자 확인 필요) | arXiv 2026-03 | 삼각 부등식 기반 재귀 계층 인덱스로 KV 검색 O(log n) 단축 + 지연 업데이트; 풀 어텐션 대비 3.6×↑ | arXiv:2603.08453 |
| 2026 | [Self-Indexing KVCache: Predicting Sparse Attention from Compressed Keys](https://arxiv.org/abs/2603.14224) | (저자 확인 필요) | AAAI 2026 | 1-bit VQ 스킴으로 압축키에서 직접 코사인 유사도 top-k 검색; 별도 인덱스 불필요, 장문맥 추론·E2E 효율 SOTA 초과 | arXiv:2603.14224 |

### D. 분산·분리 서빙 및 KV 전송

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [Beluga: A CXL-Based Memory Architecture for Scalable and Efficient LLM KVCache Management](https://arxiv.org/abs/2511.20172) | (저자 확인 필요) | SIGMOD 2025 (PACMMOD) | CXL 2.0 스위치 기반 공유 메모리 풀로 GPU/CPU 네이티브 load/store 접근; RDMA 대비 읽기 지연 7.0×↓, TTFT 89.6%↓, 처리량 7.35×↑ | arXiv:2511.20172 |
| 2026 | [Theoretically Optimal Attention/FFN Ratios in Disaggregated LLM Serving](https://arxiv.org/abs/2601.21351) | Chendong Song et al. | arXiv 2026-01 | 확률적 워크로드 모델로 Attention-FFN 분리(AFD) 아키텍처의 최적 A/F 비율 closed-form 도출; P/D 분리 설계의 이론 기반 제공 | arXiv:2601.21351 |

### E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [Unifying MoE and MLA for Efficient Language Models (MoE-MLA-RoPE)](https://arxiv.org/abs/2508.01261) | Sushant Mehta et al. | KDD 2025 Workshop | MoE 전문가 특화가 MLA 정보 손실 보완; 17M~202M 파라미터 실험에서 68% KV 절감, 3.2× 추론 가속, perplexity 0.8% 저하 | arXiv:2508.01261 |
| 2025 | [TPLA: Tensor Parallel Latent Attention for Efficient Disaggregated Prefill and Decode Inference](https://arxiv.org/abs/2508.15881) | (저자 확인 필요, Peking Univ. 외) | arXiv 2025-08 | 텐서 병렬 환경에서 MLA 압축 이점 보존; 잠재 표현·헤드 차원 동시 분산; DeepSeek-V3·Kimi-K2 32K 컨텍스트 1.79~1.93×↑ | arXiv:2508.15881 |
| 2026 | [MHA2MLA-VLM: Enabling DeepSeek's Economical Multi-Head Latent Attention across Vision-Language Models](https://arxiv.org/abs/2601.11464) | (저자 확인 필요) | arXiv 2026-01 | 모달리티 적응 partial-RoPE + 시각·텍스트 KV 공간 독립 저랭크 압축; LLaVA-1.5/NeXT, Qwen2.5-VL 적용, 최소 지도 데이터로 성능 회복 | arXiv:2601.11464 |

### F. 장문맥·계층적 오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [SparKV: Overhead-Aware KV Cache Loading for Efficient On-Device LLM Inference](https://arxiv.org/abs/2604.21231) | Hongyao Liu et al. (City Univ. of Hong Kong) | arXiv 2026-04 | 어텐션 희소성 기반 경량 MLP 비용 예측으로 클라우드 스트리밍 vs. 온디바이스 계산 동적 결정; TTFT 1.3~5.1×↓, 에너지 1.5~3.3×↓ | arXiv:2604.21231 |

> 해당 기간 신규 없음: G. RAG·평가 방법론, H. 보안·프라이버시

---

## 4. Open Problems

직전 보고서들의 12개 미해결 과제에 더해, 이번 수집에서 확인된 추가 과제들이다.

### 문제 13: 의미 단위 KV 관리에서 의미 경계 결정의 불안정성
SemantiCache, DynSplit-KV, SentenceKV 등 의미 경계 기반 KV 관리는 자연어의 의미 단위가 작업(코드·수학·대화)과 언어에 따라 크게 달라진다는 문제가 있다. 고정 구분자(마침표, 쉼표)가 효과적이지 않은 수학 증명, 코드 스니펫, 중국어·한국어 등에서 의미 경계 탐지 방법론의 일반화 능력이 충분히 검증되지 않았다.

### 문제 14: P/D 분리의 에너지 비용 - 성능 트레이드오프의 체계적 측정 부재
Revisiting Disaggregated LLM Serving은 P/D 분리가 에너지 소비를 높일 수 있음을 실증하였으나, 이는 특정 하드웨어·부하 조건에서의 관찰이다. GPU 유형(H100 vs. A100 vs. 추론 전용 칩), 네트워크 토폴로지(InfiniBand vs. Ethernet vs. CXL), 모델 아키텍처(MLA vs. GQA), 요청 부하 패턴별 에너지-처리량 Pareto 곡선이 체계적으로 정량화된 연구가 부재하다.

### 문제 15: 압축된 KV 공간에서의 의미 보존 보장
"Physics of KV Cache Compression"([arXiv:2603.01426](https://arxiv.org/abs/2603.01426))이 실증한 것처럼, 벤치마크 정확도 저하 없이 KV를 90%까지 압축해도 내부 표현이 이미 손상되어 있을 수 있다. 현재의 평가 프로토콜(PPL, LongBench 점수)은 이 내부 표현 분해를 포착하지 못한다. 압축 후 내부 표현의 의미적 완전성(semantic fidelity)을 측정하는 방법론 및 벤치마크가 필요하다.

### 문제 16: MLA의 멀티모달 확장에서의 시각-텍스트 KV 불균형
MHA2MLA-VLM은 시각·텍스트 KV 공간을 독립 압축하지만, 이미지 토큰의 KV와 텍스트 KV 간 중요도 가중치가 서로 다르게 분포되어 있다는 점(이미지 토큰은 고정 수, 텍스트는 가변 수)이 충분히 다뤄지지 않았다. VLM에서 멀티모달 KV 예산을 어떻게 할당할지는 미해결 문제이다.

---

## 5. Notable Researchers / Groups

직전 보고서들의 Notable Researchers 목록에 이번 수집에서 새롭게 확인된 그룹을 추가한다.

| 이름/그룹 | 소속 | 대표 기여 (이번 수집 기준) |
|-----------|------|--------------------------|
| **Hongyao Liu, Zhengru Fang 그룹** | City University of Hong Kong | SparKV (클라우드-에지 협력 KV 로딩) |
| **Yuxuan Zhu, Pin-Yu Chen 그룹** | RPI / IBM Research | OjaKV (온라인 Oja PCA 저랭크 KV 압축) |
| **Shaoting Feng, Junchen Jiang 그룹** | University of Chicago / Microsoft Research | AdaptCache (압축 인식 KV 스토리지 계층) |
| **Sushant Mehta et al.** | (소속 확인 필요) | MoE-MLA-RoPE (MoE+MLA 통합 아키텍처, KDD 2025 Workshop) |
| **AAAI 2026 Self-Indexing KVCache 팀** | (소속 확인 필요) | Self-Indexing KVCache (1-bit VQ 통합 압축+검색, AAAI 2026) |
| **Zifan He et al.** | (소속 확인 필요) | GPU-FPGA 메모리 처리 파이프라인 이종 가속 |
| **Chendong Song et al.** | (소속 확인 필요) | Theoretically Optimal A/F Ratios (AFD 이론 기반) |

---

## 6. Resources

### 신규 오픈소스 코드·라이브러리

| 자원 | URL | 설명 |
|------|-----|------|
| SentenceKV | https://github.com/zzbright1998/SentenceKV | COLM 2025 문장 수준 시맨틱 KV 캐싱 공식 구현 |
| AnDPro (NeurIPS 2025) | https://github.com/MIRALab-USTC/LLM-AnDPro | 앵커 방향 투영 KV 축출 (직전 보고서에서 확인) |
| FlexKV (vLLM/Dynamo 통합) | https://github.com/taco-project/FlexKV | Tencent TACO 분산 KV 스토어; 2026년 3월 vLLM 메인라인 병합 |

### 신규 벤치마크·평가 프레임워크

| 자원 | URL/arXiv | 설명 |
|------|----------|------|
| KV Cache Physics Analysis | https://arxiv.org/abs/2603.01426 | 어텐션 다이내믹스를 통한 KV 압축의 이론적 한계 분석; 90% 임계 환각 위험 실증 |
| KVCache in the Wild (USENIX ATC 25) | https://arxiv.org/abs/2506.02634 | Alibaba Cloud 운영 환경의 KV 캐시 워크로드 특성 분석 및 현실적 캐시 제거 정책 제안 (arXiv 제출 시점 2025-06으로 time_range 마감 직후) |

---

## 7. Reading List

직전 보고서들의 Reading List(25편)를 유지하며, 이번 수집에서 새롭게 추천할 자료를 추가한다.

### 신규 추가

26. **[SAGE-KV](https://arxiv.org/abs/2503.08879)** (Wang et al., ICLR 2025) — 단순하면서 효과적인 프리필 후 1회 top-k 선택; 토큰·헤드 수준 eviction의 기준선으로 활용 가능.
27. **[SentenceKV](https://arxiv.org/abs/2504.00970)** (Zhao et al., COLM 2025) — 문장 수준 시맨틱 KV 관리의 대표 사례; 의미 단위 연구의 입문.
28. **[Self-Indexing KVCache](https://arxiv.org/abs/2603.14224)** (AAAI 2026) — 압축과 검색의 통합; 1-bit VQ의 이론·실용성 이해에 적합.
29. **[Beluga](https://arxiv.org/abs/2511.20172)** (SIGMOD 2025) — CXL 기반 공유 메모리 풀 설계 원리; 차세대 메모리 인프라 방향 이해에 필수.
30. **[Understanding the Physics of KV Cache Compression](https://arxiv.org/abs/2603.01426)** (arXiv 2026-03) — KV 압축의 이론적 한계 분석; 압축 안전성 평가 방법론 심화.
31. **[Theoretically Optimal Attention/FFN Ratios](https://arxiv.org/abs/2601.21351)** (arXiv 2026-01) — AFD 시스템 설계의 이론적 기반; P/D 분리 용량 계획에 활용 가능.
32. **[OjaKV](https://arxiv.org/abs/2509.21623)** (Zhu et al., RPI/IBM, arXiv 2025) — 온라인 저랭크 적응의 필요성을 AIME25 비교로 실증; Reasoning 모델 KV 압축 연구의 주요 참고점.

---

## 8. Methodology

### 검색 쿼리

본 보고서에서 신규 자료 수집에 사용한 검색 쿼리는 다음과 같다.

```
KV cache quantization LLM inference 2025 2026 arxiv new method
KV cache eviction token selection sparse attention LLM arxiv 2025 2026
prefill decode disaggregation KV cache serving system arxiv 2025 2026 new
MLA multi-head latent attention KV compression architecture arxiv 2025 2026 new
KV cache offloading CPU NVMe long context LLM arxiv 2025 2026 new paper
vLLM SGLang KV cache new features update 2025 2026
SAGE-KV LLMs self-attention guided KV cache eviction arxiv 2503.08879
MHA2MLA VLM vision language model KV cache arxiv 2601.11464 2026
adaptive KV cache quantization on-device LLM arxiv 2604.04722 2026
KV cache disaggregated serving CXL RDMA distributed pool arxiv 2025 2026 new
Beluga CXL memory architecture LLM KV cache arxiv 2511.20172
ARKV adaptive resource KV cache long context LLM arxiv 2603.08727
SparKV IceCache KV cache on-device LLM inference arxiv 2025 2026
FlexKV distributed KV store reuse Tencent NVIDIA 2025 2026
IceCache semantic token clustering PagedAttention KV cache arxiv 2604.10539
SAGE-KV ICLR 2025 KV cache eviction LLM long context performance
SemantiCache KV cache compression semantic chunking clustered merging arxiv 2603.14303
Unifying MoE multi-head latent attention KV cache arxiv 2508.01261 2025
TPLA tensor parallel latent attention disaggregated prefill decode arxiv 2508.15881
AdaptCache KV cache native storage hierarchy language model serving arxiv 2509.00105
SentenceKV sentence level KV caching LLM inference arxiv 2504.00970
KV cache attention dynamics physics compression LLM arxiv 2603.01426 2026
LycheeCluster long context inference structure aware chunking hierarchical KV arxiv 2603.08453
DynSplit-KV dynamic semantic splitting KVCache compression arxiv 2602.03184
Self-Indexing KVCache predicting sparse attention compressed keys arxiv 2603.14224
OjaKV context-aware online low-rank KV cache compression Oja's Rule arxiv 2509.21623
Cocktail chunk-adaptive mixed-precision quantization long context LLM arxiv 2503.23294
EchoKV KV cache architecture sharing similarity arxiv 2025 2026
KVCache in the wild characterizing cloud provider LLM inference arxiv 2506.02634
revisiting disaggregated LLM serving performance energy arxiv 2601.08833 2026
Understand accelerate memory processing pipeline disaggregated LLM inference arxiv 2603.29002
theoretically optimal attention FFN ratios disaggregated LLM serving arxiv 2601.21351
```

### 수집 출처

| 범주 | 출처 |
|------|------|
| ML/AI 컨퍼런스 | ICLR 2025, COLM 2025, AAAI 2026, KDD 2025 Workshop |
| 시스템 컨퍼런스 | DATE 2025, SIGMOD 2025 (PACMMOD), USENIX ATC 2025 |
| 프리프린트 | arXiv cs.LG, cs.CL, cs.DC, cs.AR (2025-01 ~ 2026-04) |
| 집계·탐색 | EmergentMind, Semantic Scholar, HuggingFace Papers, alphaXiv |
| 기관 자료 | Microsoft Research, IBM Research 출판 목록 |

### 신규성 필터 적용 결과

- **비교 대상:** 직전 세 보고서(2026-04-30 78건, 2026-05-02 29건, 2026-05-03 14건) 총 **121건** URL/제목/기법명 집합
- **제외된 기존 항목:** 121건
- **신규 수록 항목:** 총 **18개 논문** (A 3건, B 5건, C 7건, D 2건, E 3건, F 1건)
- **신규 없는 영역:** G(RAG·평가), H(보안·프라이버시)

### 가정 및 한계

- **저자 정보 미확인:** SemantiCache(2603.14303), LycheeCluster(2603.08453), IceCache(2604.10539), EchoKV(2603.22910), Cocktail(2503.23294), ARKV(2603.08727), Self-Indexing KVCache(2603.14224), Beluga(2511.20172), TPLA(2508.15881), MHA2MLA-VLM(2601.11464) 등의 저자 전체 명단을 검색 스니펫에서 완전히 확인하지 못하였다. arXiv 원문에서 직접 확인이 필요하다.
- **Beluga venue:** SIGMOD 2025 (PACMMOD)로 표기하였으나, ACM DL 링크에서 확인된 정보이며 최종 게재지 확정은 arXiv 원문에서 재확인 권장.
- **KVCache in the Wild (arXiv:2506.02634):** USENIX ATC 2025 발표 논문이지만 arXiv 제출일이 2025-06으로 time_range 마감(2026-04) 내에 포함될 수 있으나, 실제 연구 기간이 time_range를 벗어나지 않는지 확인이 필요하여 보고서 본문 표에서는 제외하고 Resources 섹션에 참고 항목으로만 수록하였다.
- **OjaKV venue:** arXiv 2025-09 프리프린트로, ICLR 2026 수록 여부는 OpenReview에서 확인 필요 (OpenReview 링크 발견됨).
- 수치(배속, 압축률)는 각 논문이 자체 보고한 수치이며, 하드웨어 환경·기준선이 논문마다 상이하므로 직접 비교에 주의가 필요하다.
- "Physics of KV Cache Compression"([arXiv:2603.01426](https://arxiv.org/abs/2603.01426))은 평가 방법론 관련 이론 논문으로 G 섹션에 해당하나, 이전 보고서에서 수록된 RULER/SCBench와 달리 이론 분석 관점의 신규 기여가 있어 Open Problems 및 Resources에 인용하였다.
