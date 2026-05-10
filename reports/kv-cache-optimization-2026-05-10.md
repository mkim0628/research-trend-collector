---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-10
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-10)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview

---

## 1. Executive Summary

- **에이전트·멀티턴 서빙 특화 스케줄링 부상** — 개별 추론 호출이 아닌 에이전트 워크플로 전체를 스케줄 단위로 삼아 KV 캐시 재사용 예측을 통합하는 연구(SAGA, PPD Disaggregation)가 등장하며, 서빙 시스템 설계 패러다임이 "요청 단위"에서 "워크플로 단위"로 이동 중이다.

- **추론(Reasoning) 특화 KV 압축 확산** — Chain-of-Thought 및 장문 추론 모델에서 KV 캐시가 수십 배 증가하는 문제를 겨냥해, 정보 이론 기반(CapKV), 삼각함수 분석 기반(TriAttention, KNOWN에 포함), 점진적 양자화(PM-KVQ) 등 추론 시나리오 전용 압축 기법이 빠르게 분화하고 있다.

- **잠재 공간 기반 초고압축** — 토큰 축출이나 양자화가 아닌 잠재 공간(latent space) 매칭을 통해 KV를 50배까지 압축하는 Fast KV Compaction이 공개되어, 품질 손실 없는 고비율 압축 Pareto 경계를 새로 정의했다.

- **계층별(depth-wise) KV 공유 아키텍처 기법 정교화** — YOCO++, Stochastic KV Routing 등이 교차 레이어 KV 공유를 학습 시 확률적으로 적용해, 배포 시 다양한 하드웨어 예산에 적응 가능한 모델을 생성하는 방향으로 발전했다.

- **멀티모달(VLM) KV 최적화 집중** — 비전 토큰이 언어 토큰 대비 훨씬 많은 VLM에서 KV 캐시 팽창이 심각한 병목으로 부각되면서, 시각-언어 교차 압축(LightKV), 창 단위 혼합 정밀도 양자화(WindowQuant), 엔트로피 기반 연속 상태 변환(RetentiveKV) 등 VLM 전용 기법이 2026년 5월 이후 집중 발표되고 있다.

---

## 2. Landscape

KV 캐시 최적화 연구는 2023년 PagedAttention(vLLM), StreamingLLM 등에서 시작해 2024~2026년에 이르러 여섯 가지 축으로 분화·성숙했다.

```
KV 캐시 최적화
├── A. 서빙 시스템 — 스케줄링·메모리 관리·연속 배치
│   ├── 에이전트·멀티턴 워크플로 스케줄링 (SAGA, PPD)
│   └── SLO-aware 이론적 최적화 (Online Scheduling)
├── B. KV 양자화·압축 — 비트폭 축소·변환 코딩·잠재 공간
│   ├── 잠재 공간 매칭 (Fast KV Compaction, 50×)
│   ├── 추론 특화 혼합 정밀도 (PM-KVQ, WindowQuant)
│   └── 정보 이론적 순차 압축 (Sequential KV via PLTs)
├── C. 토큰 축출·희소 어텐션 — 중요도 기반 KV 선택
│   ├── 정보 이론적 용량 최적화 (CapKV)
│   ├── VLM 엔트로피 기반 연속 메모리 (RetentiveKV)
│   ├── 구조적 그래프 기반 (StructKV, CodeComp)
│   └── 레이어별 예산 배분 (DepthKV)
├── D. 분산·분리 서빙 — Prefill-Decode 분리·KV 전송
│   ├── 멀티턴 append-prefill 최적화 (PPD)
│   └── SM 레벨 계산 분리·통합 스토리지 (semi-PD)
├── E. 아키텍처 수준 KV 절감 — 교차 레이어 공유·MLA 변형
│   ├── 잔차 연결 YOCO 강화 (YOCO++)
│   └── 확률적 교차 레이어 라우팅 (Stochastic KV Routing)
└── F. 장문맥·오프로딩 — GPU↔CPU↔NVMe 계층
    ├── 클라우드-엣지 KV 청크 스트리밍 (SparKV)
    ├── 하이브리드 양자화+오프로딩 (TailorKV)
    └── VLM 비전 토큰 경량화 (LightKV)
```

현재 거시 트렌드는 다음과 같다:
1. **연구 범위 확장**: 텍스트 LLM → 멀티모달(VLM) → 에이전트 워크플로로 KV 연구 대상이 확대.
2. **이론 기반 강화**: 휴리스틱 축출에서 정보 이론(CapKV), 수학적 최적화(Online Scheduling), 확률 모델(Sequential KV via PLTs)로 이동.
3. **학습 시 압축 친화성 내재화**: 배포 시 다양한 버짓에 적응하기 위해, 학습 단계에서 교차 레이어 공유를 확률적으로 삽입(Stochastic KV Routing).

---

## 3. Recent Work

### A. 서빙 시스템

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters](https://arxiv.org/abs/2605.00528) | (확인 필요) | arXiv 2026-05 | 에이전트 워크플로 전체를 스케줄 단위로 삼아 KV 캐시 재사용을 예측, 64-GPU 클러스터에서 vLLM 대비 태스크 완료 시간 1.64× 단축·GPU 메모리 활용률 1.22× 향상 | arXiv:2605.00528 |
| 2026 | [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) | Zongze Li, Jingyu Liu et al. | arXiv 2026-03 | 멀티턴에서 append-prefill과 full-prefill을 구분해 동적 라우팅, Turn 2+ TTFT 68% 절감·KV 전송 혼잡 완화 | arXiv:2603.13358 |
| 2026 | [Online Scheduling for LLM Inference with KV Cache Constraints](https://arxiv.org/abs/2502.07115) | Patrick Jaillet et al. (MIT) | arXiv 2025-02 (v5 2026-01) | KV 캐시 메모리 제약 하에서 평균 지연을 최소화하는 준-온라인·완전 온라인 스케줄링 알고리즘 제안, 상수 후회(constant regret) 보장 | arXiv:2502.07115 |
| 2025 | [semi-PD: Towards Efficient LLM Serving via Phase-Wise Disaggregated Computation and Unified Storage](https://arxiv.org/abs/2504.19867) | Ke Hong et al. (Infinigence AI) | arXiv 2025-04 | SM 레벨 계산 분리+통합 메모리 관리로 KV 전송 오버헤드 제거, DeepSeek 모델에서 e2e 지연 1.27~2.58× 절감 | arXiv:2504.19867 |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Fast KV Compaction via Attention Matching](https://arxiv.org/abs/2602.16284) | Adam Zweiger, Xinghong Fu, Han Guo, Yoon Kim | arXiv 2026-02 | Attention Matching 기반 잠재 공간 KV 압축으로 50× 압축 비율 달성, Cartridges 수준 품질을 수초 내 처리 | arXiv:2602.16284 |
| 2026 | [PM-KVQ: Progressive Mixed-precision KV Cache Quantization for Long-CoT LLMs](https://arxiv.org/abs/2505.18610) | (Tsinghua Univ. et al.) | arXiv 2025-05 / ICLR 2026 워크숍 | 장문 CoT 추론 LLM에서 블록별 비트폭을 점진적 감소, 위치 보간 캘리브레이션 적용, 동일 메모리 예산 대비 추론 벤치마크 최대 8% 향상 | arXiv:2505.18610 |
| 2026 | [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs Inference Optimization](https://arxiv.org/abs/2605.02262) | Wei Tao et al. (HUST, Tsinghua, Ping An) | arXiv 2026-05 | VLM 비전 토큰 창 단위 유사도 기반 혼합 정밀도 양자화, 토큰별 탐색 대비 설정 시간 대폭 단축·하드웨어 효율 개선 | arXiv:2605.02262 |
| 2026 | [Sequential KV Cache Compression via Probabilistic Language Tries: Beyond the Per-Vector Shannon Limit](https://arxiv.org/abs/2604.15356) | Gregory Magarshak | arXiv 2026-04 | 모델 자신의 언어 예측을 활용한 2계층 순차 압축(접두어 중복 제거 + 예측 델타 코딩), per-vector Shannon 한계를 초월하는 압축률 이론적 제시 | arXiv:2604.15356 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) | (확인 필요) | arXiv 2026-04 | 정보 병목 원리로 KV 축출을 재해석, CapKV 제안(log-det 근사 기반 용량 최대화), 기존 휴리스틱의 공통 목적 함수 통합 | arXiv:2604.25975 |
| 2026 | [RetentiveKV: State-Space Memory for Uncertainty-Aware Multimodal KV Cache Eviction](https://arxiv.org/abs/2605.04075) | Sihao Liu et al. | arXiv 2026-04 | VLM의 "지연된 중요도" 시각 토큰을 이산 축출 대신 SSM 상태로 연속 전환, 엔트로피 기반 재활성화, 5× KV 압축·1.5× 디코딩 가속 | arXiv:2605.04075 |
| 2026 | [StructKV: Preserving the Structural Skeleton for Scalable Long-Context Inference](https://arxiv.org/abs/2604.06746) | Zhirui Chen, Peiyang Liu, Ling Shao | arXiv 2026-04 | 전체 네트워크 깊이의 Attention을 집계한 전역 In-Degree 중심성으로 글로벌 정보 허브 토큰 보존, LongBench·RULER 벤치마크 성능 유지 | arXiv:2604.06746 |
| 2026 | [DepthKV: Layer-Dependent KV Cache Pruning for Long-Context LLM Inference](https://arxiv.org/abs/2604.24647) | Zahra Dehghanighobadi, Asja Fischer | arXiv 2026-04 | 레이어별 중요도 기반 비균등 예산 배분(중요 레이어는 더 많은 KV 유지, 덜 중요한 레이어는 적극 제거), 균등 배분 대비 성능 향상 | arXiv:2604.24647 |
| 2026 | [CodeComp: Structural KV Cache Compression for Agentic Coding](https://arxiv.org/abs/2604.10235) | (Univ. of Hong Kong, LMSYS) | arXiv 2026-04 | Code Property Graph(CPG) 기반 정적 분석을 KV 압축에 활용, 코드 구조적 핵심 토큰(call site, 분기 조건) 보호, SGLang 통합, 버그 지역화·코드 생성 벤치마크에서 어텐션 전용 압축 대비 우세 | arXiv:2604.10235 |

### D. 분산·분리 서빙

> 이 영역은 A(서빙 시스템)와 중첩되나, KV 전송·이동·분리 아키텍처에 특화된 항목을 별도 분류한다.

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) | Zongze Li, Jingyu Liu et al. | arXiv 2026-03 | append-prefill/full-prefill 구분 동적 라우팅으로 KV 전송 혼잡 완화, Turn 2+ TTFT 68% 절감 | arXiv:2603.13358 |
| 2025 | [semi-PD: Towards Efficient LLM Serving via Phase-Wise Disaggregated Computation and Unified Storage](https://arxiv.org/abs/2504.19867) | Ke Hong et al. | arXiv 2025-04 | SM 레벨 계산 격리 + 통합 KV 스토리지로 복제 가중치·KV 전송 비용 제거, 요청 지연 1.27~2.58× 절감 | arXiv:2504.19867 |

*비고: 2026-05-04 이전 수집된 BanaServe(2510.13223), TraCT(2512.18194), PrefillShare(2602.12029), CacheFlow(2604.25080) 등은 KNOWN에 포함.*

### E. 아키텍처 수준 KV 절감

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [YOCO++: Enhancing YOCO with KV Residual Connections for Efficient LLM Inference](https://arxiv.org/abs/2604.13556) | (확인 필요, GitHub: wuyou2002) | arXiv 2026-04 | 하단 레이어 KV에 가중 잔차 연결을 추가해 교차 레이어 KV 공유 시 성능 저하 방지, 50% KV 압축률에서 교차 레이어 방법 중 SOTA | arXiv:2604.13556 |
| 2026 | [Stochastic KV Routing: Enabling Adaptive Depth-Wise Cache Sharing](https://arxiv.org/abs/2604.22782) | Anastasiia Filippova, David Grangier, Marco Cuturi, João Monteiro (Apple) | arXiv 2026-04 | 학습 시 무작위 교차 레이어 어텐션(random cross-layer attention) 삽입으로 배포 시 다양한 KV 예산에 적응 가능한 모델 생성, 데이터 제약 환경에서 성능 유지 또는 향상 | arXiv:2604.22782 |

*비고: TPA(2501.06425), MLA/TransMLA(2502.07864) 등은 KNOWN에 포함.*

### F. 장문맥·오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [SparKV: Overhead-Aware KV Cache Loading for Efficient On-Device LLM Inference](https://arxiv.org/abs/2604.21231) | (확인 필요) | arXiv 2026-04 | KV 청크별 비용 모델링 후 스트리밍/로컬 계산 경로를 동적 선택·오버랩, TTFT 1.3~5.1× 절감·에너지 1.5~3.3× 절감 | arXiv:2604.21231 |
| 2025 | [TailorKV: A Hybrid Framework for Long-Context Inference via Tailored KV Cache Optimization](https://arxiv.org/abs/2505.19586) | (확인 필요) | ACL 2025 Findings | 레이어별 양자화-친화적/희소성-친화적 분류, 양자화(1-bit) + 오프로딩(Top-K 동적 로드) 하이브리드, Llama-3.1-8B 128K를 단일 RTX 3090에서 82ms/token | arXiv:2505.19586 |
| 2026 | [Make Your LVLM KV Cache More Lightweight](https://arxiv.org/abs/2605.00789) | Xihao Chen, Yangyang Guo, Roger Zimmermann (NUS) | arXiv 2026-05 | 텍스트 프롬프트 안내 하에 비전 토큰 간 교차 모달리티 메시지 패싱으로 55% 비전 토큰만 유지, KV 절반 절감·연산 40% 감소·성능 유지 | arXiv:2605.00789 |

---

## 4. Open Problems

1. **압축-추론 품질 트레이드오프의 표준 평가 미흡** — KV 압축 효과를 reasoning 벤치마크(AIME, GSM8K)로 평가한 연구(PM-KVQ, TriAttention)가 늘고 있으나, long-CoT LLM 전용 표준 벤치마크 스위트가 아직 부재하다.

2. **멀티모달 KV 압축의 일반화 한계** — RetentiveKV, LightKV, WindowQuant 등 VLM 전용 방법이 각각 상이한 가정(SSM 상태 크기, 창 크기, 모달리티 분리 가능성)에 의존해 범용 VLM 서빙 시스템에 통합하기 어렵다.

3. **에이전트 워크플로 KV 예측의 정확도 상한** — SAGA는 Agent Execution Graph로 KV 재사용을 예측하나, 불확실한 도구 호출 결과나 동적 경로 분기에서의 예측 정확도 한계가 명확하지 않다.

4. **잠재 공간 압축의 다양한 모델 적용 가능성** — Fast KV Compaction(50×)은 일부 데이터셋에서 우수하나, 다양한 모델 아키텍처(MLA, GQA, 슬라이딩 윈도우)에서의 성능 일반화가 검증되지 않았다.

5. **교차 레이어 KV 공유의 학습 비용** — Stochastic KV Routing처럼 학습 단계에서 확률적 공유를 내재화하면 배포 유연성이 높아지지만, 기존 사전학습 모델에 fine-tuning으로 이를 추가하는 비용·성능 저하가 아직 충분히 연구되지 않았다.

6. **정보 이론적 KV 축출의 계산 오버헤드** — CapKV의 log-det 근사가 실용적 처리량을 얼마나 저해하는지, 또 대형 배치에서 스케일 가능한지 실측 데이터가 필요하다.

---

## 5. Notable Researchers / Groups

- **MIT (Patrick Jaillet 그룹)** — 이론적 최적 스케줄링 연구(Online Scheduling for LLM Inference), KV 제약 하의 배치·지연 최적화 알고리즘 설계.
- **Apple Machine Learning Research (David Grangier, Marco Cuturi 등)** — Stochastic KV Routing 등 학습 단계 KV 공유 내재화 연구, 배포 유연성 중심 접근.
- **National University of Singapore (Roger Zimmermann 그룹)** — LightKV 등 VLM KV 경량화, 시각-언어 교차 압축 연구.
- **Tsinghua University (NICS 연구실)** — PM-KVQ 등 CoT/추론 특화 KV 양자화, 혼합 정밀도 캘리브레이션.
- **LMSYS / Univ. of Hong Kong** — CodeComp 등 에이전트 코딩 KV 압축, SGLang 통합 구현.
- **Infinigence AI (Ke Hong 등)** — semi-PD, SM 레벨 Prefill-Decode 분리 서빙.
- **Harbin Institute of Technology Shenzhen / Guangzhou University** — TTKV 등 시간적 계층 KV 관리.
- **독립 연구자** — Gregory Magarshak (Sequential KV via PLTs, 정보 이론적 순차 압축).

---

## 6. Resources

### Datasets & Benchmarks
- **LongBench** — 장문맥 이해 벤치마크, KV 압축 정확도 평가 표준 (StructKV, DepthKV, IceCache 등에서 공통 사용).
- **RULER** — 100K+ 컨텍스트 검색·이해 평가, 압축 시 장문 의존성 유지 측정.
- **AIME 2025** — 수학적 추론 능력 평가, 추론 특화 KV 압축 평가에 활용 (TriAttention, PM-KVQ).
- **MME, SeedBench** — 멀티모달 VLM 벤치마크, LightKV·RetentiveKV 등 VLM KV 평가.
- **SWE-bench, WebArena** — 에이전트 코딩·브라우징 태스크, SAGA 등 에이전트 스케줄링 평가.

### Code & Frameworks
- **IceCache** — [GitHub: yuzhenmao/IceCache](https://github.com/yuzhenmao/IceCache) (ICLR 2026)
- **PM-KVQ** — [GitHub: thu-nics/PM-KVQ](https://github.com/thu-nics/PM-KVQ)
- **TailorKV** — [GitHub: ydyhello/TailorKV](https://github.com/ydyhello/TailorKV)
- **TriAttention** — vLLM 플러그인 포함, [프로젝트 페이지](https://weianmao.github.io/tri-attention-project-page/) (KNOWN에 포함)
- **semi-PD** — [GitHub: infinigence/Semi-PD](https://github.com/infinigence/Semi-PD)
- **YOCO++** — [GitHub: wuyou2002/YOCO-plus](https://github.com/wuyou2002/YOCO-plus)
- **NVIDIA kvpress** — [GitHub: NVIDIA/kvpress](https://github.com/NVIDIA/kvpress) 다수 KV 압축 기법 통합 라이브러리

---

## 7. Reading List

1. **(입문)** Efficient Memory Management for Large Language Model Serving with PagedAttention (Kwon et al., SOSP 2023) — KV 캐시 관리 전 분야의 기점, 가상 메모리 기법 도입. *(historical)*
2. **(입문)** SGLang: Efficient Execution of Structured Language Model Programs (Zheng et al.) — RadixAttention 기반 프리픽스 캐시 공유의 핵심 구조.
3. **(서베이)** A Survey on Large Language Model Acceleration based on KV Cache Management (arXiv:2412.19442) — 분야 전체 지형도.
4. **(서베이)** KV Cache Optimization Strategies for Scalable and Efficient LLM Inference (arXiv:2603.20397, March 2026) — 최신 5대 방향(축출·압축·하이브리드 메모리·신규 어텐션·조합) 정리.
5. **(심화: 압축)** Fast KV Compaction via Attention Matching (arXiv:2602.16284) — 잠재 공간 50× 압축 원리 이해.
6. **(심화: 서빙)** SAGA: Workflow-Atomic Scheduling (arXiv:2605.00528) — 에이전트 워크플로 KV 재사용 예측 아키텍처.
7. **(심화: 분리 서빙)** Not All Prefills Are Equal: PPD Disaggregation (arXiv:2603.13358) — 멀티턴 서빙에서 append-prefill/full-prefill 구분 핵심 개념.
8. **(심화: VLM)** RetentiveKV (arXiv:2605.04075) — SSM 기반 연속 메모리 진화, VLM 지연 중요도 문제.
9. **(심화: 아키텍처)** Stochastic KV Routing (arXiv:2604.22782) — 학습 내재화 교차 레이어 공유, 배포 유연성 트레이드오프.
10. **(심화: 이론)** Online Scheduling for LLM Inference with KV Cache Constraints (arXiv:2502.07115) — 이론적 최적 스케줄링 알고리즘·상수 후회 보장.

---

## 8. Methodology

**사용한 주요 검색 쿼리:**
- `KV cache LLM inference optimization arxiv 2026 May new papers serving system`
- `KV cache quantization compression token eviction LLM 2026 arxiv recent`
- `disaggregated prefill decode KV cache transfer LLM serving 2026 arxiv`
- `MLA cross-layer KV sharing architecture LLM 2026 arxiv attention mechanism`
- `long context LLM KV offloading CPU NVMe 100K tokens 2026 arxiv`
- `arxiv KV cache 2026 May speculative decoding prefix caching vLLM SGLang new`
- `sparse attention token eviction RL-based policy KV cache LLM 2026 arxiv`
- `"KV cache" LLM arxiv 2026 May site:arxiv.org new paper inference`
- 개별 논문명 검색 다수 (DepthKV, SparKV, TTKV, IceCache, CacheFlow, StructKV, CodeComp, Dual-Blade, Predictive Multi-Tier, SAGA, RetentiveKV, TailorKV, PM-KVQ, WindowQuant, sequential KV via PLTs, YOCO++, Stochastic KV Routing, Fast KV Compaction, CapKV, semi-PD, LightKV 등)

**스캔 출처:**
- arXiv cs.LG, cs.CL, cs.DC, cs.AR (메인 검색)
- arXiv HTML 페이지 (WebFetch 시 403 오류 다수 — 검색 결과 요약으로 대체)
- Hugging Face Papers, EmergentMind, Papers.cool, alphaXiv (보조 메타데이터 확인)
- ACL Anthology (TailorKV ACL 2025 Findings 확인)
- Wiley / ACM DL (BanaServe 저널 출판 확인)
- 연구자 GitHub 프로젝트 페이지 (YOCO++, semi-PD, PM-KVQ)

**적용한 신규성 필터:**
- 직전 보고서(2026-05-04) 기준 KNOWN_URLS 152건 대조
- 제외된 기존 항목: TriAttention(2604.04921), ARKV(2603.08727), IceCache(2604.10539), TTKV(2604.19769), CacheFlow(2604.25080), Dual-Blade(2604.26557), Predictive Multi-Tier(2604.26968) 등 7건 이상
- 신규 항목: 18건 (A: 4건, B: 4건, C: 5건, D: 2건, E: 2건, F: 3건; A-D 일부 중복 항목 있음)

**가정·한계:**
- `time_range` 상한이 명세에는 `2026-04`이지만, 직전 보고서 이후 신규 보완 목적으로 2026-05 논문(SAGA: 2026-05-01, WindowQuant: 2026-05-04, LightKV: 2026-05-01, RetentiveKV: 2026-04-14 → 2605로 제출) 포함.
- arXiv HTML 직접 접근이 403으로 막혀, 일부 논문의 저자·소속 정보를 검색 결과 요약에서 추출. 불확실한 경우 "확인 필요"로 표기.
- `2502.07115` (Online Scheduling)는 원 제출 2025년 2월이나 v5가 2026년 1월로, 실질적 기여가 2026년 시점에도 유효하여 포함.
- `2505.18610` (PM-KVQ)는 OpenReview에서 ICLR 2026 관련 정황 확인 — 정식 학회 게재 여부는 추가 확인 필요.
- `2604.25975` (CapKV), `2605.00528` (SAGA)의 일부 저자 정보는 검색 결과에서 확인되지 않아 생략.
