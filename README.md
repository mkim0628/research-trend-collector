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
_마지막 업데이트: 2026-05-18 · 보고서 8개 · 논문 195편 · Deep-dive 1건_

### LLM KV 캐시 관리·최적화
- Latest: [kv-cache-optimization-2026-05-18](reports/kv-cache-optimization-2026-05-18.md)
- 주요 논문:

  **A. 서빙 시스템·메모리 관리**
  - [A First Comprehensive Study of TurboQuant: Accuracy and Performance](https://vllm.ai/blog/2026-05-11-turboquant) — 4개 모델(30B~200B+)·5개 벤치마크에서 TurboQuant vs FP8 vs BF16 비교; FP8이 2× KV 용량 절감+정확도 손실 최소로 기본값 권고, TurboQuant는 메모리 절감 우선 시나리오에 적합
  - [Serving Agentic Workloads at Scale with vLLM x Mooncake](https://vllm.ai/blog/2026-05-06-mooncake-store) — 복수 vLLM 인스턴스가 클러스터 전역 Mooncake Store를 공유하는 분산 KV 캐시 풀 통합; 에이전트 워크로드(80K+ 토큰)에서 처리량 3.8×·P50 TTFT 46×·E2E 지연 8.6× 감소, GB200 60× 거의 선형 스케일링
  - [SGLang v0.5.12](https://github.com/sgl-project/sglang/releases) — UnifiedRadixTree로 DeepSeek V4 HiCache(GPU→CPU→Storage 다중 계층 KV 오프로딩) 지원, W4A4 MegaMoE 커널 추가; HiSparse 희소 어텐션·SSD 오프로드 통합
  - [SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters](https://arxiv.org/abs/2605.00528) — 에이전트 워크플로우 전체를 스케줄 단위로 삼아 KV 캐시 재사용 그래프를 구축; 64-GPU 클러스터에서 vLLM 대비 작업 완료 시간 1.64× 단축, GPU 메모리 활용률 1.22× 향상
  - [Efficient Serving for Dynamic Agent Workflows with Prediction-based KV-Cache Management](https://arxiv.org/abs/2605.06472) — 동적 에이전트 워크플로우에서 히스토리·컨텍스트 융합으로 미래 에이전트 호출 예측; 재사용 가능성 높은 KV GPU 유지 + 보수적 prefetch; LRU 대비 1.85×↑, SOTA KVFlow 대비 1.26×↑
  - [Online Scheduling for LLM Inference with KV Cache Constraints](https://arxiv.org/abs/2502.07115) — KV 제약 하 최적 배치·스케줄링 이론; 반온라인 모델에서 평균 지연 exact 최적성, 풀 온라인 확률적 도착 시 상수 후회 보증
  - [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) — 멀티턴 서빙에서 Turn 2+ 요청을 디코드 노드에서 로컬 처리할지 P 노드로 전송할지 동적 라우팅; Turn 2+ TTFT 68%↓, TPOT 유지
  - [AdaptCache: KV Cache Native Storage Hierarchy for Low-Delay and High-Quality Language Model Serving](https://arxiv.org/abs/2509.00105) — 각 KV 항목별 압축 알고리즘·비율·배치 장치 동적 결정; KIVI 대비 TTFT 69%↓, 정적 기준선 대비 1.43~2.4× 지연 절감
  - [Revisiting Disaggregated Large Language Model Serving for Performance and Energy Implications](https://arxiv.org/abs/2601.08833) — P/D 분리 성능 이점이 요청 부하·KV 전송 매체에 따라 보장되지 않으며 에너지 소비가 더 높을 수 있음을 DVFS 프로파일링으로 실증
  - [Understand and Accelerate Memory Processing Pipeline for Disaggregated LLM Inference](https://arxiv.org/abs/2603.29002) — 4단계 메모리 처리 파이프라인 통일 모델 + GPU-FPGA 이종 처리; 1.04~2.2×↑, 에너지 1.11~4.7×↓
  - [TaiChi: Prefill-Decode Aggregation or Disaggregation?](https://arxiv.org/abs/2508.01989) — SLO에 따라 집합·분리 모드를 동적으로 전환하는 통합 서빙; goodput 최대 77%↑
  - [MuxWise: Towards High-Goodput LLM Serving with Prefill-decode Multiplexing](https://arxiv.org/abs/2504.14489) — 레이어 단위 버블-없는 인트라-GPU P/D 다중화; SLO 보장 처리량 2.20×(최대 3.06×)↑
  - [DuetServe: Harmonizing Prefill and Decode for LLM Serving via Adaptive GPU Multiplexing](https://arxiv.org/abs/2511.04791) — 오염 예측 시 SM 수준 공간 다중화 활성화; Qwen3 기준 처리량 1.3×↑
  - [Prefill-as-a-Service: KVCache of Next-Generation Models Could Go Cross-Datacenter](https://arxiv.org/abs/2604.15039) — 크로스 데이터센터 P/D 분리; 처리량 54%↑, P90 TTFT 64%↓
  - [CacheFlow: Efficient LLM Serving with 3D-Parallel KV Cache Restoration](https://arxiv.org/abs/2604.25080) — 토큰·레이어·GPU 3차원 병렬 KV 복원; 배치 인식 투포인터 스케줄러로 TTFT 10~62%↓
  - [ContiguousKV: Accelerating LLM Prefill with Granularity-Aligned KV Cache Management](https://arxiv.org/abs/2601.13631) — 프리픽스 KV 오프로딩 시 청크 단위 정렬 + 비동기 프리페치; 최신 오프로딩 대비 Re-Prefill 3.85×↑

  **B. KV 양자화·압축**
  - [CommVQ: Commutative Vector Quantization for KV Cache Compression](https://arxiv.org/abs/2506.18879) — 코드북을 RoPE 행렬과 교환 가능하게 설계해 역양자화 비용을 사전 계산으로 흡수; 2-bit에서 FP16 대비 87.5% KV 크기 절감, 1-bit에서도 최소 정확도 손실로 LLaMA-3.1 8B × 128K 컨텍스트를 RTX 4090 단일 GPU로 구동 가능 (ICML '25)
  - [KVmix: Gradient-Based Layer Importance-Aware Mixed-Precision Quantization for KV Cache](https://arxiv.org/abs/2506.08018) — 그래디언트로 K·V 프로젝션 행렬의 레이어별 중요도를 측정해 비트폭 배분; 최근 피벗 토큰 풀 정밀도 보존 장문맥 전략 결합; Llama·Mistral에서 Key 2.19bit·Value 2.38bit 평균으로 4.9× 메모리 압축, 5.3× 처리량 향상 (AAAI)
  - [RateQuant: Optimal Mixed-Precision KV Cache Quantization via Rate-Distortion Theory](https://arxiv.org/abs/2605.06675) — Rate-Distortion 이론의 역 워터필링으로 헤드별 비트폭 최적 배분; 1.6초 보정으로 KIVI PPL 49.3 → 14.9 (70%↓), QuaRot 6.6 PPL 개선
  - [eOptShrinkQ: Near-Lossless KV Cache Compression Through Optimal Spectral Denoising and Quantization](https://arxiv.org/abs/2605.02905) — KV 캐시를 스파이크 랜덤 행렬 모델로 분해; 최적 특이값 수축(eOptShrink) + TurboQuant 잔차 양자화; ~2.2 bit에서 FP16 수준 멀티-니들 검색 성능
  - [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs Inference Optimization](https://arxiv.org/abs/2605.02262) — 비디오 VLM의 시각 토큰 윈도우-텍스트 유사도 기반 비트폭 자동 탐색; 윈도우 수준 양자화 계산으로 하드웨어 효율 유지
  - [XQuant: Breaking the Memory Wall for LLM Inference with KV Cache Rematerialization](https://arxiv.org/abs/2508.10395) — KV 대신 입력 활성화 X를 양자화·캐시 후 K/V 온더플라이 재구체화; 7.7× 메모리 절감(PPL↑<0.1), XQuant-CL 변형 12.5× 절감 vs. FP16
  - [KVComp: A High-Performance, LLM-Aware, Lossy Compression Framework for KV Cache](https://arxiv.org/abs/2509.00579) — 오류 제어 양자화 + GPU 기반 고속 엔트로피 인코딩 + 캐시 내 압축 해제 공동 설계; SOTA 대비 압축률 최대 83%↑, 속도 저하 무시 수준
  - [KVCompose: Efficient Structured KV Cache Compression with Composite Tokens](https://arxiv.org/abs/2509.05165) — 어텐션 점수 기반 헤드별 독립 토큰 선택 후 균일 복합 토큰으로 정렬; 특수 커널 없이 기존 엔진 호환, 장문맥 전반 SOTA 초과
  - [VidKV: Plug-and-Play 1.x-Bit KV Cache Quantization for Video Large Language Models](https://arxiv.org/abs/2503.16257) — 비디오 LLM Key: 채널별 2-bit(비정상) + FFT 1-bit(정상) 혼합; Value: 1.58-bit 채널별 양자화 + 시맨틱 중요 토큰 선택 보존; FP16 동등 성능 달성
  - [FibQuant: Universal Vector Quantization for Random-Access KV-Cache Compression](https://arxiv.org/abs/2605.11478) — Fibonacci/quasi-uniform 방향 + Beta-quantile 반경 범용 벡터 양자화; 보정 없이 분수·sub-1-bit 동작점 지원, TurboQuant를 동일 정수 비율에서 엄밀히 지배
  - [When Quantization Is Free: An int4 KV Cache That Outruns fp16 on Apple Silicon](https://arxiv.org/abs/2605.05699) — Apple Silicon 통합 메모리에서 sign-randomized FFT + per-channel λ + int4 nibble pack 단일 융합 Metal 커널; Gemma-3 1B에서 fp16 대비 3~8% ms/tok↓, 3× 메모리 절감
  - [How to Compress KV Cache in RL Post-Training? Shadow Mask Distillation for Memory-Efficient Alignment](https://arxiv.org/abs/2605.06850) — RL 롤아웃 중 KV 압축의 오프-폴리시 편향을 Shadow Mask Distillation로 해소; 장문맥 RL 후처리 메모리 벽 극복
  - [Beyond Token Eviction: Mixed-Dimension Budget Allocation for Efficient KV Cache Compression](https://arxiv.org/abs/2603.20616) — 토큰별 차원 수를 연속적으로 배분하는 MixedDimKV/MixedDimKV-H; 기존 토큰 축출을 차원 축소의 극단 사례로 일반화, LongBench HeadKV 대비 지속적 우위
  - [Cocktail: Chunk-Adaptive Mixed-Precision Quantization for Long-Context LLM Inference](https://arxiv.org/abs/2503.23294) — 쿼리-청크 유사도 기반 비트폭 동적 선택 + 청크 재정렬; 장문맥 LLM 추론 SOTA 초과 (DATE 2025)
  - [OjaKV: Context-Aware Online Low-Rank KV Cache Compression with Oja's Rule](https://arxiv.org/abs/2509.21623) — Oja 온라인 PCA로 압축 기저 지속 갱신; 정적 SVD 기법 AIME25 0% vs. OjaKV 13% 정확도 유지
  - [Don't Waste Bits! Adaptive KV-Cache Quantization for Lightweight On-Device LLMs](https://arxiv.org/abs/2604.04722) — 경량 컨트롤러로 {2,4,8-bit,FP16} 동적 선택; 정적 양자화 대비 지연 17.75%↓, 정확도 7.6점↑
  - [ARKV: Adaptive and Resource-Efficient KV Cache Management under Limited Memory Budget](https://arxiv.org/abs/2603.08727) — 레이어별 OQ 비율 추정 + 토큰별 3-상태 관리; 4× 메모리 절감에서 기준선 97% 정확도 유지
  - [EchoKV: Efficient KV Cache Compression via Similarity-Based Reconstruction](https://arxiv.org/abs/2603.22910) — 인터/인트라 레이어 헤드 유사도 활용 경량 재구성 네트워크; 7B 모델 ~1 A100 GPU-시간 학습
  - [TurboQuant: Online Vector Quantization with Near-optimal Distortion Rate](https://arxiv.org/abs/2504.19874) — 랜덤 직교 회전 + QJL 잔차로 3-bit 벡터 양자화; KV 6×↓, H100 기준 어텐션 8×↑ (ICLR 2026)
  - [RotateKV: Accurate and Robust 2-Bit KV Cache Quantization via Outlier-Aware Adaptive Rotations](https://arxiv.org/abs/2501.16383) — 채널 재정렬 아웃라이어 인식 FWHT 회전; 2-bit PPL 저하 0.3↓
  - [KIVI: A Tuning-Free Asymmetric 2bit Quantization for KV Cache](https://arxiv.org/abs/2402.02750) — 파인튜닝 없는 비대칭 2-bit KV 양자화; 메모리 2.6×↓ (ICML 2024)
  - [KVzap: Fast, Adaptive, and Faithful KV Cache Pruning](https://arxiv.org/abs/2601.07891) — KVzip 경량 근사 + 입력 밀도 적응 임계치; KVpress 리더보드 2~4× 압축 SOTA

  **C. 토큰 축출·희소 어텐션**
  - [Minimal-Intervention KV Retention: A Design-Space Study and a Diversity-Penalty Survivor](https://arxiv.org/abs/2605.14292) — 5개 차원(캐시 표현·헤드별 라우팅·압축 주기·디코딩·스코어링) × 7 메커니즘을 소규모 예산(b∈{64,128})에서 MATH-500으로 체계 평가 후 전부 기각; TriAttention 스코어러에 V-공간 다양성 패널티 greedy facility-location 선택(α)으로 1함수 수정 제안
  - [AhaKV: Adaptive Holistic Attention-Driven KV Cache Eviction for Efficient Inference of Large Language Models](https://arxiv.org/abs/2506.03762) — 누적 어텐션 스코어의 위치 편향을 SG-softmax 엔트로피 조정으로 보정하고, value 벡터를 활용한 value-prior로 축출 스코어 정제; 여러 벤치마크에서 편향 완화로 글로벌 문맥 정보 유지 SOTA 달성
  - [Reformulating KV Cache Eviction Problem for Long-Context LLM Inference](https://arxiv.org/abs/2605.07234) — LaProx: 주의 맵과 프로젝션된 값 상태 간의 곱셈적 상호작용 모델링으로 출력 인식 층별 행렬곱 근사 문제로 재정식화; LongBench 전반 SOTA
  - [RetentiveKV: State-Space Memory for Uncertainty-Aware Multimodal KV Cache Eviction](https://arxiv.org/abs/2605.04075) — 엔트로피 기반 중요도 추정 후 축출된 KV를 모달리티별 상태 공간으로 흡수하는 연속적 메모리 진화 프레임워크; KV 5.0× 압축, 디코딩 1.5× 가속
  - [Self-Pruned Key-Value Attention: Learning When to Write by Predicting Future Utility](https://arxiv.org/abs/2605.14037) — 경량 유틸리티 예측기가 각 KV 쌍을 채점해 미래 유용성이 임계치를 초과하는 것만 장기 캐시에 기록; KV 캐시 3~10× 압축, validation loss·다운스트림 태스크 성능 거의 무손실
  - [Make Each Token Count: Towards Improving Long-Context Performance with KV Cache Eviction](https://arxiv.org/abs/2605.09649) — 글로벌 리텐션 게이트로 레이어·헤드 전역 토큰 미래 유용성 학습(DBTrimKV); "풀 캐시가 항상 최적이 아님"을 실증, 선택적 eviction으로 장문맥 성능 개선
  - [SideQuest: Model-Driven KV Cache Management for Long-Horizon Agentic Reasoning](https://arxiv.org/abs/2602.22603) — LRM이 병렬 부채널 컨텍스트에서 KV 중요도를 직접 추론하는 모델 주도 압축; 에이전틱 벤치마크 KV 60%↓, 정확도 손실 무시 수준
  - [CodeComp: Structural KV Cache Compression for Agentic Coding](https://arxiv.org/abs/2604.10235) — 코드 속성 그래프(CPG) 기반 스팬 수준 구조 보호 + 예산 할당; 어텐션 only 기준선 대비 결함 위치 파악·패치 생성 전반 우위, SGLang 통합
  - [LKV: End-to-End Learning of Head-wise Budgets and Token Selection for LLM KV Cache Eviction](https://arxiv.org/abs/2605.06676) — 헤드별 예산 학습(LKV-H) + 어텐션 행렬 미실체화 토큰 중요도 도출(LKV-T); LongBench 15% KV 보존에서 거의 무손실, 6.6× 저장 절감
  - [Sparse Attention as a Range Searching Problem: Towards an Inference-Efficient Index for KV Cache](https://arxiv.org/abs/2605.06763) — 희소 어텐션을 반공간 범위 탐색으로 환원; Louver 인덱스로 거짓 음성 제로 이론 보증, FlashAttention보다 빠른 런타임
  - [MISA: Mixture of Indexer Sparse Attention for Long-Context LLM Inference](https://arxiv.org/abs/2605.07363) — DeepSeek DSA 인덱서를 MoE 헤드 풀로 대체; 블록 수준 통계 기반 경량 라우터로 활성 헤드 수 동적 축소, 장문맥 인덱서 지배 비용 제거
  - [StreamIndex: Memory-Bounded Compressed Sparse Attention via Streaming Top-k](https://arxiv.org/abs/2605.02568) — DeepSeek V4 CSA 파이프라인의 256GB 임시 텐서 문제를 청크 파티션-병합 top-k로 해소; S=1,048,576까지 6.21GB HBM으로 확장, recall 0.9980+
  - [SAGE-KV: LLMs Know What to Drop](https://arxiv.org/abs/2503.08879) — 프리필 후 1회 top-k 선택(토큰+헤드); StreamLLM 대비 4× 메모리 효율 (ICLR 2025)
  - [SentenceKV: Efficient LLM Inference via Sentence-Level Semantic KV Caching](https://arxiv.org/abs/2504.00970) — 문장 수준 시맨틱 벡터 GPU 유지 + 개별 KV CPU 오프로드 (COLM 2025)
  - [IceCache: Memory-efficient KV-cache Management for Long-Sequence LLMs](https://arxiv.org/abs/2604.10539) — 시맨틱 토큰 클러스터링 DCI-tree + ANN 페이지 선택
  - [DynSplit-KV: Dynamic Semantic Splitting for KVCache Compression](https://arxiv.org/abs/2602.03184) — 동적 의미 경계 분할; FlashAttention 대비 2.2×↑, 메모리 2.6×↓
  - [SemantiCache: Efficient KV Cache Compression via Semantic Chunking and Clustered Merging](https://arxiv.org/abs/2603.14303) — GSC 클러스터 병합 + 비례 어텐션 재균형; 디코딩 2.61×↑
  - [LycheeCluster: Efficient Long-Context Inference with Structure-Aware Chunking and Hierarchical KV Indexing](https://arxiv.org/abs/2603.08453) — 계층 인덱스로 KV 검색 O(log n) 단축; 풀 어텐션 대비 3.6×↑
  - [Self-Indexing KVCache: Predicting Sparse Attention from Compressed Keys](https://arxiv.org/abs/2603.14224) — 1-bit VQ로 압축키에서 직접 top-k 검색; 별도 인덱스 불필요 (AAAI 2026)
  - [AnDPro: Accurate KV Cache Eviction via Anchor Direction Projection](https://arxiv.org/abs/2509.18143) — Value 벡터 앵커 방향 투영 기반 토큰 중요도; LongBench 96.07% 정확도, 3.44% 예산 (NeurIPS 2025)
  - [FreeKV: Boosting KV Cache Retrieval for Efficient LLM Inference](https://arxiv.org/abs/2505.13109) — 투기적 검색 + 하이브리드 CPU/GPU 레이아웃; SOTA 대비 13×↑
  - [ForesightKV: Foresight-Driven KV Cache Eviction via RL](https://arxiv.org/abs/2602.03203) — RL 기반 장기 기여도 예측; AIME 절반 예산에서 SOTA 초과
  - [Learning to Evict from Key-Value Cache (KV Policy)](https://arxiv.org/abs/2602.10238) — 헤드별 경량 RL 에이전트; 생성 트레이스에서 미래 유용성 학습; RULER·LongBench 제로샷 일반화

  **D. 분산·분리 서빙 및 KV 전송**
  - [Tutti: Making SSD-Backed KV Cache Practical for Long-Context LLM Serving](https://arxiv.org/abs/2605.03375) — GPU-centric KV 오브젝트 스토어; CPU를 데이터 경로에서 배제, GPU io_uring 비동기 직접 객체 I/O + 슬랙-인식 스케줄링; GDS 기반 LMCache 대비 TTFT 78.3%↓, 요청 처리율 2×↑, 비용 27%↓
  - [Predictive Multi-Tier Memory Management for KV Cache in Large-Scale GPU Inference](https://arxiv.org/abs/2604.26968) — 아키텍처 변형 인식 사이징 엔진 + 6계층 메모리 계층 + Bayesian 재사용 예측; 64-GPU H100 클러스터에서 캐시 적중률 70~84%, TTFT 1.4~2.1× 감소
  - [KVDirect: Distributed Disaggregated LLM Inference](https://arxiv.org/abs/2501.14743) — 다중 노드 분산 P/D 분리를 위한 텐서 중심 통신 메커니즘 + Pull 기반 KV 전송; KV 전송이 총 지연의 0.5~1.1%에 불과, 기준선 대비 요청 지연 55%↓
  - [Beluga: A CXL-Based Memory Architecture for Scalable and Efficient LLM KVCache Management](https://arxiv.org/abs/2511.20172) — CXL 2.0 스위치 공유 메모리 풀; RDMA 대비 읽기 지연 7.0×↓, TTFT 89.6%↓, 처리량 7.35×↑ (SIGMOD 2025)
  - [Theoretically Optimal Attention/FFN Ratios in Disaggregated LLM Serving](https://arxiv.org/abs/2601.21351) — AFD 아키텍처 최적 A/F 비율 closed-form 도출
  - [Mooncake: A KVCache-centric Disaggregated Architecture for LLM Serving](https://arxiv.org/abs/2407.00079) — KV 중심 분리 아키텍처; 처리량 525%↑ (FAST 2025 Best Paper)
  - [KV-Fold: One-Step KV-Cache Recurrence for Long-Context Inference](https://arxiv.org/abs/2605.12471) — KV 캐시를 청크 좌측 폴드(foldl) 재귀로 처리; 학습·아키텍처 변경 없이 Llama-3.1-8B 128K 토큰 40GB GPU에서 100% 정확 검색
  - [An Efficient Hybrid Sparse Attention with CPU-GPU Parallelism for Long-Context Inference](https://arxiv.org/abs/2605.07719) — CPU 상주 KV 캐시에 대한 출력 인식 예산 할당 + 헤드별 희소 구성 + 크로스-디바이스 협력 실행(Fluxion); GPU 유휴 시간 제거
  - [SparKV: Overhead-Aware KV Cache Loading for Efficient On-Device LLM Inference](https://arxiv.org/abs/2604.21231) — 클라우드 스트리밍 vs. 온디바이스 계산 동적 결정; TTFT 1.3~5.1×↓, 에너지 1.5~3.3×↓
  - [TraCT: Transparent CXL-based KV Cache Transfer for LLM Inference](https://arxiv.org/abs/2512.18194) — CXL 공유 메모리 KV 풀; TTFT 9.8×↓
  - [ShadowKV: KV Cache in Shadows for High-Throughput Long-Context LLM Inference](https://arxiv.org/abs/2410.21465) — SVD K GPU + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑ (ICML 2025 Spotlight)
  - [KVSwap: Disk-aware KV Cache Offloading for Long-Context On-device Inference](https://arxiv.org/abs/2511.11907) — 디스크 특성 인식 KV 오프로딩 (MobiSys 2026)
  - [Dual-Blade: Dual-Path NVMe-Direct KV-Cache Offloading for Edge LLM Inference](https://arxiv.org/abs/2604.26557) — NVMe-Direct 이중 경로; prefill 33.1%↓, decode 42.4%↓
  - [TokenDance: Scaling Multi-Agent LLM Serving via Collective KV Cache Sharing](https://arxiv.org/abs/2604.03143) — All-Gather 라운드 단위 블록-스파스 diff KV 공유; 에이전트 KV 17.5×↓, prefill 1.9×↑

  **E. 아키텍처 수준 KV 절감**
  - [Hardware-Centric Analysis of DeepSeek's Multi-Head Latent Attention](https://arxiv.org/abs/2506.02523) — MLA의 최초 하드웨어 중심 분석: 잠재 투영 행렬 재사용(reuse) vs 재계산(recompute) 두 실행 방식의 처리량·에너지 트레이드오프를 Stream DSE 프레임워크로 수치화; MLA가 대역폭 제한 하드웨어에서 어텐션 워크로드를 compute-bound 영역으로 이동시킴을 입증 (Electronics Letters, KU Leuven)
  - [Universal YOCO for Efficient Depth Scaling](https://arxiv.org/abs/2604.01220) — YOCO 디코더-디코더 구조에 파라미터 공유 반복 계산(Universal Self-Decoder)을 결합; 상수 글로벌 KV 캐시와 선형 프리필링을 유지하면서 표현 깊이 확장
  - [Key-Value Means: Transformers with Expandable Block-Recurrent Compressed Memory](https://arxiv.org/abs/2605.09877) — KVM: 고정 크기 또는 성장형 블록 순환 어텐션; 커스텀 커널 없이 표준 연산으로 구현 가능, 청크 단위 병렬 훈련·프리필 지원
  - [EG-MLA: Embedding-Gated Multi-head Latent Attention for Scalable and Efficient LLMs](https://arxiv.org/abs/2509.16686) — MLA 잠재 공간에 토큰별 임베딩 게이팅 추가; MHA 대비 KV 요소 91.6%↓, MLA 대비 59.9%↓ 추가 절감, 표현력 향상
  - [MoE-MLA-RoPE: Unifying Mixture of Experts and MLA for Efficient Language Models](https://arxiv.org/abs/2508.01261) — MoE+MLA 결합으로 68% KV 절감, 3.2× 추론 가속 (KDD 2025 Workshop)
  - [TPLA: Tensor Parallel Latent Attention for Efficient Disaggregated Prefill and Decode Inference](https://arxiv.org/abs/2508.15881) — 텐서 병렬 환경에서 MLA 이점 보존; DeepSeek-V3·Kimi-K2 1.79~1.93×↑
  - [MHA2MLA-VLM: Enabling DeepSeek's MLA across Vision-Language Models](https://arxiv.org/abs/2601.11464) — 시각·텍스트 KV 독립 저랭크 압축; LLaVA-1.5/NeXT, Qwen2.5-VL 적용
  - [DeepSeek-V2: A Strong, Economical, and Efficient Mixture-of-Experts Language Model (MLA)](https://arxiv.org/abs/2405.04434) — KV 93.3%↓, 처리량 5.76×↑
  - [TransMLA: Multi-head Latent Attention Is All You Need](https://arxiv.org/abs/2502.07864) — GQA→MLA 사후 변환; KV 68.75%↓, 추론 10.6×↑ (NeurIPS 2025 Spotlight)
  - [TPA: Tensor Product Attention Is All You Need](https://arxiv.org/abs/2501.06425) — 텐서 분해 어텐션; KV 10×↓ (NeurIPS 2025 Spotlight)

  **F. 장문맥·오프로딩**
  - [Breaking the Boundaries of Long-Context LLM Inference: Adaptive KV Management on a Single Commodity GPU](https://arxiv.org/abs/2506.20187) — LeoAM: 단일 commodity GPU를 위한 최초 중요도 인식 장문맥 시스템; 층별 어텐션 가중치 분포 편향에 기반한 가변 크기 청크 분할 + 디스크에 경량 KV 추상(abstract)만 저장해 전송 지연 최소화; 평균 추론 지연 3.46× 단축, 유사 품질 유지

  **G. VLM·멀티모달 KV 관리**
  - [Make Your LVLM KV Cache More Lightweight](https://arxiv.org/abs/2605.00789) — 텍스트 프롬프트 유도 크로스-모달리티 메시지 패싱으로 시각 토큰 점진적 압축(LightKV); 원본 55% 토큰으로 KV 반감, 연산량 40%↓, 8개 오픈소스 LVLM에서 기준선 상회

  **H. 보안·프라이버시**
  - [Shadow in the Cache: Unveiling and Mitigating Privacy Risks of KV-cache in LLM Inference](https://arxiv.org/abs/2508.09442) — KV 역산·충돌·주입 3종 공격 + KV-Cloak 방어 (NDSS 2026)
  - [Selective KV-Cache Sharing to Mitigate Timing Side-Channels in LLM Inference (SafeKV)](https://arxiv.org/abs/2508.08438) — 타이밍 사이드채널 차단 선택적 KV 공유

  **I. 서베이·평가 방법론**
  - [KV Cache Optimization Strategies for Scalable and Efficient LLM Inference](https://arxiv.org/abs/2603.20397) — 5개 방향 체계적 리뷰; 2026년 분야 지형도

- 관련 Deep-dive:
  - [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md)

### Deep Dives
- [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md) — 멀티모달 LLM 추론에서 이미지·텍스트 KV 캐시를 위치(prefix) 제약 없이 디스크에 저장·재사용하면서, 이미지 토큰 앞부분의 anchor 토큰만 선택적으로 재계산해 정확도 손실은 최소화하고 TTFT는 최대 54.1% 줄이며 처리량을 약 2.0배 향상. (원문: [OpenReview](https://openreview.net/forum?id=bld5GVRad0))

<!-- END: AUTO-INDEX -->
