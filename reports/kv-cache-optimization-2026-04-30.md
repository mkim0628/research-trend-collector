---
type: trend-report
topic: "LLM KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-04-30
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM KV 캐시 관리·최적화 동향 보고서

**날짜:** 2026-04-30 | **기간:** 2023-01 ~ 2026-04 | **깊이:** overview

---

## 1. Executive Summary

### 트렌드 1: MLA(Multi-head Latent Attention) 아키텍처의 급속한 확산
DeepSeek-V2가 MLA를 도입해 KV 캐시를 기존 대비 93.3% 절감하고 처리량 5.76×를 달성한 이후([arXiv 2024](https://arxiv.org/abs/2405.04434)), DeepSeek-V3(671B MoE)까지 MLA를 확장 적용하였다([arXiv 2024](https://arxiv.org/abs/2412.19437)). 2025~2026년에는 기존 MHA/GQA 모델을 MLA로 사후 변환하는 TransMLA([NeurIPS 2025](https://arxiv.org/abs/2502.07864)), MHA2MLA([ACL 2025](https://arxiv.org/abs/2502.14837)) 연구가 등장하며 사전학습 재비용 없이 MLA의 이점을 누리는 방향으로 생태계가 확장되고 있다.

### 트렌드 2: Prefill/Decode(P/D) 분리 서빙의 성숙과 상용화
P/D를 별도 인스턴스로 분리해 SLO와 처리량을 함께 개선하는 접근이 DistServe([OSDI 2024](https://arxiv.org/abs/2401.09670)), Splitwise([ISCA 2024](https://arxiv.org/abs/2311.18677)), Mooncake([FAST 2025 Best Paper](https://arxiv.org/abs/2407.00079)) 등을 거쳐 상용 서비스에 적용되고 있다. 2025~2026년에는 FlowKV([arXiv 2025](https://arxiv.org/abs/2504.03775))가 KV 전송 지연을 96% 감소시키고, Nexus([arXiv 2025](https://arxiv.org/abs/2507.06608))가 단일 GPU 내 SM 수준 P/D 분리를 제안하는 등 분리 서빙의 세밀도가 높아지고 있다. vLLM도 chunked prefill과 Automatic Prefix Caching(APC)을 기본 활성화하며 이 방향을 채택하였다([vLLM Blog 2025](https://vllm.ai/blog/vllm-2024-wrapped-2025-vision)).

### 트렌드 3: 극단적 KV 양자화 — 2-bit 이하로의 진입
2024년 KIVI([ICML 2024](https://arxiv.org/abs/2402.02750))의 2-bit 양자화 이후, CQ([NeurIPS 2024](https://arxiv.org/abs/2405.03917))의 채널당 1-bit, SVDq([arXiv 2025](https://arxiv.org/abs/2502.15304))의 Key 1.25-bit 등 극단적 압축 연구가 이어지고 있다. KVTuner([ICML 2025](https://arxiv.org/abs/2502.04420))와 MiniKV([ACL 2025](https://arxiv.org/abs/2411.18077))는 레이어별 민감도 분석과 토큰 선택을 결합해 3-bit 수준에서 거의 무손실 성능을 실현하고 있다. 양자화와 저랭크 분해를 결합(Palu, xKV)하거나 Long-CoT에 특화(PM-KVQ)하는 방향도 부상하고 있다.

### 트렌드 4: 강화학습(RL) 기반 지능형 KV 축출 정책의 등장
중요도 휴리스틱 기반 축출(SnapKV, StreamingLLM 등)에서 벗어나, 미래 어텐션 패턴을 예측하거나 RL로 최적 축출 정책을 학습하는 방향이 2025~2026년에 급부상하였다. ForesightKV([arXiv 2026](https://arxiv.org/abs/2602.03203))는 RL 기반 장기 기여도 예측으로 절반 예산에서 AIME SOTA를 초과하였고, LookaheadKV([arXiv 2026](https://arxiv.org/abs/2603.10899))는 Lookahead LoRA로 미래 어텐션 패턴을 예측한다. Expected Attention([arXiv 2025](https://arxiv.org/abs/2510.00636))은 미래 쿼리 분포를 활용해 KV 중요도를 사전에 추정하는 방법을 제안하였다.

### 트렌드 5: CXL·신규 메모리 계층을 활용한 KV 오프로딩 인프라 확장
GPU DRAM의 한계를 넘어 CPU DRAM, CXL 확장 메모리, FPGA/PNM 등 이종 메모리 계층을 KV 캐시에 활용하는 연구가 2025년부터 본격화되었다. TraCT([arXiv 2025](https://arxiv.org/abs/2512.18194))는 CXL 공유 메모리로 TTFT를 9.8× 감소시켰고, CXL-PNM([arXiv 2025](https://arxiv.org/abs/2511.00321))은 CXL 내 근방 메모리 연산으로 1M 토큰 서빙을 단일 노드에서 실현하였다. ShadowKV([ICML 2025](https://arxiv.org/abs/2410.21465))와 SpeCache([ICML 2025](https://arxiv.org/abs/2503.16163))는 GPU/CPU 협력 전략으로 처리량과 압축률을 동시에 달성하였다.

---

## 2. Landscape — 분야 지형도

LLM KV 캐시 최적화는 2023년 이후 크게 7개 서브토픽으로 수렴하고 있다.

```
LLM KV 캐시 최적화
├── A. 서빙 시스템·메모리 관리
│   ├── PagedAttention / 가상 메모리 매핑 (vLLM, vAttention)
│   ├── Chunked Prefill / APC (vLLM, Sarathi-Serve)
│   ├── 희소 어텐션 커널 (FlashInfer, MInference)
│   └── 투기적 디코딩 연동 (EAGLE, EAGLE-2)
│
├── B. KV 양자화·압축
│   ├── 균일/비균일 정수 양자화 (KIVI, KVQuant, CQ)
│   ├── 혼합 정밀도·레이어별 적응 (KVTuner, KITTY, PM-KVQ)
│   ├── 저랭크 분해 (Palu, SVDq, xKV, MFA)
│   └── 토큰 선택·가지치기 결합 (MiniKV, ZipCache, MixKVQ)
│
├── C. 토큰 축출·희소 어텐션
│   ├── 중요도 점수 기반 축출 (SnapKV, StreamingLLM 계열)
│   ├── 쿼리 인식·페이지 선택 (Quest, HashEvict)
│   ├── 헤드별 적응 예산 (Ada-KV, HeadKV, DuoAttention)
│   └── 미래 예측·RL 기반 (ForesightKV, LookaheadKV, Expected Attention)
│
├── D. 분산·분리 서빙 및 KV 전송
│   ├── Prefill/Decode 분리 (DistServe, Splitwise, Mooncake)
│   ├── KV 전송 최적화 (FlowKV, CacheGen, LMCache)
│   ├── 분산 KV 스토어 (Preble, KVShare, BanaServe)
│   └── SM 수준/멀티모달 분리 (Nexus, HydraInfer)
│
├── E. 아키텍처 수준 KV 절감
│   ├── MLA 계열 (DeepSeek-V2/V3, TransMLA, MHA2MLA)
│   ├── Cross-layer KV 공유 (CLA, LCKV, KVSharer)
│   ├── 단일 KV 저장 (YOCO, YOCO++)
│   └── 텐서 분해 (TPA, MFA, MTLA)
│
├── F. 장문맥·계층적 오프로딩
│   ├── CPU 오프로딩 (InfiniGen, MagicPIG, RetrievalAttention)
│   ├── CXL 확장 메모리 (TraCT, CXL-SpecKV, CXL-PNM, CXL-NDP)
│   └── 투기적 프리페치 (SpeCache, ScoutAttention, Async KV Prefetch)
│
└── G. RAG·평가 방법론
    ├── RAG KV 재사용·융합 (RAGCache, CacheBlend, Cache-Craft)
    └── 벤치마크 (RULER, SCBench, MILLION)
```

### 주요 흐름 간 상호작용

- **B + C 결합**: 양자화와 토큰 축출을 함께 최적화하는 연구(MiniKV, ZipCache)가 증가하고 있다.
- **E → D**: MLA 기반 모델의 KV가 작아짐에 따라 P/D 분리 시 전송 비용이 줄어 분산 서빙의 경제성이 높아진다.
- **F → A**: CXL 계층이 GPU HBM의 연장선처럼 활용되면서 서빙 시스템의 메모리 관리 정책이 재설계되고 있다.
- **Long-CoT 특화**: Reasoning 모델(DeepSeek-R1 계열)이 수천 토큰 이상의 중간 추론을 생성하면서, 긴 생성 단계에서의 KV 관리(PM-KVQ, ForesightKV, LServe)가 별도 연구 방향으로 부상하였다.

---

## 3. Recent Work

### A. 서빙 시스템·메모리 관리

| 논문 | Venue/Year | Contribution |
|------|-----------|-------------|
| [vLLM 2024 Wrapped & 2025 Vision](https://vllm.ai/blog/vllm-2024-wrapped-2025-vision) | vLLM Blog 2025 | chunked prefill 기본 활성화, APC·speculative decoding·disaggregated prefill 통합 |
| [SGLang: Efficient Execution of Structured Language Model Programs](https://arxiv.org/abs/2312.07104) | NeurIPS 2024 | RadixAttention 자동 KV 재사용; 처리량 6.4×↑, few-shot cache hit rate 85~95% |
| [SGLang v0.4](https://www.lmsys.org/blog/2024-12-04-sglang-v0-4/) | LMSYS Blog 2024-12 | Zero-Overhead Batch Scheduler + Cache-Aware LB; 처리량 1.3×↑, MLA 7×↑ |
| [Sarathi-Serve](https://arxiv.org/abs/2403.02310) | OSDI 2024 | stall-free chunked prefill; Mistral-7B 2.6×, Falcon-180B 5.6×↑ |
| [FlashInfer](https://arxiv.org/abs/2501.01005) | MLSys 2025 Best Paper | 블록 희소 포맷 + JIT 컴파일 어텐션 커널; ITL 29~69%↓ |
| [vAttention](https://arxiv.org/abs/2405.04437) | ASPLOS 2025 | CUDA 가상 메모리 동적 KV 할당; PagedAttention 오버헤드 제거, 처리량 1.23×↑ |
| [POD-Attention](https://arxiv.org/abs/2410.18038) | ASPLOS 2025 | 동일 GPU에서 prefill·decode 어텐션 동시 실행; 서빙 처리량 22%↑ |
| [LServe](https://arxiv.org/abs/2502.14866) | MLSys 2025 | prefill/decode 통합 희소 어텐션; prefill 2.9×, decode 1.3~2.1×↑ |
| [QServe](https://arxiv.org/abs/2405.04532) | MLSys 2025 | W4A8KV4 양자화 서빙 시스템; Qwen1.5-72B 2.4~3.5×↑ |
| [NanoFlow](https://arxiv.org/abs/2408.12757) | arXiv 2024 | nano-batch intra-device 병렬성; SOTA 대비 1.91×↑ |
| [BatchLLM](https://arxiv.org/abs/2412.03594) | arXiv 2024 | 글로벌 prefix KV 공유 최적화; 처리량 1.3~10.8×↑ |
| [TetriInfer](https://arxiv.org/abs/2401.11181) | arXiv 2024 | chunked prefill + P/D 분리; TTFT 97%↓, JCT 47%↓ |
| [ThunderServe](https://arxiv.org/abs/2502.09334) | arXiv 2025 | 이종 클라우드 배포 최적화; 처리량 2.1×↑ |
| [Preble](https://arxiv.org/abs/2407.00023) | arXiv 2024 | 분산 프롬프트 스케줄링; 평균 지연 1.5~14.5×↓, p99 2~10×↓ |
| [EAGLE](https://arxiv.org/abs/2401.15077) | ICML 2024 | 피처 기반 투기적 디코딩; 속도 2.7~3.5×↑ |
| [EAGLE-2](https://arxiv.org/abs/2406.16858) | EMNLP 2024 | 동적 드래프트 트리 투기적 디코딩으로 수용률 향상 |
| [VIDUR](https://arxiv.org/abs/2405.05465) | MLSys 2024 | LLM 추론 고충실도 시뮬레이션·구성 탐색 도구 |
| [DualMap](https://arxiv.org/abs/2602.06502) | arXiv 2026 | KV affinity + 부하 분산 동시 달성 스케줄러 |
| [LMCache](https://arxiv.org/abs/2510.09665) | arXiv 2025 | GPU 외부 계층 KV 스토어; 처리량 15×↑, TTFT 11s→1.5s |

### B. KV 양자화·압축

| 논문 | Venue/Year | Contribution |
|------|-----------|-------------|
| [KIVI](https://arxiv.org/abs/2402.02750) | ICML 2024 | 파인튜닝 없는 비대칭 2-bit KV 양자화; 메모리 2.6×↓, 배치 2.35~3.47×↑ |
| [KVQuant](https://arxiv.org/abs/2401.18079) | NeurIPS 2024 | per-channel 비균일 3-bit 양자화; 단일 GPU 1M 컨텍스트 달성 |
| [CQ](https://arxiv.org/abs/2405.03917) | NeurIPS 2024 | 채널 결합 양자화; 채널당 1-bit 달성, 처리량 1.4~3.5×↑ |
| [ZipCache](https://arxiv.org/abs/2405.14256) | NeurIPS 2024 | salient 토큰 식별 기반 적응 비트폭; 4.98× 압축, 지연 56.9%↓ |
| [MiniCache](https://arxiv.org/abs/2405.14366) | NeurIPS 2024 | 인접 레이어 KV 유사성 기반 깊이 차원 병합으로 메모리 절감 |
| [Palu](https://arxiv.org/abs/2407.21118) | ICLR 2025 | KV 프로젝션 SVD 저랭크 분해; 50% 압축 1.89×, 양자화 결합 2.91×↑ |
| [KVTuner](https://arxiv.org/abs/2502.04420) | ICML 2025 | 레이어별 민감도 분석 혼합 정밀도; 3.25-bit에서 거의 무손실 |
| [MiniKV](https://arxiv.org/abs/2411.18077) | ACL 2025 | 2-bit + 토큰 선택 공동 설계; 86% 압축, 처리량 48%↑ |
| [AsymKV](https://arxiv.org/abs/2410.13212) | COLING 2025 | 1-bit Value 레이어별 비대칭 양자화; 75% 레이어 1-bit로 FP16 수준 유지 |
| [LogQuant](https://arxiv.org/abs/2503.19950) | arXiv 2025 | 로그 분포 필터링 2-bit 양자화; 처리량 25%↑, Math 40~200%↑ |
| [KITTY](https://arxiv.org/abs/2511.18643) | arXiv 2025 | 채널 민감도 기반 동적 혼합 정밀도; 처리량 2.1~4.1×↑ |
| [xKV](https://arxiv.org/abs/2503.18893) | arXiv 2025 | 크로스레이어 SVD 압축; SOTA 대비 6.8× 압축, 정확도 2.7%↑ |
| [SVDq](https://arxiv.org/abs/2502.15304) | arXiv 2025 | SVD + 혼합 정밀도; Key 1.25-bit, 410× 압축 달성 |
| [MixKVQ](https://arxiv.org/abs/2512.19206) | arXiv 2024 | 쿼리 인식 혼합 정밀도; KV 79%↓, AIME 성능 유지 |
| [PM-KVQ](https://openreview.net/forum?id=Vem6FQvRvq) | arXiv 2025 | Long-CoT용 누진적 혼합 정밀도; 처리량 2.73~5.18×↑ |
| [KVTC](https://arxiv.org/abs/2511.01815) | ICLR 2026 | PCA + 적응 양자화 + 엔트로피 코딩; 최대 20×(특수 용도 40×) 압축 |
| [WKVQuant](https://arxiv.org/abs/2402.12065) | arXiv 2024 | 가중치 + KV 동시 양자화 PTQ 통합 프레임워크 |
| [RVQ-KV](https://arxiv.org/abs/2410.15704) | arXiv 2024 | 잔차 벡터 양자화 KV; FP16 대비 5.5× 압축 |

### C. 토큰 축출·희소 어텐션

| 논문 | Venue/Year | Contribution |
|------|-----------|-------------|
| [Quest](https://arxiv.org/abs/2406.10774) | ICML 2024 | 쿼리 인식 KV 페이지 선택; 추론 지연 7.03×↓ |
| [MInference](https://arxiv.org/abs/2407.02490) | NeurIPS 2024 | 동적 희소 프리필 어텐션; 1M 토큰 추론 30분→3분 |
| [NACL](https://arxiv.org/abs/2408.03675) | ACL 2024 | 프록시 + 무작위 결합 축출; KV 50%↓에서 성능 76~80% 유지 |
| [DuoAttention](https://arxiv.org/abs/2410.10819) | arXiv 2024 | Retrieval/Streaming 헤드 이분화 차등 KV 관리 |
| [HeadKV](https://arxiv.org/abs/2410.19258) | arXiv 2024 | 헤드별 검색·추론 능력 기반 KV 예산 차등 할당 |
| [HashEvict](https://arxiv.org/abs/2412.16187) | arXiv 2024 | LSH 기반 프리어텐션 축출; FastGen 대비 프리필 17×↑ |
| [Ada-KV](https://arxiv.org/abs/2407.11550) | NeurIPS 2025 | 헤드별 적응 KV 예산 할당로 고정 예산 대비 성능 향상 |
| [TokenSelect](https://arxiv.org/abs/2411.02886) | EMNLP 2025 | 비연속 희소성 기반 KV 선택; 어텐션 23.84×↑, 지연 2.28×↓ |
| [ChunkKV](https://arxiv.org/abs/2502.00299) | NeurIPS 2025 | 의미 청크 단위 KV 선택; 처리량 26.5%↑ |
| [RocketKV](https://arxiv.org/abs/2502.14051) | arXiv 2025 | 2단계 압축(SnapKV++ + HSA); 400× 압축, 속도 3.7×↑ |
| [FastKV](https://arxiv.org/abs/2502.01068) | arXiv 2025 | TSP로 프리필·디코딩 분리 가속; 처리량 1.97×↑ |
| [DefensiveKV](https://arxiv.org/abs/2510.13334) | arXiv 2025 | 축출 취약성 분석 + 방어적 집계; 품질 손실 2.6~4.8% |
| [Expected Attention](https://arxiv.org/abs/2510.00636) | arXiv 2025 | 미래 쿼리 분포로 KV 중요도 사전 추정 |
| [LAVa](https://arxiv.org/abs/2509.09754) | EMNLP 2025 | 잔차 스트림 손실 기반 헤드·레이어 동적 예산 할당 |
| [CAOTE](https://arxiv.org/abs/2504.14051) | arXiv 2025 | 어텐션 출력 오차 최소화 기반 축출 정책 |
| [ForesightKV](https://arxiv.org/abs/2602.03203) | arXiv 2026 | RL 기반 장기 기여도 예측 축출; AIME 절반 예산으로 SOTA 초과 |
| [LookaheadKV](https://arxiv.org/abs/2603.10899) | arXiv 2026 | Lookahead LoRA로 미래 어텐션 패턴 예측 기반 축출 |

### D. 분산·분리 서빙 및 KV 전송

| 논문 | Venue/Year | Contribution |
|------|-----------|-------------|
| [DistServe](https://arxiv.org/abs/2401.09670) | OSDI 2024 | P/D 분리로 goodput 최적화; 요청처리 7.4×↑, 엄격한 SLO 12.6×↑ |
| [Splitwise](https://arxiv.org/abs/2311.18677) | ISCA 2024 | 이종 GPU P/D 분리; 처리량 1.4×↑, 비용 20%↓ |
| [Mooncake](https://arxiv.org/abs/2407.00079) | FAST 2025 Best Paper | KV 중심 분리 아키텍처(Kimi 운영); 처리량 525%↑ |
| [CacheGen](https://arxiv.org/abs/2310.07240) | SIGCOMM 2024 | KV 압축 비트스트림 전송; 크기 3.5~4.3×↓, 지연 3.2~3.7×↓ |
| [CacheBlend](https://arxiv.org/abs/2405.16444) | EuroSys 2025 | RAG 멀티청크 KV 선택적 재계산 융합으로 정확도 보존 |
| [LMCache](https://arxiv.org/abs/2510.09665) | arXiv 2025 | GPU 외부 계층 KV 스토어; 처리량 15×↑, TTFT 대폭 단축 |
| [FlowKV](https://arxiv.org/abs/2504.03775) | arXiv 2025 | 저지연 KV 전송 + 부하 인식 스케줄링; KV 전송 지연 96%↓ |
| [BanaServe](https://arxiv.org/abs/2510.13223) | arXiv 2025 | KV + 모듈 동적 마이그레이션; vLLM 대비 3.9×↑ |
| [TraCT](https://arxiv.org/abs/2512.18194) | arXiv 2025 | CXL 공유 메모리 KV 풀; TTFT 9.8×↓, P99 6.2×↓ |
| [CXL-SpecKV](https://arxiv.org/abs/2512.11920) | arXiv 2025 | CXL + FPGA KV 오프로딩; 처리량 3.2×↑ |
| [ShadowKV](https://arxiv.org/abs/2410.21465) | ICML 2025 Spotlight | SVD K GPU 유지 + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑ |
| [PrefillShare](https://arxiv.org/abs/2602.12029) | arXiv 2026 | 다중 LLM 공유 Prefill 모듈; p95 지연 4.5×↓, 처리량 3.9×↑ |
| [DualMap](https://arxiv.org/abs/2602.06502) | arXiv 2026 | KV affinity + 부하 균형 동시 달성 스케줄러 |
| [KVShare](https://arxiv.org/abs/2503.16525) | arXiv 2025 | 멀티테넌트 의미론적 KV 재사용; TTFT 9.39×↓ |
| [Nexus](https://arxiv.org/abs/2507.06608) | arXiv 2025 | 단일 GPU 내 SM 수준 P/D 분리 |
| [HydraInfer](https://arxiv.org/abs/2505.12658) | arXiv 2025 | 멀티모달 LLM 하이브리드 P/D 분리; vLLM 대비 처리량 4×↑ |

### E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)

| 논문 | Venue/Year | Contribution |
|------|-----------|-------------|
| [DeepSeek-V2 (MLA)](https://arxiv.org/abs/2405.04434) | arXiv 2024 | Multi-head Latent Attention; KV 93.3%↓, 처리량 5.76×↑ |
| [DeepSeek-V3](https://arxiv.org/abs/2412.19437) | arXiv 2024 | 671B MoE에 MLA 적용; KV 70KB vs LLaMA-3.1-405B 516KB |
| [TransMLA](https://arxiv.org/abs/2502.07864) | NeurIPS 2025 Spotlight | GQA→MLA 사후 변환; KV 68.75%↓, 추론 10.6×↑ |
| [MHA2MLA](https://arxiv.org/abs/2502.14837) | ACL 2025 | MHA→MLA 변환; KV 92.19%↓, 0.3~0.6% 데이터로 성능 회복 |
| [X-EcoMLA](https://arxiv.org/abs/2503.11132) | arXiv 2025 | 사전학습 어텐션 MLA 업사이클링 방법론 |
| [YOCO](https://arxiv.org/abs/2405.05254) | NeurIPS 2024 | 디코더-디코더 단일 KV 저장; 65B 기준 80×↓, 1M 프리필 71.8×↑ |
| [YOCO++](https://arxiv.org/abs/2604.13556) | arXiv 2025 | YOCO + KV 잔차 연결로 성능 개선 |
| [CLA](https://arxiv.org/abs/2405.12981) | arXiv 2024 | 인접 레이어 KV 공유; MQA 대비 2× 추가 KV 절감 |
| [LCKV](https://arxiv.org/abs/2405.10637) | ACL 2024 | 최상위 레이어 KV만 캐시 재사용; 처리량 26×↑ |
| [KVSharer](https://arxiv.org/abs/2410.18517) | arXiv 2024 | 비유사 레이어 KV 공유; 연산 30%↓, 속도 1.3×↑ |
| [NSA](https://arxiv.org/abs/2502.11089) | ACL 2025 | DeepSeek 훈련 가능 희소 어텐션; 64K 시퀀스 전방향 가속 |
| [TPA](https://arxiv.org/abs/2501.06425) | NeurIPS 2025 Spotlight | 텐서 분해 어텐션; KV 10×↓ |
| [MFA](https://arxiv.org/abs/2412.19255) | arXiv 2024 | 행렬 인수분해 어텐션; MFA-KR 변형으로 KV 93.7%↓ |
| [MTLA](https://arxiv.org/abs/2505.13544) | arXiv 2025 | 시간+공간 차원 동시 KV 압축; 속도 3.75×↑, GPU 메모리 7×↓ |

### F. 장문맥·계층적 오프로딩

| 논문 | Venue/Year | Contribution |
|------|-----------|-------------|
| [InfiniGen](https://arxiv.org/abs/2406.19707) | OSDI 2024 | CPU 오프로딩 + 선택적 GPU 프리페치; 기존 오프로딩 대비 3.0×↑ |
| [MagicPIG](https://arxiv.org/abs/2410.16179) | arXiv 2024 | LSH GPU+CPU 협력; 처리량 1.5~5×↑, RTX4090 96K 디코딩 54ms |
| [RetrievalAttention](https://arxiv.org/abs/2409.10516) | arXiv 2024 | ANNS 기반 CPU KV 검색; RTX4090에서 128K 8B 모델 서빙 |
| [ShadowKV](https://arxiv.org/abs/2410.21465) | ICML 2025 Spotlight | SVD K GPU + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑ |
| [SpeCache](https://arxiv.org/abs/2503.16163) | ICML 2025 | 1~2bit GPU + FP16 CPU 투기적 프리페치; 10× 압축 무손실 달성 |
| [ScoutAttention](https://arxiv.org/abs/2603.27138) | arXiv 2026 | 레이어 선행 CPU 사전 계산; 기존 오프로딩 2.1×↑, 풀어텐션 5.1×↑ |
| [InfiniteHiP](https://arxiv.org/abs/2502.08910) | arXiv 2025 | 계층적 토큰 프루닝 + LRU 오프로딩; L40s에서 3M 토큰 18.95×↑ |
| [Async KV Prefetch](https://arxiv.org/abs/2504.06319) | arXiv 2025 | 비동기 KV 프리페치; H20 어텐션 2.15×↑, FA3 대비 처리량 1.97×↑ |
| [CXL-PNM](https://arxiv.org/abs/2511.00321) | arXiv 2025 | CXL 내 근방 연산으로 단일 노드 1M 토큰 서빙 달성 |
| [CXL-NDP](https://arxiv.org/abs/2509.03377) | arXiv 2025 | CXL 비트플레인 동적 양자화; 처리량 43%↑, 최대 컨텍스트 87%↑ |
| [MILLION](https://arxiv.org/abs/2504.03661) | arXiv 2025 | Product Quantization 장문맥; 32K 컨텍스트 2.09×↑ |

### G. RAG·평가 방법론

| 논문 | Venue/Year | Contribution |
|------|-----------|-------------|
| [RAGCache](https://arxiv.org/abs/2404.12457) | arXiv 2024 | RAG 문서 청크 KV 트리 캐시로 반복 쿼리 비용 절감 |
| [CacheBlend](https://arxiv.org/abs/2405.16444) | EuroSys 2025 | RAG 멀티청크 KV 선택적 재계산 융합; 정확도 보존 |
| [Cache-Craft](https://arxiv.org/abs/2502.15734) | arXiv 2025 | RAG 청크 캐시 관리 시스템으로 KV 재사용 체계화 |
| [RULER](https://arxiv.org/abs/2404.06654) | COLM 2024 | 장문맥 실질 활용 능력 종합 벤치마크 |
| [SCBench](https://arxiv.org/abs/2412.10319) | arXiv 2024 | KV 캐시 중심 장문맥 분석 전용 벤치마크 |

---

## 4. Open Problems

### 문제 1: MLA와 양자화/축출 기법의 공동 설계 부재
MLA는 KV를 잠재 벡터로 압축하기 때문에 기존 채널별 양자화나 토큰 중요도 점수 계산이 그대로 적용되지 않는다. MLA 구조에 특화된 양자화 및 토큰 축출 기법은 아직 초기 단계이며, MLA 기반 모델(DeepSeek-V2/V3 계열)이 확산됨에 따라 이 간극을 메우는 연구가 필요하다.

### 문제 2: RL/예측 기반 축출의 훈련·추론 비용 정당화
ForesightKV, LookaheadKV 등 RL·미래 예측 기반 축출은 오프라인 훈련 비용과 온라인 예측 오버헤드가 있다. 실제 배포 시 훈련·갱신 비용 대비 절약량이 정당화되는지, 도메인 이동(domain shift) 상황에서 일반화가 유지되는지는 충분히 검증되지 않았다.

### 문제 3: P/D 분리 시 네트워크 병목과 표준화 부재
P/D 분리 서빙이 성숙해졌으나, KV 전송 인터페이스(CacheGen, FlowKV, LMCache 등)가 각 프레임워크마다 상이하여 상호 운용이 어렵다. KV 전송 프로토콜의 표준화, 압축 포맷 호환성, 오류 복구 메커니즘은 미해결 상태이다.

### 문제 4: Long-CoT(Reasoning) 모델에서의 KV 증가 대응
DeepSeek-R1, o3 등 Reasoning 모델은 수천~수만 토큰의 중간 추론 과정을 생성한다. 이 과정에서 KV 캐시가 폭발적으로 증가하는데, 기존 슬라이딩 윈도우나 고정 예산 축출은 논리적 연결고리를 끊어 추론 오류를 일으킬 수 있다. 추론 구조(인과 체인)를 보존하는 KV 관리 기법이 충분하지 않다.

### 문제 5: CXL 계층 메모리의 지연·대역폭 불확실성
CXL 기반 KV 오프로딩은 실험 하드웨어(시뮬레이터, FPGA 프로토타입)에서 검증된 경우가 많다. 실제 CXL 2.0/3.0 DRAM 모듈과 운영 체제 스케줄러 간 상호작용에서의 지연 변동성, 멀티테넌트 혼용 시 QoS 보장 방법 등 실운영 증거가 부족하다.

### 문제 6: KV 캐시 보안·프라이버시 취약성
DefensiveKV([arXiv 2025](https://arxiv.org/abs/2510.13334))가 지적하듯, KV 캐시 공유(멀티테넌트 APC, KVShare 등) 환경에서 다른 사용자의 프롬프트 정보가 KV를 통해 추론될 수 있다. 캐시 오염 공격(prompt injection via shared KV), 사이드 채널 공격, 데이터 잔류 문제는 아직 체계적으로 연구되지 않았다.

### 문제 7: 이기종 모델·태스크 혼합 환경에서의 KV 재사용 한계
KVShare, BatchLLM, Preble 등은 동일 모델·유사 프롬프트 간 KV 재사용을 전제한다. 하지만 동일 서비스 내 여러 파인튜닝 변종 모델이 혼용되거나, 사용자 태스크가 다양할 때 KV 재사용률이 급감하는 "cold-start" 문제와 캐시 메모리 낭비가 발생한다.

---

## 5. Notable Researchers / Groups

| 이름/그룹 | 소속 | 대표 기여 |
|-----------|------|----------|
| **Tri Dao** | Princeton / Together AI | FlashAttention 시리즈, FlashInfer |
| **Ion Stoica 그룹** | UC Berkeley (Sky Computing Lab) | vLLM, SGLang, Preble, CacheBlend |
| **Lianmin Zheng** | UC Berkeley / LMSYS | SGLang, Punica, vLLM |
| **Dacheng Li** | UC Berkeley | ShadowKV, SGLang v0.4 |
| **DeepSeek 팀** | DeepSeek AI | MLA(DeepSeek-V2/V3), NSA, DeepSeek-R1 |
| **Baris Kasikci 그룹** | University of Michigan | DistServe, Sarathi-Serve |
| **Mosharaf Chowdhury 그룹** | University of Michigan | DistServe, CacheGen |
| **Kimi/Moonshot AI 팀** | Moonshot AI | Mooncake, KV 중심 분리 서빙 |
| **Ce Zhang 그룹** | ETH Zürich / Together AI | ZipCache, 서빙 최적화 |
| **Kurt Keutzer 그룹** | UC Berkeley | KVQuant, KIVI, QServe |
| **Song Han 그룹** | MIT / NVIDIA | QServe, LServe, EfficientML |
| **Xipeng Qiu 그룹** | Fudan University | MInference, 장문맥 효율화 |
| **Beidi Chen 그룹** | CMU / Meta AI | Quest, 희소 어텐션 |
| **Microsoft Research Asia** | Microsoft | MInference, YOCO, TPA, TransMLA |
| **Google DeepMind** | Google | Gemini KV 효율화 연구 (확인 필요) |

---

## 6. Resources

### 주요 오픈소스 프레임워크 및 라이브러리

| 자원 | URL | 설명 |
|------|-----|------|
| vLLM | https://github.com/vllm-project/vllm | PagedAttention 기반 LLM 서빙 엔진 |
| SGLang | https://github.com/sgl-project/sglang | RadixAttention, 고성능 LLM 서빙 |
| FlashInfer | https://github.com/flashinfer-ai/flashinfer | JIT 컴파일 커널 기반 어텐션 라이브러리 |
| FlashAttention-3 | https://github.com/Dao-AILab/flash-attention | 하드웨어 최적화 어텐션 커널 |
| LMCache | https://github.com/LMCache/LMCache | GPU 외부 계층 KV 캐시 스토어 |
| MInference | https://github.com/microsoft/MInference | 동적 희소 프리필 어텐션 라이브러리 |
| KVQuant | https://github.com/SqueezeAILab/KVQuant | 비균일 KV 양자화 구현 |
| KIVI | https://github.com/jy-tang/KIVI | 2-bit KV 양자화 파이썬 구현 |

### 벤치마크 및 평가 도구

| 자원 | URL/arXiv | 설명 |
|------|----------|------|
| RULER | https://arxiv.org/abs/2404.06654 | 장문맥 실질 활용 능력 종합 벤치마크 |
| SCBench | https://arxiv.org/abs/2412.10319 | KV 캐시 중심 장문맥 분석 벤치마크 |
| LongBench | https://github.com/THUDM/LongBench | 장문맥 이해 능력 다과제 벤치마크 |
| VIDUR | https://github.com/microsoft/vidur | LLM 추론 서빙 고충실도 시뮬레이터 |
| LLMPerf | https://github.com/ray-project/llmperf | LLM 서빙 성능 측정 도구 |

### 데이터셋

| 자원 | 설명 |
|------|------|
| SCROLLS | 장문 문서 요약·QA 평가 데이터셋 |
| Needle-in-a-Haystack | 장문맥 검색 능력 평가용 합성 데이터 |
| AIME 2024/2025 | 수학 추론 능력 평가 (Reasoning 모델 KV 평가에 활용) |

---

## 7. Reading List

입문에서 심화 순으로 구성하였다.

### 입문 (기초 개념 및 동기)

1. **Attention Is All You Need** (Vaswani et al., NeurIPS 2017) — 트랜스포머 어텐션 메커니즘과 KV 캐시의 원점. (historical)
2. **FlashAttention** (Dao et al., NeurIPS 2022) — IO 인식 어텐션 커널; KV 캐시 메모리 계층 이해의 기초. (historical)
3. **Efficient Memory Management for Large Language Model Serving with PagedAttention** (Kwon et al., SOSP 2023) — vLLM의 기반; KV 캐시 단편화 문제와 가상 메모리 해결 방법. (historical)
4. **[RULER](https://arxiv.org/abs/2404.06654)** (Hsieh et al., COLM 2024) — 장문맥 KV 캐시 활용 능력의 실질적 평가 방법론.

### 중급 (핵심 서빙 시스템)

5. **[SGLang](https://arxiv.org/abs/2312.07104)** (Zheng et al., NeurIPS 2024) — RadixAttention 자동 KV 재사용; 서빙 시스템 구조 이해에 필수.
6. **[Sarathi-Serve](https://arxiv.org/abs/2403.02310)** (Agrawal et al., OSDI 2024) — stall-free chunked prefill; P/D 워크로드 간섭 해결 방법.
7. **[DistServe](https://arxiv.org/abs/2401.09670)** (Zhong et al., OSDI 2024) — P/D 분리의 이론적 틀과 goodput 최적화.
8. **[Mooncake](https://arxiv.org/abs/2407.00079)** (Qin et al., FAST 2025) — KV 중심 분리 아키텍처의 실운영 사례.
9. **[FlashInfer](https://arxiv.org/abs/2501.01005)** (Ye et al., MLSys 2025) — JIT 컴파일 기반 어텐션 커널 설계 원리.

### 중급 (KV 압축·양자화)

10. **[KIVI](https://arxiv.org/abs/2402.02750)** (Liu et al., ICML 2024) — 2-bit KV 양자화 입문; 파인튜닝 없는 접근의 시작점.
11. **[KVQuant](https://arxiv.org/abs/2401.18079)** (Hooper et al., NeurIPS 2024) — 비균일 양자화 기법과 이론적 배경.
12. **[Palu](https://arxiv.org/abs/2407.21118)** (Chang et al., ICLR 2025) — 저랭크 분해와 양자화 결합의 시너지.
13. **[MInference](https://arxiv.org/abs/2407.02490)** (Jiang et al., NeurIPS 2024) — 동적 희소 어텐션; 1M 토큰 프리필 가속.
14. **[Quest](https://arxiv.org/abs/2406.10774)** (Tang et al., ICML 2024) — 쿼리 인식 KV 페이지 선택의 핵심 아이디어.

### 심화 (아키텍처·최신 연구)

15. **[DeepSeek-V2 (MLA)](https://arxiv.org/abs/2405.04434)** (DeepSeek Team, 2024) — MLA 설계 원리; KV 93.3% 절감의 이론적·실험적 근거.
16. **[YOCO](https://arxiv.org/abs/2405.05254)** (Sun et al., NeurIPS 2024) — 단일 KV 저장 디코더-디코더 아키텍처; 아키텍처 혁신의 극단.
17. **[TransMLA](https://arxiv.org/abs/2502.07864)** (He et al., NeurIPS 2025) — 사후 MLA 변환; 기존 모델 생태계의 MLA 이식 방법론.
18. **[ForesightKV](https://arxiv.org/abs/2602.03203)** (2026) — RL 기반 축출; 지능형 캐시 관리의 최신 방향.
19. **[ShadowKV](https://arxiv.org/abs/2410.21465)** (Sun et al., ICML 2025) — GPU/CPU 메모리 계층 협력의 정교한 설계.
20. **[TraCT](https://arxiv.org/abs/2512.18194)** (arXiv 2025) — CXL 공유 메모리 KV 풀; 새로운 메모리 계층 활용의 실험적 증거.

---

## 8. Methodology

### 검색 쿼리 및 출처 범위

본 보고서는 사용자가 제공한 R1~R6 수집 데이터를 기반으로 작성되었으며, 별도의 실시간 웹 검색은 수행되지 않았다. 제공된 데이터는 아래 학술 출처에서 수집된 것으로 명시되어 있다.

**포함 학술 기관/학회 (2023-01 ~ 2026-04)**

| 범주 | 출처 |
|------|------|
| 시스템 컨퍼런스 | OSDI 2024, SOSP 2023, ISCA 2024, ASPLOS 2025, FAST 2025, EuroSys 2025, SIGCOMM 2024 |
| ML/AI 컨퍼런스 | NeurIPS 2024/2025, ICML 2024/2025, ICLR 2025/2026, MLSys 2024/2025 |
| NLP 컨퍼런스 | ACL 2024/2025, EMNLP 2024/2025, COLING 2025, COLM 2024 |
| 프리프린트 | arXiv (2024-01 ~ 2026-04) |

**가정 및 한계**

- 제공된 URL은 모두 사용자가 검증한 것으로 간주하였다. 단, arXiv 2025~2026 논문 중 일부는 동료 심사 전 프리프린트이므로 결과가 최종 출판본과 다를 수 있다.
- venue 표기가 "확인 필요"인 항목: PM-KVQ(OpenReview 링크만 제공됨, 최종 게재지 불명확), YOCO++([arXiv 2025](https://arxiv.org/abs/2604.13556), 아직 프리프린트), ScoutAttention([arXiv 2026](https://arxiv.org/abs/2603.27138), 아직 프리프린트).
- 수치(배속, 압축률)는 각 논문이 자체 보고한 수치이며, 하드웨어 환경·기준선이 논문마다 상이하므로 직접 비교에 주의가 필요하다.
- Google DeepMind의 Gemini KV 효율화 연구는 공개 논문 기준으로 확인 불가한 부분이 있어 "확인 필요"로 표기하였다.

**검색 재현을 위한 키워드 예시**

```
"KV cache" "quantization" LLM 2024 2025
"prefill decode disaggregation" serving
"multi-head latent attention" OR "MLA" compression
"KV cache eviction" "token selection" transformer
"CXL" "KV cache" offloading memory
"long context" "KV cache" offload
site:arxiv.org "KV cache" 2025
```
