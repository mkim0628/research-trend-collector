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
_마지막 업데이트: 2026-05-01 · 보고서 1개 · 논문 96편 · Deep-dive 1건_

### 📂 LLM KV 캐시 관리·최적화
- Latest: [kv-cache-optimization-2026-04-30](reports/kv-cache-optimization-2026-04-30.md)
- 주요 논문:

  **A. 서빙 시스템·메모리 관리**
  - [vLLM 2024 Wrapped & 2025 Vision](https://vllm.ai/blog/vllm-2024-wrapped-2025-vision) — chunked prefill 기본 활성화, APC·speculative decoding·disaggregated prefill 통합
  - [SGLang: Efficient Execution of Structured Language Model Programs](https://arxiv.org/abs/2312.07104) — RadixAttention 자동 KV 재사용; 처리량 6.4×↑, few-shot cache hit rate 85~95%
  - [SGLang v0.4](https://www.lmsys.org/blog/2024-12-04-sglang-v0-4/) — Zero-Overhead Batch Scheduler + Cache-Aware LB; 처리량 1.3×↑, MLA 7×↑
  - [Sarathi-Serve](https://arxiv.org/abs/2403.02310) — stall-free chunked prefill; Mistral-7B 2.6×, Falcon-180B 5.6×↑
  - [FlashInfer](https://arxiv.org/abs/2501.01005) — 블록 희소 포맷 + JIT 컴파일 어텐션 커널; ITL 29~69%↓

  **B. KV 양자화·압축**
  - [KIVI](https://arxiv.org/abs/2402.02750) — 파인튜닝 없는 비대칭 2-bit KV 양자화; 메모리 2.6×↓, 배치 2.35~3.47×↑
  - [KVQuant](https://arxiv.org/abs/2401.18079) — per-channel 비균일 3-bit 양자화; 단일 GPU 1M 컨텍스트 달성
  - [CQ](https://arxiv.org/abs/2405.03917) — 채널 결합 양자화; 채널당 1-bit 달성, 처리량 1.4~3.5×↑
  - [ZipCache](https://arxiv.org/abs/2405.14256) — salient 토큰 식별 기반 적응 비트폭; 4.98× 압축, 지연 56.9%↓
  - [MiniCache](https://arxiv.org/abs/2405.14366) — 인접 레이어 KV 유사성 기반 깊이 차원 병합으로 메모리 절감

  **C. 토큰 축출·희소 어텐션**
  - [Quest](https://arxiv.org/abs/2406.10774) — 쿼리 인식 KV 페이지 선택; 추론 지연 7.03×↓
  - [MInference](https://arxiv.org/abs/2407.02490) — 동적 희소 프리필 어텐션; 1M 토큰 추론 30분→3분
  - [NACL](https://arxiv.org/abs/2408.03675) — 프록시 + 무작위 결합 축출; KV 50%↓에서 성능 76~80% 유지
  - [DuoAttention](https://arxiv.org/abs/2410.10819) — Retrieval/Streaming 헤드 이분화 차등 KV 관리
  - [HeadKV](https://arxiv.org/abs/2410.19258) — 헤드별 검색·추론 능력 기반 KV 예산 차등 할당

  **D. 분산·분리 서빙 및 KV 전송**
  - [DistServe](https://arxiv.org/abs/2401.09670) — P/D 분리로 goodput 최적화; 요청처리 7.4×↑, 엄격한 SLO 12.6×↑
  - [Splitwise](https://arxiv.org/abs/2311.18677) — 이종 GPU P/D 분리; 처리량 1.4×↑, 비용 20%↓
  - [Mooncake](https://arxiv.org/abs/2407.00079) — KV 중심 분리 아키텍처(Kimi 운영); 처리량 525%↑
  - [CacheGen](https://arxiv.org/abs/2310.07240) — KV 압축 비트스트림 전송; 크기 3.5~4.3×↓, 지연 3.2~3.7×↓
  - [CacheBlend](https://arxiv.org/abs/2405.16444) — RAG 멀티청크 KV 선택적 재계산 융합으로 정확도 보존

  **E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)**
  - [DeepSeek-V2 (MLA)](https://arxiv.org/abs/2405.04434) — Multi-head Latent Attention; KV 93.3%↓, 처리량 5.76×↑
  - [DeepSeek-V3](https://arxiv.org/abs/2412.19437) — 671B MoE에 MLA 적용; KV 70KB vs LLaMA-3.1-405B 516KB
  - [TransMLA](https://arxiv.org/abs/2502.07864) — GQA→MLA 사후 변환; KV 68.75%↓, 추론 10.6×↑
  - [MHA2MLA](https://arxiv.org/abs/2502.14837) — MHA→MLA 변환; KV 92.19%↓, 0.3~0.6% 데이터로 성능 회복
  - [X-EcoMLA](https://arxiv.org/abs/2503.11132) — 사전학습 어텐션 MLA 업사이클링 방법론

  **F. 장문맥·계층적 오프로딩**
  - [InfiniGen](https://arxiv.org/abs/2406.19707) — CPU 오프로딩 + 선택적 GPU 프리페치; 기존 오프로딩 대비 3.0×↑
  - [MagicPIG](https://arxiv.org/abs/2410.16179) — LSH GPU+CPU 협력; 처리량 1.5~5×↑, RTX4090 96K 디코딩 54ms
  - [RetrievalAttention](https://arxiv.org/abs/2409.10516) — ANNS 기반 CPU KV 검색; RTX4090에서 128K 8B 모델 서빙
  - [ShadowKV](https://arxiv.org/abs/2410.21465) — SVD K GPU + V CPU 오프로드; 배치 6×↑, 처리량 3.04×↑
  - [SpeCache](https://arxiv.org/abs/2503.16163) — 1~2bit GPU + FP16 CPU 투기적 프리페치; 10× 압축 무손실 달성

  **G. RAG·평가 방법론**
  - [RAGCache](https://arxiv.org/abs/2404.12457) — RAG 문서 청크 KV 트리 캐시로 반복 쿼리 비용 절감
  - [Cache-Craft](https://arxiv.org/abs/2502.15734) — RAG 청크 캐시 관리 시스템으로 KV 재사용 체계화
  - [RULER](https://arxiv.org/abs/2404.06654) — 장문맥 실질 활용 능력 종합 벤치마크
  - [SCBench](https://arxiv.org/abs/2412.10319) — KV 캐시 중심 장문맥 분석 전용 벤치마크
- 관련 Deep-dive:
  - [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md)

### 🔬 Deep Dives
- [InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction](reports/deep-dives/infoblend-multimodal-kv-reuse.md) — 멀티모달 LLM 추론에서 이미지·텍스트 KV 캐시를 위치(prefix) 제약 없이 디스크에 저장·재사용하면서, 이미지 토큰 앞부분의 anchor 토큰만 선택적으로 재계산해 정확도 손실은 최소화하고 TTFT는 최대 54.1% 줄이며 처리량을 약 2.0배 향상. (원문: [OpenReview](https://openreview.net/forum?id=bld5GVRad0))

<!-- END: AUTO-INDEX -->
