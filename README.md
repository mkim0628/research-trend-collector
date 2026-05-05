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
_마지막 업데이트: 2026-05-05 · 보고서 5개 · 논문 164편 · Deep-dive 1건_

### LLM KV 캐시 최적화
- Latest: [kv-cache-optimization-2026-05-05](reports/kv-cache-optimization-2026-05-05.md)
- 주요 논문:

  **A. 서빙 시스템·메모리 관리**
  - [PRESERVE: Prefetching Model Weights and KV-Cache in Distributed LLM Serving](https://arxiv.org/abs/2501.08192) — 통신 구간 중 모델 가중치·KV 캐시 동시 프리페치; E2E 1.6×↑ (Huawei Zurich)
  - [ShadowServe: Interference-Free KV Cache Fetching for Distributed Prefix Caching](https://arxiv.org/abs/2509.16857) — BlueField-3 SmartNIC에 KV 전송 데이터 플레인 완전 오프로드; TPOT 2.2×↓, TTFT 1.38×↓, 처리량 1.35×↑
  - [Efficient Remote Prefix Fetching with GPU-native Media ASICs (KVFetcher)](https://arxiv.org/abs/2602.09725) — GPU 내장 비디오 코덱으로 KV 비디오 포맷 인코딩·전송·디코딩; 대역폭 제한 환경에서 경쟁적 TTFT
  - [AdaptCache: KV Cache Native Storage Hierarchy for Low-Delay and High-Quality Language Model Serving](https://arxiv.org/abs/2509.00105) — KV 항목별 압축 알고리즘·비율·배치 장치 동적 결정; KIVI 대비 TTFT 69%↓
  - [Revisiting Disaggregated Large Language Model Serving for Performance and Energy Implications](https://arxiv.org/abs/2601.08833) — P/D 분리 성능 이점이 부하·전송 매체에 따라 보장되지 않으며 에너지 소비가 더 높을 수 있음을 DVFS 프로파일링으로 실증
  - [TaiChi: Prefill-Decode Aggregation or Disaggregation?](https://arxiv.org/abs/2508.01989) — SLO에 따라 집합·분리 모드를 동적으로 전환; goodput 최대 77%↑
  - [MuxWise: Towards High-Goodput LLM Serving with Prefill-decode Multiplexing](https://arxiv.org/abs/2504.14489) — 레이어 단위 버블-없는 인트라-GPU P/D 다중화; SLO 보장 처리량 2.20×(최대 3.06×)↑
  - [DuetServe: Harmonizing Prefill and Decode for LLM Serving via Adaptive GPU Multiplexing](https://arxiv.org/abs/2511.04791) — 오염 예측 시 SM 수준 공간 다중화 활성화; Qwen3 기준 처리량 1.3×↑
  - [Understand and Accelerate Memory Processing Pipeline for Disaggregated LLM Inference](https://arxiv.org/abs/2603.29002) — 4단계 메모리 처리 파이프라인 통일 모델 + GPU-FPGA 이종 처리; 1.04~2.2×↑, 에너지 1.11~4.7×↓

  **B. KV 양자화·압축**
  - [Accurate KV Cache Quantization with Outlier Tokens Tracing (OTT)](https://arxiv.org/abs/2505.10938) — Key 크기 기반 아웃라이어 토큰 동적 추적·FP16 유지; 2-bit에서 메모리 6.4×↓, 처리량 2.3×↑ (ACL 2025)
  - [KVCompose: Efficient Structured KV Cache Compression with Composite Tokens](https://arxiv.org/abs/2509.05165) — 헤드별 어텐션 가중치 기반 복합 토큰 집계 + 레이어별 적응 예산 (ICLR 2026 OpenReview)
  - [KVReviver: Reversible KV Cache Compression with Sketch-Based Token Reconstruction](https://arxiv.org/abs/2512.17917) — 스케치 자료구조로 압축 토큰 저장·재구성; 2k 길이 10% 메모리에서 풀 어텐션 동등
  - [KVComp: A High-Performance, LLM-Aware, Lossy Compression Framework for KV Cache](https://arxiv.org/abs/2509.00579) — 오차 제어 양자화 + GPU 기반 고처리량 엔트로피 코딩; SOTA 양자화 대비 압축률 83%↑
  - [KeepKV: Achieving Periodic Lossless KV Cache Compression for Efficient LLM Inference](https://arxiv.org/abs/2504.09936) — Electoral Votes 메커니즘으로 병합 기반 KV 압축; 10% KV 예산에서 처리량 2×↑ (AAAI 2026)
  - [PackKV: Reducing KV Cache Memory Footprint through LLM-Aware Lossy Compression](https://arxiv.org/abs/2512.24449) — 5단계 KV 전용 손실 압축 파이프라인; K 153.2%↑·V 179.6%↑ 압축률 (IPDPS 2026)
  - [DeltaKV: Residual-Based KV Cache Compression via Long-Range Similarity](https://arxiv.org/abs/2602.08005) — 전역 유사 참조 토큰 잔차 경량 MLP 인코딩; KV 29% 메모리에서 준무손실, Sparse-vLLM 엔진 2×↑
  - [DynaKV: One Size Does Not Fit All — Token-Wise Adaptive Compression for KV Cache](https://arxiv.org/abs/2603.04411) — 토큰별 의미에 따라 동적 저랭크 압축률 할당
  - [Sequential KV Cache Compression via Probabilistic Language Tries](https://arxiv.org/abs/2604.15356) — KV를 시퀀스로 보아 확률적 접두사 중복 제거; TurboQuant Shannon 한계 이론적 최대 900,000× 초과 가능성 도출
  - [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs](https://arxiv.org/abs/2605.02262) — VLM 시각 토큰 KV 윈도우 단위 비트폭 탐색 + 재정렬 하드웨어 효율화
  - [TurboQuant: Online Vector Quantization with Near-optimal Distortion Rate](https://arxiv.org/abs/2504.19874) — 랜덤 직교 회전 + QJL 잔차로 3-bit 벡터 양자화; KV 6×↓, H100 기준 어텐션 8×↑ (ICLR 2026)
  - [RotateKV: Accurate and Robust 2-Bit KV Cache Quantization via Outlier-Aware Adaptive Rotations](https://arxiv.org/abs/2501.16383) — 채널 재정렬 아웃라이어 인식 FWHT 회전; 2-bit PPL 저하 0.3↓
  - [AQUA-KV: Adaptive Key-Value Quantization for Large Language Models](https://arxiv.org/abs/2501.19392) — K–V 의존성 활용 적응형 어댑터; 2~2.5bit 무손실 (ICML 2025)
  - [KIVI: A Tuning-Free Asymmetric 2bit Quantization for KV Cache](https://arxiv.org/abs/2402.02750) — 파인튜닝 없는 비대칭 2-bit KV 양자화; 메모리 2.6×↓ (ICML 2024)
  - [Cocktail: Chunk-Adaptive Mixed-Precision Quantization for Long-Context LLM Inference](https://arxiv.org/abs/2503.23294) — 쿼리-청크 유사도 기반 비트폭 동적 선택 + 청크 재정렬 (DATE 2025)
  - [OjaKV: Context-Aware Online Low-Rank KV Cache Compression with Oja's Rule](https://arxiv.org/abs/2509.21623) — Oja 온라인 PCA로 압축 기저 지속 갱신; 정적 SVD 기법 AIME25 0% vs. OjaKV 13% 정확도 유지
  - [Don't Waste Bits! Adaptive KV-Cache Quantization for Lightweight On-Device LLMs](https://arxiv.org/abs/2604.04722) — 경량 컨트롤러로 {2,4,8-bit,FP16} 동적 선택; 지연 17.75%↓, 정확도 7.6점↑
  - [ARKV: Adaptive and Resource-Efficient KV Cache Management under Limited Memory Budget](https://arxiv.org/abs/2603.08727) — 레이어별 OQ 비율 추정 + 토큰별 3-상태 관리; 4× 메모리 절감에서 97% 정확도 유지
  - [EchoKV: Efficient KV Cache Compression via Similarity-Based Reconstruction](https://arxiv.org/abs/2603.22910) — 인터/인트라 레이어 헤드 유사도 활용 경량 재구성 네트워크

  **C. 토큰 축출·희소 어텐션**
  - [KVFlow: Efficient Prefix Caching for Accelerating LLM-Based Multi-Agent Workflows](https://arxiv.org/abs/2507.07400) — 에이전트 실행 그래프 추상화 + 워크플로 인식 KV 축출 + 겹침 KV 프리페치; SGLang HiCache 대비 1.83~2.19×↑ (NeurIPS 2025)
  - [Fast KVzip: Efficient and Accurate LLM Inference with Gated KV Eviction](https://arxiv.org/abs/2601.17668) — 저랭크 싱크 어텐션 게이트 훈련; KV 70% 축출 준무손실, 1 H100-시간 미만 학습
  - [Fast KV Compaction via Attention Matching](https://arxiv.org/abs/2602.16284) — attention 출력 재현 closed-form KV 컴팩션; 일부 데이터셋 50× 컴팩션을 수 초 안에 달성
  - [LASER-KV: Overcoming the Greedy Bias in KV-Cache Compression](https://arxiv.org/abs/2602.02199) — 블록 단위 누적 예산 + LSH 정확 회수로 그리디 편향 극복; Babilong 128k에서 최대 10%↑
  - [CapKV: Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) — Information Bottleneck + log-determinant 근사로 KV 정보 용량 최대화; 기존 방법들을 통합하는 이론적 원리 제시
  - [Inference-Time Hyper-Scaling with KV Cache Compression (DMS)](https://arxiv.org/abs/2506.05345) — KV 8× 압축으로 동일 컴퓨팅 예산 내 더 많은 토큰 생성; Qwen3-8B AIME24 +9.1점, LiveCodeBench +9.6점 (NeurIPS 2025)
  - [SAGE-KV: LLMs Know What to Drop — Self-Attention Guided KV Cache Eviction](https://arxiv.org/abs/2503.08879) — 프리필 후 1회 top-k 선택(토큰+헤드); StreamLLM 대비 4× 메모리 효율 (ICLR 2025)
  - [SentenceKV: Efficient LLM Inference via Sentence-Level Semantic KV Caching](https://arxiv.org/abs/2504.00970) — 문장 수준 시맨틱 벡터 GPU 유지 + 개별 KV CPU 오프로드 (COLM 2025)
  - [IceCache: Memory-efficient KV-cache Management for Long-Sequence LLMs](https://arxiv.org/abs/2604.10539) — 시맨틱 토큰 클러스터링 DCI-tree + ANN M-DCI 페이지 선택
  - [DynSplit-KV: Dynamic Semantic Splitting for KVCache Compression](https://arxiv.org/abs/2602.03184) — 동적 의미 경계 분할; FlashAttention 대비 2.2×↑, 메모리 2.6×↓
  - [SemantiCache: Efficient KV Cache Compression via Semantic Chunking and Clustered Merging](https://arxiv.org/abs/2603.14303) — GSC 클러스터 병합 + 비례 어텐션 재균형; 디코딩 2.61×↑
  - [LycheeCluster: Efficient Long-Context Inference with Structure-Aware Chunking and Hierarchical KV Indexing](https://arxiv.org/abs/2603.08453) — 계층 인덱스로 KV 검색 O(log n) 단축; 풀 어텐션 대비 3.6×↑
  - [Self-Indexing KVCache: Predicting Sparse Attention from Compressed Keys](https://arxiv.org/abs/2603.14224) — 1-bit VQ로 압축키에서 직접 top-k 검색; 별도 인덱스 불필요 (AAAI 2026)
  - [AnDPro: Accurate KV Cache Eviction via Anchor Direction Projection](https://arxiv.org/abs/2509.18143) — Value 벡터 앵커 방향 투영 기반 토큰 중요도; LongBench 96.07% 정확도, 3.44% 예산 (NeurIPS 2025)
  - [FreeKV: Boosting KV Cache Retrieval for Efficient LLM Inference](https://arxiv.org/abs/2505.13109) — 투기적 검색 + 하이브리드 CPU/GPU 레이아웃; SOTA 대비 13×↑
  - [ForesightKV](https://arxiv.org/abs/2602.03203) — RL 기반 장기 기여도 예측; AIME 절반 예산에서 SOTA 초과

  **D. 분산·분리 서빙 및 KV 전송**
  - [Beluga: A CXL-Based Memory Architecture for Scalable and Efficient LLM KVCache Management](https://arxiv.org/abs/2511.20172) — CXL 2.0 스위치 공유 메모리 풀; RDMA 대비 읽기 지연 7.0×↓, TTFT 89.6%↓, 처리량 7.35×↑ (SIGMOD 2025)
  - [Theoretically Optimal Attention/FFN Ratios in Disaggregated LLM Serving](https://arxiv.org/abs/2601.21351) — AFD 아키텍처 최적 A/F 비율 closed-form 도출
  - [Mooncake](https://arxiv.org/abs/2407.00079) — KV 중심 분리 아키텍처(Kimi 운영); 처리량 525%↑ (FAST 2025 Best Paper)
  - [Prefill-as-a-Service](https://arxiv.org/abs/2604.15039) — 크로스 데이터센터 P/D 분리; 처리량 54%↑, P90 TTFT 64%↓
  - [TraCT](https://arxiv.org/abs/2512.18194) — CXL 공유 메모리 KV 풀; TTFT 9.8×↓

  **E. 아키텍처 수준 KV 절감**
  - [PoD: Proximal Tokens over Distant Tokens — Compressing KV Cache via Inter-Layer Attention](https://arxiv.org/abs/2412.02252) — 근접 토큰 전체 KV 유지 + 원거리 토큰 레이어 간 Key 공유; KV 35%↓
  - [MoE-MLA-RoPE: Unifying Mixture of Experts and MLA for Efficient Language Models](https://arxiv.org/abs/2508.01261) — MoE+MLA 결합으로 68% KV 절감, 3.2× 추론 가속 (KDD 2025 Workshop)
  - [TPLA: Tensor Parallel Latent Attention for Efficient Disaggregated Prefill and Decode Inference](https://arxiv.org/abs/2508.15881) — 텐서 병렬 환경에서 MLA 이점 보존; DeepSeek-V3·Kimi-K2 1.79~1.93×↑
  - [MHA2MLA-VLM: Enabling DeepSeek's MLA across Vision-Language Models](https://arxiv.org/abs/2601.11464) — 시각·텍스트 KV 독립 저랭크 압축; LLaVA-1.5/NeXT, Qwen2.5-VL 적용
  - [DeepSeek-V2 (MLA)](https://arxiv.org/abs/2405.04434) — Multi-head Latent Attention; KV 93.3%↓, 처리량 5.76×↑
  - [TransMLA](https://arxiv.org/abs/2502.07864) — GQA→MLA 사후 변환; KV 68.75%↓, 추론 10.6×↑ (NeurIPS 2025 Spotlight)
  - [TPA](https://arxiv.org/abs/2501.06425) — 텐서 분해 어텐션; KV 10×↓ (NeurIPS 2025 Spotlight)

  **F. 장문맥·계층적 오프로딩**
  - [Agent Memory Below the Prompt: Persistent Q4 KV Cache for Multi-Agent LLM Inference on Edge Devices](https://arxiv.org/abs/2603.04428) — 에이전트별 4-bit KV 디스크 지속성 + 직접 적재; TTFT 최대 136×↓(Gemma 4K)
  - [SparKV: Overhead-Aware KV Cache Loading for Efficient On-Device LLM Inference](https://arxiv.org/abs/2604.21231) — 클라우드 스트리밍 vs. 온디바이스 계산 동적 결정; TTFT 1.3~5.1×↓, 에너지 1.5~3.3×↓
  - [ShadowKV](https://arxiv.org/abs/2410.21465) — SVD K GPU + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑ (ICML 2025 Spotlight)
  - [KVSwap: Disk-aware KV Cache Offloading for Long-Context On-device Inference](https://arxiv.org/abs/2511.11907) — 스토리지 특성별(NVMe/eMMC) 예측 사전적재 + 재사용 버퍼 (MobiSys 2026)
  - [Dual-Blade: Dual-Path NVMe-Direct KV-Cache Offloading for Edge LLM Inference](https://arxiv.org/abs/2604.26557) — NVMe-Direct 이중 경로 + 적응 파이프라인; prefill 33.1%↓, decode 42.4%↓

  **G. RAG·평가 방법론**
  - [KVCache Cache in the Wild: Characterizing and Optimizing KVCache at a Large Cloud Provider](https://arxiv.org/abs/2506.02634) — Alibaba Cloud 대규모 KV 캐시 워크로드 최초 체계적 특성화; 워크로드 인식 축출 정책 제안 (USENIX ATC 2025)
  - [A Survey on Large Language Model Acceleration based on KV Cache Management](https://arxiv.org/abs/2412.19442) — 토큰·모델·시스템 수준 KV 관리 3계층 분류 종합 서베이; 2025년 7월까지 업데이트 (ICLR 2026 Workshop)
  - [KV Cache Optimization Strategies for Scalable and Efficient LLM Inference](https://arxiv.org/abs/2603.20397) — 5개 방향 체계적 리뷰; 2026년 분야 지형도

  **H. 보안·프라이버시 및 에이전트 특화 KV 관리**
  - [LRAgent: Efficient KV Cache Sharing for Multi-LoRA LLM Agents](https://arxiv.org/abs/2602.01053) — 공유 기반 KV + 어댑터 KV 저랭크 별도 저장 + Flash-LoRA-Attention 커널
  - [FASTLIBRA / ELORA: Improving Multi-LoRA LLM Serving via Efficient LoRA and KV Cache Management](https://arxiv.org/abs/2505.03756) — LoRA-KV 의존성 인식 통합 캐싱 풀; vLLM 대비 TTFT 63%↓
  - [SideQuest: Model-Driven KV Cache Management for Long-Horizon Agentic Reasoning](https://arxiv.org/abs/2602.22603) — LRM 자기 참조 보조 작업으로 KV 관리; 에이전트 라운드 간 시간적 중요도 변화에 적응
  - [KEEP: A KV-Cache-Centric Memory Management System for Efficient Embodied Planning](https://arxiv.org/abs/2602.23592) — 정적-동적 메모리 혼합 세분화로 KV 재계산 감소 (Microsoft Research)
  - [CodeComp: Structural KV Cache Compression for Agentic Coding](https://arxiv.org/abs/2604.10235) — Joern 코드 속성 그래프(CPG) 기반 구조적 중요 스팬 보호; SGLang 통합
  - [Shadow in the Cache: Unveiling and Mitigating Privacy Risks of KV-cache in LLM Inference](https://arxiv.org/abs/2508.09442) — KV 역산·충돌·주입 3종 공격 + KV-Cloak 방어 (NDSS 2026)
  - [Selective KV-Cache Sharing to Mitigate Timing Side-Channels in LLM Inference (SafeKV)](https://arxiv.org/abs/2508.08438) — 타이밍 사이드채널 차단 선택적 KV 공유

- 관련 Deep-dive:
  - [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md)

### Deep Dives
- [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md) — 멀티모달 LLM 추론에서 이미지·텍스트 KV 캐시를 위치(prefix) 제약 없이 디스크에 저장·재사용하면서, 이미지 토큰 앞부분의 anchor 토큰만 선택적으로 재계산해 정확도 손실은 최소화하고 TTFT는 최대 54.1% 줄이며 처리량을 약 2.0배 향상. (원문: [OpenReview](https://openreview.net/forum?id=bld5GVRad0))

<!-- END: AUTO-INDEX -->
