---
type: trend-report
topic: "LLM KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-14
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM KV 캐시 관리·최적화 — Research Trend Report (2026-05-14)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview
>
> **신규성 주의:** 본 보고서는 직전 보고서(`reports/kv-cache-optimization-2026-05-04.md`, 총 18건)를 포함한 네 편의 누적 보고서 기준으로 KNOWN_URLS에 수록된 항목을 제외하고 **신규 발견 논문·기법만** 수록합니다. 주로 2026-05-04 이후 arXiv에 공개된 논문을 대상으로 합니다.

---

## 1. Executive Summary

### 트렌드 1: 학습 기반 KV Eviction의 부상 — 휴리스틱에서 최적화로
기존 KV 축출 정책(H2O, SnapKV, Quest 등)이 어텐션 가중치 집계라는 휴리스틱에 의존하던 것과 달리, 2026년 5월에는 축출 문제를 미분가능 최적화 문제로 재정의하는 연구가 복수 등장하였다. LKV([arXiv:2605.06676](https://arxiv.org/abs/2605.06676))는 헤드별 예산 배분과 토큰 선택을 End-to-End 학습 가능하게 구현하여 LongBench에서 KV 15% 보존만으로 거의 무손실 성능을 달성하였다. LaProx([arXiv:2605.07234](https://arxiv.org/abs/2605.07234))는 어텐션 맵과 투영된 값(Value) 상태의 곱셈 상호작용을 명시적으로 모델링하여 토큰 중요도를 레이어·헤드 전역에서 비교 가능한 단일 스코어로 산출한다. 두 연구 모두 "헤드 수준 독립 결정"이라는 기존 패러다임의 근본적 한계를 지적하며, 글로벌 최적 배분의 필요성을 실증한다.

### 트렌드 2: NVMe KV 오프로딩의 시스템화 — GPU 중심 I/O 재설계
장문맥 추론에서 KV 캐시가 GPU HBM과 CPU DRAM을 초과함에 따라, NVMe SSD로의 오프로딩이 현실화되고 있다. Tutti([arXiv:2605.03375](https://arxiv.org/abs/2605.03375))는 CPU를 데이터 경로에서 완전히 배제하고 GPU가 직접 SSD I/O를 제어하는 GPU-centric KV 오브젝트 스토어를 제안, 최신 GDS 기반 기준선(LMCache) 대비 TTFT 78.3%↓, 요청 처리율 2×↑를 달성하였다. KV-Fold([arXiv:2605.12471](https://arxiv.org/abs/2605.12471))는 KV 캐시를 청크 단위 좌측 폴드(left fold) 방식으로 순차 처리하여, 별도의 학습이나 아키텍처 변경 없이 Llama-3.1-8B에서 128K 토큰까지 단일 40GB GPU 메모리 한도 내에서 100% 정확한 검색을 보여주었다.

### 트렌드 3: KV 양자화의 이론화 — 정보 이론과 벡터 양자화
KV 양자화 연구가 경험적 비트폭 선택에서 정보 이론적 최적화로 이동하고 있다. RateQuant([arXiv:2605.06675](https://arxiv.org/abs/2605.06675))는 Rate-Distortion 이론의 역 워터필링(reverse waterfilling)으로 헤드별 비트폭을 최적 배분하여, Qwen3-8B 2.5-bit 평균에서 KIVI의 PPL 49.3을 14.9로 70% 절감하였다. FibQuant([arXiv:2605.11478](https://arxiv.org/abs/2605.11478))는 Fibonacci/quasi-uniform 방향과 Beta-quantile 반경을 결합한 범용 벡터 양자화기로, 보정(calibration) 없이 분수-bit 및 1-bit 미만 동작점을 지원하며 TurboQuant를 동일 정수 비율에서 엄밀히 지배(dominate)함을 증명하였다.

### 트렌드 4: 멀티모달·VLM KV 관리의 전문화
시각-언어 모델(VLM/LVLM)에서 시각 토큰의 KV 캐시 오버헤드를 독립적으로 압축하는 연구가 집중 등장하였다. LightKV([arXiv:2605.00789](https://arxiv.org/abs/2605.00789))는 텍스트 프롬프트 유도 크로스-모달리티 메시지 패싱으로 시각 토큰을 점진적 압축하여, 원본의 55% 토큰만으로 KV 반감·연산량 40%↓를 달성하였다. RetentiveKV([arXiv:2605.04075](https://arxiv.org/abs/2605.04075))는 시각 토큰의 "지연 중요도(deferred importance)" 문제를 State Space Model 기반 연속 메모리 진화로 해결하여 5×압축·1.5× 디코딩 가속을 달성하였다. WindowQuant([arXiv:2605.02262](https://arxiv.org/abs/2605.02262))는 비디오 LM의 시각 토큰 윈도우-텍스트 유사도로 비트폭을 검색·배분하는 혼합 정밀도 방식을 제안하였다.

### 트렌드 5: 희소 어텐션 인덱싱의 알고리즘화 — 이론적 보증과 시스템 통합
희소 어텐션 검색을 근사가 아닌 정확한 알고리즘 문제로 환원하는 연구가 두드러진다. Louver([arXiv:2605.06763](https://arxiv.org/abs/2605.06763))는 희소 어텐션을 반공간 범위 탐색(halfspace range searching) 문제로 재정의하여 지정 임계값 대비 거짓 음성(false negative) 제로를 이론·실험적으로 보증하며 FlashAttention보다 빠른 런타임을 보였다. MISA([arXiv:2605.07363](https://arxiv.org/abs/2605.07363))는 DeepSeek 희소 어텐션(DSA) 인덱서의 다중 헤드 계산 병목을 MoE 라우터로 해결하여 장문맥에서 지배 비용인 인덱서 헤드 수를 동적 축소한다. StreamIndex([arXiv:2605.02568](https://arxiv.org/abs/2605.02568))는 DeepSeek V4의 압축 희소 어텐션(CSA) 파이프라인이 S=65,536에서 256GB 임시 텐서를 생성하는 문제를 청크 단위 파티션-병합 top-k로 해결하여 S=1,048,576까지 6.21GB 피크 HBM으로 확장하였다.

---

## 2. Landscape — 분야 지형도

직전 보고서(2026-05-04)에서 확립한 A~H 서브토픽 분류를 유지하면서, 2026년 5월 중순 기준 다음과 같은 새 흐름이 관찰된다.

```
LLM KV 캐시 최적화 (2026-05-14 업데이트)
├── A. 서빙 시스템·메모리 관리
│   ├── (기존) PagedAttention / vLLM V1 / SGLang HiCache / Mooncake ...
│   └── [신규] 멀티턴 P/D 하이브리드 라우팅 (PPD Disaggregation)
│
├── B. KV 양자화·압축
│   ├── (기존) KIVI / KVQuant / TurboQuant / OjaKV / Don't Waste Bits ...
│   ├── [신규] Rate-Distortion 최적 혼합 정밀도 (RateQuant)
│   ├── [신규] 범용 벡터 양자화 무보정 (FibQuant)
│   ├── [신규] 저랭크+양자화 2단계 파이프라인 (eOptShrinkQ)
│   ├── [신규] Apple Silicon int4 융합 커널 (int4 KV on Apple Silicon)
│   ├── [신규] RL 후처리 KV 압축 오프-폴리시 편향 해소 (Shadow Mask Distillation)
│   └── [신규] 혼합 차원 예산 배분 — 토큰 축출의 연속화 (MixedDimKV)
│
├── C. 토큰 축출·희소 어텐션
│   ├── (기존) SnapKV / SAGE-KV / SemantiCache / LycheeCluster / Self-Indexing KVCache ...
│   ├── [신규] E2E 학습 기반 헤드별 예산+토큰 선택 (LKV)
│   ├── [신규] 출력 인식 레이어별 축출 재정의 (LaProx)
│   ├── [신규] 이론 보증 범위 탐색 인덱스 (Louver)
│   ├── [신규] DeepSeek DSA 인덱서 MoE 대체 (MISA)
│   └── [신규] CSA 파이프라인 메모리 절약 스트리밍 top-k (StreamIndex)
│
├── D. 분산·분리 서빙 및 KV 전송
│   ├── (기존) DistServe / Mooncake / Beluga / Revisiting Disaggregated ...
│   └── [신규] 멀티턴 동적 라우팅 P/D 하이브리드 (PPD)
│
├── E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)
│   ├── (기존) MLA / TransMLA / MHA2MLA / YOCO / TPLA / MoE-MLA ...
│   └── [신규] 해당 기간 신규 없음
│
├── F. 장문맥·계층적 오프로딩
│   ├── (기존) AdaptCache / SparKV / DualBlade / KVSwap ...
│   ├── [신규] GPU-centric NVMe KV 오브젝트 스토어 (Tutti)
│   ├── [신규] 학습-free 청크 좌측 폴드 장문맥 (KV-Fold)
│   └── [신규] CPU-GPU 병렬 하이브리드 희소 어텐션 (Fluxion)
│
└── G. VLM·멀티모달 KV
    ├── (기존) MHA2MLA-VLM / RetentiveKV ...
    ├── [신규] 크로스-모달리티 메시지 패싱 압축 (LightKV — LightKV / 2605.00789)
    ├── [신규] State Space Model 연속 메모리 진화 (RetentiveKV — 2605.04075)
    └── [신규] 비디오 VLM 윈도우 유사도 혼합 정밀도 양자화 (WindowQuant)
```

### 주요 신규 흐름

- **학습 vs. 휴리스틱 갈림길**: 2026년 5월 발표된 LKV와 LaProx는 각각 "데이터 기반 예산 배분"과 "출력 인식 중요도 점수"로 기존 어텐션 집계 휴리스틱이 성능 천장을 만들고 있음을 실증하였다. 이는 "어텐션 점수 = 중요도"라는 암묵적 가정에 이론적 반론을 제기하는 흐름이다.
- **벡터 양자화의 이론화**: FibQuant는 스칼라 양자화 대비 벡터 양자화의 이론적 우위를 보정 없이 증명한 최초 사례이며, RateQuant는 Rate-Distortion 이론을 KV 양자화에 처음으로 적용하였다. 두 연구 모두 "실험적 비트폭 선택"에서 "원칙적 비율 배분"으로의 전환을 상징한다.
- **VLM KV 전문화 가속**: LightKV, RetentiveKV, WindowQuant가 같은 주에 발표되어, VLM에서의 시각 토큰 KV 문제가 하나의 독립 연구 영역으로 성숙하고 있음을 보여준다.

---

## 3. Recent Work

> **필터링 기준:** KNOWN_URLS에 수록된 총 153건(2026-04-30 78건, 2026-05-02 29건, 2026-05-03 14건, 2026-05-04 18건, 명세에 별도 제공된 URL 목록 포함)의 URL/제목/기법명 집합과 매칭된 항목은 제외하였다. 아래 표는 신규 논문·기법만 수록한다.

### A. 서빙 시스템·메모리 관리

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) | Zongze Li et al. | arXiv 2026-03 | 멀티턴 서빙에서 Turn 2+ 요청을 디코드 노드에서 로컬 처리할지 P 노드로 전송할지 동적 라우팅; Turn 2+ TTFT 68%↓, TPOT 유지 | arXiv:2603.13358 |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [RateQuant: Optimal Mixed-Precision KV Cache Quantization via Rate-Distortion Theory](https://arxiv.org/abs/2605.06675) | (저자 확인 필요, BMW TechWorks·NUS·Tsinghua 소속으로 보고됨) | arXiv 2026-05 | Rate-Distortion 이론의 역 워터필링으로 헤드별 비트폭 최적 배분; 1.6초 보정으로 KIVI PPL 49.3 → 14.9 (70%↓), QuaRot 6.6 PPL 개선 | arXiv:2605.06675 |
| 2026 | [FibQuant: Universal Vector Quantization for Random-Access KV-Cache Compression](https://arxiv.org/abs/2605.11478) | (저자 확인 필요) | arXiv 2026-05 | Fibonacci/quasi-uniform 방향 + Beta-quantile 반경 범용 벡터 양자화; 보정 없이 분수·sub-1-bit 동작점 지원, TurboQuant를 동일 정수 비율에서 엄밀히 지배 | arXiv:2605.11478 |
| 2026 | [eOptShrinkQ: Near-Lossless KV Cache Compression Through Optimal Spectral Denoising and Quantization](https://arxiv.org/abs/2605.02905) | Pei-Chun Su (Yale Univ.) | arXiv 2026-05 | KV 캐시를 스파이크 랜덤 행렬 모델로 분해; 최적 특이값 수축(eOptShrink) + TurboQuant 잔차 양자화; ~2.2 bit에서 FP16 수준 멀티-니들 검색 성능 | arXiv:2605.02905 |
| 2026 | [When Quantization Is Free: An int4 KV Cache That Outruns fp16 on Apple Silicon](https://arxiv.org/abs/2605.05699) | Mohamed Amine Bergach | arXiv 2026-05 | Apple Silicon 통합 메모리에서 sign-randomized FFT + per-channel λ + int4 nibble pack 단일 융합 Metal 커널; Gemma-3 1B에서 fp16 대비 3~8% ms/tok↓, 3× 메모리 절감 | arXiv:2605.05699 |
| 2026 | [How to Compress KV Cache in RL Post-Training? Shadow Mask Distillation for Memory-Efficient Alignment](https://arxiv.org/abs/2605.06850) | Rui Zhu et al. (Yale, Minnesota, Indiana) | arXiv 2026-05 | RL 롤아웃 중 KV 압축의 오프-폴리시 편향을 Shadow Mask Distillation로 해소; 장문맥 RL 후처리 메모리 벽 극복 | arXiv:2605.06850 |
| 2026 | [Beyond Token Eviction: Mixed-Dimension Budget Allocation for Efficient KV Cache Compression](https://arxiv.org/abs/2603.20616) | Ruijie Miao et al. | arXiv 2026-03 | 토큰별 차원 수를 연속적으로 배분하는 MixedDimKV/MixedDimKV-H; 기존 토큰 축출을 차원 축소의 극단 사례로 일반화, LongBench HeadKV 대비 지속적 우위 | arXiv:2603.20616 |
| 2026 | [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs Inference Optimization](https://arxiv.org/abs/2605.02262) | Wei Tao et al. | arXiv 2026-05 | 비디오 VLM의 시각 토큰 윈도우-텍스트 유사도 기반 비트폭 자동 탐색; 윈도우 수준 양자화 계산으로 하드웨어 효율 유지 | arXiv:2605.02262 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [LKV: End-to-End Learning of Head-wise Budgets and Token Selection for LLM KV Cache Eviction](https://arxiv.org/abs/2605.06676) | Enshuai Zhou et al. | arXiv 2026-05 | 헤드별 예산 학습(LKV-H) + 어텐션 행렬 미실체화 토큰 중요도 도출(LKV-T); LongBench 15% KV 보존에서 거의 무손실, 6.6× 저장 절감 | arXiv:2605.06676 |
| 2026 | [Reformulating KV Cache Eviction Problem for Long-Context LLM Inference](https://arxiv.org/abs/2605.07234) | Tho Mai, Joo-Young Kim (KAIST) | arXiv 2026-05 | KV 축출을 레이어별 행렬곱 근사 문제로 재정의(LaProx); 어텐션 맵×투영 값 곱셈 상호작용 모델링으로 모델 전역 비교 가능 단일 스코어 산출, LongBench 전반 SOTA | arXiv:2605.07234 |
| 2026 | [Sparse Attention as a Range Searching Problem: Towards an Inference-Efficient Index for KV Cache](https://arxiv.org/abs/2605.06763) | Mohsen Dehghankar, Abolfazl Asudeh | arXiv 2026-05 | 희소 어텐션을 반공간 범위 탐색으로 환원; Louver 인덱스로 거짓 음성 제로 이론 보증, FlashAttention보다 빠른 런타임 | arXiv:2605.06763 |
| 2026 | [MISA: Mixture of Indexer Sparse Attention for Long-Context LLM Inference](https://arxiv.org/abs/2605.07363) | Ruijie Zhou et al. (Peking Univ.) | arXiv 2026-05 | DeepSeek DSA 인덱서를 MoE 헤드 풀로 대체; 블록 수준 통계 기반 경량 라우터로 활성 헤드 수 동적 축소, 장문맥 인덱서 지배 비용 제거 | arXiv:2605.07363 |
| 2026 | [StreamIndex: Memory-Bounded Compressed Sparse Attention via Streaming Top-k](https://arxiv.org/abs/2605.02568) | (저자 확인 필요) | arXiv 2026-05 | DeepSeek V4 CSA 파이프라인의 256GB 임시 텐서 문제를 청크 파티션-병합 top-k로 해소; S=1,048,576까지 6.21GB HBM으로 확장, 동일 입력 대비 recall 0.9980+ | arXiv:2605.02568 |

### D. 분산·분리 서빙 및 KV 전송

> 해당 기간(2026-05-04 이후) 신규 시스템 논문은 A 섹션의 PPD(arXiv:2603.13358)와 중복 기재를 피하기 위해 A 섹션에 수록하였다. D 섹션 전용 신규 독립 논문은 이번 수집에서 확인되지 않았다.

> **해당 기간 신규 없음 (D 전용)** — 직전 보고서에서 Beluga, Theoretically Optimal A/F Ratios, Revisiting Disaggregated가 수록되었으며, 이번 수집에서 추가 신규 시스템 논문은 발견되지 않았다.

### E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)

> **해당 기간 신규 없음** — MLA, YOCO, TPLA, MoE-MLA 등 관련 신규 논문은 2026-05-04 이후 이번 수집 기간에 발견되지 않았다.

### F. 장문맥·계층적 오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Tutti: Making SSD-Backed KV Cache Practical for Long-Context LLM Serving](https://arxiv.org/abs/2605.03375) | Shi Qiu et al. | arXiv 2026-05 | GPU-centric KV 오브젝트 스토어; CPU를 데이터 경로에서 배제, GPU io_uring 비동기 직접 객체 I/O + 슬랙-인식 스케줄링; GDS 기반 LMCache 대비 TTFT 78.3%↓, 요청 처리율 2×↑, 비용 27%↓ | arXiv:2605.03375 |
| 2026 | [KV-Fold: One-Step KV-Cache Recurrence for Long-Context Inference](https://arxiv.org/abs/2605.12471) | (저자 확인 필요) | arXiv 2026-05 | KV 캐시를 청크 좌측 폴드(foldl) 재귀로 처리; 학습·아키텍처 변경 없이 Llama-3.1-8B 128K 토큰 40GB GPU에서 100% 정확 검색, 수치 안정성 10,000× 범위에 무감 | arXiv:2605.12471 |
| 2026 | [An Efficient Hybrid Sparse Attention with CPU-GPU Parallelism for Long-Context Inference](https://arxiv.org/abs/2605.07719) | Feiyu Yao et al. | arXiv 2026-05 | CPU 상주 KV 캐시에 대한 출력 인식 예산 할당 + 헤드별 희소 구성 + 크로스-디바이스 협력 실행(Fluxion); GPU 유휴 시간 제거, 장문맥 CPU-GPU 하이브리드 추론 E2E 효율화 | arXiv:2605.07719 |

### G. VLM·멀티모달 KV 관리

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Make Your LVLM KV Cache More Lightweight](https://arxiv.org/abs/2605.00789) | Xihao Chen et al. | arXiv 2026-05 (OpenReview 제출) | 텍스트 프롬프트 유도 크로스-모달리티 메시지 패싱으로 시각 토큰 점진적 압축(LightKV); 원본 55% 토큰으로 KV 반감, 연산량 40%↓, 8개 오픈소스 LVLM에서 기준선 상회 | arXiv:2605.00789 |
| 2026 | [RetentiveKV: State-Space Memory for Uncertainty-Aware Multimodal KV Cache Eviction](https://arxiv.org/abs/2605.04075) | Sihao Liu et al. | arXiv 2026-05 | 시각 토큰의 "지연 중요도"와 공간 연속성을 SSM 기반 연속 메모리 진화로 처리; 이산 축출 → 연속 갱신 패러다임 전환; 5× KV 압축, 1.5× 디코딩 가속 | arXiv:2605.04075 |

> **참고:** RL 후처리 KV 압축(arXiv:2605.06850)은 B 섹션에 수록하였으며, QKVShare(arXiv:2605.03884, 멀티에이전트 온디바이스 KV 핸드오프)는 아래 주석을 참고.

---

> **QKVShare (arXiv:2605.03884):** 멀티에이전트 온디바이스 LLM 간 양자화된 KV 핸드오프 프레임워크. Llama-3.1-8B 8K 컨텍스트에서 TTFT 397.1 ms vs. 재-prefill 1029.7 ms. 서빙 시스템과 VLM 양쪽에 걸치는 교차 분야 논문으로, 위 A/G 분류에 단독 중복 기재를 피하고 별도 언급함.

---

## 4. Open Problems

직전 보고서들의 16개 미해결 과제에 더해, 이번 수집에서 확인된 추가 과제들이다.

### 문제 17: 학습 기반 KV 예산 배분의 일반화 — 도메인·모델 이전성
LKV는 LongBench와 RULER 기준으로 우수한 성능을 보이지만, 예산 학습이 특정 태스크 분포에 과적합될 가능성이 있다. 수학 추론(AIME), 코드 생성(HumanEval), 다국어 태스크 등 분포 외 데이터에서 학습된 헤드별 예산이 얼마나 일반화되는지 체계적 평가가 없다. 또한 모델 패밀리(Llama vs. DeepSeek vs. Qwen)별로 학습된 예산 정책의 이전 가능성도 미검증이다.

### 문제 18: NVMe KV 오프로딩의 쓰기 증폭과 수명 비용
Tutti가 GPU 중심 I/O로 NVMe 대역폭 포화를 달성하였지만, KV 캐시의 높은 쓰기 빈도는 소비자 등급 NVMe의 쓰기 내구성(TBW)을 급격히 소모한다. 데이터센터급 pSLC NAND와 소비자 QLC NAND의 수명-비용 트레이드오프, 다중 요청 동시 서빙 시 I/O 경합 관리 전략이 정량화되지 않았다.

### 문제 19: VLM 시각 토큰 KV의 공간 연속성 보존
LightKV, RetentiveKV, WindowQuant는 모두 시각 토큰 수를 줄이지만, 이미지·비디오의 공간-시간적 구조(패치 인접성, 프레임 연속성)가 KV 압축 후 얼마나 보존되는지에 대한 정량적 분석이 부족하다. 특히 미세한 공간 위치 정보가 중요한 물체 검출·OCR·비디오 시간 추론 태스크에서의 열화 패턴이 체계화되지 않았다.

### 문제 20: RL 후처리에서의 KV 압축-보상 모델 상호작용
Shadow Mask Distillation(arXiv:2605.06850)은 오프-폴리시 편향 완화를 제안하였으나, KV 압축이 RL 보상 신호의 분산과 정책 그래디언트 안정성에 미치는 영향이 이론적으로 분석되지 않았다. PPO 대비 GRPO, DPO 등 다른 RL 알고리즘과의 호환성 및 KV 압축률에 따른 보상 모델 정확도 변화가 미해결 문제이다.

---

## 5. Notable Researchers / Groups

직전 보고서들의 Notable Researchers 목록에 이번 수집에서 새롭게 확인된 그룹을 추가한다.

| 이름/그룹 | 소속 | 대표 기여 (이번 수집 기준) |
|-----------|------|--------------------------|
| **Tho Mai, Joo-Young Kim** | KAIST | LaProx — KV 축출을 출력 인식 행렬곱 근사 문제로 재정의 (arXiv:2605.07234) |
| **Enshuai Zhou et al.** | (확인 필요) | LKV — E2E 학습 기반 헤드별 예산 + 토큰 선택 (arXiv:2605.06676) |
| **Pei-Chun Su** | Yale University | eOptShrinkQ — 랜덤 행렬 이론 기반 KV 스펙트럴 압축 (arXiv:2605.02905) |
| **Shi Qiu et al.** | (확인 필요) | Tutti — GPU-centric NVMe KV 오브젝트 스토어 (arXiv:2605.03375) |
| **Mohsen Dehghankar, Abolfazl Asudeh** | (확인 필요) | Louver — 희소 어텐션의 반공간 범위 탐색 이론 (arXiv:2605.06763) |
| **Ruijie Zhou et al.** | Peking University (MuLab) | MISA — DeepSeek DSA 인덱서의 MoE 기반 효율화 (arXiv:2605.07363) |
| **Rui Zhu et al.** | Yale, Minnesota, Indiana | Shadow Mask Distillation — RL 후처리 KV 압축 (arXiv:2605.06850) |
| **Sihao Liu et al.** | (확인 필요) | RetentiveKV — VLM용 SSM 기반 연속 KV 메모리 (arXiv:2605.04075) |
| **Xihao Chen et al.** | (확인 필요) | LightKV — LVLM 시각 토큰 크로스-모달리티 압축 (arXiv:2605.00789) |

---

## 6. Resources

### 신규 오픈소스 코드·라이브러리

| 자원 | URL | 설명 |
|------|-----|------|
| StreamIndex | https://github.com/RightNow-AI/StreamIndex | DeepSeek V4 CSA용 메모리 경계 스트리밍 top-k Triton 구현 |
| MISA (MuLabPKU/TransArch) | https://github.com/MuLabPKU/TransArch | DeepSeek DSA MoE 인덱서 대체 구현 |

### 신규 벤치마크·평가 자원

| 자원 | URL/arXiv | 설명 |
|------|----------|------|
| RateQuant 보정 도구 | arXiv:2605.06675 | Rate-Distortion 기반 헤드별 비트폭 최적화; 1.6초 GPU 보정으로 적용 가능 |
| KV-Fold 장문맥 니들 벤치마크 | arXiv:2605.12471 | 16K~128K, chain depth 511, 152 trials; 단일 40GB GPU 메모리 한도 설정 |

---

## 7. Reading List

직전 보고서들의 Reading List(32편)를 유지하며, 이번 수집에서 새롭게 추천할 자료를 추가한다.

### 신규 추가

33. **[LKV](https://arxiv.org/abs/2605.06676)** (Enshuai Zhou et al., arXiv 2026-05) — KV 축출을 E2E 학습 문제로 재정의; 헤드별 예산 최적화의 중요성을 실증한 이정표 논문.
34. **[LaProx](https://arxiv.org/abs/2605.07234)** (Tho Mai, Joo-Young Kim, KAIST, arXiv 2026-05) — 출력 인식 글로벌 중요도 스코어; "어텐션 = 중요도" 패러다임의 대안 입문.
35. **[RateQuant](https://arxiv.org/abs/2605.06675)** (arXiv 2026-05) — Rate-Distortion 이론의 KV 양자화 적용; 역 워터필링 비트 배분 수식 이해에 적합.
36. **[Tutti](https://arxiv.org/abs/2605.03375)** (Shi Qiu et al., arXiv 2026-05) — GPU-centric NVMe KV 저장 시스템; 장문맥 서빙 인프라 설계의 실용 참고.
37. **[Louver](https://arxiv.org/abs/2605.06763)** (Dehghankar & Asudeh, arXiv 2026-05) — 희소 어텐션의 알고리즘화; 근사 없는 정확 검색의 이론·시스템 이해에 필수.
38. **[RetentiveKV](https://arxiv.org/abs/2605.04075)** (Sihao Liu et al., arXiv 2026-05) — VLM KV 축출의 SSM 기반 패러다임; 이산→연속 메모리 진화 개념 입문.
39. **[eOptShrinkQ](https://arxiv.org/abs/2605.02905)** (Pei-Chun Su, Yale, arXiv 2026-05) — 스파이크 랜덤 행렬 이론 기반 KV 압축; 수학적 배경 심화 학습에 적합.

---

## 8. Methodology

### 검색 쿼리

본 보고서에서 신규 자료 수집에 사용한 주요 검색 쿼리는 다음과 같다.

```
KV cache LLM inference optimization arxiv 2026 May new paper
KV cache compression quantization LLM 2026 arxiv
KV cache eviction token sparse attention LLM arxiv May 2026
prefill decode disaggregation KV transfer LLM serving 2026 arxiv new
MLA cross-layer KV sharing architecture LLM 2026 arxiv new May
long context KV offload CPU NVMe inference LLM arxiv 2026 May
arxiv 2605 KV cache LLM new paper May 2026
vLLM SGLang KV cache update serving system 2026 May new feature
arxiv 2605.07234 LaProx KV cache eviction LLM reformulating
arxiv 2605.06676 LKV head-wise budget token selection KV cache eviction
arxiv 2605.03375 Tutti SSD NVMe KV cache LLM serving
arxiv 2605.11478 FibQuant vector quantization KV cache compression
arxiv 2605.03884 QKVShare quantized KV cache handoff multi-agent on-device
arxiv 2605.05699 int4 KV cache Apple Silicon quantization free
arxiv 2605.06850 shadow mask distillation KV cache RL post-training
arxiv 2605.06675 RateQuant mixed-precision KV cache rate-distortion
arxiv 2605 PPD disaggregation multi-turn 2603.13358
arxiv 2605.06763 Louver sparse attention range searching KV cache
arxiv 2605.07363 MISA mixture indexer sparse attention long context
arxiv 2605.07719 hybrid sparse attention CPU GPU parallelism
arxiv 2605.02568 StreamIndex memory-bounded sparse attention streaming top-k
arxiv 2605 KV-Fold KV cache recurrence 2605.12471
arxiv 2605 beyond token eviction mixed-dimension budget 2603.20616
arxiv 2605 Make LVLM KV Cache Lightweight 2605.00789
arxiv 2605 RetentiveKV multimodal 2605.04075
arxiv 2605.02262 WindowQuant VLM KV cache mixed-precision
arxiv 2605 eOptShrinkQ 2605.02905 spectral denoising
```

### 수집 출처

| 범주 | 출처 |
|------|------|
| 프리프린트 | arXiv cs.LG, cs.CL, cs.DC, cs.AR, cs.OS (2026-05-04 ~ 2026-05-14) |
| 집계·탐색 | Semantic Scholar, arXiv listing, Google Scholar 스니펫 |
| 기관 자료 | KAIST, Yale, Peking University, BMW TechWorks 저자 소속 검색 |

### 신규성 필터 적용 결과

- **비교 대상:** KNOWN_URLS 153건 + 직전 보고서(2026-05-04) 18건 합계 URL/제목/기법명 집합
- **제외된 기존 항목:** 153건 이상 (KNOWN_URLS 목록 및 직전 보고서 수록 논문 전부)
- **신규 수록 항목:** 총 **18개 논문** (A 1건, B 7건, C 5건, D 0건, E 0건, F 3건, G 2건)
- **별도 언급 항목:** QKVShare (arXiv:2605.03884) — 복수 카테고리 교차 논문으로 표 외 언급
- **신규 없는 영역:** D(분산 서빙 전용), E(아키텍처 수준), H(보안·프라이버시)

### 가정 및 한계

- **저자 정보 미확인:** RateQuant(2605.06675) 전체 저자 명단, FibQuant(2605.11478) 저자, StreamIndex(2605.02568) 저자, KV-Fold(2605.12471) 저자, LKV(2605.06676) 소속 기관, Tutti(2605.03375) 소속 기관, Louver(2605.06763) 소속 기관, RetentiveKV(2605.04075) 소속 기관, LightKV(2605.00789) 소속 기관은 검색 스니펫에서 완전히 확인되지 않았다. arXiv 원문에서 직접 확인이 필요하다.
- **PPD (arXiv:2603.13358):** arXiv 제출일이 2026-03로 직전 보고서(2026-05-04) 이전이지만, KNOWN_URLS에 포함되지 않아 이번 보고서에 신규 수록하였다. 정기 수집 주기의 스캔 범위 차이로 발생한 누락으로 판단된다.
- **MixedDimKV (arXiv:2603.20616):** 마찬가지로 arXiv 제출이 2026-03이나 KNOWN_URLS에 부재하여 신규 수록하였다.
- **수치 직접 비교 주의:** 모든 성능 수치(배속, 압축률, PPL)는 각 논문이 자체 보고한 수치이며, 하드웨어 환경·기준선·데이터셋이 논문마다 상이하므로 직접 비교에 주의가 필요하다.
- **QKVShare (arXiv:2605.03884)의 실용 검증:** 저자가 "더 강한 컨트롤러 절제 실험과 동등 비교가 필요하다"고 명시하였으므로 초기 단계 연구로 취급해야 한다.
- **WindowQuant (arXiv:2605.02262):** 비디오 VLM에 특화된 논문으로, 이미지-텍스트 VLM에 직접 적용 가능성은 별도 검증 필요.
- **eOptShrinkQ (arXiv:2605.02905):** arXiv 제출일이 2026-04-06으로 표기된 경우와 2026-05 표기가 혼재한다. 검색 결과에서 "April 6, 2026"으로 확인되었으므로 time_range(2023-01 ~ 2026-04) 내에 해당함을 주의한다.
