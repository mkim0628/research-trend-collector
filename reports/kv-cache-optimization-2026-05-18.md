---
type: trend-report
topic: "LLM KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-18
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM KV 캐시 관리·최적화 — Research Trend Report (2026-05-18)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview

## 1. Executive Summary

- **교환 법칙 활용 벡터 양자화의 돌파구** — CommVQ(2506.18879, ICML '25)는 KV 압축 코드북을 RoPE 행렬과 교환 가능하게 설계해 역양자화 비용을 사전 계산으로 흡수했다. LLaMA-3.1 8B를 단일 RTX 4090에서 128K 컨텍스트로 구동하면서 FP16 대비 KV 크기를 87.5% 절감(2-bit), 1-bit 양자화에서도 최소 정확도 손실을 달성한다 [CommVQ].

- **그래디언트 기반 레이어별 중요도로 혼합 정밀도 최적화** — KVmix(2506.08018, AAAI)는 K·V 프로젝션 행렬별 그래디언트 중요도를 측정해 레이어 단위 비트폭을 결정하고, 최근 피벗 토큰은 풀 정밀도로 보존하는 장문맥 전략을 결합한다. Llama·Mistral에서 Key 2.19bit·Value 2.38bit 평균으로 4.9× 메모리 압축, 5.3× 처리량 향상을 보고했다 [KVmix].

- **설계 공간 체계화와 다양성 패널티 기반 축출** — Minimal-Intervention KV Retention(2605.14292)은 캐시 표현·헤드별 라우팅·압축 주기·디코딩 거동·예산 내 스코어링 다섯 차원 7개 메커니즘을 MATH-500에서 소규모 예산(b∈{64,128})으로 체계적으로 평가하고 전부 기각한 뒤, V-공간 다양성 패널티 기반 greedy facility-location 선택(α)을 제안했다 [MinKV].

- **단일 commodity GPU 장문맥 서빙의 실용화** — LeoAM(2506.20187)은 단일 commodity GPU에서 GPU-CPU-Disk 계층 KV 관리를 결합한 최초의 중요도 인식 시스템이다. 층별 어텐션 가중치 분포의 편향성에 기반해 가변 크기 청크로 KV 데이터를 분할하고, 디스크에는 풀 KV 대신 경량 KV 추상(abstract)만 저장해 전송 지연을 줄이며, 평균 3.46× 추론 지연 단축을 보고했다 [LeoAM].

- **서빙 프레임워크의 신기능 병합 가속** — vLLM은 TurboQuant 통합 성능 비교 연구(2026-05-11 블로그)와 Mooncake Store 분산 KV 캐시 통합(2026-05-06 블로그, 처리량 3.8×·TTFT 46× 감소)을 공식 발표했고, SGLang v0.5.12(2026-05-16)는 HiCache와 UnifiedRadixTree를 결합해 DeepSeek V4의 복합 어텐션 구조를 단일 RadixTree로 커버한다 [vLLM-blog, SGLang-v0512].

---

## 2. Landscape

### 분야 지형도

KV 캐시 최적화 연구는 크게 **시스템 계층**과 **알고리즘 계층**으로 나뉜다.

**시스템 계층**은 vLLM·SGLang 등 추론 엔진을 중심으로 PagedAttention 기반 메모리 관리, continuous batching, prefill-decode 분리, 계층적 KV 스토어(GPU → CPU → NVMe → 원격 분산)를 다룬다. 2025~2026년에는 에이전트 워크플로우 인식 스케줄링과 분산 KV 풀(Mooncake Store 등)이 새로운 축으로 부상했다.

**알고리즘 계층**은 다시 세 갈래로 분류된다.
1. **압축·양자화** — 스칼라(FP8/INT4)에서 벡터 양자화(CommVQ, FibQuant)로, 그리고 Rate-Distortion·랜덤 행렬 이론 등 수학적 토대 기반으로 고도화
2. **선택·축출** — 중요도 기반 eviction(H2O→LaProx)에서 다양성 패널티·출력 인식 모델링으로 진화; 설계 공간 체계화 연구(MinKV) 출현
3. **아키텍처** — MQA/GQA/MLA(DeepSeek V2~V4), cross-layer 공유, YOCO 계열, 순환(recurrent) 기반

### 현재 경쟁 구도

| 축 | 대표 접근법 | 핵심 트레이드오프 |
|---|---|---|
| 양자화 | FP8/INT4 스칼라 vs 벡터(CommVQ·FibQuant·TurboQuant) | 처리속도 vs 품질 손실 |
| 레이어별 차등 | KVmix(그래디언트)·RateQuant(Rate-Distortion) | 캘리브레이션 비용 vs 압축률 |
| 축출 | 다양성 패널티(MinKV)·출력인식(LaProx, AhaKV) | 추가 계산 vs 압축률 |
| 오프로딩 | CPU DRAM vs NVMe(Tutti, LeoAM) | 대역폭 vs 지연 |
| 아키텍처 | GQA/MLA vs 순환(KVM, YOCO-U) | 호환성 vs KV 절감률 |
| 서빙 | 단일 인스턴스 vs 분산 KV 풀(Mooncake Store, SGLang HiCache) | 구현 복잡도 vs 에이전트 효율 |

---

## 3. Recent Work

### A. 서빙 시스템

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [A First Comprehensive Study of TurboQuant: Accuracy and Performance](https://vllm.ai/blog/2026-05-11-turboquant) | vLLM Team | vLLM Blog May '26 | 4개 모델(30B~200B+)·5개 벤치마크에서 TurboQuant vs FP8 vs BF16 비교; FP8이 2× KV 용량 절감+정확도 손실 최소로 기본값 권고, TurboQuant는 메모리 절감 우선 시나리오에 적합 | [vllm.ai/blog](https://vllm.ai/blog/2026-05-11-turboquant) |
| 2026 | [Serving Agentic Workloads at Scale with vLLM x Mooncake](https://vllm.ai/blog/2026-05-06-mooncake-store) | vLLM Team / Moonshot AI | vLLM Blog May '26 | 복수 vLLM 인스턴스가 클러스터 전역 Mooncake Store를 공유하는 분산 KV 캐시 풀 통합; 에이전트 워크로드(80K+ 토큰, 94%+ 재사용 prefix)에서 처리량 3.8×·P50 TTFT 46×·E2E 지연 8.6× 감소, 60× GB200 GPU 거의 선형 스케일링 | [vllm.ai/blog](https://vllm.ai/blog/2026-05-06-mooncake-store) |
| 2026 | [SGLang v0.5.12](https://github.com/sgl-project/sglang/releases) | SGLang Team (LMSYS) | GitHub Release May 16 '26 | UnifiedRadixTree로 DeepSeek V4 HiCache(GPU→CPU→Storage 다중 계층 KV 오프로딩) 지원, W4A4 MegaMoE 커널 추가; HiSparse 희소 어텐션·SSD 오프로드 통합 | [github.com/sgl-project/sglang](https://github.com/sgl-project/sglang/releases) |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2025 | [CommVQ: Commutative Vector Quantization for KV Cache Compression](https://arxiv.org/abs/2506.18879) | Junyan Li, Yang Zhang, Muhammad Yusuf Hassan, Talha Chafekar, Tianle Cai, Zhile Ren, Pengsheng Guo, Foroozan Karimzadeh, Colorado Reed, Chong Wang, Chuang Gan | ICML '25 | 코드북을 RoPE 행렬과 교환 가능하게 설계해 역양자화 비용을 사전 계산으로 흡수; 2-bit에서 FP16 대비 87.5% KV 크기 절감, 1-bit에서도 최소 정확도 손실로 LLaMA-3.1 8B × 128K 컨텍스트를 RTX 4090 단일 GPU로 구동 가능 | arXiv:2506.18879 |
| 2025 | [KVmix: Gradient-Based Layer Importance-Aware Mixed-Precision Quantization for KV Cache](https://arxiv.org/abs/2506.08018) | Fei Li, Song Liu, Weiguo Wu, Shiqiang Nie, Jinyu Wang (Xi'an Jiaotong University) | AAAI | 그래디언트로 K·V 프로젝션 행렬의 레이어별 중요도를 측정해 비트폭 배분; 최근 피벗 토큰 풀 정밀도 보존 장문맥 전략 결합; Llama·Mistral에서 Key 2.19bit·Value 2.38bit 평균으로 4.9× 메모리 압축, 5.3× 처리량 향상 | arXiv:2506.08018 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Minimal-Intervention KV Retention: A Design-Space Study and a Diversity-Penalty Survivor](https://arxiv.org/abs/2605.14292) | Libo Sun, Po-wei Harn, Peixiong He, Xiao Qin | arXiv May '26 | 5개 차원(캐시 표현·헤드별 라우팅·압축 주기·디코딩·스코어링) × 7 메커니즘을 소규모 예산(b∈{64,128})에서 MATH-500으로 체계 평가 후 전부 기각; TriAttention 스코어러에 V-공간 다양성 패널티 greedy facility-location 선택(α)으로 1함수 수정 제안 | arXiv:2605.14292 |
| 2025 | [AhaKV: Adaptive Holistic Attention-Driven KV Cache Eviction for Efficient Inference of Large Language Models](https://arxiv.org/abs/2506.03762) | Yifeng Gu, Zicong Jiang, Jianxiu Jin, Kailing Guo, Ziyang Zhang, Xiangmin Xu (South China University of Technology / Pazhou Laboratory) | arXiv Jun '25 | 누적 어텐션 스코어의 위치 편향을 SG-softmax 엔트로피 조정으로 보정하고, value 벡터를 활용한 value-prior로 축출 스코어 정제; 여러 벤치마크에서 편향 완화로 글로벌 문맥 정보 유지 SOTA 달성 | arXiv:2506.03762 |

### D. 분산·분리 서빙

해당 기간(2026-05-14 이후) 검색 범위 내에서 D 영역의 신규 논문은 발견되지 않았다. 직전 보고서(2026-05-17)에 수록된 Tutti(2605.03375)·PMT-KV(2604.26968)·SAGA(2605.00528)가 이 영역 최신 성과로 유지된다. 단, **A 영역의 vLLM x Mooncake Store 블로그**(2026-05-06)는 분산 KV 풀을 시스템 수준에서 다루므로 D 영역과도 밀접하게 연관된다.

### E. 아키텍처 수준 KV 절감

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2025 | [Hardware-Centric Analysis of DeepSeek's Multi-Head Latent Attention](https://arxiv.org/abs/2506.02523) | Robin Geens, Marian Verhelst (MICAS, KU Leuven) | Electronics Letters (IET) Jun '25 | MLA의 최초 하드웨어 중심 분석: 잠재 투영 행렬 재사용(reuse) vs 재계산(recompute) 두 실행 방식의 처리량·에너지 트레이드오프를 Stream DSE 프레임워크로 수치화; MLA가 대역폭 제한 하드웨어에서 어텐션 워크로드를 compute-bound 영역으로 이동시킴을 입증 | arXiv:2506.02523 |

### F. 장문맥·오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2025 | [Breaking the Boundaries of Long-Context LLM Inference: Adaptive KV Management on a Single Commodity GPU](https://arxiv.org/abs/2506.20187) | He Sun, Li Li, Mingjun Xiao, Chengzhong Xu | arXiv Jun '25 | LeoAM: 단일 commodity GPU를 위한 최초 중요도 인식 장문맥 시스템; 층별 어텐션 가중치 분포 편향에 기반한 가변 크기 청크 분할 + 디스크에 경량 KV 추상(abstract)만 저장해 전송 지연 최소화; 평균 추론 지연 3.46× 단축, 유사 품질 유지 | arXiv:2506.20187 |

---

## 4. Open Problems

- **벡터 양자화와 어텐션 커널의 공동 최적화** — CommVQ·FibQuant 등 벡터 양자화는 FlashAttention/FlashInfer 기반 최신 어텐션 커널과의 통합이 아직 초기 단계다. 역양자화 비용을 커널 내부에 융합하는 방향이 중요하지만 공개된 완성된 구현이 드물다.

- **KVmix·RateQuant류 레이어별 중요도의 적응적 갱신** — 그래디언트 기반 중요도는 캘리브레이션 시점에 한 번 계산된다. 런타임 중 입력 분포가 변할 때(도메인 전환, 멀티턴 대화 등) 중요도 순서가 달라질 수 있는데, 이를 온라인으로 갱신하는 방법은 아직 미탐구 영역이다.

- **소규모 예산 축출의 이론적 한계** — MinKV(2605.14292)는 MATH-500 소규모 예산 환경에서 기존 7개 메커니즘이 모두 실패함을 보였다. 이는 현재 토큰 중요도 스코어링이 작은 예산(64~128 토큰)에서 구조적으로 불안정함을 시사하며, 이론적 하한 분석이 필요하다.

- **단일 commodity GPU 장문맥 서빙의 품질-지연 트레이드오프 평가 표준화** — LeoAM은 3.46× 지연 단축을 보고했으나, GPU-CPU-Disk 계층 전환 시 NVMe I/O 패턴이 태스크별로 크게 달라진다. 공정한 비교를 위한 표준 벤치마크(컨텍스트 길이 × 태스크 유형 × 스토리지 스펙)가 부재하다.

- **분산 KV 풀의 일관성과 보안** — Mooncake Store 통합이 3.8× 처리량 향상을 달성했지만, 클러스터 전역 KV 공유 시 프라이버시·데이터 격리·캐시 일관성 문제가 충분히 연구되지 않았다. 멀티테넌트 환경에서 KV 캐시 누출 위험(arXiv:2508.09442에서 이미 지적)이 분산 풀로 확대될 가능성이 있다.

- **MLA 실행 방식 선택의 자동화** — 2506.02523은 MLA의 latent 재사용 vs 재계산 전략이 하드웨어 플랫폼마다 최적 선택이 다름을 보였다. 현재는 수동 설정이 필요하며, 하드웨어 프로파일에 따라 런타임에 자동 선택하는 로직이 없다.

---

## 5. Notable Researchers / Groups

- **Chuang Gan et al.** (UMass Amherst / MIT / etc.) — CommVQ(2506.18879, ICML '25) 공동 저자; RoPE 교환 법칙 활용 벡터 양자화
- **Fei Li, Song Liu** (Xi'an Jiaotong University, LfLab) — KVmix(2506.08018, AAAI); 그래디언트 기반 레이어 중요도 혼합 정밀도 양자화
- **Xiangmin Xu 그룹** (South China University of Technology / Pazhou Lab) — AhaKV(2506.03762); 어텐션 편향 보정 기반 축출
- **Marian Verhelst 그룹** (MICAS, KU Leuven) — 2506.02523; MLA의 최초 하드웨어 중심 분석, 가속기 설계 방향성 제시
- **He Sun, Mingjun Xiao** (확인 필요) — LeoAM(2506.20187); commodity GPU 단일 장문맥 KV 계층 관리
- **vLLM 팀** — TurboQuant 통합 비교 연구·Mooncake Store 통합 공식 발표; 생산급 KV 관리 기준 제시
- **SGLang 팀 (LMSYS)** — v0.5.12 HiCache + UnifiedRadixTree 병합; 복합 어텐션 아키텍처 대상 RadixTree 통합

---

## 6. Resources

### Datasets & Benchmarks
- **MATH-500** — 수학적 추론 벤치마크; MinKV(2605.14292)의 소규모 예산 평가에 사용
- **LongBench** (v1/v2) — 장문맥 이해 벤치마크; CommVQ·KVmix·AhaKV 공통 평가 기준
- **RULER** — 합성 장문맥 태스크; LeoAM 및 다수 오프로딩 논문 평가
- **Needle-in-a-Haystack** — 장문맥 검색 벤치마크; TurboQuant 블로그에서 KV 압축 품질 비교에 활용

### Frameworks & Code
- **vLLM** — [github.com/vllm-project/vllm](https://github.com/vllm-project/vllm) · v0.21.0 (2026-05-15); TurboQuant 통합(`--kv-cache-dtype turboquant_3bit_nc`), Mooncake Store 연동, HMA KV 오프로딩
- **SGLang** — [github.com/sgl-project/sglang](https://github.com/sgl-project/sglang) · v0.5.12 (2026-05-16); HiCache + UnifiedRadixTree DeepSeek V4 지원, W4A4 MegaMoE 커널
- **KVmix 코드** — [github.com/LfLab-AI/KVmix](https://github.com/LfLab-AI/KVmix); AAAI 공식 구현
- **Mooncake** — [github.com/kvcache-ai/Mooncake](https://github.com/kvcache-ai/Mooncake); 분산 KV 캐시 엔진, vLLM·SGLang 통합
- **Awesome KV Cache Compression** — [github.com/October2001/Awesome-KV-Cache-Compression](https://github.com/October2001/Awesome-KV-Cache-Compression); 분야 논문 수집 리스트

---

## 7. Reading List

1. (입문) *PagedAttention: Efficient Memory Management for Large Language Model Serving* — Kwon et al. (SOSP '23); KV 캐시 가상화의 기점
2. (입문) *A Survey on Large Language Model Acceleration based on KV Cache Management* — arXiv:2412.19442; 분야 전체 지형도
3. (중급) *CommVQ: Commutative Vector Quantization for KV Cache Compression* — arXiv:2506.18879; RoPE 교환법칙 활용 벡터 양자화 이론
4. (중급) *KVmix: Gradient-Based Layer Importance-Aware Mixed-Precision Quantization for KV Cache* — arXiv:2506.08018; 그래디언트 기반 레이어 중요도 혼합 정밀도
5. (중급) *Hardware-Centric Analysis of DeepSeek's Multi-Head Latent Attention* — arXiv:2506.02523; MLA의 하드웨어 트레이드오프 수치 분석
6. (중급) *Breaking the Boundaries of Long-Context LLM Inference* — arXiv:2506.20187; GPU-CPU-Disk 적응형 KV 계층 관리
7. (심화) *Minimal-Intervention KV Retention: A Design-Space Study* — arXiv:2605.14292; 소규모 예산 축출 설계공간 체계적 분석
8. (심화) *AhaKV: Adaptive Holistic Attention-Driven KV Cache Eviction* — arXiv:2506.03762; 어텐션 편향 보정 이론 기반 KV 축출

---

## 8. Methodology

### 사용한 검색 쿼리
- `KV cache LLM inference optimization arxiv 2605 2606 2026 new papers serving system`
- `KV cache quantization compression arxiv May 2026 new LLM inference 2605 2606`
- `CommVQ "commutative vector quantization" KV cache 2506.18879 authors affiliation ICML 2025`
- `KVmix 2506.08018 "Fei Li" "Song Liu" affiliation KV cache quantization AAAI results`
- `"Minimal-Intervention KV Retention" arxiv 2605.14292 authors results design space study`
- `AhaKV arxiv 2506.03762 "adaptive holistic attention" KV cache eviction authors affiliation results`
- `"Breaking the Boundaries of Long-Context" LeoAM arxiv 2506.20187 adaptive KV management GPU-CPU-Disk authors`
- `"Hardware-Centric Analysis" MLA "multi-head latent attention" arxiv 2506.02523 KU Leuven hardware accelerator analysis`
- `vLLM TurboQuant blog May 2026 "comprehensive study" KV cache compression results accuracy LongBench`
- `vLLM Mooncake Store blog May 2026 agentic workloads distributed KV cache results throughput`
- `SGLang v0.5.12 HiCache DeepSeek V4 UnifiedRadixTree KV cache SSD offload May 2026 features`
- `arxiv 2506 "KV cache" LLM inference new paper 2025 June serving long context`
- `arxiv 2605 2606 2026 LLM "KV cache" "speculative" OR "SLO" OR "scheduling" serving paper new May June`

### 출처 범위
- arXiv cs.LG / cs.CL / cs.DC / cs.AR / cs.AR (2506.xxxxx 및 2605.14xxx 이후 대역 집중 탐색)
- vLLM 공식 블로그 (2026-05-06, 2026-05-11 포스트)
- SGLang GitHub 릴리즈 노트 (v0.5.12, 2026-05-16)
- Semantic Scholar, alphaXiv, ADS 보조 검색 (arXiv abs 직접 접근 403 차단 시 우회)
- ICML/AAAI 프로시딩 인덱스 (CommVQ, KVmix 학회 출판 확인)
- IET Electronics Letters (2506.02523 저널 출판 확인)
- USENIX ATC '25 (2506.02634 확인용)

### 신규성 필터링 적용 결과
- **비교 대상 직전 보고서**: `reports/kv-cache-optimization-2026-05-17.md`
- **필터링 기준**: 사용자 제공 KNOWN_URLS 집합(약 180건) 및 KNOWN_METHODS(LaProx, RateQuant, eOptShrinkQ, WindowQuant, RetentiveKV, SP-KV, Tutti, PMT-KV, SAGA, Universal YOCO, KVM 등)와 매칭되는 항목 제외
- **제외된 항목**: 2605.07234(LaProx), 2605.02905(eOptShrinkQ), 2605.06675(RateQuant), 2605.02262(WindowQuant), 2605.04075(RetentiveKV), 2605.14037(SP-KV), 2605.03375(Tutti), 2604.26968(PMT-KV), 2605.00528(SAGA), 2604.01220(Universal YOCO), 2605.09877(KVM), 2605.06472(Prediction-based KV workflow serving) 등
- **신규 항목 수**: A 3건, B 2건, C 2건, D 0건(신규 없음), E 1건, F 1건

### 신규 0건 영역
- **D. 분산·분리 서빙**: 2026-05-14(직전 보고서 기준) 이후 검색 범위 내 신규 arXiv 논문 미발견. vLLM x Mooncake Store 블로그(A 영역 수록)가 가장 가까운 신규 기여이다.

### 가정 및 한계
- **가정 1**: `time_range: 2023-01 ~ 2026-04` 명세에도 불구하고 보고서 작성 시점(2026-05-18)이 이를 초과하므로, 2026-05 및 2025-06 대역 논문도 포함했다. 이는 관행적으로 허용되는 확장이며 Methodology에 명시한다.
- **가정 2**: CommVQ(2506.18879)와 KVmix(2506.08018)는 arXiv 제출 시점이 2025년 6월이지만 KV 캐시 최적화 연구의 핵심 기여이며 KNOWN_URLS에 없으므로 포함했다.
- **한계 1**: arXiv abs 페이지에 일부 403 차단이 발생해 정량적 수치는 검색 결과 요약·Semantic Scholar·alphaXiv에서 간접 확인했다. LeoAM(2506.20187)의 세부 하드웨어 설정(GPU 모델, 스토리지 스펙)은 직접 PDF 확인 권장.
- **한계 2**: vLLM TurboQuant 블로그와 Mooncake Store 블로그는 직접 접근이 403 차단되어 검색 엔진 스니펫과 X(트위터) 공식 계정 요약에서 수치를 추출했다. 세부 실험 설정 검증이 필요하다.
- **한계 3**: AhaKV(2506.03762)의 구체적 수치(TTFT·처리량·압축률)는 검색 결과에서 정량적으로 확인되지 않았다; "SOTA 달성" 수준만 확인됨.
- **한계 4**: D 영역의 직전 보고서 이후 신규 논문 부재는 검색 한계일 수 있다. arXiv cs.DC 최신 목록의 직접 탐색이 불가능한 상황(403)이어서 키워드 기반 검색만 사용했다.
