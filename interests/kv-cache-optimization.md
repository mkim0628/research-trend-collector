# KV Cache Management Optimization for LLM Inference

대형 언어 모델(LLM) 추론에서 KV(Key–Value) 캐시는 디코딩 단계의 주된 메모리·대역폭 병목이다. 시퀀스 길이·배치 크기·동시 요청 수에 비례해 폭증하는 KV 캐시를 어떻게 관리·압축·재사용·분산하느냐가 throughput, latency, 지원 가능한 컨텍스트 길이를 결정한다. 본 명세는 **추론 단에서의 KV 캐시 관리 최적화**에 한정해 동향을 추적한다(학습 단계 메모리 최적화는 제외).

## Topic
LLM 추론에서의 KV 캐시 관리·압축·재사용·스케줄링 최적화 (시스템·알고리즘 양쪽 포함)

## Keywords
- KV cache management
- PagedAttention / paged KV cache
- prefix caching / KV cache reuse / RadixAttention
- KV cache compression
- KV cache quantization
- token eviction / cache eviction
- attention sink / streaming LLM
- multi-query attention (MQA), grouped-query attention (GQA), multi-head latent attention (MLA)
- disaggregated prefill / decode serving
- KV offloading (CPU / SSD / NVMe)
- long-context inference
- continuous batching
- vLLM / SGLang / TensorRT-LLM / LMDeploy / Mooncake

## Subtopics
- **메모리 관리·할당**: PagedAttention 류의 가상 메모리 기법, 단편화 완화, 연속 배치(continuous batching)와의 상호작용
- **캐시 압축·양자화**: KV의 비트 폭 축소(KIVI, KVQuant, IntactKV 등), 저랭크 분해, 혼합 정밀도
- **토큰 선택·축출**: H2O, StreamingLLM, Scissorhands, SnapKV, FastGen, PyramidKV 등 중요도 기반 eviction
- **프리픽스/세션 캐시 재사용**: SGLang RadixAttention, 시스템 프롬프트 공유, 다중 사용자 간 캐시 공유
- **아키텍처 수준 절감**: MQA / GQA / MLA(DeepSeek-V2), cross-layer 공유, sliding window
- **분산·분리 서빙**: Prefill–Decode 분리(DistServe, Splitwise, Mooncake), KV 마이그레이션·전송 비용
- **계층적 오프로딩**: GPU ↔ CPU ↔ NVMe 계층 캐시, 비동기 prefetch, 페이지 교체 정책
- **장문맥 추론과의 결합**: 100K~10M 토큰 컨텍스트에서의 캐시 전략, RAG·툴 사용과의 상호작용
- **품질·지연 트레이드오프 평가**: 캐시 절감이 정확도·perplexity·태스크 성능에 미치는 영향 평가 프로토콜

## Time Range
2023-01 ~ 2026-04
(PagedAttention·StreamingLLM 등 핵심 기점부터 현재까지)

## Venues
- 시스템: MLSys, OSDI, SOSP, ASPLOS, ATC, EuroSys, NSDI, ISCA
- ML: NeurIPS, ICML, ICLR, ACL, EMNLP
- 워크숍·기술 보고서: ES-FoMo, EfficientML.ai, NVIDIA / Meta / DeepSeek / Moonshot 기술 블로그
- arXiv: cs.LG, cs.CL, cs.DC, cs.AR, cs.OS

## Priority Systems / Frameworks
다음 두 프레임워크의 설계 결정과 변경 이력을 1순위로 추적한다(논문 vs 구현 차이 비교에 핵심 자료).
- **vLLM** — PagedAttention 원조, 연속 배치 구현
- **SGLang** — RadixAttention 기반 프리픽스 캐시 공유

위 두 프레임워크 외 자료(TensorRT-LLM, LMDeploy, llama.cpp, Mooncake, DeepSeek inference 등)는 보조 참고로만 활용한다.

## Exclusions
- 학습(training) 단계의 메모리 최적화 (gradient checkpointing 등)
- 모델 가중치만의 양자화·프루닝 (KV와 무관한 부분)
- 일반적인 RAG 시스템 설계 (KV 캐시 관점이 아닌 경우)

> 단, FlashAttention 같은 attention 커널 연구라도 **KV 캐시 관리 측면을 함께 다루는 후속**(예: FlashDecoding, FlashInfer 등)은 포함한다.

## Depth
overview

> 본 명세는 분야 지형도와 macro 트렌드 파악을 목표로 한다. 개별 기법의 알고리즘·실험 디테일은 `/deep-dive`로 따로 분석한다.

## Language
ko

## 추가 메모
- 시스템 논문(분산 서빙·메모리 관리)과 알고리즘 논문(eviction·quantization)을 균형 있게 다룬다.
- 같은 기법이라도 학계 발표본과 프레임워크 구현의 차이가 큰 경우가 많으므로 두 출처를 모두 확인한다 (예: PagedAttention 논문 vs. vLLM 구현 변경 이력).
- DeepSeek-V2의 MLA, Mooncake의 KV pool 같은 산업 진영의 큰 변화는 별도 macro 트렌드로 분리해 추적한다.
- 가능하면 각 기법의 **메모리 절감률 / 처리량 향상 / 품질 손실** 세 축의 수치를 함께 메모한다.
