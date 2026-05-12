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
_마지막 업데이트: 2026-05-12 · 보고서 5개 · 논문 176편 · Deep-dive 1건_

### LLM 추론 KV 캐시 관리·최적화
- Latest: [kv-cache-optimization-2026-05-12](reports/kv-cache-optimization-2026-05-12.md)
- 주요 논문:

  **A. 서빙 시스템·메모리 관리** (신규 — 2026-05-12 보고서)
  - [Fluxion: An Efficient Hybrid Sparse Attention with CPU-GPU Parallelism for Long-Context Inference](https://arxiv.org/abs/2605.07719) — 출력-인식 KV 예산 할당 + CPU-GPU 협력 실행; CPU 상주 KV 처리에서 1.5~3.7× 가속
  - [Shadow Mask Distillation for Memory-Efficient Alignment](https://arxiv.org/abs/2605.06850) — RL 롤아웃 시 KV 압축이 유발하는 off-policy 편향 문제 발견; Shadow Mask Distillation로 정책 불일치 교정
  - [Predictive Multi-Tier Memory Management for KV Cache in Large-Scale GPU Inference](https://arxiv.org/abs/2604.26968) — MHA/GQA/MQA/MLA 통합 KV 크기 정확 계산 엔진; 최대 7.4× 배치 크기 향상

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
  - [Prefill-as-a-Service: KVCache of Next-Generation Models Could Go Cross-Datacenter](https://arxiv.org/abs/2604.15039) — 크로스 데이터센터 P/D 분리; Ethernet 기반 KVCache 전송; 처리량 54%↑, P90 TTFT 64%↓
  - [TokenDance: Scaling Multi-Agent LLM Serving via Collective KV Cache Sharing](https://arxiv.org/abs/2604.03143) — 멀티 에이전트 All-Gather 패턴 KV diff 공유; 11~17× 압축, vLLM 대비 2.7× 더 많은 동시 에이전트 지원
  - [CacheFlow: Efficient LLM Serving with 3D-Parallel KV Cache Restoration](https://arxiv.org/abs/2604.25080) — 토큰·레이어·GPU 3차원 병렬 KV 복원; TTFT 10~62%↓

  **B. KV 양자화·압축** (신규 — 2026-05-12 보고서)
  - [RateQuant: Optimal Mixed-Precision KV Cache Quantization via Rate-Distortion Theory](https://arxiv.org/abs/2605.06675) — Rate-Distortion 역 워터필링으로 헤드별 최적 비트 배분 closed-form 도출; Qwen3-8B KIVI PPL 49.3→14.9 (70%↓)
  - [eOptShrinkQ: Near-Lossless KV Cache Compression Through Optimal Spectral Denoising and Quantization](https://arxiv.org/abs/2605.02905) — KV 캐시를 저랭크 공유 컨텍스트 + 풀랭크 잔차로 분해; eOptShrink + TurboQuant 2단계 파이프라인
  - [When Quantization Is Free: An int4 KV Cache That Outruns fp16 on Apple Silicon](https://arxiv.org/abs/2605.05699) — Metal 커널에서 부호 임의화 FFT + int4 패킹 융합; fp16 대비 3× 메모리 절감, fp16보다 빠른 실행
  - [HeadQ: Model-Visible Distortion and Score-Space Correction for KV-Cache Quantization](https://arxiv.org/abs/2605.03562) — 모델-가시적 좌표계에서 오류 측정; 키의 경우 저랭크 잔차 사이드 코드를 로짓 교정으로 적용
  - [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs](https://arxiv.org/abs/2605.02262) — 비디오 LM 시각 토큰 윈도우-텍스트 유사도 기반 비트폭 동적 선택; 토큰 단위 방법 대비 하드웨어 효율 개선

  **B. KV 양자화·압축** (2026-05-04 보고서)
  - [Cocktail: Chunk-Adaptive Mixed-Precision Quantization for Long-Context LLM Inference](https://arxiv.org/abs/2503.23294) — 쿼리-청크 유사도 기반 비트폭 동적 선택 + 청크 재정렬; 장문맥 LLM 추론 SOTA 초과 (DATE 2025)
  - [OjaKV: Context-Aware Online Low-Rank KV Cache Compression with Oja's Rule](https://arxiv.org/abs/2509.21623) — Oja 온라인 PCA로 압축 기저 지속 갱신; 정적 SVD 기법 AIME25 0% vs. OjaKV 13% 정확도 유지
  - [Don't Waste Bits! Adaptive KV-Cache Quantization for Lightweight On-Device LLMs](https://arxiv.org/abs/2604.04722) — 경량 컨트롤러로 {2,4,8-bit,FP16} 동적 선택; 정적 양자화 대비 지연 17.75%↓, 정확도 7.6점↑
  - [ARKV: Adaptive and Resource-Efficient KV Cache Management under Limited Memory Budget](https://arxiv.org/abs/2603.08727) — 레이어별 OQ 비율 추정 + 토큰별 3-상태 관리; 4× 메모리 절감에서 기준선 97% 정확도 유지
  - [EchoKV: Efficient KV Cache Compression via Similarity-Based Reconstruction](https://arxiv.org/abs/2603.22910) — 인터/인트라 레이어 헤드 유사도 활용 경량 재구성 네트워크; 7B 모델 ~1 A100 GPU-시간 학습

  **B. KV 양자화·압축** (2026-05-03 보고서)
  - [TurboQuant: Online Vector Quantization with Near-optimal Distortion Rate](https://arxiv.org/abs/2504.19874) — 랜덤 직교 회전 + QJL 잔차로 3-bit 벡터 양자화; KV 6×↓, H100 기준 어텐션 8×↑ (ICLR 2026)
  - [TriAttention: Efficient Long Reasoning with Trigonometric KV Compression](https://arxiv.org/abs/2604.04921) — pre-RoPE Q/K 집중도 삼각함수 모델로 KV 중요도 추정; AIME25 10.7× KV 절감, 2.5×↑
  - [PolyKV: A Shared Asymmetrically-Compressed KV Cache Pool for Multi-Agent LLM Inference](https://arxiv.org/abs/2604.24971) — K int8 + V TurboQuant 3-bit 풀 공유; 15 에이전트 KV 97.7%↓

  **B. KV 양자화·압축** (2026-05-02 보고서)
  - [RotateKV: Accurate and Robust 2-Bit KV Cache Quantization via Outlier-Aware Adaptive Rotations](https://arxiv.org/abs/2501.16383) — 채널 재정렬 아웃라이어 인식 FWHT 회전; 2-bit PPL 저하 0.3↓ (LLaMA-2-13B)
  - [AQUA-KV: Adaptive Key-Value Quantization for Large Language Models](https://arxiv.org/abs/2501.19392) — K–V 의존성 활용 적응형 어댑터; 2~2.5bit에서 perplexity 상대 오차 1% 미만 (ICML 2025)
  - [KVzap: Fast, Adaptive, and Faithful KV Cache Pruning](https://arxiv.org/abs/2601.07891) — KVzip 경량 근사 + 입력 밀도 적응 임계치; KVpress 리더보드 2~4× 압축 SOTA

  **B. KV 양자화·압축** (2026-04-30 보고서)
  - [KIVI](https://arxiv.org/abs/2402.02750) — 파인튜닝 없는 비대칭 2-bit KV 양자화; 메모리 2.6×↓ (ICML 2024)
  - [KVTuner](https://arxiv.org/abs/2502.04420) — 레이어별 민감도 분석 혼합 정밀도; 3.25-bit에서 거의 무손실 (ICML 2025)
  - [Palu](https://arxiv.org/abs/2407.21118) — KV 프로젝션 SVD 저랭크 분해; 50% 압축 1.89×, 양자화 결합 2.91×↑ (ICLR 2025)
  - [KVTC](https://arxiv.org/abs/2511.01815) — PCA + 적응 양자화 + 엔트로피 코딩; 최대 20×(특수 용도 40×) 압축 (ICLR 2026)

  **C. 토큰 축출·희소 어텐션** (신규 — 2026-05-12 보고서)
  - [LaProx: Reformulating KV Cache Eviction Problem for Long-Context LLM Inference](https://arxiv.org/abs/2605.07234) — 축출 문제를 레이어별 행렬 곱 근사로 재정의; 최초 전역 비교 가능 중요도 점수; LongBench 5% KV 캐시로 SOTA
  - [LKV: End-to-End Learning of Head-wise Budgets and Token Selection for LLM KV Cache Eviction](https://arxiv.org/abs/2605.06676) — KV 압축을 엔드-투-엔드 미분 가능 최적화 문제로 재정의; LongBench·RULER 15% KV 유지로 준손실 없는 성능
  - [Louver: Sparse Attention as a Range Searching Problem](https://arxiv.org/abs/2605.06763) — 희소 어텐션을 반공간 범위 탐색으로 재정의; 이론적·실험적 제로 false negative 보장
  - [MISA: Mixture of Indexer Sparse Attention for Long-Context LLM Inference](https://arxiv.org/abs/2605.07363) — DeepSeek DSA 인덱서 헤드를 MoE 풀로 처리; 경량 라우터로 활성 헤드 소수만 선택, 인덱서 비용 대폭 절감

  **C. 토큰 축출·희소 어텐션** (2026-05-04 보고서)
  - [SAGE-KV: LLMs Know What to Drop](https://arxiv.org/abs/2503.08879) — 프리필 후 1회 top-k 선택(토큰+헤드); StreamLLM 대비 4× 메모리 효율 (ICLR 2025)
  - [SentenceKV: Efficient LLM Inference via Sentence-Level Semantic KV Caching](https://arxiv.org/abs/2504.00970) — 문장 수준 시맨틱 벡터 GPU 유지 + 개별 KV CPU 오프로드 (COLM 2025)
  - [IceCache: Memory-efficient KV-cache Management for Long-Sequence LLMs](https://arxiv.org/abs/2604.10539) — 시맨틱 토큰 클러스터링 DCI-tree + ANN 페이지 선택
  - [DynSplit-KV: Dynamic Semantic Splitting for KVCache Compression](https://arxiv.org/abs/2602.03184) — 동적 의미 경계 분할; FlashAttention 대비 2.2×↑, 메모리 2.6×↓
  - [SemantiCache: Efficient KV Cache Compression via Semantic Chunking and Clustered Merging](https://arxiv.org/abs/2603.14303) — GSC 클러스터 병합 + 비례 어텐션 재균형; 디코딩 2.61×↑
  - [LycheeCluster: Efficient Long-Context Inference with Structure-Aware Chunking and Hierarchical KV Indexing](https://arxiv.org/abs/2603.08453) — 계층 인덱스로 KV 검색 O(log n) 단축; 풀 어텐션 대비 3.6×↑
  - [Self-Indexing KVCache: Predicting Sparse Attention from Compressed Keys](https://arxiv.org/abs/2603.14224) — 1-bit VQ로 압축키에서 직접 top-k 검색; 별도 인덱스 불필요 (AAAI 2026)

  **C. 토큰 축출·희소 어텐션** (2026-05-03 보고서)
  - [AnDPro: Accurate KV Cache Eviction via Anchor Direction Projection](https://arxiv.org/abs/2509.18143) — Value 벡터 앵커 방향 투영 기반 토큰 중요도; LongBench 96.07% 정확도, 3.44% 예산 (NeurIPS 2025)
  - [FreeKV: Boosting KV Cache Retrieval for Efficient LLM Inference](https://arxiv.org/abs/2505.13109) — 투기적 검색 + 하이브리드 CPU/GPU 레이아웃; SOTA KV 검색 대비 13×↑

  **C. 토큰 축출·희소 어텐션** (2026-05-02 보고서)
  - [OBCache: Optimal Brain KV Cache Pruning for Efficient Long-Context LLM Inference](https://arxiv.org/abs/2510.07651) — OBD 이론 적용; K·V·KV 쌍 토큰 현저성 closed-form 점수, 어텐션 출력 섭동 최소화
  - [Lethe: Layer- and Time-Adaptive KV Cache Pruning for Reasoning-Intensive LLM Serving](https://arxiv.org/abs/2511.06029) — 레이어별 희소성 인식 예산 + RASR 시간 적응; Full Cache 대비 KV 91.7%↓, 처리량 2.56×↑
  - [KV Policy / KVP: Learning to Evict from Key-Value Cache](https://arxiv.org/abs/2602.10238) — 헤드별 경량 RL 에이전트; 생성 트레이스에서 미래 유용성 학습; RULER·LongBench 제로샷 일반화

  **C. 토큰 축출·희소 어텐션** (2026-04-30 보고서)
  - [ForesightKV](https://arxiv.org/abs/2602.03203) — RL 기반 장기 기여도 예측 축출; AIME 절반 예산에서 SOTA 초과
  - [Quest](https://arxiv.org/abs/2406.10774) — 쿼리 인식 KV 페이지 선택; 추론 지연 7.03×↓ (ICML 2024)
  - [MInference](https://arxiv.org/abs/2407.02490) — 동적 희소 프리필 어텐션; 1M 토큰 추론 30분→3분 (NeurIPS 2024)

  **D. 분산·분리 서빙 및 KV 전송** (신규 — 2026-05-12 보고서)
  - [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) — Turn 2+ append-prefill이 full-prefill보다 디코딩 방해 훨씬 적음; KV 상태 재사용 동적 라우팅으로 Turn 2+ TTFT 68%↓

  **D. 분산·분리 서빙 및 KV 전송** (2026-05-04 보고서)
  - [Beluga: A CXL-Based Memory Architecture for Scalable and Efficient LLM KVCache Management](https://arxiv.org/abs/2511.20172) — CXL 2.0 스위치 공유 메모리 풀; RDMA 대비 읽기 지연 7.0×↓, TTFT 89.6%↓, 처리량 7.35×↑ (SIGMOD 2025)
  - [Theoretically Optimal Attention/FFN Ratios in Disaggregated LLM Serving](https://arxiv.org/abs/2601.21351) — AFD 아키텍처 최적 A/F 비율 closed-form 도출

  **D. 분산·분리 서빙 및 KV 전송** (2026-04-30 보고서)
  - [Mooncake](https://arxiv.org/abs/2407.00079) — KV 중심 분리 아키텍처; 처리량 525%↑ (FAST 2025 Best Paper)
  - [TraCT](https://arxiv.org/abs/2512.18194) — CXL 공유 메모리 KV 풀; TTFT 9.8×↓
  - [ShadowKV](https://arxiv.org/abs/2410.21465) — SVD K GPU 유지 + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑ (ICML 2025 Spotlight)

  **E. 아키텍처 수준 KV 절감** (신규 — 2026-05-12 보고서)
  - [LightKV: Make Your LVLM KV Cache More Lightweight](https://arxiv.org/abs/2605.00789) — 교차 모달리티 메시지 패싱으로 비전 토큰 KV 중복 제거; 55% 비전 토큰으로 비전 KV 50% 절감, 연산 40%↓

  **E. 아키텍처 수준 KV 절감** (2026-05-04 보고서)
  - [MoE-MLA-RoPE: Unifying Mixture of Experts and MLA for Efficient Language Models](https://arxiv.org/abs/2508.01261) — MoE+MLA 결합으로 68% KV 절감, 3.2× 추론 가속 (KDD 2025 Workshop)
  - [TPLA: Tensor Parallel Latent Attention for Efficient Disaggregated Prefill and Decode Inference](https://arxiv.org/abs/2508.15881) — 텐서 병렬 환경에서 MLA 이점 보존; DeepSeek-V3·Kimi-K2 1.79~1.93×↑
  - [MHA2MLA-VLM: Enabling DeepSeek's MLA across Vision-Language Models](https://arxiv.org/abs/2601.11464) — 시각·텍스트 KV 독립 저랭크 압축; LLaVA-1.5/NeXT, Qwen2.5-VL 적용

  **E. 아키텍처 수준 KV 절감** (2026-04-30 보고서)
  - [DeepSeek-V2 (MLA)](https://arxiv.org/abs/2405.04434) — Multi-head Latent Attention; KV 93.3%↓, 처리량 5.76×↑
  - [TransMLA](https://arxiv.org/abs/2502.07864) — GQA→MLA 사후 변환; KV 68.75%↓, 추론 10.6×↑ (NeurIPS 2025 Spotlight)
  - [TPA](https://arxiv.org/abs/2501.06425) — 텐서 분해 어텐션; KV 10×↓ (NeurIPS 2025 Spotlight)

  **F. 장문맥·계층적 오프로딩** (신규 — 2026-05-12 보고서)
  - [Tutti: Making SSD-Backed KV Cache Practical for Long-Context LLM Serving](https://arxiv.org/abs/2605.03375) — GPU-centric KV 객체 저장소 + GPU io_uring 비동기 직접 객체 I/O; GDS-LMCache 대비 TTFT 78.3%↓, 처리 가능 요청률 2×↑

  **F. 장문맥·계층적 오프로딩** (2026-05-04 보고서)
  - [SparKV: Overhead-Aware KV Cache Loading for Efficient On-Device LLM Inference](https://arxiv.org/abs/2604.21231) — 어텐션 희소성 기반 클라우드 스트리밍 vs. 온디바이스 계산 동적 결정; TTFT 1.3~5.1×↓, 에너지 1.5~3.3×↓

  **F. 장문맥·계층적 오프로딩** (이전 보고서)
  - [KVSwap: Disk-aware KV Cache Offloading for Long-Context On-device Inference](https://arxiv.org/abs/2511.11907) — NVMe·UFS·eMMC 디스크 특성 인식 교체 정책 (MobiSys 2026)
  - [Dual-Blade: Dual-Path NVMe-Direct KV-Cache Offloading for Edge LLM Inference](https://arxiv.org/abs/2604.26557) — 페이지 캐시·NVMe 직접 이중 경로; prefill 33.1%↓, decode 42.4%↓
  - [ShadowKV](https://arxiv.org/abs/2410.21465) — SVD K GPU + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑ (ICML 2025 Spotlight)

  **G. RAG·평가 방법론 / 서베이** (이전 보고서)
  - [KV Cache Optimization Strategies for Scalable and Efficient LLM Inference](https://arxiv.org/abs/2603.20397) — 5개 방향(축출·압축·하이브리드 메모리·아키텍처·조합) 체계적 리뷰; 2026년 분야 지형도

  **G. 투기적 디코딩·특수 환경** (신규 — 2026-05-12 보고서)
  - [SpecKV: Adaptive Speculative Decoding with Compression-Aware Gamma Selection](https://arxiv.org/abs/2605.02888) — KV 압축 수준별 최적 투기 길이(γ) 동적 선택; fixed-γ=4 대비 56.0% 개선

  **H. 보안·프라이버시** (이전 보고서)
  - [Shadow in the Cache: Unveiling and Mitigating Privacy Risks of KV-cache in LLM Inference](https://arxiv.org/abs/2508.09442) — KV 역산·충돌·주입 3종 공격 실증 + KV-Cloak 가역 행렬 난독화 방어 (NDSS 2026)
  - [SafeKV: Selective KV-Cache Sharing to Mitigate Timing Side-Channels in LLM Inference](https://arxiv.org/abs/2508.08438) — 민감도 분류 기반 선택적 KV 공유로 타이밍 사이드채널 차단

- 관련 Deep-dive:
  - [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md)

### Deep Dives

- [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md) — 멀티모달 LLM 추론에서 이미지·텍스트 KV 캐시를 위치(prefix) 제약 없이 디스크에 저장·재사용하면서, 이미지 토큰 앞부분의 anchor 토큰만 선택적으로 재계산해 정확도 손실은 최소화하고 TTFT는 최대 54.1% 줄이며 처리량을 약 2.0배 향상. (원문: [OpenReview](https://openreview.net/forum?id=bld5GVRad0))

<!-- END: AUTO-INDEX -->
