---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-17
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-17)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview

## 1. Executive Summary

- **에이전트 워크플로우 전용 KV 스케줄링 부상** — 수십~수백 회의 연쇄 LLM 호출로 구성된 에이전트 태스크를 하나의 스케줄 단위로 다루는 SAGA(2605.00528)가 등장했다. 워크플로우 구조를 사전 파악해 KV 캐시 재사용률을 극대화하며, 64-GPU 클러스터에서 vLLM 대비 작업 완료 시간 1.64× 단축을 보고했다 [SAGA].

- **양자화 이론의 고도화** — 스칼라 양자화에서 벡터 양자화로, 그리고 Rate-Distortion 이론·랜덤 행렬 이론 등 수학적 토대를 활용한 KV 압축이 경쟁하고 있다. RateQuant(2605.06675)는 역 워터필링으로 최적 비트 할당을 닫힌 형태로 도출하며, eOptShrinkQ(2605.02905)는 저랭크 공유 성분과 잔차를 분리해 동등 품질에서 TurboQuant 대비 ~1비트 절감을 달성한다 [RateQuant, eOptShrinkQ].

- **출력 인식(output-aware) 축출 전략으로의 전환** — 주의 가중치만을 중요도 대리 지표로 쓰던 기존 방식에서 벗어나, 값(value) 행렬·출력 프로젝션·헤드 간 상호작용까지 명시적으로 모델링하는 LaProx(2605.07234)와 엔트로피 기반 상태 전이를 도입하는 RetentiveKV(2605.04075)가 발표됐다 [LaProx, RetentiveKV].

- **SSD 기반 KV 오프로딩의 실용화** — GPU HBM과 CPU DRAM을 초과하는 컨텍스트 규모에서 NVMe SSD로의 KV 오프로딩이 본격 연구됐다. Tutti(2605.03375)는 CPU를 임계 경로에서 제거하는 GPU-centric KV 오브젝트 스토어를 제안하며, 예측형 다계층 메모리 관리(2604.26968)는 Bayesian 재사용 예측으로 70~84% 캐시 적중률을 보고했다 [Tutti, PMT-KV].

- **아키텍처 수준 KV 절감의 다양화** — YOCO의 상수 글로벌 KV 캐시 패러다임을 반복 계산과 결합한 Universal YOCO(2604.01220), 그리고 블록 순환(block-recurrence) 형태의 KVM(2605.09877)이 새로운 아키텍처 선택지를 제시했다 [YOCO-U, KVM].

---

## 2. Landscape

### 분야 지형도

KV 캐시 최적화 연구는 크게 **시스템 계층**과 **알고리즘 계층**으로 나뉜다.

**시스템 계층**은 vLLM·SGLang 등 추론 엔진을 중심으로 PagedAttention 기반 메모리 관리, continuous batching, prefill-decode 분리(P-D disaggregation), 계층적 KV 스토어(GPU → CPU → NVMe → 원격)를 다룬다. 2025~2026년에 들어 에이전트 워크플로우 인식(workflow-aware) 스케줄링이 새로운 축으로 부상했다.

**알고리즘 계층**은 다시 세 갈래로 분류된다.
1. **압축** — 양자화(scalar→vector), 저랭크 분해(SVD, PCA), 엔트로피 코딩
2. **선택·축출** — 중요도 기반 eviction(H2O~LaProx), 학습 기반(LKV, SP-KV), 희소 어텐션 인덱스
3. **아키텍처** — MQA/GQA/MLA, cross-layer 공유, YOCO 계열, 순환(recurrent) 기반

이 두 계층의 경계는 점차 흐려지고 있다. 예를 들어, Tutti는 GPU 커널 설계(시스템)와 NVMe I/O 스케줄링(알고리즘)을 통합하고, RateQuant는 정보이론적 보장(알고리즘)을 통해 시스템 수준의 비트 할당을 결정한다.

### 현재 경쟁 구도

| 축 | 대표 접근법 | 핵심 트레이드오프 |
|---|---|---|
| 양자화 | FP8/INT4/INT2 스칼라 vs 벡터(TurboQuant, FibQuant) | 처리 속도 vs 품질 손실 |
| 축출 | 정적 saliency vs 학습 기반 예측(SP-KV, LKV) | 추가 훈련 비용 vs 압축률 |
| 오프로딩 | CPU DRAM vs NVMe(Tutti, DUAL-BLADE) | 대역폭 vs 지연 |
| 아키텍처 | GQA/MLA vs 순환(KVM, YOCO-U) | 호환성 vs KV 절감률 |
| 서빙 | 단일 요청 최적화 vs 워크플로우 인식(SAGA) | 구현 복잡도 vs 에이전트 효율 |

---

## 3. Recent Work

### A. 서빙 시스템

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters](https://arxiv.org/abs/2605.00528) | Dongxin Guo et al. | arXiv May '26 | 에이전트 워크플로우 전체를 스케줄 단위로 삼아 KV 캐시 재사용 그래프를 구축; 64-GPU 클러스터에서 vLLM 대비 작업 완료 시간 1.64× 단축, GPU 메모리 활용률 1.22× 향상 | arXiv:2605.00528 |

**vLLM v0.21.0 (2026-05-15 릴리즈)**
vLLM은 0.21.0에서 KV 오프로딩 서브시스템과 Hybrid Memory Allocator(HMA)를 통합했다. 슬라이딩 윈도우 그룹 지원, DCP/PCP OffloadingConnector, MooncakeStoreConnector(분산 KV 캐시 오프로딩)가 추가됐으며, Blackwell GPU용 TOKENSPEED_MLA 어텐션 백엔드(DeepSeek-R1/Kimi-K25 prefill+decode)를 새로 지원한다. SGLang v0.5.11(2026-05-05)은 RadixArk 공개 런칭 및 MHA FP8-KV 지원, Qwen3-VL KV 쓰기 최적화(QK-norm + 3D mRoPE + KV cache write 단일 커널 융합)를 포함했다.

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [RateQuant: Optimal Mixed-Precision KV Cache Quantization via Rate-Distortion Theory](https://arxiv.org/abs/2605.06675) | Fei Zuo, Zikang Zhou, Hao Cong et al. (BMW Group / NUS / Tsinghua) | arXiv May '26 | Rate-Distortion 이론의 역 워터필링으로 캘리브레이션 세트에서 per-quantizer 왜곡 모델을 피팅해 최적 비트 배분을 닫힌 형태로 도출; Qwen3-8B에서 2.5bit 환경, KIVI 대비 perplexity 49.3 → 14.9 (70% 감소), 캘리브레이션 1.6초 소요 | arXiv:2605.06675 |
| 2026 | [eOptShrinkQ: Near-Lossless KV Cache Compression Through Optimal Spectral Denoising and Quantization](https://arxiv.org/abs/2605.02905) | Pei-Chun Su (Yale University) | arXiv May '26 | 스파이크 랜덤 행렬 모델로 저랭크 공유 성분을 eOptShrink로 추출하고 잔차를 TurboQuant로 양자화; Llama-3.1-8B에서 동일 품질 대비 TurboQuant 대비 ~1bit 절감, LongBench 16개 태스크 평가 | arXiv:2605.02905 |
| 2026 | [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs Inference Optimization](https://arxiv.org/abs/2605.02262) | Wei Tao, Xiaoyang Qu, Peiqiang Wang et al. | arXiv May '26 | VLM의 긴 시각 토큰 시퀀스를 윈도우 단위로 묶어 텍스트 프롬프트와의 유사도를 기반으로 최적 비트 폭을 빠르게 결정; 다양한 데이터셋에서 기존 VLM·KV 양자화 SOTA 초과 | arXiv:2605.02262 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Reformulating KV Cache Eviction Problem for Long-Context LLM Inference](https://arxiv.org/abs/2605.07234) | Tho Mai, Joo-Young Kim (KAIST) | arXiv May '26 | LaProx: 주의 맵과 프로젝션된 값 상태 간의 곱셈적 상호작용을 명시적으로 모델링해 출력 인식(output-aware) 층별(layer-wise) 행렬 곱 근사 문제로 재정식화; 19개 데이터셋에서 KV 캐시 5% 유지 시 SOTA 초과, 극단적 압축 시 정확도 손실 2× 감소 | arXiv:2605.07234 |
| 2026 | [RetentiveKV: State-Space Memory for Uncertainty-Aware Multimodal KV Cache Eviction](https://arxiv.org/abs/2605.04075) | Sihao Liu, YuFan Xiong, Zhonghua Jiang et al. | arXiv May '26 | 엔트로피 기반 중요도 추정 후 축출된 KV를 모달리티별 상태 공간으로 흡수하는 연속적 메모리 진화 프레임워크; 멀티모달 벤치마크에서 KV 캐시 5.0× 압축, 디코딩 1.5× 가속 | arXiv:2605.04075 |
| 2026 | [Self-Pruned Key-Value Attention: Learning When to Write by Predicting Future Utility](https://arxiv.org/abs/2605.14037) | Gergely Szilvasy, Manuel Faysse, Maria Lomeli et al. (Meta FAIR / CentraleSupélec) | arXiv May '26 | 경량 유틸리티 예측기가 각 KV 쌍을 채점해 미래 유용성이 임계치를 초과하는 것만 장기 캐시에 기록; 동적 희소화로 KV 캐시 3~10× 압축, validation loss·다운스트림 태스크 성능 거의 무손실 | arXiv:2605.14037 |

### D. 분산·분리 서빙

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Tutti: Making SSD-Backed KV Cache Practical for Long-Context LLM Serving](https://arxiv.org/abs/2605.03375) | Shi Qiu, Yifan Hu, Xintao Wang et al. | arXiv May '26 | CPU를 HBM-SSD 간 임계 데이터/I/O 제어 경로에서 제거하는 GPU-centric KV 오브젝트 스토어; GPU가 레이어당 1회 I/O 커널을 비동기로 로드해 단편화된 GPU 메모리 레이아웃으로 인한 수많은 소형 랜덤 I/O 문제를 해소 | arXiv:2605.03375 |
| 2026 | [Predictive Multi-Tier Memory Management for KV Cache in Large-Scale GPU Inference](https://arxiv.org/abs/2604.26968) | Sanjeev Rao Ganjihal | arXiv Apr '26 | 아키텍처 변형 인식 사이징 엔진 + 6계층 메모리 계층(40 GB → 38 TB) + Bayesian 재사용 예측; 64-GPU H100 클러스터에서 캐시 적중률 70~84%, TTFT 1.4~2.1× 감소, TensorRT-LLM 대비 처리량 2.0×·비용 30% 절감 | arXiv:2604.26968 |

### E. 아키텍처 수준 KV 절감

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Universal YOCO for Efficient Depth Scaling](https://arxiv.org/abs/2604.01220) | Yutao Sun, Li Dong, Tianzhu Ye et al. (Microsoft Research) | arXiv Apr '26 | YOCO 디코더-디코더 구조에 파라미터 공유 반복 계산(Universal Self-Decoder)을 결합; 상수 글로벌 KV 캐시와 선형 프리필링을 유지하면서 표현 깊이를 제한된 오버헤드로 확장, 일반·장문맥 벤치마크에서 YOCO 대비 경쟁력 유지 | arXiv:2604.01220 |
| 2026 | [Key-Value Means: Transformers with Expandable Block-Recurrent Compressed Memory](https://arxiv.org/abs/2605.09877) | Daniel Goldstein, Eugene Cheah | arXiv May '26 | KVM(Key-Value Means): 고정 크기 또는 성장형 블록 순환 어텐션; 커스텀 커널 없이 표준 연산으로 구현 가능, 청크 단위 병렬 훈련·프리필 지원, O(N)~O(N²) 사이의 연속적 프리필 복잡도 선택 가능 | arXiv:2605.09877 |

### F. 장문맥·오프로딩

*F 영역의 신규 논문은 D 영역 Tutti(2605.03375)와 겹친다. Tutti는 NVMe SSD 기반 장문맥 KV 서빙의 실용화가 핵심 기여이므로 D와 F 양쪽에 모두 해당한다.*

| Year | Title | Authors | Venue | Contribution | Link |
|---|---|---|---|---|---|
| 2026 | [Tutti: Making SSD-Backed KV Cache Practical for Long-Context LLM Serving](https://arxiv.org/abs/2605.03375) | Shi Qiu, Yifan Hu, Xintao Wang et al. | arXiv May '26 | GPU HBM·CPU DRAM을 초과하는 장문맥 KV를 SSD로 오프로딩 시 CPU 개입을 제거하는 GPU-centric 설계; 단편화된 메모리 레이아웃에서 발생하는 소형 랜덤 I/O 문제를 해소해 GPU 스톨 최소화 | arXiv:2605.03375 |

---

## 4. Open Problems

- **에이전트 규모의 KV 재사용 보장** — SAGA는 단일 클러스터 내에서 에이전트 워크플로우를 추적하지만, 멀티-데이터센터·멀티 모델 혼재 환경에서의 KV 전달 비용과 재사용 정책은 미해결이다.

- **VLM·멀티모달 KV의 이질성** — 시각 토큰은 텍스트 토큰과 다른 중요도 분포를 가진다. RetentiveKV와 WindowQuant가 이를 다루기 시작했으나, 오디오·비디오·코드 등 다양한 모달리티를 통합하는 일반적 KV 정책은 부재하다.

- **Rate-Distortion 보장과 실제 태스크 품질의 간극** — RateQuant·eOptShrinkQ 등은 수학적 최적성을 주장하지만, perplexity 감소가 downstream 태스크(코드 생성, 복잡한 추론)에서 동일하게 나타나지 않는 경우가 있다. 태스크 인식(task-aware) 양자화 평가 프로토콜이 필요하다.

- **SSD I/O와 어텐션 커널 공동 최적화** — Tutti는 I/O 경로를 GPU-centric으로 재설계했으나, FlashInfer 계열의 어텐션 커널과의 통합 및 공동 최적화는 아직 탐구 초기 단계이다.

- **아키텍처 KV 절감과 기존 서빙 스택 통합** — KVM·Universal YOCO 등 순환/반복 아키텍처는 PagedAttention 기반 메모리 관리자와의 통합이 비자명하며, 청크 단위 프리필·연속 배치와의 상호작용이 충분히 연구되지 않았다.

- **이론적 기반 강화** — Position paper(2605.01280)는 현재 서빙 시스템의 알고리즘적 핵심(FIFO 스케줄링, LRU 축출, 라운드로빈 라우팅)이 LLM 추론의 구조적 특성을 무시한다고 지적한다. KV 캐시 크기 동적 성장, prefill-decode 비대칭, 미지 출력 길이를 명시적으로 모델링하는 이론적 프레임워크 개발이 과제다.

---

## 5. Notable Researchers / Groups

- **Joo-Young Kim** (KAIST) — LaProx(2605.07234) 저자; 출력 인식 KV 축출 이론화
- **Pei-Chun Su** (Yale University) — eOptShrinkQ(2605.02905); 랜덤 행렬 이론 기반 KV 압축
- **Fei Zuo et al.** (BMW Group / NUS / Tsinghua) — RateQuant(2605.06675); Rate-Distortion 기반 최적 혼합 정밀도 양자화
- **Li Dong, Furu Wei 그룹** (Microsoft Research) — Universal YOCO(2604.01220) 포함 YOCO 계열 아키텍처 지속 연구
- **Meta FAIR** (Gergely Szilvasy, Hervé Jégou 등) — SP-KV(2605.14037); 학습 기반 미래 유틸리티 예측 축출
- **LMSYS 그룹 / SGLang 팀** (Lianmin Zheng 등) — SGLang v0.5.x RadixArk, PD 분리 decode-radix cache; 프레임워크 레벨 KV 재사용 최적화 선도
- **vLLM 팀** — v0.21.0 HMA-KV 오프로딩 통합, MooncakeStoreConnector; 생산급 KV 관리 기준 제시
- **Namyoon Lee, Yongjune Kim** (POSTECH) — FibQuant(2605.11478, 기존 수집됨); 벡터 양자화 이론

---

## 6. Resources

### Datasets & Benchmarks
- **LongBench** (v1/v2) — 장문맥 이해 벤치마크; LaProx·eOptShrinkQ·RateQuant 등 대부분 논문의 핵심 평가 기준
- **RULER** — 합성 장문맥 태스크 (multi-hop, retrieval); LKV 등 평가에 활용
- **AIME '25** — 수학적 추론 벤치마크; 추론 모델 KV 압축 평가에 사용
- **WikiText-103** — 언어 모델링 perplexity 기준; FibQuant·eOptShrinkQ 등

### Frameworks & Code
- **vLLM** — [github.com/vllm-project/vllm](https://github.com/vllm-project/vllm) · v0.21.0 (2026-05-15 릴리즈); HMA KV 오프로딩, MooncakeStoreConnector, TOKENSPEED_MLA 백엔드
- **SGLang** — [github.com/sgl-project/sglang](https://github.com/sgl-project/sglang) · v0.5.11 (2026-05-05); RadixArk, FP8-KV, decode-radix cache
- **LMCache** — [github.com/LMCache/LMCache](https://github.com/LMCache/LMCache); GPU→CPU→로컬/원격 디스크 계층 KV 스토어, vLLM·SGLang 통합
- **SAGA 구현** — vLLM v0.6.0 확장으로 구현 (~8.5K Python + ~1.2K C++/CUDA)

### Survey
- Awesome KV Cache Compression GitHub — [github.com/October2001/Awesome-KV-Cache-Compression](https://github.com/October2001/Awesome-KV-Cache-Compression)

---

## 7. Reading List

1. (입문) *PagedAttention: Efficient Memory Management for Large Language Model Serving with PagedAttention* — Kwon et al. (SOSP '23); KV 캐시 가상화의 기점
2. (입문) *A Survey on Large Language Model Acceleration based on KV Cache Management* — arXiv:2412.19442; 분야 전체 지형도
3. (중급) *LaProx: Reformulating KV Cache Eviction Problem for Long-Context LLM Inference* — arXiv:2605.07234; 출력 인식 축출 이론
4. (중급) *RateQuant: Optimal Mixed-Precision KV Cache Quantization via Rate-Distortion Theory* — arXiv:2605.06675; 양자화 이론적 한계 이해
5. (중급) *Tutti: Making SSD-Backed KV Cache Practical for Long-Context LLM Serving* — arXiv:2605.03375; SSD 오프로딩 시스템 설계
6. (심화) *SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters* — arXiv:2605.00528; 에이전트 워크플로우 인식 스케줄링
7. (심화) *Universal YOCO for Efficient Depth Scaling* — arXiv:2604.01220; YOCO 계열 아키텍처 KV 절감 최신 방향
8. (위치 논문) *Position: LLM Serving Needs Mathematical Optimization and Algorithmic Foundations* — arXiv:2605.01280; 현재 서빙 시스템 한계와 이론적 기반 필요성

---

## 8. Methodology

### 사용한 검색 쿼리
- `KV cache LLM inference serving system 2026 arXiv vLLM SGLang new`
- `KV cache quantization compression LLM 2026 arXiv new`
- `token eviction sparse attention KV cache LLM 2026 arXiv`
- `prefill decode disaggregation KV transfer distributed serving LLM 2026 arXiv`
- `MLA cross-layer KV sharing architecture optimization LLM 2026 arXiv`
- `long context KV offload CPU NVMe 100K LLM 2026 arXiv`
- `arxiv 2605 KV cache LLM inference new papers May 2026`
- `vLLM SGLang release update May 2026 blog`
- `LaProx "reformulating KV cache eviction" 2605.07234 arxiv authors abstract`
- `Louver "sparse attention range searching" KV cache 2605.06763 arxiv`
- `Tutti "SSD-backed KV cache" 2605.03375 arxiv authors throughput results`
- `FibQuant "vector quantization" KV cache 2605.11478 arxiv`
- `RateQuant "rate-distortion" KV quantization 2605.06675 arxiv`
- `eOptShrinkQ "spectral denoising" KV cache 2605.02905 arxiv`
- `RetentiveKV "state-space memory" KV cache eviction 2605.04075 arxiv`
- `LKV "end-to-end learning" "head-wise budgets" KV eviction 2605.06676 arxiv`
- `"Self-Pruned Key-Value Attention" 2605.14037 arxiv authors results`
- `"predictive multi-tier memory" KV cache 2604.26968 arxiv`
- `"Universal YOCO" 2604.01220 arxiv authors KV cache results`
- `"Key-Value Means" 2605.09877 arxiv KV cache authors`
- `vLLM 0.21.0 release KV cache offload HMA TOKENSPEED_MLA May 2026`
- `"SAGA" "workflow-atomic scheduling" KV cache agent inference 2605.00528`

### 출처 범위
- arXiv cs.LG / cs.CL / cs.DC / cs.AR (2605.xxxxx 대역 집중 탐색)
- vLLM 공식 블로그 및 GitHub 릴리즈 노트 (v0.21.0)
- SGLang GitHub 릴리즈 노트 (v0.5.11)
- WebFetch로 arXiv abs 페이지 직접 접근 (일부 403 차단으로 검색 결과 보완)

### 신규성 필터링 적용 결과
- **비교 대상 직전 보고서**: `reports/kv-cache-optimization-2026-05-16.md`
- **필터링 기준**: 사용자 제공 KNOWN_URLS 집합(약 172건) 및 KNOWN_METHODS와 매칭되는 항목 제외
- **제외된 항목**: 2605.06676(LKV), 2605.06763(Louver), 2605.09649(DBTrimKV/Make Each Token Count), 2605.11478(FibQuant), 2605.12471(KV-Fold), 2604.13556(YOCO++), 2510.13223(BanaServe) 등
- **수집된 신규 항목**: A 1건+릴리즈, B 3건, C 3건, D 2건(Tutti 중복 포함), E 2건, F Tutti와 동일

### 가정 및 한계
- **가정**: `time_range: 2023-01 ~ 2026-04` 명세에도 불구하고, 보고서 작성 시점(2026-05-17)이 time_range 종료(2026-04)를 다소 초과하므로 2026-05 대역 논문도 포함했다. 이는 관행적으로 허용되는 확장이며 Methodology에 명시한다.
- **한계 1**: arXiv HTML 및 abs 페이지에 일부 403 차단이 발생해 정량적 수치(예: Tutti의 구체적 처리량 수치, SAGA의 세부 설정)는 검색 결과 요약에서 간접 확인했다. 직접 PDF 확인 권장.
- **한계 2**: vLLM v0.21.0 및 SGLang v0.5.11의 변경 사항은 GitHub 릴리즈 노트와 검색 결과로 확인했으나, 일부 세부 기능은 공식 문서에서 추가 검증이 필요하다.
- **한계 3**: Forcing-KV(2605.09681, 자동회귀 비디오 생성용), AdapShot(2605.03644, ICL), Key-Value Means(2605.09877, RNN 계열 아키텍처) 등 주제 경계의 논문은 포함 여부 판단이 필요할 수 있다. KVM은 KV 캐시 메모리 절감에 직접 기여하므로 포함했다.
