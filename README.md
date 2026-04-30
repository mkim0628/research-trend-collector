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

매일 새벽 5시에 모든 `interests/*` 파일에 대해 `/collect-trends`를 비대화형으로 실행하려면 [`scripts/daily-collect.sh`](scripts/daily-collect.sh)를 호스트의 cron에 등록하세요.

```bash
chmod +x scripts/daily-collect.sh
crontab -e
# 다음 한 줄 추가 (절대 경로):
# 0 5 * * * /ABS/PATH/research-trend-collector/scripts/daily-collect.sh
```

자세한 전제 조건은 [`CLAUDE.md`](CLAUDE.md)의 "자동 스케줄링" 섹션을 참고하세요.

## Reports Index

> 아래 영역은 `report-indexer` 서브에이전트가 자동 갱신합니다. 마커 사이만 교체되며, 그 밖의 내용은 보존됩니다.

<!-- BEGIN: AUTO-INDEX -->
_마지막 업데이트: 2026-04-30 · 보고서 1개 · 논문 26편 · Deep-dive 0건_

### 📂 LLM KV 캐시 관리·최적화
- Latest: [kv-cache-optimization-2026-04-30](reports/kv-cache-optimization-2026-04-30.md)
- 주요 논문:
  - [Efficient Memory Management for Large Language Model Serving with PagedAttention](https://arxiv.org/abs/2309.06180) — 가상 메모리 방식 KV 블록 관리로 단편화 제거, 처리량 2~4x 향상 (vLLM 기반)
  - [SGLang: Efficient Execution of Structured Language Model Programs](https://arxiv.org/abs/2312.07104) — RadixAttention으로 트라이 기반 KV 자동 재사용; TTFT 최대 5x 감소, 처리량 4.4x 향상
  - [Sarathi-Serve: Efficient LLM Inference by Piggybacking Decodes with Chunked Prefills](https://arxiv.org/abs/2308.16369) — Chunked prefill로 decode stall 제거, 배치 효율 향상
  - [DistServe: Disaggregating Prefill and Decoding for Goodput-optimized Large Language Model Serving](https://arxiv.org/abs/2401.09670) — Prefill/Decode 물리 분리로 GPU 활용률 최적화, SLO 달성률 크게 향상
  - [Splitwise: Efficient Generative LLM Inference Using Phase Splitting](https://arxiv.org/abs/2311.18677) — 단계 분리 + 이종 GPU 클러스터 활용, 비용 20% 절감

<!-- END: AUTO-INDEX -->
