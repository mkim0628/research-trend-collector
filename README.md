# Research Trend Collector

연구 동향을 매일 수집하고, 누적된 결과를 이 README의 인덱스에서 한눈에 보기 위한 워크스페이스입니다. 일일 보고서는 `reports/`에 쌓이고, 특정 논문에 대한 심층 분석은 `reports/deep-dives/`에 분리되어 저장됩니다. 두 결과 모두 아래 *Reports Index* 영역에 자동으로 정리됩니다.

## 사용법

| 커맨드 | 설명 |
| --- | --- |
| `/collect-trends interests/<file>` | 관심 분야 명세 파일을 읽어 일일 동향 보고서를 생성하고 README 인덱스를 갱신합니다. |
| `/deep-dive <논문 \| URL \| arXiv ID>` | 특정 연구물을 심층 분석한 보고서를 `reports/deep-dives/`에 저장하고 인덱스에 반영합니다. |
| `/index-reports` | `reports/`를 스캔해 README의 인덱스 영역만 재생성합니다(보고서 본문은 건드리지 않음). |

상세 운영 규칙·보고서 형식·작업 원칙은 [`CLAUDE.md`](CLAUDE.md)를 참고하세요.

## 자동 실행

매일 동향 수집을 자동으로 돌리려면 [Claude Code Routines](https://claude.ai/code/routines)에서 새 루틴을 만드세요.

- **Repository**: `mkim0628/research-trend-collector`
- **Trigger**: Schedule — 매일 원하는 시각
- **Prompt** 예시: `interests/ 아래 example.* 를 제외한 모든 명세 파일에 대해 /collect-trends 를 실행하고, 변경이 있으면 main 브랜치에 커밋·푸시해줘.`

루틴은 Anthropic 클라우드에서 실행되므로 호스트 cron이나 로컬 셸 스크립트는 필요 없습니다.

## Reports Index

> 아래 영역은 `report-indexer` 서브에이전트가 자동 갱신합니다. 마커 사이만 교체되며, 그 밖의 내용은 보존됩니다.

<!-- BEGIN: AUTO-INDEX -->
_마지막 업데이트: 2026-05-13 · 보고서 5개 · 논문 157편 · Deep-dive 1건_

### LLM 추론 KV 캐시 관리·최적화
- Latest: [kv-cache-optimization-2026-05-13](reports/kv-cache-optimization-2026-05-13.md)
- 주요 논문:

  **A. 서빙 시스템·메모리 관리** (신규 — 2026-05-13 보고서)
  - [SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters](https://arxiv.org/abs/2605.00528) — 에이전트 워크플로를 최소 스케줄 단위로 삼아 KV 캐시 보존; KV 재생성 시간 38% → 8%로 감소 (HPDC 2026)
  - [Efficient Serving for Dynamic Agent Workflows with Prediction-based KV-Cache Management (PBKV)](https://arxiv.org/abs/2605.06472) — 미래 에이전트 호출 예측으로 KV 재사용 극대화하는 예측 기반 관리 시스템

  **A. 서빙 시스템·메모리 관리** (2026-05-04 보고서)
  - [AdaptCache: KV Cache Native Storage Hierarchy for Low-Delay and High-Quality Language Model Serving](https://arxiv.org/abs/2509.00105) — 각 KV 항목별 압축 알고리즘·비율·배치 장치 동적 결정; KIVI 대비 TTFT 69%↓, 정적 기준선 대비 1.43~2.4× 지연 절감
  - [Revisiting Disaggregated Large Language Model Serving for Performance and Energy Implications](https://arxiv.org/abs/2601.08833) — P/D 분리 성능 이점이 요청 부하·KV 전송 매체에 따라 보장되지 않으며 에너지 소비가 더 높을 수 있음을 DVFS 프로파일링으로 실증
  - [Understand and Accelerate Memory Processing Pipeline for Disaggregated LLM Inference](https://arxiv.org/abs/2603.29002) — 4단계 메모리 처리 파이프라인 통일 모델 + GPU-FPGA 이종 처리; 1.04~2.2×↑, 에너지 1.11~4.7×↓

  **A. 서빙 시스템·메모리 관리** (2026-05-03 보고서)
  - [TaiChi: Prefill-Decode Aggregation or Disaggregation?](https://arxiv.org/abs/2508.01989) — SLO에 따라 집합·분리 모드를 동적으로 전환하는 통합 서빙; goodput 최대 77%↑
  - [MuxWise: Towards High-Goodput LLM Serving with Prefill-decode Multiplexing](https://arxiv.org/abs/2504.14489) — 레이어 단위 버블-없는 인트라-GPU P/D 다중화; SLO 보장 처리량 2.20×(최대 3.06×)↑
  - [DuetServe: Harmonizing Prefill and Decode for LLM Serving via Adaptive GPU Multiplexing](https://arxiv.org/abs/2511.04791) — 오염 예측 시 SM 수준 공간 다중화 활성화; Qwen3 기준 처리량 1.3×↑

  **A. 서빙 시스템·메모리 관리** (2026-05-02 보고서)
  - [vLLM V1: A Major Upgrade to vLLM's Core Architecture](https://blog.vllm.ai/2025/01/27/v1-alpha-release.html) — KV 관리자·스케줄러·워커 전면 재설계; CPU 오프로딩, FP8·TurboQuant 2-bit KV, 멀티모달 prefix caching 통합
  - [SGLang HiCache: Fast Hierarchical KV Caching](https://www.lmsys.org/blog/2025-09-10-sglang-hicache/) — RadixAttention을 GPU(L1)·CPU(L2)·분산 스토리지(L3) 3계층으로 확장; TTFT 80%↓, 처리량 6×↑
  - [Prefill-as-a-Service: KVCache of Next-Generation Models Could Go Cross-Datacenter](https://arxiv.org/abs/2604.15039) — 크로스 데이터센터 P/D 분리; 처리량 54%↑, P90 TTFT 64%↓
  - [CacheFlow: Efficient LLM Serving with 3D-Parallel KV Cache Restoration](https://arxiv.org/abs/2604.25080) — 토큰·레이어·GPU 3차원 병렬 KV 복원; TTFT 10~62%↓
  - [TokenDance: Scaling Multi-Agent LLM Serving via Collective KV Cache Sharing](https://arxiv.org/abs/2604.03143) — 멀티 에이전트 All-Gather 패턴 KV diff 블록 공유; 11~17× 압축, 2.7× 더 많은 동시 에이전트

  **A. 서빙 시스템·메모리 관리** (2026-04-30 보고서)
  - [SGLang: Efficient Execution of Structured Language Model Programs](https://arxiv.org/abs/2312.07104) — RadixAttention 자동 KV 재사용; 처리량 6.4×↑, few-shot cache hit rate 85~95% (NeurIPS 2024)
  - [Sarathi-Serve](https://arxiv.org/abs/2403.02310) — stall-free chunked prefill; Mistral-7B 2.6×, Falcon-180B 5.6×↑ (OSDI 2024)
  - [FlashInfer](https://arxiv.org/abs/2501.01005) — 블록 희소 포맷 + JIT 컴파일 어텐션 커널; ITL 29~69%↓ (MLSys 2025 Best Paper)
  - [Mooncake](https://arxiv.org/abs/2407.00079) — KV 중심 분리 아키텍처; 처리량 525%↑ (FAST 2025 Best Paper)
  - [LMCache](https://arxiv.org/abs/2510.09665) — GPU 외부 계층 KV 스토어; 처리량 15×↑, TTFT 대폭 단축

  **B. KV 양자화·압축** (신규 — 2026-05-13 보고서)
  - [RateQuant: Optimal Mixed-Precision KV Cache Quantization via Rate-Distortion Theory](https://arxiv.org/abs/2605.06675) — rate-distortion reverse waterfilling으로 헤드별 최적 비트 폭 배분; Qwen3-8B 2.5bit에서 KIVI perplexity 49.3→14.9
  - [FibQuant: Universal Vector Quantization for Random-Access KV-Cache Compression](https://arxiv.org/abs/2605.11478) — Fibonacci/Roberts-Kronecker 준균일 방향 + Beta-quantile + Lloyd-Max 정제로 랜덤 접근 가능한 범용 벡터 양자화기
  - [eOptShrinkQ: Near-Lossless KV Cache Compression Through Optimal Spectral Denoising and Quantization](https://arxiv.org/abs/2605.02905) — 최적 특이값 수축으로 저랭크 공유 문맥 추출 후 잔차를 TurboQuant로 양자화; ~2.2bit에서 TurboQuant 3.0bit 성능 초과
  - [Kitty: Accurate and Efficient 2-bit KV Cache Quantization with Dynamic Channel-wise Precision Boost](https://arxiv.org/abs/2511.18643) — 키 채널 민감도 기반 동적 채널별 정밀도 부스팅; ~8× KV 메모리 절감, 2.1-4.1× 처리량 향상 (MLSys 2026)

  **B. KV 양자화·압축** (2026-05-04 보고서)
  - [Cocktail: Chunk-Adaptive Mixed-Precision Quantization for Long-Context LLM Inference](https://arxiv.org/abs/2503.23294) — 쿼리-청크 유사도 기반 비트폭 동적 선택 + 청크 재정렬; 장문맥 LLM 추론 SOTA 초과 (DATE 2025)
  - [OjaKV: Context-Aware Online Low-Rank KV Cache Compression with Oja's Rule](https://arxiv.org/abs/2509.21623) — Oja 온라인 PCA로 압축 기저 지속 갱신; 정적 SVD 기법 AIME25 0% vs. OjaKV 13% 정확도 유지
  - [Don't Waste Bits! Adaptive KV-Cache Quantization for Lightweight On-Device LLMs](https://arxiv.org/abs/2604.04722) — 경량 컨트롤러로 {2,4,8-bit,FP16} 동적 선택; 정적 양자화 대비 지연 17.75%↓, 정확도 7.6점↑
  - [ARKV: Adaptive and Resource-Efficient KV Cache Management under Limited Memory Budget](https://arxiv.org/abs/2603.08727) — 레이어별 OQ 비율 추정 + 토큰별 3-상태 관리; 4× 메모리 절감에서 기준선 97% 정확도 유지
  - [EchoKV: Efficient KV Cache Compression via Similarity-Based Reconstruction](https://arxiv.org/abs/2603.22910) — 인터/인트라 레이어 헤드 유사도 활용 경량 재구성 네트워크; 7B 모델 ~1 A100 GPU-시간 학습

  **B. KV 양자화·압축** (2026-05-03 및 이전 보고서)
  - [TurboQuant](https://arxiv.org/abs/2504.19874) — 랜덤 직교 회전 + QJL 잔차로 3-bit 벡터 양자화; KV 6×↓, H100 기준 어텐션 8×↑ (ICLR 2026)
  - [RotateKV](https://arxiv.org/abs/2501.16383) — 채널 재정렬 아웃라이어 인식 FWHT 회전; 2-bit PPL 저하 0.3↓
  - [KIVI](https://arxiv.org/abs/2402.02750) — 파인튜닝 없는 비대칭 2-bit KV 양자화; 메모리 2.6×↓ (ICML 2024)
  - [KVzap](https://arxiv.org/abs/2601.07891) — KVzip 경량 근사 + 입력 밀도 적응 임계치; KVpress 리더보드 2~4× 압축 SOTA
  - [AQUA-KV](https://arxiv.org/abs/2501.19392) — K–V 의존성 활용 적응형 어댑터; 2~2.5bit에서 LongBench perplexity 상대 오차 1% 미만 (ICML 2025)

  **C. 토큰 축출·희소 어텐션** (신규 — 2026-05-13 보고서)
  - [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective (CapKV)](https://arxiv.org/abs/2604.25975) — Information Bottleneck 관점에서 유지 KV 부분집합의 상호정보량을 log-determinant + leverage score로 근사하는 capacity-aware eviction
  - [Reformulating KV Cache Eviction Problem for Long-Context LLM Inference (LaProx)](https://arxiv.org/abs/2605.07234) — 어텐션 맵×프로젝트 값의 곱셈 상호작용을 output-aware 행렬 근사 문제로 재정식화; LongBench 16개 태스크 대부분 SOTA (KAIST)
  - [LKV: End-to-End Learning of Head-wise Budgets and Token Selection for LLM KV Cache Eviction](https://arxiv.org/abs/2605.06676) — KV 압축을 종단간 미분가능 최적화로 정식화; LKV-H + LKV-T로 LongBench·RULER 최고 성능
  - [SkipKV: Selective Skipping of KV Generation and Storage for Efficient Inference with Large Reasoning Models](https://arxiv.org/abs/2512.07993) — 장문 CoT 추론 모델 전용 문장-1차 점수 + 적응형 스티어링으로 KV 저장·생성 선택적 생략 (MLSys 2026)
  - [An Efficient Hybrid Sparse Attention with CPU-GPU Parallelism for Long-Context Inference (Fluxion)](https://arxiv.org/abs/2605.07719) — CPU 상주 KV에 대한 출력-aware 예산 + 크로스-디바이스 협력; KV 예산 0.05에서 고정-희소 대비 1.5-3.7× 가속

  **C. 토큰 축출·희소 어텐션** (2026-05-04 보고서)
  - [SAGE-KV: LLMs Know What to Drop](https://arxiv.org/abs/2503.08879) — 프리필 후 1회 top-k 선택(토큰+헤드); StreamLLM 대비 4× 메모리 효율 (ICLR 2025)
  - [SentenceKV: Efficient LLM Inference via Sentence-Level Semantic KV Caching](https://arxiv.org/abs/2504.00970) — 문장 수준 시맨틱 벡터 GPU 유지 + 개별 KV CPU 오프로드 (COLM 2025)
  - [IceCache: Memory-efficient KV-cache Management for Long-Sequence LLMs](https://arxiv.org/abs/2604.10539) — 시맨틱 토큰 클러스터링 DCI-tree + ANN 페이지 선택
  - [DynSplit-KV: Dynamic Semantic Splitting for KVCache Compression](https://arxiv.org/abs/2602.03184) — 동적 의미 경계 분할; FlashAttention 대비 2.2×↑, 메모리 2.6×↓
  - [SemantiCache: Efficient KV Cache Compression via Semantic Chunking and Clustered Merging](https://arxiv.org/abs/2603.14303) — GSC 클러스터 병합 + 비례 어텐션 재균형; 디코딩 2.61×↑
  - [LycheeCluster: Efficient Long-Context Inference with Structure-Aware Chunking and Hierarchical KV Indexing](https://arxiv.org/abs/2603.08453) — 계층 인덱스로 KV 검색 O(log n) 단축; 풀 어텐션 대비 3.6×↑
  - [Self-Indexing KVCache: Predicting Sparse Attention from Compressed Keys](https://arxiv.org/abs/2603.14224) — 1-bit VQ로 압축키에서 직접 top-k 검색; 별도 인덱스 불필요 (AAAI 2026)

  **C. 토큰 축출·희소 어텐션** (2026-05-03 및 이전 보고서)
  - [AnDPro](https://arxiv.org/abs/2509.18143) — Value 벡터 앵커 방향 투영 기반 토큰 중요도; LongBench 96.07% 정확도, 3.44% 예산 (NeurIPS 2025)
  - [FreeKV](https://arxiv.org/abs/2505.13109) — 투기적 검색 + 하이브리드 CPU/GPU 레이아웃; SOTA 대비 13×↑
  - [ForesightKV](https://arxiv.org/abs/2602.03203) — RL 기반 장기 기여도 예측; AIME 절반 예산에서 SOTA 초과

  **D. 분산·분리 서빙 및 KV 전송** (신규 — 2026-05-04 보고서)
  - [Beluga: A CXL-Based Memory Architecture for Scalable and Efficient LLM KVCache Management](https://arxiv.org/abs/2511.20172) — CXL 2.0 스위치 공유 메모리 풀; RDMA 대비 읽기 지연 7.0×↓, TTFT 89.6%↓, 처리량 7.35×↑ (SIGMOD 2025)
  - [Theoretically Optimal Attention/FFN Ratios in Disaggregated LLM Serving](https://arxiv.org/abs/2601.21351) — AFD 아키텍처 최적 A/F 비율 closed-form 도출

  **D. 분산·분리 서빙 및 KV 전송** (이전 보고서)
  - [Mooncake](https://arxiv.org/abs/2407.00079) — KV 중심 분리 아키텍처; 처리량 525%↑ (FAST 2025 Best Paper)
  - [Prefill-as-a-Service](https://arxiv.org/abs/2604.15039) — 크로스 데이터센터 P/D 분리; 처리량 54%↑, P90 TTFT 64%↓
  - [TraCT](https://arxiv.org/abs/2512.18194) — CXL 공유 메모리 KV 풀; TTFT 9.8×↓

  **E. 아키텍처 수준 KV 절감** (신규 — 2026-05-04 보고서)
  - [MoE-MLA-RoPE: Unifying Mixture of Experts and MLA for Efficient Language Models](https://arxiv.org/abs/2508.01261) — MoE+MLA 결합으로 68% KV 절감, 3.2× 추론 가속 (KDD 2025 Workshop)
  - [TPLA: Tensor Parallel Latent Attention for Efficient Disaggregated Prefill and Decode Inference](https://arxiv.org/abs/2508.15881) — 텐서 병렬 환경에서 MLA 이점 보존; DeepSeek-V3·Kimi-K2 1.79~1.93×↑
  - [MHA2MLA-VLM: Enabling DeepSeek's MLA across Vision-Language Models](https://arxiv.org/abs/2601.11464) — 시각·텍스트 KV 독립 저랭크 압축; LLaVA-1.5/NeXT, Qwen2.5-VL 적용

  **E. 아키텍처 수준 KV 절감** (이전 보고서)
  - [DeepSeek-V2 (MLA)](https://arxiv.org/abs/2405.04434) — KV 93.3%↓, 처리량 5.76×↑
  - [TransMLA](https://arxiv.org/abs/2502.07864) — GQA→MLA 사후 변환; KV 68.75%↓, 추론 10.6×↑ (NeurIPS 2025 Spotlight)
  - [TPA](https://arxiv.org/abs/2501.06425) — 텐서 분해 어텐션; KV 10×↓ (NeurIPS 2025 Spotlight)

  **F. 장문맥·계층적 오프로딩** (신규 — 2026-05-13 보고서)
  - [Tutti: Making SSD-Backed KV Cache Practical for Long-Context LLM Serving](https://arxiv.org/abs/2605.03375) — GPU-centric KV 객체 저장소로 CPU를 I/O 경로에서 제거; LMCache 대비 TTFT 78.3% 절감, 처리량 2×
  - [KV-Fold: One-Step KV-Cache Recurrence for Long-Context Inference](https://arxiv.org/abs/2605.12471) — KV 캐시를 시퀀스 청크에 대한 left fold 누산기로 처리하는 훈련-free 장문맥 추론 프로토콜

  **F. 장문맥·계층적 오프로딩** (2026-05-04 보고서)
  - [SparKV: Overhead-Aware KV Cache Loading for Efficient On-Device LLM Inference](https://arxiv.org/abs/2604.21231) — 클라우드 스트리밍 vs. 온디바이스 계산 동적 결정; TTFT 1.3~5.1×↓, 에너지 1.5~3.3×↓

  **F. 장문맥·계층적 오프로딩** (이전 보고서)
  - [ShadowKV](https://arxiv.org/abs/2410.21465) — SVD K GPU + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑ (ICML 2025 Spotlight)
  - [KVSwap](https://arxiv.org/abs/2511.11907) — 디스크 특성 인식 KV 오프로딩 (MobiSys 2026)
  - [Dual-Blade](https://arxiv.org/abs/2604.26557) — NVMe-Direct 이중 경로; prefill 33.1%↓, decode 42.4%↓

  **G. RAG·평가 방법론** (이전 보고서)
  - [KV Cache Optimization Strategies for Scalable and Efficient LLM Inference](https://arxiv.org/abs/2603.20397) — 5개 방향 체계적 리뷰; 2026년 분야 지형도

  **H. 보안·프라이버시** (이전 보고서)
  - [Shadow in the Cache](https://arxiv.org/abs/2508.09442) — KV 역산·충돌·주입 3종 공격 + KV-Cloak 방어 (NDSS 2026)
  - [SafeKV](https://arxiv.org/abs/2508.08438) — 타이밍 사이드채널 차단 선택적 KV 공유

- 관련 Deep-dive:
  - [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md)

### Deep Dives
- [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md) — 멀티모달 LLM 추론에서 이미지·텍스트 KV 캐시를 위치(prefix) 제약 없이 디스크에 저장·재사용하면서, 이미지 토큰 앞부분의 anchor 토큰만 선택적으로 재계산해 정확도 손실은 최소화하고 TTFT는 최대 54.1% 줄이며 처리량을 약 2.0배 향상. (원문: [OpenReview](https://openreview.net/forum?id=bld5GVRad0))

<!-- END: AUTO-INDEX -->
