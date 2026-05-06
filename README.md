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
_마지막 업데이트: 2026-05-06 · 보고서 5개 · 논문 152편 · Deep-dive 1건_

### 📂 LLM 추론 KV 캐시 관리·최적화
- Latest: [kv-cache-optimization-2026-05-06](reports/kv-cache-optimization-2026-05-06.md)
- 주요 논문:

  **A. 서빙 시스템·메모리 관리**
  - [SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters](https://arxiv.org/abs/2605.00528) — 에이전트 워크플로우 전체를 스케줄 단위로 삼아 Agent Execution Graph 기반 KV 재사용 예측; Bélády 1.31× 이내
  - [GhostServe: A Lightweight Checkpointing System in the Shadow for Fault-Tolerant LLM Serving](https://arxiv.org/abs/2605.00831) — Erasure coding으로 KV 캐시 패리티 샤드를 호스트 메모리에 유지; 복구 지연 2.7× 감소
  - [SpecKV: Adaptive Speculative Decoding with Compression-Aware Gamma Selection](https://arxiv.org/abs/2605.02888) — KV 압축 수준에 따라 speculation length γ를 단계별로 동적 선택; 고정 γ=4 대비 56.0% 개선
  - [AdaptCache: KV Cache Native Storage Hierarchy for Low-Delay and High-Quality Language Model Serving](https://arxiv.org/abs/2509.00105) — 각 KV 항목별 압축 알고리즘·비율·배치 장치 동적 결정; KIVI 대비 TTFT 69%↓, 정적 기준선 대비 1.43~2.4× 지연 절감
  - [Revisiting Disaggregated Large Language Model Serving for Performance and Energy Implications](https://arxiv.org/abs/2601.08833) — P/D 분리 성능 이점이 요청 부하·KV 전송 매체에 따라 보장되지 않으며 에너지 소비가 더 높을 수 있음을 DVFS 프로파일링으로 실증
  - [TaiChi: Prefill-Decode Aggregation or Disaggregation?](https://arxiv.org/abs/2508.01989) — SLO에 따라 집합·분리 모드를 동적으로 전환하는 통합 서빙; goodput 최대 77%↑
  - [MuxWise: Towards High-Goodput LLM Serving with Prefill-decode Multiplexing](https://arxiv.org/abs/2504.14489) — 레이어 단위 버블-없는 인트라-GPU P/D 다중화; SLO 보장 처리량 2.20×(최대 3.06×)↑
  - [DuetServe: Harmonizing Prefill and Decode for LLM Serving via Adaptive GPU Multiplexing](https://arxiv.org/abs/2511.04791) — 오염 예측 시 SM 수준 공간 다중화 활성화; Qwen3 기준 처리량 1.3×↑
  - [Understand and Accelerate Memory Processing Pipeline for Disaggregated LLM Inference](https://arxiv.org/abs/2603.29002) — 4단계 메모리 처리 파이프라인 통일 모델 + GPU-FPGA 이종 처리; 1.04~2.2×↑, 에너지 1.11~4.7×↓
  - [vLLM V1: A Major Upgrade to vLLM's Core Architecture](https://blog.vllm.ai/2025/01/27/v1-alpha-release.html) — KV 관리자·스케줄러·워커 전면 재설계; CPU 오프로딩, FP8·TurboQuant 2-bit KV, 멀티모달 prefix caching 통합
  - [SGLang HiCache: Fast Hierarchical KV Caching](https://www.lmsys.org/blog/2025-09-10-sglang-hicache/) — RadixAttention을 GPU(L1)·CPU(L2)·분산 스토리지(L3) 3계층으로 확장; TTFT 80%↓, 처리량 6×↑
  - [CacheFlow: Efficient LLM Serving with 3D-Parallel KV Cache Restoration](https://arxiv.org/abs/2604.25080) — 토큰·레이어·GPU 3차원 병렬 KV 복원; 배치 인식 투포인터 스케줄러로 TTFT 10~62%↓

  **B. KV 양자화·압축**
  - [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs Inference Optimization](https://arxiv.org/abs/2605.02262) — VLM 시각 토큰 윈도우 단위 유사도 기반 혼합 정밀도 양자화; 관련 윈도우는 고정밀도, 무관 윈도우는 초저비트로 압축
  - [VQKV: High-Fidelity and High-Ratio Cache Compression via Vector-Quantization](https://arxiv.org/abs/2603.16435) — Training-free VQ 기반 압축; LLaMA3.1-8B에서 82.8% 압축비 + LongBench 98.6% 성능 유지, 4.3× 생성 길이 확장
  - [Sequential KV Cache Compression via Probabilistic Language Tries: Beyond the Per-Vector Shannon Limit](https://arxiv.org/abs/2604.15356) — Probabilistic Language Trie 기반 시퀀스 단위 압축; per-vector Shannon 한계를 넘는 이론적 프레임워크 및 예측 델타 코딩 제시
  - [R-KV: Redundancy-aware KV Cache Compression for Reasoning Models](https://arxiv.org/abs/2505.24133) — 추론 모델 전용 중복 토큰 인식 KV 압축; 캐시 10% 예산에서 풀 캐시 성능 거의 유지, 90% 메모리 절감·6.6× 처리량
  - [TailorKV: A Hybrid Framework for Long-Context Inference via Tailored KV Cache Optimization](https://arxiv.org/abs/2505.19586) — 레이어별 양자화 친화성/희소성 친화성 분류 후 혼합 전략 적용; 128K-context Llama-3.1-8B RTX 3090 단일 GPU로 82 ms 디코딩, 53.7% GPU 메모리 절감
  - [TurboQuant: Online Vector Quantization with Near-optimal Distortion Rate](https://arxiv.org/abs/2504.19874) — 랜덤 직교 회전 + QJL 잔차로 3-bit 벡터 양자화; KV 6×↓, H100 기준 어텐션 8×↑ (ICLR 2026)
  - [Don't Waste Bits! Adaptive KV-Cache Quantization for Lightweight On-Device LLMs](https://arxiv.org/abs/2604.04722) — 경량 컨트롤러로 {2,4,8-bit,FP16} 동적 선택; 정적 양자화 대비 지연 17.75%↓, 정확도 7.6점↑
  - [OjaKV: Context-Aware Online Low-Rank KV Cache Compression with Oja's Rule](https://arxiv.org/abs/2509.21623) — Oja 온라인 PCA로 압축 기저 지속 갱신; 정적 SVD 기법 AIME25 0% vs. OjaKV 13% 정확도 유지
  - [Cocktail: Chunk-Adaptive Mixed-Precision Quantization for Long-Context LLM Inference](https://arxiv.org/abs/2503.23294) — 쿼리-청크 유사도 기반 비트폭 동적 선택 + 청크 재정렬; 장문맥 LLM 추론 SOTA 초과 (DATE 2025)
  - [ARKV: Adaptive and Resource-Efficient KV Cache Management under Limited Memory Budget](https://arxiv.org/abs/2603.08727) — 레이어별 OQ 비율 추정 + 토큰별 3-상태 관리; 4× 메모리 절감에서 기준선 97% 정확도 유지
  - [EchoKV: Efficient KV Cache Compression via Similarity-Based Reconstruction](https://arxiv.org/abs/2603.22910) — 인터/인트라 레이어 헤드 유사도 활용 경량 재구성 네트워크; 7B 모델 ~1 A100 GPU-시간 학습
  - [RotateKV: Accurate and Robust 2-Bit KV Cache Quantization via Outlier-Aware Adaptive Rotations](https://arxiv.org/abs/2501.16383) — 채널 재정렬 아웃라이어 인식 FWHT 회전; 2-bit PPL 저하 0.3↓
  - [KIVI](https://arxiv.org/abs/2402.02750) — 파인튜닝 없는 비대칭 2-bit KV 양자화; 메모리 2.6×↓ (ICML 2024)

  **C. 토큰 축출·희소 어텐션**
  - [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective (CapKV)](https://arxiv.org/abs/2604.25975) — Information Bottleneck 원리 기반 KV 용량 최대화 목적함수 도출; leverage score 기반 CapKV가 기존 휴리스틱 eviction 통합 해석 및 성능 상회
  - [How Much Cache Does Reasoning Need? Depth-Cache Tradeoffs in KV-Compressed Transformers](https://arxiv.org/abs/2604.17935) — k-hop pointer chasing 모델로 KV 압축 추론 능력의 이론적 하한·상한 도출; 압축 한계와 추론 깊이 트레이드오프 정량화
  - [Self-Indexing KVCache: Predicting Sparse Attention from Compressed Keys](https://arxiv.org/abs/2603.14224) — 1-bit VQ 기반 부호화로 희소 어텐션 예측과 양자화를 단일 CUDA 커널에 통합; 메모리 절감·속도·정밀도 동시 달성 (AAAI 2026)
  - [SAGE-KV: LLMs Know What to Drop](https://arxiv.org/abs/2503.08879) — 프리필 후 1회 top-k 선택(토큰+헤드); StreamLLM 대비 4× 메모리 효율 (ICLR 2025)
  - [SentenceKV: Efficient LLM Inference via Sentence-Level Semantic KV Caching](https://arxiv.org/abs/2504.00970) — 문장 수준 시맨틱 벡터 GPU 유지 + 개별 KV CPU 오프로드 (COLM 2025)
  - [LycheeCluster: Efficient Long-Context Inference with Structure-Aware Chunking and Hierarchical KV Indexing](https://arxiv.org/abs/2603.08453) — 계층 인덱스로 KV 검색 O(log n) 단축; 풀 어텐션 대비 3.6×↑
  - [SemantiCache: Efficient KV Cache Compression via Semantic Chunking and Clustered Merging](https://arxiv.org/abs/2603.14303) — GSC 클러스터 병합 + 비례 어텐션 재균형; 디코딩 2.61×↑
  - [DynSplit-KV: Dynamic Semantic Splitting for KVCache Compression](https://arxiv.org/abs/2602.03184) — 동적 의미 경계 분할; FlashAttention 대비 2.2×↑, 메모리 2.6×↓
  - [IceCache: Memory-efficient KV-cache Management for Long-Sequence LLMs](https://arxiv.org/abs/2604.10539) — 시맨틱 토큰 클러스터링 DCI-tree + ANN 페이지 선택
  - [AnDPro](https://arxiv.org/abs/2509.18143) — Value 벡터 앵커 방향 투영 기반 토큰 중요도; LongBench 96.07% 정확도, 3.44% 예산 (NeurIPS 2025)
  - [FreeKV: Boosting KV Cache Retrieval for Efficient LLM Inference](https://arxiv.org/abs/2505.13109) — 투기적 검색 + 하이브리드 CPU/GPU 레이아웃; SOTA 대비 13×↑
  - [ForesightKV](https://arxiv.org/abs/2602.03203) — RL 기반 장기 기여도 예측; AIME 절반 예산에서 SOTA 초과
  - [TriAttention: Efficient Long Reasoning with Trigonometric KV Compression](https://arxiv.org/abs/2604.04921) — pre-RoPE Q/K 집중도 삼각함수 모델로 KV 중요도 추정; AIME25 10.7× KV 절감, 2.5×↑

  **D. 분산·분리 서빙 및 KV 전송**
  - [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) — Append-prefill은 decode node에 로컬 처리, Full-prefill만 prefill node로 라우팅하는 PPD 분리; 멀티턴 SLO 동시 충족
  - [Efficient Multi-round LLM Inference over Disaggregated Serving (AMPD)](https://arxiv.org/abs/2602.14516) — 멀티라운드 증분 prefill 워크로드 적응형 라우팅으로 SLO 달성률 67.3~339.7% 향상
  - [Beluga: A CXL-Based Memory Architecture for Scalable and Efficient LLM KVCache Management](https://arxiv.org/abs/2511.20172) — CXL 2.0 스위치 공유 메모리 풀; RDMA 대비 읽기 지연 7.0×↓, TTFT 89.6%↓, 처리량 7.35×↑ (SIGMOD 2025)
  - [Theoretically Optimal Attention/FFN Ratios in Disaggregated LLM Serving](https://arxiv.org/abs/2601.21351) — AFD 아키텍처 최적 A/F 비율 closed-form 도출
  - [TokenDance: Scaling Multi-Agent LLM Serving via Collective KV Cache Sharing](https://arxiv.org/abs/2604.03143) — 멀티 에이전트 All-Gather 패턴 KV diff 공유; 11~17× 압축, vLLM 대비 2.7× 더 많은 동시 에이전트 지원
  - [Prefill-as-a-Service: KVCache of Next-Generation Models Could Go Cross-Datacenter](https://arxiv.org/abs/2604.15039) — 크로스 데이터센터 P/D 분리; 처리량 54%↑, P90 TTFT 64%↓
  - [Mooncake](https://arxiv.org/abs/2407.00079) — KV 중심 분리 아키텍처; 처리량 525%↑ (FAST 2025 Best Paper)
  - [TraCT](https://arxiv.org/abs/2512.18194) — CXL 공유 메모리 KV 풀; TTFT 9.8×↓

  **E. 아키텍처 수준 KV 절감**
  - [Stochastic KV Routing: Enabling Adaptive Depth-Wise Cache Sharing](https://arxiv.org/abs/2604.22782) — 훈련 중 랜덤 크로스레이어 어텐션으로 depth-wise KV 공유에 강건한 모델 학습; 대형 데이터 제한 환경에서 정규화 효과로 성능 유지 또는 향상 (Apple)
  - [Unifying MoE and MLA for Efficient Language Models (MoE-MLA-RoPE)](https://arxiv.org/abs/2508.01261) — MoE+MLA 결합으로 68% KV 절감, 3.2× 추론 가속 (KDD 2025 Workshop)
  - [TPLA: Tensor Parallel Latent Attention for Efficient Disaggregated Prefill and Decode Inference](https://arxiv.org/abs/2508.15881) — 텐서 병렬 환경에서 MLA 이점 보존; DeepSeek-V3·Kimi-K2 1.79~1.93×↑
  - [MHA2MLA-VLM: Enabling DeepSeek's MLA across Vision-Language Models](https://arxiv.org/abs/2601.11464) — 시각·텍스트 KV 독립 저랭크 압축; LLaVA-1.5/NeXT, Qwen2.5-VL 적용
  - [DeepSeek-V2 (MLA)](https://arxiv.org/abs/2405.04434) — KV 93.3%↓, 처리량 5.76×↑
  - [TransMLA](https://arxiv.org/abs/2502.07864) — GQA→MLA 사후 변환; KV 68.75%↓, 추론 10.6×↑ (NeurIPS 2025 Spotlight)
  - [TPA](https://arxiv.org/abs/2501.06425) — 텐서 분해 어텐션; KV 10×↓ (NeurIPS 2025 Spotlight)

  **F. 장문맥·계층적 오프로딩**
  - [TTKV: Temporal-Tiered KV Cache for Long-Context LLM Inference](https://arxiv.org/abs/2604.19769) — HBM(최근·고정밀도)·DRAM(과거·저정밀도) 이중 계층 + streaming attention; 교차 계층 트래픽 5.94× 감소, 지연 76% 절감
  - [DUAL-BLADE: Dual-Path NVMe-Direct KV-Cache Offloading for Edge LLM Inference](https://arxiv.org/abs/2604.26557) — Page-cache path와 NVMe-direct LBA-mapped path를 동적 선택; 엣지 환경 메모리 압박 시 파일시스템 우회로 예측 가능한 저지연 오프로딩
  - [Agent Memory Below the Prompt: Persistent Q4 KV Cache for Multi-Agent LLM Inference on Edge Devices](https://arxiv.org/abs/2603.04428) — 에이전트별 KV 캐시를 4-bit 양자화로 디스크 저장 후 복원; TTFT 최대 136× 감소, FP16 대비 4× 더 많은 에이전트 컨텍스트 수용
  - [KV Cache Offloading for Context-Intensive Tasks](https://arxiv.org/abs/2604.08426) — 고문맥 집약적 태스크(Text2JSON 벤치마크) 환경에서 KV 오프로딩 실증 분석; Llama 3·Qwen 3 모두 오프로딩 시 성능 저하 확인
  - [SparKV: Overhead-Aware KV Cache Loading for Efficient On-Device LLM Inference](https://arxiv.org/abs/2604.21231) — 클라우드 스트리밍 vs. 온디바이스 계산 동적 결정; TTFT 1.3~5.1×↓, 에너지 1.5~3.3×↓
  - [ShadowKV](https://arxiv.org/abs/2410.21465) — SVD K GPU + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑ (ICML 2025 Spotlight)
  - [KVSwap: Disk-aware KV Cache Offloading for Long-Context On-device Inference](https://arxiv.org/abs/2511.11907) — 디스크 특성 인식 KV 오프로딩 (MobiSys 2026)

  **G. RAG·평가 방법론**
  - [KV Cache Optimization Strategies for Scalable and Efficient LLM Inference](https://arxiv.org/abs/2603.20397) — 5개 방향 체계적 리뷰; 2026년 분야 지형도

  **H. 보안·프라이버시**
  - [Shadow in the Cache: Unveiling and Mitigating Privacy Risks of KV-cache in LLM Inference](https://arxiv.org/abs/2508.09442) — KV 역산·충돌·주입 3종 공격 + KV-Cloak 방어 (NDSS 2026)
  - [Selective KV-Cache Sharing to Mitigate Timing Side-Channels in LLM Inference (SafeKV)](https://arxiv.org/abs/2508.08438) — 타이밍 사이드채널 차단 선택적 KV 공유

- 관련 Deep-dive:
  - [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md)

### 🔬 Deep Dives
- [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md) — 멀티모달 LLM 추론에서 이미지·텍스트 KV 캐시를 위치(prefix) 제약 없이 디스크에 저장·재사용하면서, 이미지 토큰 앞부분의 anchor 토큰만 선택적으로 재계산해 정확도 손실은 최소화하고 TTFT는 최대 54.1% 줄이며 처리량을 약 2.0배 향상. (원문: [OpenReview](https://openreview.net/forum?id=bld5GVRad0))

<!-- END: AUTO-INDEX -->
