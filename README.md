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
_마지막 업데이트: 2026-05-09 · 보고서 5개 · 논문 157편 · Deep-dive 1건_

### LLM 추론 KV 캐시 관리·최적화
- Latest: [kv-cache-optimization-2026-05-09](reports/kv-cache-optimization-2026-05-09.md)
- 주요 논문:

  **A. 서빙 시스템**
  - [Continuum: Efficient and Robust Multi-Turn LLM Agent Scheduling with KV Cache Time-to-Live](https://arxiv.org/abs/2511.02230) — 다중 턴 에이전트 워크로드에서 KV 캐시를 TTL 기반으로 선택적으로 핀하여 재사용률 극대화; JCT 8배 이상 개선
  - [SAGA: Workflow-Atomic Scheduling for AI Agent Inference on GPU Clusters](https://arxiv.org/abs/2605.00528) — 에이전트 워크플로우 전체를 스케줄 단위로 올려 KV 재사용 최적화; 에이전트 E2E 지연 3~8배 감소
  - [Online Scheduling for LLM Inference with KV Cache Constraints](https://arxiv.org/abs/2502.07115) — KV 캐시 메모리 제약 하 배치 스케줄링 이론 모델링; semi-online 조건에서 정확 최적
  - [TaiChi: Prefill-Decode Aggregation or Disaggregation?](https://arxiv.org/abs/2508.01989) — SLO에 따라 집합·분리 모드를 동적으로 전환하는 통합 서빙; goodput 최대 77%↑
  - [MuxWise: Towards High-Goodput LLM Serving with Prefill-decode Multiplexing](https://arxiv.org/abs/2504.14489) — 레이어 단위 버블-없는 인트라-GPU P/D 다중화; SLO 보장 처리량 2.20×(최대 3.06×)↑

  **B. KV 양자화·압축**
  - [TailorKV: A Hybrid Framework for Long-Context Inference via Tailored KV Cache Optimization](https://arxiv.org/abs/2505.19586) — Transformer 층을 양자화·희소성 친화로 분류해 1-bit 정적 양자화와 Top-K 동적 검색 혼합 적용; GPU 메모리 53.7% 절감 (ACL 2025 Findings)
  - [R-KV: Redundancy-aware KV Cache Compression for Reasoning Models](https://arxiv.org/abs/2505.24133) — 어텐션 기반 중요도 + Key 벡터 유사도 기반 동적 중복 점수 결합 선택; KV 16% 보존으로 105% 정확도, 90% 메모리 절감 (NeurIPS 2025)
  - [TurboQuant: Online Vector Quantization with Near-optimal Distortion Rate](https://arxiv.org/abs/2504.19874) — 랜덤 직교 회전 + QJL 잔차로 3-bit 벡터 양자화; KV 6×↓, H100 기준 어텐션 8×↑ (ICLR 2026)
  - [Sequential KV Cache Compression via Probabilistic Language Tries: Beyond the Per-Vector Shannon Limit](https://arxiv.org/abs/2604.15356) — 토큰 시퀀스 상관관계 활용 2-계층 순차 압축; TurboQuant 대비 이론 압축비 약 914,000배 달성 가능
  - [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs Inference Optimization](https://arxiv.org/abs/2605.02262) — VLM의 시각 토큰 KV 캐시를 윈도우 단위로 최적 비트폭 결정; 탐색 시간 단축 및 정확도·처리량·메모리 SOTA 상회

  **C. 토큰 축출·희소 어텐션**
  - [Fast KVzip: Efficient and Accurate LLM Inference with Gated KV Eviction](https://arxiv.org/abs/2601.17668) — 경량 Sink-Attention 게이팅 모듈로 KV 중요도 식별·축출; 70% KV 축출 시 거의 무손실 성능
  - [Rethinking KV Cache Eviction via a Unified Information-Theoretic Objective](https://arxiv.org/abs/2604.25975) — Information Bottleneck 원리 기반 CapKV 제안; 통계적 leverage score로 토큰 선택, 기존 SOTA 축출 방법 일관 상회
  - [RetentiveKV: State-Space Memory for Uncertainty-Aware Multimodal KV Cache Eviction](https://arxiv.org/abs/2605.04075) — 멀티모달 LLM 시각 KV 축출을 상태 공간 모델 기반 연속 메모리 진화로 재정식화; KV 캐시 5배 압축, 디코딩 1.5배 가속
  - [Make Your LVLM KV Cache More Lightweight](https://arxiv.org/abs/2605.00789) — LightKV: cross-modality 메시지 패싱으로 시각 토큰 임베딩 중복 집계; 시각 KV 캐시 절반 축소, 연산 최대 40% 절감
  - [Self-Indexing KVCache: Predicting Sparse Attention from Compressed Keys](https://arxiv.org/abs/2603.14224) — 1-bit VQ로 압축키에서 직접 top-k 검색; 별도 인덱스 불필요 (AAAI 2026)

  **D. 분산·분리 서빙 및 KV 전송**
  - [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) — append-prefill과 full-prefill 구분 + 동적 라우팅으로 KV 전송 부담 완화; Turn 2+ TTFT 약 68% 감소
  - [Towards Efficient Key-Value Cache Management for Prefix Prefilling in LLM Inference](https://arxiv.org/abs/2505.21919) — RDMA 기반 분산 KV 메타데이터 관리 시스템 설계; 실제 트레이스에서 75% 이상 요청 블록 히트율 50% 초과 (IEEE Cloud 2025)
  - [Beluga: A CXL-Based Memory Architecture for Scalable and Efficient LLM KVCache Management](https://arxiv.org/abs/2511.20172) — CXL 2.0 스위치 공유 메모리 풀; RDMA 대비 읽기 지연 7.0×↓, TTFT 89.6%↓, 처리량 7.35×↑ (SIGMOD 2025)
  - [Mooncake](https://arxiv.org/abs/2407.00079) — KV 중심 분리 아키텍처; 처리량 525%↑ (FAST 2025 Best Paper)
  - [Prefill-as-a-Service: KVCache of Next-Generation Models Could Go Cross-Datacenter](https://arxiv.org/abs/2604.15039) — 크로스 데이터센터 P/D 분리; 처리량 54%↑, P90 TTFT 64%↓

  **E. 아키텍처 수준 KV 절감**
  - [Hardware-Efficient Attention for Fast Decoding](https://arxiv.org/abs/2505.21487) — GTA(KV 50% 절감)·GLA(MLA에 필적하는 품질 + FlashMLA보다 최대 2배 빠른 커널) 제안
  - [Whisper-MLA: Reducing GPU Memory Consumption of ASR Models based on MHA2MLA Conversion](https://arxiv.org/abs/2603.00563) — MHA2MLA 변환을 Whisper ASR 모델에 적용; 최소 파인튜닝으로 성능-메모리 균형 달성
  - [DeepSeek-V2 (MLA)](https://arxiv.org/abs/2405.04434) — Multi-head Latent Attention; KV 93.3%↓, 처리량 5.76×↑
  - [TransMLA](https://arxiv.org/abs/2502.07864) — GQA→MLA 사후 변환; KV 68.75%↓, 추론 10.6×↑ (NeurIPS 2025 Spotlight)
  - [TPA](https://arxiv.org/abs/2501.06425) — 텐서 분해 어텐션; KV 10×↓ (NeurIPS 2025 Spotlight)

  **F. 장문맥·계층적 오프로딩**
  - [ShadowKV](https://arxiv.org/abs/2410.21465) — SVD K GPU + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑ (ICML 2025 Spotlight)
  - [KVSwap: Disk-aware KV Cache Offloading for Long-Context On-device Inference](https://arxiv.org/abs/2511.11907) — 디스크 특성 인식 KV 오프로딩; Jetson Orin 기준 제한 메모리에서 처리량 향상 (MobiSys 2026)
  - [Dual-Blade: Dual-Path NVMe-Direct KV-Cache Offloading for Edge LLM Inference](https://arxiv.org/abs/2604.26557) — NVMe-Direct 이중 경로 + 적응 파이프라인 병렬; prefill 33.1%↓, decode 42.4%↓
  - [SparKV: Overhead-Aware KV Cache Loading for Efficient On-Device LLM Inference](https://arxiv.org/abs/2604.21231) — 어텐션 희소성 기반 클라우드 스트리밍 vs. 온디바이스 계산 동적 결정; TTFT 1.3~5.1×↓, 에너지 1.5~3.3×↓

  **G. RAG·평가 방법론**
  - [KV Cache Optimization Strategies for Scalable and Efficient LLM Inference](https://arxiv.org/abs/2603.20397) — 5개 방향(축출·압축·하이브리드 메모리·아키텍처·조합) 체계적 리뷰; 2026년 분야 지형도

  **H. 보안·프라이버시**
  - [Shadow in the Cache: Unveiling and Mitigating Privacy Risks of KV-cache in LLM Inference](https://arxiv.org/abs/2508.09442) — KV 역산·충돌·주입 3종 공격 실증 + KV-Cloak 방어 (NDSS 2026)
  - [Selective KV-Cache Sharing to Mitigate Timing Side-Channels in LLM Inference (SafeKV)](https://arxiv.org/abs/2508.08438) — 민감도 분류 기반 선택적 KV 공유로 타이밍 사이드채널 차단

- 관련 Deep-dive:
  - [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md)

### Deep Dives
- [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md) — 멀티모달 LLM 추론에서 이미지·텍스트 KV 캐시를 위치(prefix) 제약 없이 디스크에 저장·재사용하면서, 이미지 토큰 앞부분의 anchor 토큰만 선택적으로 재계산해 정확도 손실은 최소화하고 TTFT는 최대 54.1% 줄이며 처리량을 약 2.0배 향상. (원문: [OpenReview](https://openreview.net/forum?id=bld5GVRad0))

<!-- END: AUTO-INDEX -->
