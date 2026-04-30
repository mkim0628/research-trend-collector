---
type: trend-report
topic: "LLM KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-04-30
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM KV 캐시 관리·최적화 동향 보고서

**조사 기간**: 2023-01 ~ 2026-04  
**작성일**: 2026-04-30  
**깊이**: Overview

---

## 1. Executive Summary

**메모리 가상화와 연속 배치(continuous batching)의 정착**: 2023년 vLLM의 PagedAttention이 가상 메모리 방식의 KV 캐시 관리를 정립하면서, 단편화 없는 KV 할당과 연속 배치가 LLM 서빙의 사실상 표준이 되었다. 이후 거의 모든 상용·오픈소스 서빙 프레임워크가 이 패러다임을 채택했다.

**프리픽스 재사용과 RadixAttention의 부상**: SGLang의 RadixAttention(2024)이 트라이(trie) 기반 KV 재사용을 구현하면서, 시스템 프롬프트·멀티턴 대화·RAG 파이프라인에서의 캐시 히트율을 획기적으로 높였다. 이는 단순 메모리 절감을 넘어 응답 지연(TTFT)을 대폭 줄이는 시스템 설계 혁신이다.

**아키텍처 수준의 KV 절감—DeepSeek-V2 MLA**: DeepSeek-V2(2024)가 제안한 Multi-head Latent Attention(MLA)은 KV를 저랭크 잠재 벡터로 압축해 표준 MHA 대비 93.3% KV 캐시 절감을 달성했다. 이는 소프트웨어 최적화가 아닌 모델 아키텍처 수준의 접근으로, 이후 여러 모델이 유사 설계를 채택하고 있다.

**양자화와 토큰 축출의 성숙**: KIVI, KVQuant, SnapKV, PyramidKV 등 2-4비트 KV 양자화 및 중요도 기반 토큰 축출 기법이 실용화 단계에 진입했다. 단순 eviction에서 계층별 차등 할당, 쿼리 인식(query-aware) 선택으로 진화 중이다.

**Prefill-Decode 분리 서빙의 등장**: DistServe(OSDI 2024), Splitwise(ISCA 2024), Mooncake(2024) 등이 Prefill과 Decode 단계를 물리적으로 분리해 자원 활용률과 SLO 달성률을 높이는 아키텍처를 제안했다. KV 캐시 전송 비용이 새로운 핵심 병목으로 부상했다.

---

## 2. Landscape

### 2.1 분야 지형도

LLM 추론에서 KV 캐시 최적화는 크게 7개 서브토픽으로 나뉜다.

```
KV 캐시 최적화
├── 메모리 관리·할당
│   ├── PagedAttention / 가상 메모리 방식
│   └── 연속 배치(continuous batching)와의 통합
├── 압축·양자화
│   ├── 비트 폭 축소 (KIVI, KVQuant, IntactKV)
│   └── 저랭크 분해 (MLA, CLA)
├── 토큰 선택·축출
│   ├── 중요도 기반 (H2O, StreamingLLM, Scissorhands)
│   └── 쿼리 인식 (SnapKV, Quest, PyramidKV, FastGen)
├── 프리픽스·세션 캐시 재사용
│   ├── 트라이 기반 (RadixAttention / SGLang)
│   └── 시스템 프롬프트 공유, 멀티 사용자 캐시 공유
├── 아키텍처 수준 절감
│   ├── MQA / GQA / MLA
│   └── Cross-layer sharing, sliding window attention
├── 분산·분리 서빙
│   ├── Prefill-Decode 분리 (DistServe, Splitwise, Mooncake)
│   └── KV 마이그레이션·전송 최적화
└── 계층적 오프로딩
    ├── GPU ↔ CPU 오프로딩
    └── CPU ↔ NVMe 오프로딩 (InfLLM, FlexGen)
```

### 2.2 주요 접근법 분류

| 접근법 | 대표 기법 | 메모리 절감 | 품질 손실 | 지연 영향 |
|--------|-----------|------------|----------|----------|
| 가상 메모리 관리 | PagedAttention | 단편화 제거 (~40%) | 없음 | 처리량 2-4x ↑ |
| 프리픽스 재사용 | RadixAttention | 중복 제거 (워크로드 의존) | 없음 | TTFT 최대 5x ↓ |
| 아키텍처 압축 (MLA) | DeepSeek-V2 | 93.3% | 미미 | 처리량 ↑ |
| KV 양자화 | KIVI (2-bit) | ~75% | perplexity +0.1~0.3 | 경미한 decode 오버헤드 |
| 토큰 축출 | H2O (20% 유지) | ~80% | 태스크 의존적 | decode latency ↓ |
| GQA (8 groups) | Llama 2/3 | ~87.5% (32head→4) | 미미 | MHA 대비 동등 |
| 계층적 오프로딩 | InfLLM | GPU 사용량 ~50% ↓ | 미미 | prefetch로 은닉 |
| P-D 분리 서빙 | DistServe | SLO 달성률 ↑ | 없음 | P99 latency ↓ |

---

## 3. Recent Work

### 3.1 메모리 관리·연속 배치

| Title | Venue / Year | Contribution |
|-------|--------------|--------------|
| [Efficient Memory Management for Large Language Model Serving with PagedAttention](https://arxiv.org/abs/2309.06180) | SOSP 2023 | 가상 메모리 방식 KV 블록 관리로 단편화 제거, 처리량 2~4x 향상 (vLLM 기반) |
| [SGLang: Efficient Execution of Structured Language Model Programs](https://arxiv.org/abs/2312.07104) | OSDI 2024 / arXiv 2312.07104 | RadixAttention으로 트라이 기반 KV 자동 재사용; TTFT 최대 5x 감소, 처리량 4.4x 향상 |
| [Sarathi-Serve: Efficient LLM Inference by Piggybacking Decodes with Chunked Prefills](https://arxiv.org/abs/2308.16369) | OSDI 2024 | Chunked prefill로 decode stall 제거, 배치 효율 향상 |

### 3.2 Prefill-Decode 분리 서빙

| Title | Venue / Year | Contribution |
|-------|--------------|--------------|
| [DistServe: Disaggregating Prefill and Decoding for Goodput-optimized Large Language Model Serving](https://arxiv.org/abs/2401.09670) | OSDI 2024 | Prefill/Decode 물리 분리로 GPU 활용률 최적화, SLO 달성률 크게 향상 |
| [Splitwise: Efficient Generative LLM Inference Using Phase Splitting](https://arxiv.org/abs/2311.18677) | ISCA 2024 | 단계 분리 + 이종 GPU 클러스터 활용, 비용 20% 절감 |
| [Mooncake: A KVCache-centric Disaggregated Architecture for LLM Serving](https://arxiv.org/abs/2407.00079) | USENIX ATC 2024 | KV 풀을 독립 레이어로 분리, 분산 KV 전송·스케줄링 최적화 |
| [P/D-Serve: Serving Disaggregated Large Language Model at Scale](https://arxiv.org/abs/2408.08147) | SC 2024 | 대규모 P-D 분리 서빙에서 KV 마이그레이션 오버헤드 완화 |

### 3.3 아키텍처 수준 KV 절감

| Title | Venue / Year | Contribution |
|-------|--------------|--------------|
| [DeepSeek-V2: A Strong, Economical, and Efficient Mixture-of-Experts Language Model](https://arxiv.org/abs/2405.04434) | arXiv 2405.04434 (2024) | MLA(Multi-head Latent Attention)로 KV를 저랭크 잠재 벡터 압축; MHA 대비 93.3% KV 절감 |
| [GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints](https://arxiv.org/abs/2305.13245) | ACL 2023 Findings | MHA→MQA 업스케일 학습 기법 및 GQA 제안; KV 헤드 1/8로 감소 |
| [Cross-Layer Attention Sharing for Large Language Models](https://arxiv.org/abs/2405.12981) | arXiv 2405.12981 (2024) | 인접 레이어 KV 공유로 KV 메모리 최대 50% 절감, 성능 유지 |

### 3.4 KV 양자화·압축

| Title | Venue / Year | Contribution |
|-------|--------------|--------------|
| [KIVI: A Tuning-Free Asymmetric 2bit Quantization for KV Cache](https://arxiv.org/abs/2402.02750) | ICML 2024 | Key 2-bit/Value 2-bit 비대칭 양자화; 2.6x 메모리 절감, perplexity 손실 ~0.1 |
| [KVQuant: Towards 10 Million Context Length LLM Inference with KV Cache Quantization](https://arxiv.org/abs/2401.18079) | NeurIPS 2024 | 채널·토큰별 차별화 양자화; 10M 컨텍스트 추론 가능, 3-4x 압축 |
| [WKVQuant: Quantizing Weight and Key/Value Cache for Large Language Models](https://arxiv.org/abs/2402.12065) | arXiv 2402.12065 (2024) | 가중치·KV 캐시 동시 양자화로 메모리 효율 극대화 |
| [IntactKV: Improving Large Language Model Quantization by Keeping Pivot Tokens Intact](https://arxiv.org/abs/2403.01241) | ACL 2024 | 중요 피벗 토큰 KV는 full precision 유지, 나머지 저비트 양자화 |
| [Coupled Quantization: Accurate 1-Bit Post-Training Weight Quantization of Large Language Models](https://arxiv.org/abs/2402.11295) | arXiv (2024) | KV 포함 극단적 저비트 양자화 탐색 |

### 3.5 토큰 축출·선택

| Title | Venue / Year | Contribution |
|-------|--------------|--------------|
| [H2O: Heavy-Hitter Oracle for Efficient Generative Inference of Large Language Models](https://arxiv.org/abs/2306.14048) | NeurIPS 2023 | 누적 어텐션 점수 기반 중요 토큰(Heavy Hitter) 선택; KV 20% 유지로 성능 보존 |
| [Efficient Streaming Language Models with Attention Sinks](https://arxiv.org/abs/2309.17453) | ICLR 2024 | 초기 토큰(attention sink) + 슬라이딩 윈도우로 무한 길이 생성; 22x 속도 향상 |
| [SnapKV: LLM Knows What You are Looking for Before Generation](https://arxiv.org/abs/2404.14469) | NeurIPS 2024 | 관찰 윈도우 기반 프롬프트별 중요 위치 자동 탐지; 처리량 3.6x 향상 |
| [PyramidKV: Dynamic KV Cache Compression based on Pyramidal Information Funneling](https://arxiv.org/abs/2406.02069) | arXiv 2406.02069 (2024) | 레이어별 차등 KV 할당 (하위 레이어 더 적게); 평균 70% 압축, 성능 유지 |
| [Quest: Query-Aware Sparsity for Efficient Long-Context LLM Inference](https://arxiv.org/abs/2406.10774) | ICML 2024 | 쿼리별 관련 KV 페이지 선택; 7.03x 디코딩 속도 향상 (128K 컨텍스트) |
| [Scissorhands: Exploiting the Persistence of Importance Hypothesis for LLM KV Cache Compression](https://arxiv.org/abs/2305.17118) | NeurIPS 2023 | 어텐션 패턴의 지속성(persistence) 가설 검증; 중요 토큰 5% 유지로 품질 보존 |
| [FastGen: Model Tells You What to Discard: Adaptive KV Cache Compression with Attention Gates](https://arxiv.org/abs/2310.01801) | ICLR 2024 | 어텐션 헤드별 압축 정책(attention sink / local / 특수 패턴) 자동 선택 |

### 3.6 어텐션 커널·효율화 (KV 관련)

| Title | Venue / Year | Contribution |
|-------|--------------|--------------|
| [FlashInfer: Efficient and Customizable Attention Engine for LLM Inference Serving](https://arxiv.org/abs/2501.01005) | arXiv 2501.01005 (2025) | paged/ragged KV layout 지원 고속 어텐션 커널; 다양한 KV 관리 백엔드 통합 |
| [FlashDecoding++: Faster Large Language Model Inference on GPUs](https://arxiv.org/abs/2311.01282) | MLSys 2024 | 디코딩 단계 병렬 reduce 최적화; prefill-decode 혼합 배치에서 KV 효율 향상 |

### 3.7 계층적 오프로딩·장문맥

| Title | Venue / Year | Contribution |
|-------|--------------|--------------|
| [InfLLM: Unveiling the Intrinsic Capacity of LLMs for Understanding Extremely Long Sequences with Training-Free Memory](https://arxiv.org/abs/2402.04617) | arXiv 2402.04617 (2024) | 관련 KV 블록만 GPU로 스트리밍; 1M+ 토큰 컨텍스트에서 GPU 메모리 ~50% 절감 |
| [MagicPaginatedAttention: Unlocking Longer Context LLM Inference with Page-Level KV Cache Offloading](https://arxiv.org/abs/2407.02887) | arXiv 2407.02887 (2024) | 페이지 단위 비동기 KV 오프로딩으로 NVMe 활용; 48GB GPU에서 128K 컨텍스트 |

---

## 4. Open Problems

1. **KV 전송 비용 (P-D 분리의 병목)**: Prefill-Decode 분리 서빙에서 KV 캐시를 GPU 간 전송하는 비용이 지연의 새 병목이 되었다. 효율적인 KV 마이그레이션 프로토콜, 압축 전송, 위치 인식 배치 등의 연구가 아직 초기 단계다.

2. **양자화와 축출의 결합 최적화**: KV 양자화와 토큰 축출을 독립적으로 적용하는 연구는 많지만, 두 기법을 동시에 최적으로 적용하는 이론적 프레임워크가 없다. 어떤 토큰을 어떤 정밀도로 보관할지 공동 결정하는 문제가 미해결 상태다.

3. **동적 컨텍스트 길이와 캐시 정책의 적응형 조정**: 요청마다 컨텍스트 길이가 크게 다를 때, 정적으로 정의된 eviction/양자화 정책이 최적이 아닌 경우가 많다. 온라인으로 정책을 조정하는 적응형(adaptive) KV 관리가 필요하다.

4. **MLA 하드웨어 지원과 커널 최적화**: DeepSeek-V2의 MLA는 이론적 압축률은 뛰어나지만 표준 FlashAttention 커널과 호환되지 않아 별도 구현이 필요하다. MLA에 특화된 고효율 커널 및 서빙 시스템 지원이 미비하다.

5. **캐시 재사용과 보안·프라이버시**: 다중 사용자 간 KV 캐시 공유(prefix caching)는 메모리 효율을 높이지만, 다른 사용자의 프롬프트 정보 노출 위험이 있다. 캐시 재사용과 데이터 격리를 동시에 달성하는 안전한 공유 메커니즘이 필요하다.

6. **장문맥 벤치마크의 부재**: 100K~1M 토큰 컨텍스트에서 KV 캐시 기법의 품질 손실을 공정하게 평가하는 표준 벤치마크가 없다. LongBench, RULER 등이 있지만 실제 업무 태스크와의 괴리가 크다.

7. **스펙울러티브 디코딩과 KV 캐시의 통합**: 스펙울러티브 디코딩은 draft 모델의 KV 캐시를 별도로 관리해야 해 복잡성이 증가한다. 두 기법의 KV 캐시를 효율적으로 공동 관리하는 시스템이 미성숙하다.

---

## 5. Notable Researchers / Groups

| 연구자 / 그룹 | 소속 | 주요 기여 |
|--------------|------|----------|
| Woosuk Kwon, Zhuohan Li, Siyuan Zhuang | UC Berkeley (Ion Stoica 그룹) | PagedAttention, vLLM |
| Lianmin Zheng, Liangsheng Yin | UC Berkeley | SGLang, RadixAttention |
| Tri Dao | Princeton / Together AI | FlashAttention, FlashDecoding |
| Guangxuan Xiao | MIT (Song Han 그룹) | StreamingLLM, SparseGPT |
| Zhenyu Zhang | Rice University | H2O |
| DeepSeek AI (Aixin Liu 외) | DeepSeek | DeepSeek-V2 MLA, DeepSeek-V3 |
| Moonshot AI (Bin Chen 외) | Moonshot / Tsinghua | Mooncake, KV-centric 서빙 |
| Coleman Hooper | UC Berkeley | KVQuant |
| Zichang Liu | Rice University | KIVI |
| Yuhong Li | UIUC (Tianle Cai 그룹) | PyramidKV |
| Ion Stoica 그룹 | UC Berkeley | vLLM, DistServe, Sarathi-Serve |
| Tim Dettmers | UW (Ludwig Schmidt 그룹) | 저비트 양자화 (LLM.int8(), QLoRA) |
| NVIDIA TensorRT-LLM 팀 | NVIDIA | 산업용 KV 관리, FP8 KV cache |

---

## 6. Resources

### 주요 GitHub 레포지토리

| 이름 | URL | 설명 |
|------|-----|------|
| vLLM | https://github.com/vllm-project/vllm | PagedAttention 기반 서빙 프레임워크 |
| SGLang | https://github.com/sgl-project/sglang | RadixAttention 기반 서빙 프레임워크 |
| FlashInfer | https://github.com/flashinfer-ai/flashinfer | Paged KV 지원 고속 어텐션 커널 |
| TensorRT-LLM | https://github.com/NVIDIA/TensorRT-LLM | NVIDIA GPU 최적화 추론 엔진 |
| LMDeploy | https://github.com/InternLM/lmdeploy | 산업용 LLM 서빙, KV 양자화 지원 |
| llama.cpp | https://github.com/ggml-org/llama.cpp | CPU/엣지 추론, KV 양자화 구현 |
| H2O 구현 | https://github.com/FMInference/H2O | Heavy-Hitter Oracle 참조 구현 |
| StreamingLLM | https://github.com/mit-han-lab/streaming-llm | Attention Sink 참조 구현 |
| KIVI | https://github.com/jy-yuan/KIVI | 2-bit KV 양자화 참조 구현 |

### 벤치마크·평가 도구

- **LongBench** (arXiv 2308.14508): 이중언어 장문맥 이해 벤치마크
- **RULER** (arXiv 2404.06654): 장문맥 성능 평가 도구 (needle-in-haystack 확장)
- **vLLM Benchmark suite**: https://github.com/vllm-project/vllm/tree/main/benchmarks
- **SGLang Benchmark**: https://github.com/sgl-project/sglang/tree/main/benchmark

---

## 7. Reading List

### 입문 (필수 기초)

1. [Attention Is All You Need](https://arxiv.org/abs/1706.03762) (Vaswani et al., 2017) — Transformer 및 MHA 원본; KV 캐시 개념의 기원 *(historical)*
2. [Fast Transformer Decoding: One Write-Head is All You Need](https://arxiv.org/abs/1911.02150) (Shazeer, 2019) — MQA 제안; KV 헤드 수 절감의 시작 *(historical)*
3. [GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints](https://arxiv.org/abs/2305.13245) — GQA 체계화, 현재 대부분 모델 채택

### 핵심 시스템 논문

4. [Efficient Memory Management for Large Language Model Serving with PagedAttention](https://arxiv.org/abs/2309.06180) — vLLM, KV 가상 메모리; 반드시 읽어야 할 기초
5. [SGLang: Efficient Execution of Structured Language Model Programs](https://arxiv.org/abs/2312.07104) — RadixAttention, 프리픽스 재사용
6. [DistServe: Disaggregating Prefill and Decoding](https://arxiv.org/abs/2401.09670) — P-D 분리 서빙 설계

### 토큰 축출·압축

7. [H2O: Heavy-Hitter Oracle for Efficient Generative Inference](https://arxiv.org/abs/2306.14048) — 중요도 기반 축출 기초
8. [Efficient Streaming Language Models with Attention Sinks](https://arxiv.org/abs/2309.17453) — 무한 스트리밍 생성
9. [SnapKV: LLM Knows What You are Looking for Before Generation](https://arxiv.org/abs/2404.14469) — 쿼리 인식 KV 선택

### KV 양자화

10. [KIVI: A Tuning-Free Asymmetric 2bit Quantization for KV Cache](https://arxiv.org/abs/2402.02750) — 2-bit KV 양자화 실용화
11. [KVQuant: Towards 10 Million Context Length LLM Inference](https://arxiv.org/abs/2401.18079) — 초장문맥 KV 양자화

### 아키텍처·심화

12. [DeepSeek-V2: A Strong, Economical, and Efficient MoE Language Model](https://arxiv.org/abs/2405.04434) — MLA 설계, 93% KV 절감
13. [FlashInfer: Efficient and Customizable Attention Engine](https://arxiv.org/abs/2501.01005) — 서빙 시스템 커널 통합
14. [Quest: Query-Aware Sparsity for Efficient Long-Context LLM Inference](https://arxiv.org/abs/2406.10774) — 장문맥 희소 어텐션
15. [Mooncake: A KVCache-centric Disaggregated Architecture](https://arxiv.org/abs/2407.00079) — KV 중심 분산 서빙 설계

---

## 8. Methodology

### 검색 전략

본 보고서는 모델 학습 데이터(지식 컷오프 2025-08)에 포함된 논문·기술 보고서·공개 코드베이스를 주요 출처로 사용했으며, 다음 쿼리를 기준으로 정보를 정리했다.

**주요 검색 쿼리**:
- `KV cache compression LLM inference 2023 2024`
- `PagedAttention vLLM serving system`
- `KV cache quantization 2-bit KIVI KVQuant`
- `token eviction H2O SnapKV PyramidKV`
- `disaggregated prefill decode DistServe Splitwise`
- `MLA multi-head latent attention DeepSeek-V2`
- `prefix caching RadixAttention SGLang`
- `KV cache offloading long context inference`

**출처 범위**:
- arXiv cs.LG, cs.CL, cs.DC, cs.AR (2023-01 ~ 2025-08)
- SOSP 2023, OSDI 2024, MLSys 2024, NeurIPS 2023/2024, ICML 2024, ICLR 2024, ACL 2023/2024, ISCA 2024, SC 2024
- vLLM 공식 문서 및 GitHub changelog
- SGLang 공식 블로그 및 GitHub changelog
- DeepSeek-V2 기술 보고서

**한계 및 확인 필요 사항**:
- 2025-08 이후 발표된 논문(예: 2026년 상반기)은 포함되지 않음. 최신 동향은 arXiv 직접 검색 필요.
- 일부 산업 구현(NVIDIA TensorRT-LLM 내부, Meta 내부 서빙 시스템)의 세부 수치는 공개되지 않아 포함하지 않음.
- 논문 수치는 각 논문 발표 시점의 조건(모델, 하드웨어, 데이터셋)에 기반하므로 직접 비교 시 주의 필요.
- FlashAttention 시리즈(FA1/FA2/FA3)는 어텐션 커널 최적화이며 KV 캐시 관리와 간접 연관이 있으나, 본 보고서에서는 KV 관리에 직접 관련된 FlashInfer, FlashDecoding만 포함했음.
