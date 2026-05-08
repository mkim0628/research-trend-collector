---
type: trend-report
topic: "LLM 추론 KV 캐시 최적화"
slug: kv-cache-optimization
date: 2026-05-08
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 최적화 동향 (2026-05-08)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview

## 1. Executive Summary

- **DeepSeek V4 + vLLM 하이브리드 압축 어텐션** — DeepSeek V4-Pro/Flash(2026-04-24)가 MLA 기반 Compressed Sparse Attention(CSA)·Heavily Compressed Attention(HCA)으로 DeepSeek V3.2 대비 KV 캐시를 약 10배 줄이고, vLLM v0.20이 이를 전용 슬라이딩-윈도우 KV 스펙과 3종 페이지 풀로 지원. 커널 퓨전으로 1.4~20× 속도 향상. [DeepSeek V4 vLLM Blog]
- **정보이론 기반 eviction의 부상** — CapKV(2604.25975), LASER-KV(2602.02199), Sequential PLT(2604.15356) 등이 Shannon 한계나 Information Bottleneck 원리를 이론적 근거로 삼아 휴리스틱 eviction을 대체하려는 흐름이 두드러짐. [CapKV, PLT]
- **비동기·계층 sparse attention의 실용화** — AsyncTLS(2604.07815)가 계층적 블록+토큰 선택과 비동기 CPU 오프로드를 결합해 48K~96K 컨텍스트에서 1.3~4.7× 처리량 향상을 보고, 실제 서빙 수준의 구현 완성도를 갖춤. [AsyncTLS]
- **다중 턴 분리 서빙의 정교화** — PPD Disaggregation(2603.13358)이 append-prefill을 디코드 노드에서 직접 처리해 2번째 턴 이후 TTFT를 68% 단축, KV 전송 병목을 해소. [PPD]
- **아키텍처 수준 KV 절감의 다각화** — CARE(2603.17946)가 GQA→MLA 변환에 공분산 가중 분해를 도입, Stochastic KV Routing(2604.22782, KNOWN 기존 수집됨 참고)과 함께 크로스-레이어 공유 효율을 높임. [CARE]

## 2. Landscape

KV 캐시 최적화는 현재 다섯 축을 따라 동시에 진화하고 있다.

**① 서빙 시스템 계층**: vLLM v0.19/v0.20이 DeepSeek V4 MLA 지원, 비동기 스케줄러 기본 활성화, Model Runner V2를 안착시켰고, llm-d v0.5가 UCCL/NIXL 네트워크와 계층적 KV 오프로드를 통합해 오픈소스 분산 서빙 생태계를 넓혔다.

**② 알고리즘 압축 계층**: 정보이론(Information Bottleneck, Shannon 엔트로피 경계), SVD/저랭크 분해, 벡터 양자화, 엔트로피 기반 혼합 정밀도가 공존하며, "단순 휴리스틱 → 이론적 근거" 방향으로 이동 중이다. PackKV는 K/V 캐시 비트-패킹으로 GEMV 커널에 decompression을 내장한다.

**③ 희소 어텐션 / eviction 계층**: LookaheadKV(KNOWN)·CAOTE(KNOWN)·CAKE(KNOWN)에 이어 SinkRouter, CapKV, RetentiveKV 등이 attention sink 이론화·멀티모달 확장·정보이론 기반화를 추진 중이다.

**④ 분산·분리 서빙 계층**: Prefill-as-a-Service(KNOWN)·PPD가 단일 데이터센터→크로스-데이터센터로 PD 분리 범위를 확장하고 있으며, KV 전송 병목 해소가 핵심 과제로 부상했다.

**⑤ 아키텍처 계층**: DeepSeek V4의 하이브리드 압축 어텐션이 산업계에서 MLA의 다음 단계를 보여주고, CARE가 기존 GQA 모델을 훈련 없이 MLA로 변환하는 파이프라인을 제시한다.

## 3. Recent Work

> 아래 표에는 KNOWN_URLS 집합과 비교해 **신규**로 확인된 논문·기술 보고서만 포함한다.
> 기존 보고서(2026-04-30, 05-02, 05-03, 05-04)에서 이미 다룬 항목(LookaheadKV, StructKV, TTKV, CacheFlow, Dual-Blade, Predictive Multi-Tier, YOCO++, SinkTrack, IceCache, CodeComp, HybridGen, Don't Waste Bits, SparKV, PrefillShare 등)은 본 보고서 표에서 제외한다.

### A. 서빙 시스템

| Year | Title | Authors | Venue/Date | Contribution | 메모리·처리량 수치 |
|---|---|---|---|---|---|
| 2026 | [DeepSeek V4 in vLLM: Efficient Long-context Attention](https://vllm.ai/blog/deepseek-v4) | vLLM Team | vLLM Blog, 2026-04-24 | DeepSeek V4-Pro/Flash의 c4a(1/4 압축)·c128a(1/128 압축) 하이브리드 어텐션을 vLLM v0.20에서 지원; 슬라이딩-윈도우 KV 스펙·3종 통합 페이지 풀·멀티-스트림 병렬화로 구현 | 1M 토큰 기준 KV ~9.62 GiB (V3.2 대비 약 8.7× 감소); 커널 퓨전 1.4~20×, 저배치 단말 지연 5–6% 감소 |
| 2026 | [vLLM v0.19.0 / v0.20.0 Release](https://github.com/vllm-project/vllm/releases) | vLLM Contributors | GitHub, 2026-04-03 / 04-27 | v0.19: 비동기 스케줄러 기본 활성화 + 제로-버블 spec-decode; v0.20: CUDA 13.0 기본화, DeepSeek V4 안정화, Model Runner V2 완성 | 비동기 스케줄러로 spec-decode throughput 향상 (수치 미공개) |
| 2026 | [llm-d v0.5: Sustaining Performance at Scale](https://llm-d.ai/blog/llm-d-v0.5-sustaining-performance-at-scale) | llm-d Contributors | llm-d Blog, 2026-02 | 계층적 KV 오프로드(GPU HBM→CPU DRAM→파일시스템), UCCL/NIXL 백엔드로 P2P KV 전송 최적화, scale-to-zero 오토스케일링, LoRA-aware 스케줄링 | UCCL: 세분화된 플로우 분할·적응형 혼잡 제어; KV 히트율 향상 (정량 수치 미공개) |

### B. KV 양자화·압축

| Year | Title | Authors | Venue/Date | Contribution | 메모리·처리량 수치 |
|---|---|---|---|---|---|
| 2026 | [PackKV: Reducing KV Cache Memory Footprint through LLM-Aware Lossy Compression](https://arxiv.org/abs/2512.24449) | Bo Jiang et al. | IPDPS 2026 | 양자화·encode-aware repacking·비트 패킹을 통합한 손실 압축 프레임워크; GEMV 커널 내부에 decompression 내장 | K 153.2%·V 179.6% 더 높은 압축비 (SOTA 양자화 대비); K 75.6%·V 171.6% 처리량 향상 (cuBLAS 대비) |
| 2026 | [KV-CoRE: Benchmarking Data-Dependent Low-Rank Compressibility of KV-Caches in LLMs](https://arxiv.org/abs/2602.05929) | (확인 필요) | arXiv, 2026-02-05 | SVD 기반 KV 캐시 저랭크 압축성을 데이터-의존적으로 정량화; 5개 영어 도메인·16개 언어에서 모델·레이어별 압축 가능성 체계적 분석 | 핵심 발견: Key가 Value보다 일관되게 더 압축 가능 |
| 2026 | [Fast KV Compaction via Attention Matching](https://arxiv.org/abs/2602.16284) | Adam Zweiger, Xinghong Fu, Han Guo, Yoon Kim | arXiv, 2026-02-18 | 잠재 공간에서 KV 압축: 어텐션 출력을 재현하는 compact K/V 구성; 일부 하위 문제는 closed-form 해를 가짐 | 일부 데이터셋에서 50× 압축, 수 초 내 완료, 품질 손실 최소화 |
| 2026 | [Sequential KV Cache Compression via Probabilistic Language Tries: Beyond the Per-Vector Shannon Limit](https://arxiv.org/abs/2604.15356) | Gregory Magarshak | arXiv, 2026-04 | 확률적 prefix 중복 제거 + 예측 델타 코딩으로 벡터 단위 Shannon 한계를 돌파; 시퀀스 레벨 압축이론 적용 | 이론적 압축률: TurboQuant 대비 최대 914,000× (엔트로피 경계); 실용 수준에서 914× 이상 예상 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue/Date | Contribution | 메모리·처리량 수치 |
|---|---|---|---|---|---|
| 2026 | [AsyncTLS: Efficient Generative LLM Inference with Asynchronous Two-level Sparse Attention](https://arxiv.org/abs/2604.07815) | (확인 필요) | arXiv, 2026-04-09 | 블록 수준 필터링 + 토큰 수준 선택 2단 계층 + 비동기 CPU 오프로드 엔진 결합; Qwen3·GLM-4.7-Flash(GQA·MLA 모두) 지원 | 48K~96K 컨텍스트에서 오퍼레이터 1.2~10.0×, end-to-end 처리량 1.3~4.7× 향상 |
| 2026 | [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) | (확인 필요) | arXiv, 2026-04 | Information Bottleneck 원리로 KV eviction을 재형식화; 기존 휴리스틱 다수가 동일 용량 최대화의 근사임을 증명; CapKV(log-det 근사) 제안 | 다수 장문맥 벤치마크에서 기존 SOTA 대비 메모리-품질 트레이드오프 개선 (정량 수치 확인 필요) |
| 2026 | [SinkRouter: Sink-Aware Routing for Efficient Long-Context Decoding in Large Language and Multimodal Models](https://arxiv.org/abs/2604.16883) | (확인 필요) | arXiv, 2026-04 | Attention sink를 고정점(fixed point)으로 이론화; sink 신호 감지로 near-zero 출력 연산 스킵; Block-level branching Triton 커널 구현 | 512K 컨텍스트에서 2.03× 속도 향상, LongBench·InfiniteBench에서 경쟁력 있는 정확도 유지 |
| 2026 | [Residual-Mass Accounting for Partial-KV Decoding](https://arxiv.org/abs/2604.05438) | Yasuto Hoshi, Daisuke Miyashita, Jun Deguchi | arXiv, 2026-04-07 (v2: 2026-05-07) | KV 오프로드 환경에서 미검색 토큰의 softmax 바이어스를 잔여 질량(residual mass) 추정으로 보정; 백본 모델·KV 포맷 유지 | KV 트래픽 감소 + softmax 편향 제거 (정량 수치 확인 필요) |
| 2026 | [RetentiveKV: State-Space Memory for Uncertainty-Aware Multimodal KV Cache Eviction](https://arxiv.org/abs/2605.04075) | (확인 필요) | arXiv, 2026-05 | 멀티모달 LLM에서 시각 토큰의 "지연된 중요성" 문제를 SSM 기반 연속 메모리 진화로 해결; 엔트로피 기반 보존 추정기 + 상태 전이 + 쿼리 조건부 검색 | 5.0× KV 압축, 1.5× 디코딩 가속 달성 |
| 2026 | [SinkTrack: Attention Sink based Context Anchoring for Large Language Models](https://arxiv.org/abs/2604.10027) | (확인 필요) | ICLR 2026 | BOS 토큰(attention sink)에 핵심 컨텍스트 특징 주입으로 긴 생성 중 context forgetting·hallucination 완화; training-free, plug-and-play | SQuAD2.0(Llama3.1-8B-Instruct) +21.6%, M3CoT(Qwen2.5-VL-7B) +22.8% |

### D. 분산·분리 서빙

| Year | Title | Authors | Venue/Date | Contribution | 메모리·처리량 수치 |
|---|---|---|---|---|---|
| 2026 | [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) | Zongze Li et al. | arXiv, 2026-03-09 (최신: 2026-05-05) | 2번째 턴 이후 append-prefill을 디코드 노드에서 직접 처리하는 PPD 라우팅; KV 캐시 재전송 병목 해소, SLO-aware 가중치 설정 지원 | Turn 2+ TTFT 68% 단축, 경쟁력 있는 TPOT 유지 |
| 2026 | [KEEP: A KV-Cache-Centric Memory Management System for Efficient Embodied Planning](https://arxiv.org/abs/2602.23592) | Zebin Yang, Tong Xie, Baotong Lu et al. (Microsoft Research) | arXiv, 2026-02-27 | 에이전트 계획에서 메모리 업데이트로 인한 KV 재계산 최소화; Static-Dynamic 메모리 구성 + Multi-hop 재계산 알고리즘 | KV 재계산 대폭 감소 (정량 수치 확인 필요) |

### E. 아키텍처 수준 KV 절감

| Year | Title | Authors | Venue/Date | Contribution | 메모리·처리량 수치 |
|---|---|---|---|---|---|
| 2026 | [CARE: Covariance-Aware and Rank-Enhanced Decomposition for Enabling Multi-Head Latent Attention](https://arxiv.org/abs/2603.17946) | (확인 필요) | arXiv, 2026-03-18 | 사전 학습된 GQA 모델을 MLA로 변환하는 파이프라인; (i) 활성화 보존 분해, (ii) 에너지-driven 레이어별 랭크 할당(water-filling), (iii) KV-parity 매핑의 세 단계 | Qwen3·Llama-3.1에서 균일 랭크 SVD 대비 perplexity 최대 215× 감소, 평균 정확도 최대 1.70× 향상 |

### F. 장문맥·오프로딩

| Year | Title | Authors | Venue/Date | Contribution | 메모리·처리량 수치 |
|---|---|---|---|---|---|
| 2026 | [HybridGen: Efficient LLM Generative Inference via CPU-GPU Hybrid Computing](https://arxiv.org/abs/2604.18529) | (확인 필요) | arXiv, 2026-04 | CXL 확장 메모리를 활용한 CPU-GPU 협력 어텐션; attention logit 병렬화 + 피드백 기반 스케줄러 + 의미론적 KV 매핑으로 GPU(최근 토큰)·CPU(오래된 토큰) 분담 | 6개 SOTA KV 관리 기법 대비 1.41× 향상 (3종 모델·11종 크기·3종 GPU 플랫폼 평가) |
| 2026 | [Beyond Speedup — Utilizing KV Cache for Sampling and Reasoning](https://arxiv.org/abs/2601.20326) | Zeyu Xing, Xing Li, Hui-Ling Zhen, Mingxuan Yuan, Sinno Jialin Pan | arXiv, 2026-01-28 | KV 캐시를 의미론적 표현으로 재해석; Chain-of-Embedding·Fast/Slow Thinking Switch 두 응용 제안; KV 재사용으로 추론 토큰 절감 | DeepSeek-R1-Distil-Qwen-14B에서 토큰 생성 최대 5.7× 감소, 정확도 손실 최소 |

## 4. Open Problems

- **DeepSeek V4 스타일 하이브리드 압축 어텐션의 표준화**: c4a·c128a 이중 압축이 효과적임을 증명했으나, 다른 모델 패밀리로의 이식 가이드라인과 훈련 방법론이 미확립.
- **정보이론 기반 eviction의 계산 비용**: CapKV의 log-det 근사나 PLT의 trie 구조는 이론적 우수성에도 불구하고 실시간 서빙에서 오버헤드가 될 수 있음. 경량화 구현 연구 필요.
- **멀티모달 KV eviction의 시각-텍스트 불균형**: RetentiveKV가 지적했듯 시각 토큰의 "지연된 중요성"은 현재 eviction 정책 대부분이 가정하는 "현재 attention score → 미래 중요성" 가설을 위반. 비디오 LLM 등 더 긴 시각 컨텍스트에서 심각해질 것.
- **크로스-데이터센터 KV 전송 비용**: PrfaaS(KNOWN)가 가능성을 보였으나, 지연-처리량 트레이드오프를 실시간으로 제어하는 SLO-aware 전송 스케줄링은 미성숙.
- **에이전트/멀티-턴 KV 재사용의 표준 벤치마크 부재**: KEEP(에이전트 계획), PPD(멀티-턴 분리), KV for Reasoning 등 사용 사례가 다양해졌으나 공통 평가 체계가 없음.
- **GQA→MLA 변환의 품질 회복 한계**: CARE가 short post-SVD fine-tuning으로 원본 정확도 회복을 보고했으나, 대형 모델(70B+)에서의 비용·안정성 검증이 필요.

## 5. Notable Researchers / Groups

- **DeepSeek AI** — V4-Pro/Flash MLA 하이브리드 압축 어텐션 설계; 크로스-데이터센터 KV 스케일링 연구 선도 (Moonshot AI·Tsinghua와 협력)
- **vLLM Team (UC Berkeley / Anyscale)** — v0.19/v0.20에서 비동기 스케줄러·DeepSeek V4·Model Runner V2 완성; 산업 표준 서빙 프레임워크 유지
- **llm-d Contributors (Red Hat 중심 오픈소스)** — 쿠버네티스 기반 분산 KV 서빙 생태계 구축; UCCL/NIXL 네트워크 통합
- **Samsung Research (SamsungLabs)** — LookaheadKV(ICLR 2026, KNOWN) 등 eviction 연구; 모바일·엣지 KV 최적화
- **Apple Machine Learning Research** — Stochastic KV Routing(KNOWN 포함); depth-wise KV 공유 정규화 효과 연구
- **Microsoft Research** — KEEP(에이전트 계획 KV); KV 캐시 agentic 재사용 연구
- **The University of Hong Kong / LMSYS Org** — CodeComp(KNOWN); 아젠틱 코딩 KV 압축

## 6. Resources

**Datasets / Benchmarks**

- [LongBench](https://github.com/THUDM/LongBench) — 장문맥 LLM 평가 표준 벤치마크; StructKV·CapKV·SinkRouter 등 다수 논문에서 사용 (historical, KNOWN)
- RULER — 검색·추론 중심 장문맥 벤치마크; StructKV 등 평가에 사용
- Babilong — 128K 토큰 스케일 이해 벤치마크; LASER-KV(KNOWN)·CapKV 등 평가
- Text2JSON — KV 오프로딩 연구(KNOWN 2604.08426)에서 신규 제안한 컨텍스트-집약 태스크 벤치마크

**Code / Frameworks**

- [vLLM](https://github.com/vllm-project/vllm) v0.19/v0.20 — DeepSeek V4 MLA, async scheduler, Model Runner V2
- [SGLang](https://github.com/sgl-project/sglang) — NVFP4 KV 양자화, TurboQuant 통합(ICLR 2026)
- [llm-d](https://github.com/llm-d/llm-d) v0.5 — 계층적 KV 오프로드·UCCL/NIXL·P/D 분리 오케스트레이션
- [PackKV](https://github.com/BoJiang03/PackKV) — LLM-aware 손실 KV 압축 (IPDPS 2026)
- [IceCache](https://github.com/yuzhenmao/IceCache) — CPU 오프로드 기반 KV 관리 (ICLR 2026, KNOWN)
- [SinkTrack](https://github.com/67L1/SinkTrack) — Attention sink 컨텍스트 앵커링 (ICLR 2026)
- [LookaheadKV](https://github.com/SamsungLabs/LookaheadKV) — 미래 응답 없는 KV eviction (ICLR 2026, KNOWN)

## 7. Reading List

1. (입문) [A Survey on Large Language Model Acceleration based on KV Cache Management](https://arxiv.org/abs/2412.19442) — KV 캐시 최적화 분류 체계 전반 (2024, historical)
2. (입문) [DeepSeek V4 in vLLM: Efficient Long-context Attention](https://vllm.ai/blog/deepseek-v4) — 최신 하이브리드 압축 어텐션 구현 사례 (2026-04)
3. (중급) [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) — 다중 턴 환경에서 분리 서빙의 실질적 최적화 (2026-03)
4. (중급) [AsyncTLS: Efficient Generative LLM Inference with Asynchronous Two-level Sparse Attention](https://arxiv.org/abs/2604.07815) — 비동기 희소 어텐션 시스템 설계 (2026-04)
5. (중급) [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) — eviction 이론적 근거 제시 (2026-04)
6. (심화) [CARE: Covariance-Aware and Rank-Enhanced Decomposition for Enabling MLA](https://arxiv.org/abs/2603.17946) — GQA→MLA 변환 파이프라인 수학적 기초 (2026-03)
7. (심화) [Sequential KV Cache Compression via Probabilistic Language Tries](https://arxiv.org/abs/2604.15356) — Shannon 한계 돌파 이론 (2026-04)
8. (심화) [PackKV: Reducing KV Cache Memory Footprint through LLM-Aware Lossy Compression](https://arxiv.org/abs/2512.24449) — 커널 수준 통합 손실 압축 (IPDPS 2026)

## 8. Methodology

**사용한 주요 검색 쿼리**

- `KV cache LLM inference optimization arxiv 2026 April May new`
- `vLLM SGLang update release 2026 April May KV cache serving`
- `KV cache quantization compression 2-bit 1-bit LLM 2026 arxiv`
- `token eviction sparse attention KV cache LLM arxiv 2026 April May`
- `disaggregated prefill decode KV cache transfer distributed serving 2026 arxiv`
- `MLA multi-head latent attention cross-layer KV sharing architecture 2026 arxiv`
- `long context KV cache CPU NVMe offload 100K inference 2026 arxiv`
- `CARE covariance-aware MLA decomposition KV cache 2026 arxiv`
- `Not All Prefills Are Equal PPD disaggregation multi-turn LLM arxiv 2603.13358`
- `PackKV lossy compression KV cache arxiv 2512.24449`
- 기타 개별 arXiv ID 직접 검색 (2604.07815, 2604.05438, 2604.16883, 2604.10027, 2604.25975, 2605.04075 등)

**스캔 출처**

arXiv cs.LG·cs.CL·cs.DC·cs.AR, vLLM Blog/GitHub Releases, SGLang GitHub, llm-d Blog, Semantic Scholar, HuggingFace Papers, marktechpost.com

**신규성 필터링 결과**

- 비교 대상 직전 보고서: `kv-cache-optimization-2026-05-04.md` (및 04-30, 05-02, 05-03 누적)
- KNOWN_URLS 집합 크기: 155개 URL
- 필터링으로 제외된 기존 항목: LookaheadKV(2603.10899), StructKV(2604.06746), TTKV(2604.19769), CacheFlow(2604.25080), Dual-Blade(2604.26557), Predictive Multi-Tier(2604.26968), YOCO++(2604.13556), SinkTrack — 위 표에 중복 포함됨, IceCache(2604.10539), CodeComp(2604.10235), HybridGen — 위 표에 아직 미포함된 것(2604.08426 KV Offloading for Context-Intensive Tasks 포함), SparKV(2604.21231), Stochastic KV Routing(2604.22782), PrefillShare(2602.12029), BanaServe(2510.13223) 등 다수 제외
- 신규로 포함된 항목: 15건 (논문 12 + 시스템 릴리스 3)

**가정 및 한계**

- vLLM v0.19/v0.20 릴리스 날짜는 fazm.ai 블로그·GitHub newreleases.io 정보로 확인 (공식 CHANGELOG 직접 접근 불가)
- llm-d v0.5 릴리스 시기는 블로그 내용으로 추정 (2026년 2월경), 정확한 릴리스 날짜 확인 필요
- CARE·AsyncTLS·CapKV·RetentiveKV·SinkRouter 등의 저자 전체 명단은 arXiv 직접 접근 제한으로 일부 미확인 → "확인 필요" 표시
- DeepSeek V4의 arXiv 기술 보고서 ID는 미발견; vLLM 블로그를 1차 출처로 사용
- Sequential PLT(2604.15356)의 압축률 수치(최대 914,000×)는 이론적 Shannon 한계 기반이며 실측값이 아님
- SGLang v0.5 릴리스 세부 내용은 GitHub 직접 접근 불가로 일부 미확인
