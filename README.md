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
_마지막 업데이트: 2026-05-08 · 보고서 5개 · 논문 154편 · Deep-dive 1건_

### LLM 추론 KV 캐시 관리·최적화
- Latest: [kv-cache-optimization-2026-05-08](reports/kv-cache-optimization-2026-05-08.md)
- 주요 논문:

  **A. 서빙 시스템** (신규 — 2026-05-08 보고서)
  - [DeepSeek V4 in vLLM: Efficient Long-context Attention](https://vllm.ai/blog/deepseek-v4) — DeepSeek V4-Pro/Flash c4a·c128a 하이브리드 어텐션을 vLLM v0.20에서 지원; 1M 토큰 기준 KV ~9.62 GiB (V3.2 대비 약 8.7× 감소), 커널 퓨전 1.4~20×
  - [vLLM v0.19.0 / v0.20.0 Release](https://github.com/vllm-project/vllm/releases) — v0.19: 비동기 스케줄러 기본 활성화 + 제로-버블 spec-decode; v0.20: CUDA 13.0 기본화, DeepSeek V4 안정화, Model Runner V2 완성
  - [llm-d v0.5: Sustaining Performance at Scale](https://llm-d.ai/blog/llm-d-v0.5-sustaining-performance-at-scale) — 계층적 KV 오프로드(GPU HBM→CPU DRAM→파일시스템), UCCL/NIXL 백엔드로 P2P KV 전송 최적화, scale-to-zero 오토스케일링

  **A. 서빙 시스템·메모리 관리** (2026-05-04 보고서)
  - [AdaptCache: KV Cache Native Storage Hierarchy for Low-Delay and High-Quality Language Model Serving](https://arxiv.org/abs/2509.00105) — 각 KV 항목별 압축 알고리즘·비율·배치 장치 동적 결정; KIVI 대비 TTFT 69%↓, 정적 기준선 대비 1.43~2.4× 지연 절감
  - [Revisiting Disaggregated Large Language Model Serving for Performance and Energy Implications](https://arxiv.org/abs/2601.08833) — P/D 분리 성능 이점이 요청 부하·KV 전송 매체에 따라 보장되지 않으며 에너지 소비가 더 높을 수 있음을 DVFS 프로파일링으로 실증
  - [Understand and Accelerate Memory Processing Pipeline for Disaggregated LLM Inference](https://arxiv.org/abs/2603.29002) — 4단계 메모리 처리 파이프라인 통일 모델 + GPU-FPGA 이종 처리; 1.04~2.2×↑, 에너지 1.11~4.7×↓

  **A. 서빙 시스템·메모리 관리** (2026-05-03 보고서)
  - [TaiChi: Prefill-Decode Aggregation or Disaggregation?](https://arxiv.org/abs/2508.01989) — SLO에 따라 집합·분리 모드를 동적으로 전환하는 통합 서빙; goodput 최대 77%↑
  - [MuxWise: Towards High-Goodput LLM Serving with Prefill-decode Multiplexing](https://arxiv.org/abs/2504.14489) — 레이어 단위 버블-없는 인트라-GPU P/D 다중화; SLO 보장 처리량 2.20×(최대 3.06×)↑
  - [DuetServe: Harmonizing Prefill and Decode for LLM Serving via Adaptive GPU Multiplexing](https://arxiv.org/abs/2511.04791) — 오염 예측 시 SM 수준 공간 다중화 활성화; Qwen3 기준 처리량 1.3×↑

  **B. KV 양자화·압축** (신규 — 2026-05-08 보고서)
  - [PackKV: Reducing KV Cache Memory Footprint through LLM-Aware Lossy Compression](https://arxiv.org/abs/2512.24449) — 양자화·encode-aware repacking·비트 패킹 통합 손실 압축; GEMV 커널 내부 decompression 내장; K 75.6%·V 171.6% 처리량 향상 (IPDPS 2026)
  - [KV-CoRE: Benchmarking Data-Dependent Low-Rank Compressibility of KV-Caches in LLMs](https://arxiv.org/abs/2602.05929) — SVD 기반 KV 캐시 저랭크 압축성을 데이터-의존적으로 정량화; Key가 Value보다 일관되게 더 압축 가능
  - [Fast KV Compaction via Attention Matching](https://arxiv.org/abs/2602.16284) — 잠재 공간에서 어텐션 출력 재현하는 compact K/V 구성; 일부 데이터셋에서 50× 압축, 수 초 내 완료
  - [Sequential KV Cache Compression via Probabilistic Language Tries](https://arxiv.org/abs/2604.15356) — 확률적 prefix 중복 제거 + 예측 델타 코딩으로 벡터 단위 Shannon 한계를 돌파; 시퀀스 레벨 압축이론 적용

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

  **C. 토큰 축출·희소 어텐션** (신규 — 2026-05-08 보고서)
  - [AsyncTLS: Efficient Generative LLM Inference with Asynchronous Two-level Sparse Attention](https://arxiv.org/abs/2604.07815) — 블록 수준 필터링 + 토큰 수준 선택 2단 계층 + 비동기 CPU 오프로드; 48K~96K 컨텍스트 처리량 1.3~4.7×↑
  - [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) — Information Bottleneck 원리로 KV eviction 재형식화; CapKV(log-det 근사) 제안
  - [SinkRouter: Sink-Aware Routing for Efficient Long-Context Decoding](https://arxiv.org/abs/2604.16883) — Attention sink 고정점 이론화; sink 신호 감지로 near-zero 출력 연산 스킵; 512K 컨텍스트 2.03×↑
  - [Residual-Mass Accounting for Partial-KV Decoding](https://arxiv.org/abs/2604.05438) — KV 오프로드 환경에서 미검색 토큰 softmax 바이어스를 잔여 질량 추정으로 보정
  - [RetentiveKV: State-Space Memory for Uncertainty-Aware Multimodal KV Cache Eviction](https://arxiv.org/abs/2605.04075) — 멀티모달 LLM 시각 토큰 "지연된 중요성" 문제를 SSM 기반 연속 메모리 진화로 해결; 5.0× KV 압축, 1.5× 디코딩 가속

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

  **D. 분산·분리 서빙 및 KV 전송** (신규 — 2026-05-08 보고서)
  - [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) — 2번째 턴 이후 append-prefill을 디코드 노드에서 직접 처리; Turn 2+ TTFT 68% 단축
  - [KEEP: A KV-Cache-Centric Memory Management System for Efficient Embodied Planning](https://arxiv.org/abs/2602.23592) — 에이전트 계획에서 KV 재계산 최소화; Static-Dynamic 메모리 구성 + Multi-hop 재계산 알고리즘

  **D. 분산·분리 서빙 및 KV 전송** (2026-05-04 보고서)
  - [Beluga: A CXL-Based Memory Architecture for Scalable and Efficient LLM KVCache Management](https://arxiv.org/abs/2511.20172) — CXL 2.0 스위치 공유 메모리 풀; RDMA 대비 읽기 지연 7.0×↓, TTFT 89.6%↓, 처리량 7.35×↑ (SIGMOD 2025)
  - [Theoretically Optimal Attention/FFN Ratios in Disaggregated LLM Serving](https://arxiv.org/abs/2601.21351) — AFD 아키텍처 최적 A/F 비율 closed-form 도출

  **D. 분산·분리 서빙 및 KV 전송** (이전 보고서)
  - [Mooncake](https://arxiv.org/abs/2407.00079) — KV 중심 분리 아키텍처; 처리량 525%↑ (FAST 2025 Best Paper)
  - [Prefill-as-a-Service](https://arxiv.org/abs/2604.15039) — 크로스 데이터센터 P/D 분리; 처리량 54%↑, P90 TTFT 64%↓
  - [TraCT](https://arxiv.org/abs/2512.18194) — CXL 공유 메모리 KV 풀; TTFT 9.8×↓

  **E. 아키텍처 수준 KV 절감** (신규 — 2026-05-08 보고서)
  - [CARE: Covariance-Aware and Rank-Enhanced Decomposition for Enabling Multi-Head Latent Attention](https://arxiv.org/abs/2603.17946) — 사전 학습된 GQA 모델을 MLA로 변환; 공분산 가중 분해 + 에너지-driven 레이어별 랭크 할당; 균일 랭크 SVD 대비 perplexity 최대 215× 감소

  **E. 아키텍처 수준 KV 절감** (2026-05-04 보고서)
  - [MoE-MLA-RoPE: Unifying Mixture of Experts and MLA for Efficient Language Models](https://arxiv.org/abs/2508.01261) — MoE+MLA 결합으로 68% KV 절감, 3.2× 추론 가속 (KDD 2025 Workshop)
  - [TPLA: Tensor Parallel Latent Attention for Efficient Disaggregated Prefill and Decode Inference](https://arxiv.org/abs/2508.15881) — 텐서 병렬 환경에서 MLA 이점 보존; DeepSeek-V3·Kimi-K2 1.79~1.93×↑
  - [MHA2MLA-VLM: Enabling DeepSeek's MLA across Vision-Language Models](https://arxiv.org/abs/2601.11464) — 시각·텍스트 KV 독립 저랭크 압축; LLaVA-1.5/NeXT, Qwen2.5-VL 적용

  **E. 아키텍처 수준 KV 절감** (이전 보고서)
  - [DeepSeek-V2 (MLA)](https://arxiv.org/abs/2405.04434) — KV 93.3%↓, 처리량 5.76×↑
  - [TransMLA](https://arxiv.org/abs/2502.07864) — GQA→MLA 사후 변환; KV 68.75%↓, 추론 10.6×↑ (NeurIPS 2025 Spotlight)
  - [TPA](https://arxiv.org/abs/2501.06425) — 텐서 분해 어텐션; KV 10×↓ (NeurIPS 2025 Spotlight)

  **F. 장문맥·오프로딩** (신규 — 2026-05-08 보고서)
  - [HybridGen: Efficient LLM Generative Inference via CPU-GPU Hybrid Computing](https://arxiv.org/abs/2604.18529) — CXL 확장 메모리를 활용한 CPU-GPU 협력 어텐션; 6개 SOTA KV 관리 기법 대비 1.41×↑
  - [Beyond Speedup — Utilizing KV Cache for Sampling and Reasoning](https://arxiv.org/abs/2601.20326) — KV 캐시를 의미론적 표현으로 재해석; Chain-of-Embedding·Fast/Slow Thinking Switch; DeepSeek-R1-Distil-Qwen-14B에서 토큰 생성 최대 5.7× 감소

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
