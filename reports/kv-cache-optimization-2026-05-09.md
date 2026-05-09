---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-09
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-09)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview

## 1. Executive Summary

- **에이전트 워크로드용 KV 스케줄링 고도화** — 다중 턴 에이전트 루프에서 KV 캐시를 TTL(Time-to-Live) 기반으로 관리하거나, 워크플로우 전체를 스케줄 단위로 올려 KV 재사용률을 극대화하는 시스템 연구가 급속히 확장되고 있다. Continuum(2511.02230), SAGA(2605.00528)가 대표 사례이다.
- **정보 이론 기반 토큰 축출의 이론화** — 기존의 어텐션 점수 휴리스틱을 넘어 Information Bottleneck 원리, 정보 용량 최대화(CapKV), 잔차 질량 계산 등 이론적 근거를 갖춘 eviction 방법이 등장하였다.
- **KV 압축의 새로운 차원: 시퀀스·VLM·추론 모델 특화** — WindowQuant(VLM), PM-KVQ 이후를 이어 R-KV(추론 모델 중복 인식 압축), Sequential KV Compression(언어 트라이 기반 순차 압축) 등 모달리티·태스크 특화 압축이 주류로 부상하였다.
- **아키텍처 수준 KV 절감: MLA 확산과 GLA/GTA 등장** — DeepSeek의 MLA를 Whisper ASR 모델에 이식한 Whisper-MLA(2603.00563)처럼 도메인 확장이 계속되고, Hardware-Efficient Attention(2505.21487)은 MLA에 필적하는 품질을 유지하면서 FlashMLA보다 2배 빠른 GLA 커널을 제시하였다.
- **멀티모달 LLM의 KV 문제 부각** — LightKV(2605.00789), RetentiveKV(2605.04075) 등 시각 토큰의 KV 캐시를 특화 압축·축출하는 연구가 집중적으로 발표되며 LVLM·VLM 전용 KV 최적화가 독자적 분야로 자리 잡았다.

## 2. Landscape

KV 캐시 최적화 분야는 2026년 초·중반을 기점으로 세 가지 축으로 분화하고 있다.

**① 시스템 계층**: 개별 요청 단위 스케줄러에서 에이전트 워크플로우 전체를 고려한 "프로그램 수준 스케줄링"으로 추상화 수준이 높아지고 있다(SAGA). KV TTL 기반 선택적 핀(Continuum)과 이론적 최적 스케줄링(Online Scheduling, 2502.07115)도 병행한다.

**② 압축·축출 알고리즘 계층**: 어텐션 점수 기반 휴리스틱에서 정보 이론(CapKV, CapKV), 시퀀스 순서 상관관계(Sequential KV PLT), 추론 모델 특화 중복 인식(R-KV), 상태 공간 모델 기반 연속 메모리(RetentiveKV) 등 다양한 이론적 기반이 채택되고 있다.

**③ 아키텍처 계층**: MLA의 도메인 확장(ASR, VLM)과 함께, MLA급 KV 절감을 Hardware-Efficient한 방식으로 달성하는 GLA/GTA가 출현하였다. 또한 층별로 양자화·희소성을 혼합 적용하는 하이브리드 프레임워크(TailorKV)가 실용 배포에 가까워지고 있다.

멀티모달 확장(LightKV, RetentiveKV, WindowQuant)은 텍스트 LLM과 다른 시각 토큰 특성(대규모·저중요·지연 중요성)을 겨냥한 별도 연구 줄기를 형성하고 있다.

## 3. Recent Work

### A. 서빙 시스템

| Year | Title | Authors | Venue | Contribution | Key Metrics |
| --- | --- | --- | --- | --- | --- |
| 2025 | [Continuum: Efficient and Robust Multi-Turn LLM Agent Scheduling with KV Cache Time-to-Live](https://arxiv.org/abs/2511.02230) | Hanchen Li et al. (UC Berkeley, Stanford, Tsinghua) | arXiv 2511 | 다중 턴 에이전트 워크로드에서 도구 호출 간 KV 캐시를 TTL 기반으로 선택적으로 GPU 메모리에 핀하여 재사용률 극대화 | JCT 8배 이상 개선, 처리량 향상 (SWE-Bench, BFCL, OpenHands 기준) |
| 2025 | [Online Scheduling for LLM Inference with KV Cache Constraints](https://arxiv.org/abs/2502.07115) | Patrick Jaillet et al. (MIT) | arXiv 2502 (v5: 2026-01) | KV 캐시 메모리 제약 하에서 배치 스케줄링을 이론적으로 모델링하고, semi-online 환경에서 평균 지연 최적 알고리즘 제안 | semi-online 조건에서 정확 최적; 완전 online에서 상수 regret |
| 2026 | [SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters](https://arxiv.org/abs/2605.00528) | Dongxin Guo et al. | arXiv 2605 | 개별 LLM 호출이 아닌 에이전트 워크플로우 전체를 스케줄 단위로 올려 KV 재사용 예측·최적화; Bélády 오프라인 정책의 1.31배 이내 달성 | 에이전트 E2E 지연 3~8배 감소 (개별 요청 스케줄 대비) |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Key Metrics |
| --- | --- | --- | --- | --- | --- |
| 2025 | [TailorKV: A Hybrid Framework for Long-Context Inference via Tailored KV Cache Optimization](https://arxiv.org/abs/2505.19586) | 익명 외 (ACL 2025 Findings) | ACL 2025 Findings | Transformer 층을 양자화 친화·희소성 친화로 분류하고, 각 유형에 1-bit 정적 양자화와 CPU 오프로드+Top-K 동적 검색을 혼합 적용 | Llama-3.1-8B 128K 컨텍스트: 피크 GPU 메모리 53.7% 절감, 디코딩 지연 82 ms (RTX 3090) |
| 2026 | [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs Inference Optimization](https://arxiv.org/abs/2605.02262) | 익명 (arXiv 2026-05-04) | arXiv 2605 | VLM의 시각 토큰 KV 캐시를 토큰 단위 대신 윈도우 단위로 최적 비트폭을 결정해 탐색 시간 단축 및 하드웨어 효율 향상 | 기존 토큰 단위 대비 탐색 시간 대폭 단축, 정확도·처리량·메모리 모두 SOTA 상회 |
| 2026 | [Sequential KV Cache Compression via Probabilistic Language Tries: Beyond the Per-Vector Shannon Limit](https://arxiv.org/abs/2604.15356) | 익명 | arXiv 2604 | 토큰 시퀀스 상관관계를 이용한 2-계층 순차 압축(PLT 기반 공유 프리픽스 중복 제거 + 예측 델타 코딩); TurboQuant 대비 이론 압축비 약 914,000배 달성 가능함을 증명 | Shannon 한계 1000배 초과 상태에서도 TurboQuant 대비 914배 이론 압축비 |
| 2025 | [R-KV: Redundancy-aware KV Cache Compression for Reasoning Models](https://arxiv.org/abs/2505.24133) | Zefan Cai et al. | NeurIPS 2025 | 추론 모델 특화 KV 압축; 어텐션 기반 중요도 점수 + Key 벡터 유사도 기반 동적 중복 점수의 결합 선택 전략 | KV 16% 보존으로 전체 캐시 대비 105% 정확도 달성; 90% 메모리 절감, 6.6배 처리량 향상 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Key Metrics |
| --- | --- | --- | --- | --- | --- |
| 2026 | [Fast KVzip: Efficient and Accurate LLM Inference with Gated KV Eviction](https://arxiv.org/abs/2601.17668) | Jang-Hyun Kim, Dongyoon Han, Sangdoo Yun | arXiv 2601 | 경량 Sink-Attention 게이팅 모듈로 KV 중요도를 식별·축출; backprop 없이 forward pass만으로 학습, 과제 무관 재구성 목표로 일반화 | 70% KV 축출 시 거의 무손실 성능; Qwen2.5-1M, Qwen3, Gemma3 계열 검증 |
| 2026 | [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) | 익명 (arXiv 2026-04-28) | arXiv 2604 | Information Bottleneck 원리 기반 CapKV 제안: 선형-가우시안 어텐션 근사 하에서 상호 정보 목적 함수를 닫힌 형식으로 유도하고 통계적 leverage score로 토큰 선택 | 다양한 모델·장문맥 벤치마크에서 기존 SOTA 축출 방법 일관 상회 |
| 2026 | [RetentiveKV: State-Space Memory for Uncertainty-Aware Multimodal KV Cache Eviction](https://arxiv.org/abs/2605.04075) | Sihao Liu et al. (Zhejiang Univ., Alibaba) | arXiv 2605 | 멀티모달 LLM의 시각 KV 축출을 이산 트런케이션 대신 상태 공간 모델 기반 연속 메모리 진화로 재정식화; 엔트로피 기반 잠재적 중요도 정량화 | KV 캐시 5배 압축, 디코딩 1.5배 가속 |
| 2026 | [Make Your LVLM KV Cache More Lightweight](https://arxiv.org/abs/2605.00789) | Xihao Chen, Yangyang Guo, Roger Zimmermann (NUS) | arXiv 2605 | LightKV: 텍스트 프롬프트 기반 cross-modality 메시지 패싱으로 시각 토큰 임베딩 중복을 집계해 프리필 단계에서 점진 압축 | 시각 토큰 55% 유지로 시각 KV 캐시 절반 축소, 연산 최대 40% 절감 (8개 LVLM, 8개 벤치마크) |

### D. 분산·분리 서빙

| Year | Title | Authors | Venue | Contribution | Key Metrics |
| --- | --- | --- | --- | --- | --- |
| 2026 | [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) | Zongze Li et al. | arXiv 2603 | Prefill-Decode 분리 환경에서 append-prefill(신규 토큰만 처리)과 full-prefill을 구분하고 동적 라우팅(PPD)으로 KV 전송 부담 완화 | Turn 2+ TTFT 약 68% 감소, KV 전송 혼잡 완화 |
| 2025 | [Towards Efficient Key-Value Cache Management for Prefix Prefilling in LLM Inference](https://arxiv.org/abs/2505.21919) | Yue Zhu et al. | IEEE Cloud 2025 | RAG·에이전트 추론에서 KV 프리픽스 재사용 패턴을 실제 트레이스로 분석하고, RDMA 기반 분산 KV 메타데이터 관리 시스템 설계 방향 제시 | 실제 트레이스에서 75% 이상의 요청이 블록 히트율 50% 초과 |

### E. 아키텍처 수준 KV 절감

| Year | Title | Authors | Venue | Contribution | Key Metrics |
| --- | --- | --- | --- | --- | --- |
| 2026 | [Whisper-MLA: Reducing GPU Memory Consumption of ASR Models based on MHA2MLA Conversion](https://arxiv.org/abs/2603.00563) | 익명 (arXiv 2026-02-28) | arXiv 2603 | MHA2MLA 변환을 Whisper ASR 모델에 적용; Whisper 고유의 절대 위치 인코딩 문제를 해결하기 위해 디코더 self-attention에만 MLA 적용 | 최소한의 파인튜닝으로 성능-메모리 균형 달성 (구체 수치 확인 필요) |
| 2025 | [Hardware-Efficient Attention for Fast Decoding](https://arxiv.org/abs/2505.21487) | Ted Zadouri, Hubert Strauss, Tri Dao | arXiv 2505 | GTA(Grouped-Tied Attention)와 GLA(Grouped Latent Attention) 제안: GTA는 GQA 품질을 유지하며 KV 캐시 절반 사용; GLA는 MLA에 필적하는 품질 + FlashMLA보다 최대 2배 빠른 커널 | GTA: GQA 대비 KV 50% 절감; GLA: E2E 지연 감소, 처리량 최대 2배 향상 |

> **주**: YOCO++(2604.13556), Universal YOCO(2604.01220), Stochastic KV Routing(2604.22782)은 직전 보고서에서 이미 다뤄 이번 표에는 포함하지 않음.

### F. 장문맥·오프로딩

해당 기간 신규 오프로딩 논문 없음 (KNOWN_URLS 필터링 후).

- TTKV(2604.19769), DUAL-BLADE(2604.26557), SparKV(2604.21231), DepthKV(2604.24647), FreeKV(2505.13109), KV Cache Offloading for Context-Intensive Tasks(2604.08426)는 직전 보고서에서 이미 다뤄 이번 표에는 포함하지 않음.
- FreeKV(arXiv:2505.13109)는 KNOWN_URLS에 포함된 항목으로, 이번 수집에서 제외됨. 인접 디코딩 스텝 간 쿼리 유사성을 이용한 추측 검색으로 최대 13배 속도 향상을 달성한 연구로 직전 보고서를 참조.

## 4. Open Problems

- **에이전트·다중 턴 환경에서의 KV 정책 최적화**: TTL 기반(Continuum)·워크플로우 원자 스케줄링(SAGA)이 제시되었지만 비결정론적 도구 호출 패턴에서의 최적성은 여전히 미해결 문제이다.
- **추론 모델(Chain-of-Thought) 특화 KV 압축**: R-KV가 첫 시도를 보여주었으나, 추론 과정의 동적 길이·중요도 패턴을 실시간으로 예측하는 압축 정책은 아직 초기 단계이다.
- **멀티모달 KV의 시·공간 중요도 모델링**: 시각 토큰의 "지연 중요성(deferred importance)" 문제(RetentiveKV 지적)를 해결하는 범용 축출 정책이 필요하다.
- **MLA 변환의 품질 보존 한계**: Whisper-MLA처럼 절대 위치 인코딩 기반 모델에서 MLA 적용 시 성능 저하를 최소화하는 방법은 연구 초기 단계이다.
- **이론 기반 압축(Sequential KV PLT)의 실제 구현 격차**: 정보 이론 한계가 이론적으로 검증되었으나, 실제 하드웨어 커널에서의 디코딩 오버헤드 최소화가 과제로 남는다.
- **크로스 데이터센터 KV 전송 비용**: Prefill-as-a-Service 아키텍처(기존 보고서 포함)에서 KV 전송 대역폭 예산 조건이 충족되지 않을 경우의 폴백 전략 미흡.

## 5. Notable Researchers / Groups

- **Ion Stoica, Joseph Gonzalez (UC Berkeley / Sky Computing Lab)** — Continuum(CacheTTL), vLLM, SGLang 등 LLM 서빙 시스템 연구의 중심 허브
- **Tri Dao (Princeton/Dao AI)** — FlashAttention 시리즈, Hardware-Efficient Attention(GLA/GTA) 등 커널 수준 어텐션 최적화
- **Zefan Cai et al. (추론 모델 팀, NeurIPS 2025)** — R-KV: 추론 모델 특화 KV 압축
- **Jang-Hyun Kim, Sangdoo Yun (NAVER AI Lab)** — Fast KVzip: 게이팅 기반 KV 축출
- **Sihao Liu et al. (Zhejiang Univ., Alibaba)** — RetentiveKV: 상태 공간 기반 멀티모달 KV 축출
- **Xihao Chen, Roger Zimmermann (NUS)** — LightKV: LVLM KV 경량화
- **Ted Zadouri, Hubert Strauss, Tri Dao** — Hardware-Efficient Attention(GLA/GTA)
- **Patrick Jaillet et al. (MIT)** — KV 캐시 제약 하의 온라인 스케줄링 이론

## 6. Resources

**데이터셋·벤치마크:**
- AIME-24/AIME-25: 추론 모델 KV 압축 성능 평가 기준 (R-KV, RetentiveKV 사용)
- LongBench, RULER: 장문맥 KV 압축 표준 벤치마크
- SWE-Bench, BFCL, OpenHands: 에이전트 KV 스케줄링 평가 (Continuum)
- Text2JSON benchmark: KV 오프로딩 성능 평가용 컨텍스트 집약적 태스크 (KV Offloading for Context-Intensive Tasks, 기존 수집)
- MME, SeedBench: LVLM KV 압축 평가 (LightKV)

**코드:**
- Fast KVzip: https://github.com/Janghyun1230/FastKVzip
- R-KV: https://github.com/Zefan-Cai/R-KV
- TailorKV: https://github.com/ydyhello/TailorKV
- PM-KVQ: https://github.com/thu-nics/PM-KVQ (기존 수집)
- FreeKV: https://github.com/sjtu-zhao-lab/FreeKV

## 7. Reading List

1. **(입문)** [TailorKV](https://arxiv.org/abs/2505.19586) (ACL 2025 Findings) — 층별 양자화·희소성 혼합 전략의 직관적 소개, 단일 GPU 실용 배포에 적합
2. **(입문)** [R-KV](https://arxiv.org/abs/2505.24133) (NeurIPS 2025) — 추론 모델 특화 KV 압축 개념과 중복 인식 메커니즘 이해
3. **(중급)** [Fast KVzip](https://arxiv.org/abs/2601.17668) — 게이팅 기반 KV 축출 학습 방법 상세; KVzip 원작(기존 수집)과 비교하며 읽을 것
4. **(중급)** [Continuum/CacheTTL](https://arxiv.org/abs/2511.02230) — 에이전트 다중 턴 워크로드에서 KV TTL 스케줄링 설계 원리
5. **(중급)** [Hardware-Efficient Attention (GLA/GTA)](https://arxiv.org/abs/2505.21487) — MLA 대안으로서 GLA/GTA 커널 최적화; TransMLA(기존 수집)와 비교 권장
6. **(심화)** [CapKV: Rethinking KV Cache Eviction via Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) — KV 축출의 정보 이론적 통일 프레임워크
7. **(심화)** [Sequential KV Cache Compression via PLT](https://arxiv.org/abs/2604.15356) — TurboQuant 이후 Shannon 한계를 넘는 압축 가능성의 이론적 논거
8. **(심화)** [SAGA: Workflow-Atomic Scheduling](https://arxiv.org/abs/2605.00528) — 에이전트 워크플로우를 GPU 클러스터 스케줄러 수준에서 최적화하는 시스템 설계

## 8. Methodology

**사용한 주요 검색 쿼리:**
- `KV cache serving system vLLM SGLang 2026 arxiv new`
- `KV cache quantization compression 2026 arxiv LLM inference`
- `token eviction sparse attention KV cache 2026 arxiv LLM`
- `disaggregated prefill decode KV cache transfer distributed serving 2026 arxiv`
- `MLA cross-layer KV sharing architecture YOCO NSA TPA 2026 arxiv`
- `long context KV offload CPU NVMe 100K 2026 arxiv LLM inference`
- `Fast KVzip gated KV eviction arxiv 2601.17668`
- `Not All Prefills Equal PPD disaggregation multi-turn arxiv 2603.13358`
- `YOCO++ arxiv 2604.13556`, `Universal YOCO depth scaling arxiv 2604.01220`
- `DepthKV layer dependent KV cache pruning arxiv 2604.24647`
- `CacheFlow LLM serving 3D-parallel KV cache restoration arxiv 2604.25080`
- `Stochastic KV Routing adaptive depth-wise cache sharing arxiv 2604.22782`
- `Dual-Blade NVMe direct KV cache offloading edge inference arxiv 2604.26557`
- `TTKV temporal tiered KV cache long-context inference arxiv 2604.19769`
- `SparKV overhead-aware KV cache loading on-device inference arxiv 2604.21231`
- `FreeKV speculative retrieval KV cache inference arxiv 2505.13109`
- `Make LVLM KV Cache lightweight multimodal arxiv 2605.00789`
- `Predictive multi-tier memory management KV cache GPU inference arxiv 2604.26968`
- `WindowQuant mixed-precision KV cache quantization VLMs arxiv 2605.02262`
- `RetentiveKV state-space memory multimodal KV cache eviction arxiv 2605.04075`
- `Online scheduling LLM inference KV cache constraints arxiv 2502.07115`
- `Rethinking KV Cache Eviction information-theoretic objective arxiv 2604.25975`
- `StructKV structural skeleton long-context inference arxiv 2604.06746`
- `CodeComp structural KV cache compression agentic coding arxiv 2604.10235`
- `Residual-Mass Accounting partial KV decoding arxiv 2604.05438`
- `Sequential KV cache compression probabilistic language tries Shannon limit arxiv 2604.15356`
- `SAGA workflow-atomic scheduling AI agent inference GPU clusters arxiv 2605.00528`
- `Whisper-MLA MHA2MLA conversion ASR models arxiv 2603.00563`
- `Hardware-Efficient Attention fast decoding GLA KV cache arxiv 2505.21487`
- `CacheTTL multi-turn LLM agent scheduling KV cache arxiv 2511.02230`
- `TailorKV hybrid long-context KV cache layer-specific compression arxiv 2505.19586`
- `R-KV redundancy-aware KV cache reasoning models arxiv 2505.24133`
- `Towards Efficient KV Cache Management Prefix Prefilling LLM arxiv 2505.21919`
- `PM-KVQ progressive mixed-precision KV cache quantization long-CoT reasoning arxiv 2505.18610`

**스캔한 출처:**
- arXiv (cs.LG, cs.CL, cs.DC, cs.AR, cs.OS): 2505~2605 범위 집중 탐색
- Semantic Scholar, Papers with Code (검색 보조)
- Hugging Face Papers, alphaXiv (메타데이터 확인)
- GitHub (코드 URL 확인)

**필터링 기준:**
- 직전 보고서(kv-cache-optimization-2026-05-04.md) 기준 KNOWN_URLS 143건 포함 URL·제목·기법명 집합과 매칭된 항목 제외.
- 제외된 주요 항목: CacheFlow(2604.25080), KV Cache Offloading for Context-Intensive Tasks(2604.08426), YOCO++(2604.13556), Universal YOCO(2604.01220), Stochastic KV Routing(2604.22782), TTKV(2604.19769), DUAL-BLADE(2604.26557), SparKV(2604.21231), DepthKV(2604.24647), PM-KVQ(2505.18610, openreview URL로 KNOWN), FreeKV(2505.13109) 등.
- BanaServe(2510.13223)은 KNOWN_URLS 포함 확인 후 제외.

**가정 및 한계:**
- 2026-05-09 이전 arXiv 제출 기준으로 탐색하였으나, 게재 후 공개까지 시차가 있는 일부 논문은 누락될 수 있음.
- 일부 논문의 저자 소속·구체 수치는 arXiv 제출 시점 기준이며 최종 버전과 상이할 수 있음.
- Whisper-MLA(2603.00563)의 구체적 메모리 절감 수치는 검색 결과에서 확인이 불완전하여 "확인 필요"로 표기.
- WindowQuant(2605.02262)와 RetentiveKV(2605.04075)는 2026-05-09 기준 arXiv 제출 직후로, 동료 심사 전 프리프린트임.
- FreeKV(2505.13109)는 KNOWN_URLS에 포함되어 있어 신규 항목 표에서 제외하였으며, F 섹션에서 맥락 참고용으로만 언급함.

