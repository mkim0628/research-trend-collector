---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-03
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-03)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview
>
> **신규성 주의:** 본 보고서는 직전 보고서(`reports/kv-cache-optimization-2026-04-30.md`, 총 78개 항목)를 기준으로 신규 발견 논문·기법만 수록합니다. 기존 항목(vLLM/SGLang/FlashInfer/KIVI/SnapKV/DistServe/Mooncake/MLA/YOCO 등 직전 보고서 78건)은 본문 산문에서만 인용합니다.

---

## 1. Executive Summary

### 트렌드 1: P/D 분리 서빙의 세밀화 — 집합(Aggregation)과 분리(Disaggregation)의 통합
2024년 DistServe·Splitwise·Mooncake가 확립한 Prefill/Decode(P/D) 분리 패러다임이 2025~2026년에는 더 세밀한 방향으로 진화하고 있다. TaiChi([arXiv:2508.01989](https://arxiv.org/abs/2508.01989))는 SLO 조건에 따라 집합·분리 모드를 동적으로 전환하는 통합 아키텍처로 goodput을 최대 77% 향상시켰고, DuetServe([arXiv:2511.04791](https://arxiv.org/abs/2511.04791))는 단일 GPU 내 SM 수준 분리를 필요한 순간에만 적용하는 적응형 다중화를 구현했다. MuxWise([arXiv:2504.14489](https://arxiv.org/abs/2504.14489))는 레이어 단위 인트라-GPU prefill-decode 다중화로 SLO 보증 하 처리량을 평균 2.20×(최대 3.06×) 향상시켰다. HuggingFace TGI가 2025년 12월 유지관리 모드에 들어가면서 vLLM/SGLang으로 생태계가 더욱 집중되고 있으며, Mooncake Transfer Engine이 vLLM v1에 직접 통합되었다.

### 트렌드 2: 추론(Reasoning) 특화 KV 압축의 부상
DeepSeek-R1 계열 Long-CoT 모델의 확산으로 수만 토큰 이상의 생성 과정에서 발생하는 KV 폭증 문제가 독립적인 연구 방향으로 굳어지고 있다. TriAttention([arXiv:2604.04921](https://arxiv.org/abs/2604.04921))은 pre-RoPE 공간의 Q/K 집중도(concentration) 특성을 삼각함수 급수로 모델링하여 AIME25 32K-token 생성에서 Full Attention과 동등한 정확도로 10.7× KV 메모리 절감과 2.5× 처리량 향상을 달성했다. TurboQuant([arXiv:2504.19874](https://arxiv.org/abs/2504.19874), ICLR 2026)는 랜덤 직교 회전과 MSE-unbiased 1-bit QJL 잔차를 결합한 벡터 양자화로 3-bit에서 측정 가능한 정확도 손실 없이 H100 기준 8× 속도 향상을 달성했다.

### 트렌드 3: 엣지·온디바이스 KV 오프로딩의 체계화
클라우드 서버가 아닌 임베디드 AI 플랫폼과 엣지 기기에서 장문맥 추론을 지원하기 위한 디스크 기반 KV 오프로딩 연구가 2025~2026년에 체계화되고 있다. KVSwap([arXiv:2511.11907](https://arxiv.org/abs/2511.11907))은 NVMe/eMMC 특성에 맞춘 KV 예측 사전적재(speculative preload)와 재사용 버퍼를 결합하여 NVIDIA Jetson Orin 플랫폼에서 압축 메모리 예산 하 기존 오프로딩 대비 처리량을 향상시켰다. Dual-Blade([arXiv:2604.26557](https://arxiv.org/abs/2604.26557))는 NVMe 직접 접근(Direct I/O) 경로와 페이지 캐시 경로를 이중화하여 prefill 지연 33.1%↓, decode 지연 42.4%↓를 달성했다.

### 트렌드 4: 다중 에이전트 환경 전용 KV 재사용·공유 시스템의 등장
단일 사용자-단일 모델 서빙에서 시작된 KV 재사용 연구가 다수의 에이전트가 동일 컨텍스트를 공유하는 멀티에이전트 아키텍처로 확장되고 있다. TokenDance([arXiv:2604.03143](https://arxiv.org/abs/2604.03143))는 All-Gather 패턴에서 블록-스파스 diff 방식으로 에이전트 간 KV를 단일 공유 복사본으로 압축하여 에이전트 KV 저장량을 17.5×↓, prefill 속도를 1.9×↑ 달성했다. PolyKV([arXiv:2604.24971](https://arxiv.org/abs/2604.24971))는 단일 압축 KV 캐시 풀(K: int8, V: TurboQuant MSE 3-bit)을 최대 15개 에이전트가 공유하여 Llama-3-8B 기준 KV 메모리를 97.7%↓를 달성했다.

### 트렌드 5: KV 캐시 보안·프라이버시 연구의 본격화
멀티테넌트 KV 캐시 공유 환경에서의 프라이버시 취약성이 2025년 하반기부터 독립 연구 영역으로 부상하고 있다. Shadow in the Cache([arXiv:2508.09442](https://arxiv.org/abs/2508.09442), NDSS 2026)는 KV 캐시에서 직접 민감한 사용자 입력을 역산할 수 있는 세 가지 공격 벡터(역산, 충돌, 주입)를 실증하고 경량 가역 행렬 난독화 방어 KV-Cloak을 제안했다. 이 연구 방향은 직전 보고서에서 DefensiveKV가 제기한 우려를 더욱 구체화하여, KV 캐시 공유 설계의 보안 기반 재검토를 촉구하고 있다.

---

## 2. Landscape — 분야 지형도

직전 보고서(2026-04-30)에서 확립한 7개 서브토픽 분류(A~G)는 그대로 유지되면서, 이번 기간(2026년 5월 기준)에 다음과 같은 새 세부 가지들이 성장하였다.

```
LLM KV 캐시 최적화 (2026-05 업데이트)
├── A. 서빙 시스템·메모리 관리
│   ├── (기존) PagedAttention / Chunked Prefill / APC / FlashInfer ...
│   ├── [신규] 집합·분리 통합 (TaiChi, MuxWise, DuetServe)
│   └── [신규] Mooncake Transfer Engine → vLLM v1 직접 통합
│
├── B. KV 양자화·압축
│   ├── (기존) KIVI / KVQuant / Palu / SVDq / KVTuner ...
│   ├── [신규] 벡터 양자화·회전 기반 (TurboQuant / PolyKV MSE-3bit)
│   ├── [신규] 어댑터 기반 cross-KV 예측 압축 (AQUA-KV)
│   └── [신규] 추론(Reasoning) 특화 삼각함수 압축 (TriAttention)
│
├── C. 토큰 축출·희소 어텐션
│   ├── (기존) SnapKV / Quest / ForesightKV / LookaheadKV ...
│   ├── [신규] Value 벡터 공간 앵커 방향 투영 (AnDPro / NeurIPS 2025)
│   ├── [신규] 학습 가능 토큰 유지 게이트 (TRIM-KV / Cache What Lasts)
│   └── [신규] 알고리즘-시스템 공동 설계 검색 (FreeKV)
│
├── D. 분산·분리 서빙 및 KV 전송
│   ├── (기존) DistServe / Splitwise / Mooncake / FlowKV ...
│   ├── [신규] 집합↔분리 동적 전환 (TaiChi)
│   ├── [신규] 레이어 단위 인트라-GPU 다중화 (MuxWise)
│   ├── [신규] 적응형 SM 분리 (DuetServe)
│   └── [신규] 다중 에이전트 KV 집합 공유 (TokenDance)
│
├── E. 아키텍처 수준 KV 절감
│   ├── (기존) MLA / TransMLA / YOCO / CLA / TPA ...
│   ├── [신규] 파라미터 공유 기반 크로스 레이어 압축 (CommonKV)
│   └── [신규] 에코(echo) 유사성 재구성 (EchoKV)
│
├── F. 장문맥·계층적 오프로딩
│   ├── (기존) ShadowKV / SpeCache / ScoutAttention / CXL-PNM ...
│   ├── [신규] 엣지·온디바이스 NVMe 오프로딩 (KVSwap, Dual-Blade)
│   └── [신규] 추론 특화 KV 압축 (TriAttention — F와 B의 교차 영역)
│
├── G. RAG·평가 방법론
│   ├── (기존) RAGCache / CacheBlend / RULER / SCBench ...
│   └── [신규] 서베이 논문 (KV Cache Optimization Strategies, 2603.20397)
│
└── H. 보안·프라이버시 (신규 서브토픽)
    ├── [신규] KV 역산·충돌·주입 공격 (Shadow in the Cache / KV-Cloak)
    └── [신규] 타이밍 사이드채널 방어 (SafeKV / arXiv:2508.08438)
```

### 주요 신규 흐름

- **Reasoning × KV**: Long-CoT 모델의 KV 폭증 문제는 단순 예산 제한 축출로 해결이 어렵다. TriAttention처럼 RoPE의 수학적 구조를 활용하는 알고리즘적 접근이 빠르게 성장하고 있다.
- **Multi-agent → 새 캐시 공유 단위**: 단일 요청 단위의 prefix caching을 넘어, 에이전트 라운드(All-Gather) 전체를 하나의 캐시 공유 단위로 다루는 TokenDance·PolyKV 계열이 출현하였다.
- **보안 vs. 효율 트레이드오프**: KV 재사용·공유는 효율성을 높이지만 프라이버시 위험을 수반한다는 사실이 구체적 공격 시연을 통해 확인되면서, 서빙 스택에 격리(isolation) 계층을 추가하는 방향이 부상하고 있다.

---

## 3. Recent Work

> **필터링 기준:** 직전 보고서 `kv-cache-optimization-2026-04-30.md` 78개 항목(URL/제목/기법명 집합)과 매칭된 항목은 제외하였다. 아래 표는 신규 논문·기법만 수록한다.

### A. 서빙 시스템·메모리 관리 (신규)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [TaiChi: Prefill-Decode Aggregation or Disaggregation?](https://arxiv.org/abs/2508.01989) | Wei et al. | arXiv 2025-08 | SLO에 따라 집합·분리 모드를 동적으로 전환하는 통합 서빙; goodput 최대 77%↑ | arXiv:2508.01989 |
| 2025 | [MuxWise: Towards High-Goodput LLM Serving with Prefill-decode Multiplexing](https://arxiv.org/abs/2504.14489) | Chen et al. | arXiv 2025-04 | 레이어 단위 버블-없는 인트라-GPU P/D 다중화; SLO 보장 처리량 2.20×(최대 3.06×)↑ | arXiv:2504.14489 |
| 2025 | [DuetServe: Harmonizing Prefill and Decode for LLM Serving via Adaptive GPU Multiplexing](https://arxiv.org/abs/2511.04791) | (저자 확인 필요) | arXiv 2025-11 | 오염 예측 시 SM 수준 공간 다중화 활성화; Qwen3 기준 처리량 1.3×↑ | arXiv:2511.04791 |

### B. KV 양자화·압축 (신규)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [TurboQuant: Online Vector Quantization with Near-optimal Distortion Rate](https://arxiv.org/abs/2504.19874) | Google Research / NYU | ICLR 2026 | 랜덤 직교 회전 + QJL 잔차로 3-bit 벡터 양자화; KV 6×↓, H100 기준 어텐션 8×↑ | arXiv:2504.19874 |
| 2025 | [AQUA-KV (Cache Me If You Must): Adaptive Key-Value Quantization for Large Language Models](https://arxiv.org/abs/2501.19392) | Shutova et al. | ICML 2025 | 인접 레이어 K/V 예측 어댑터로 예측 불가 잔차만 저장; Llama 3.2 기준 2~2.5-bit 무손실 | arXiv:2501.19392 |
| 2026 | [TriAttention: Efficient Long Reasoning with Trigonometric KV Compression](https://arxiv.org/abs/2604.04921) | MIT/NVIDIA/Zhejiang Univ. | arXiv 2026-04 | pre-RoPE Q/K 집중도 삼각함수 모델로 KV 중요도 추정; AIME25 10.7× KV 절감, 2.5×↑ | arXiv:2604.04921 |
| 2026 | [PolyKV: A Shared Asymmetrically-Compressed KV Cache Pool for Multi-Agent LLM Inference](https://arxiv.org/abs/2604.24971) | (저자 확인 필요) | arXiv 2026-04 | K: int8 + V: TurboQuant 3-bit 풀 공유로 15 에이전트 KV 97.7%↓ | arXiv:2604.24971 |

### C. 토큰 축출·희소 어텐션 (신규)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [AnDPro: Accurate KV Cache Eviction via Anchor Direction Projection for Efficient LLM Inference](https://arxiv.org/abs/2509.18143) | MIRA Lab, USTC | NeurIPS 2025 | Value 벡터 앵커 방향 투영 기반 토큰 중요도; LongBench 16개 데이터셋 96.07% 정확도, 3.44% 예산 | [OpenReview](https://openreview.net/forum?id=Tdl89SZItB) |
| 2025 | [Cache What Lasts (TRIM-KV): Token Retention for Memory-Bounded KV Cache in LLMs](https://arxiv.org/abs/2512.03324) | (저자 확인 필요) | arXiv 2025-12 | 경량 유지 게이트로 토큰 생성 시 장기 중요도 학습; GSM8K·AIME24·LongBench 전반 SOTA 대비 58.9% 향상 | arXiv:2512.03324 |
| 2025 | [FreeKV: Boosting KV Cache Retrieval for Efficient LLM Inference](https://arxiv.org/abs/2505.13109) | Liu et al. (SJTU/Huawei) | arXiv 2025-05 | 투기적 검색(speculative retrieval) + 하이브리드 CPU/GPU 레이아웃으로 KV 검색 임계경로 제거; SOTA KV 검색 대비 13×↑ | arXiv:2505.13109 |

### D. 분산·분리 서빙 및 KV 전송 (신규)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [TokenDance: Scaling Multi-Agent LLM Serving via Collective KV Cache Sharing](https://arxiv.org/abs/2604.03143) | (저자 확인 필요) | arXiv 2026-04 | All-Gather 라운드 단위 블록-스파스 diff KV 공유; 에이전트 KV 17.5×↓, prefill 1.9×↑ | arXiv:2604.03143 |

### E. 아키텍처 수준 KV 절감 (신규)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [CommonKV: Compressing KV Cache with Cross-layer Parameter Sharing](https://arxiv.org/abs/2508.16134) | (저자 확인 필요) | arXiv 2025-08 | 인접 레이어 파라미터 SVD 유사성 기반 가중치 공유 KV 압축; 양자화·축출 결합 시 98% 압축 가능 | arXiv:2508.16134 |

### F. 장문맥·계층적 오프로딩 (신규)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [KVSwap: Disk-aware KV Cache Offloading for Long-Context On-device Inference](https://arxiv.org/abs/2511.11907) | (저자 확인 필요) | arXiv 2025-11 | 스토리지 특성별(NVMe/eMMC) 예측 사전적재 + 재사용 버퍼; Jetson Orin 기준 제한 메모리에서 기존 오프로딩 대비 처리량↑ | arXiv:2511.11907 |
| 2026 | [Dual-Blade: Dual-Path NVMe-Direct KV-Cache Offloading for Edge LLM Inference](https://arxiv.org/abs/2604.26557) | Jeong et al. | arXiv 2026-04 | 페이지 캐시·NVMe 직접 이중 경로 + 적응 파이프라인 병렬; prefill 33.1%↓, decode 42.4%↓ | arXiv:2604.26557 |

### G. RAG·평가 방법론 / 서베이 (신규)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [KV Cache Optimization Strategies for Scalable and Efficient LLM Inference](https://arxiv.org/abs/2603.20397) | Xu et al. (Dell Technologies) | arXiv 2026-03 | 5개 방향(축출·압축·하이브리드 메모리·아키텍처·조합) 체계적 리뷰; 2026년 시점 분야 현황 지형도 | arXiv:2603.20397 |

### H. 보안·프라이버시 (신규 서브토픽)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [Shadow in the Cache: Unveiling and Mitigating Privacy Risks of KV-cache in LLM Inference](https://arxiv.org/abs/2508.09442) | Luo, Shao et al. | NDSS 2026 | KV 역산·충돌·주입 3종 공격 실증 + KV-Cloak 가역 행렬 난독화 방어; 정확도 손실 무시 수준 | arXiv:2508.09442 |
| 2025 | [Selective KV-Cache Sharing to Mitigate Timing Side-Channels in LLM Inference (SafeKV)](https://arxiv.org/abs/2508.08438) | (저자 확인 필요) | arXiv 2025-08 | 민감도 분류 기반 선택적 KV 공유로 타이밍 사이드채널 차단; 처리량 이득 대부분 유지 | arXiv:2508.08438 |

---

## 4. Open Problems

직전 보고서(2026-04-30)의 7개 미해결 과제에 더해, 이번 수집에서 확인된 추가 과제들이다.

### 문제 8: 집합·분리 모드 동적 전환의 오버헤드와 안정성
TaiChi·DuetServe·MuxWise는 SLO 위반 예측을 기반으로 서빙 모드를 동적으로 변경한다. 그러나 모드 전환 자체에 수반되는 KV 마이그레이션 비용, 예측 오류(false positive/negative) 처리, 멀티테넌트 워크로드에서의 SLO 충돌은 아직 충분히 분석되지 않았다.

### 문제 9: 다중 에이전트 KV 공유에서의 비동기·장기 세션 처리
TokenDance·PolyKV는 동기화된 라운드 구조를 전제한다. 에이전트가 비동기로 실행되거나 세션이 장기간 지속될 때 공유 KV가 오염(staleness)될 위험, 에이전트 별 개인화(fine-tuning) 차이로 인한 KV 불일치 문제는 미해결 상태이다.

### 문제 10: TurboQuant 등 벡터 양자화 기법의 추론(Reasoning) 모델 적용 검증
TurboQuant는 NLP 벤치마크에서 무손실 3-bit를 달성했지만, Long-CoT reasoning 모델(DeepSeek-R1, o3 계열)의 수만 토큰 생성 과정에서 양자화 편향이 누적될 수 있는지 체계적으로 검증된 결과가 아직 없다. TriAttention이 지적한 RoPE 위치 변화에 따른 쿼리 회전 문제는 벡터 양자화에도 잠재적으로 적용된다.

### 문제 11: 엣지·온디바이스 오프로딩의 표준화된 평가 프레임워크 부재
KVSwap(Jetson Orin AGX), Dual-Blade(NVMe 직접 접근), llama.cpp NVMe 오프로딩은 각자 다른 하드웨어·소프트웨어 스택에서 평가되어 직접 비교가 불가능하다. 엣지 LLM 추론을 위한 표준 벤치마크(디바이스 프로파일, I/O 대역폭 스펙, 모델 크기 등급)가 없다.

### 문제 12: KV 보안과 캐시 효율의 근본적 트레이드오프
SafeKV·KV-Cloak는 KV 공유를 제한하거나 난독화하여 프라이버시를 보호하지만, 이는 캐시 히트율 감소와 난독화 연산 오버헤드를 수반한다. 보안 보장의 강도(예: 완전 격리 vs. 통계적 방어)와 서빙 처리량 사이의 정량적 트레이드오프 곡선을 체계적으로 측정하는 연구가 없다.

---

## 5. Notable Researchers / Groups

직전 보고서의 Notable Researchers 목록에 이번 수집에서 새롭게 확인된 그룹을 추가한다.

| 이름/그룹 | 소속 | 대표 기여 |
|-----------|------|----------|
| **Google Research / Google DeepMind** | Google | TurboQuant (ICLR 2026) — 벡터 양자화 KV 압축; [연구 블로그](https://research.google/blog/turboquant-redefining-ai-efficiency-with-extreme-compression/) |
| **MIT / NVIDIA / Zhejiang Univ. 협력팀** | MIT, NVIDIA, Zhejiang Univ. | TriAttention — 추론 특화 삼각함수 KV 압축 (2026) |
| **MIRA Lab, USTC** | USTC (중국과학기술대) | AnDPro (NeurIPS 2025) — 앵커 방향 투영 KV 축출 |
| **Shanghai Jiao Tong Univ. / Huawei** | SJTU, Huawei | FreeKV (2025) — 투기적 KV 검색 + 알고리즘-시스템 공동 설계 |
| **Luo, Shao et al.** | (소속 확인 필요) | Shadow in the Cache (NDSS 2026) — KV 프라이버시 공격·방어 |

직전 보고서의 기존 그룹(UC Berkeley Sky Lab, DeepSeek, MIT/NVIDIA Song Han 그룹, MIRA Lab 등)은 지속 활발히 활동 중이며 업데이트는 생략한다.

---

## 6. Resources

### 신규 오픈소스 코드·라이브러리

| 자원 | URL | 설명 |
|------|-----|------|
| TurboQuant (비공식 구현) | https://github.com/hackimov/turboquant-kv | Google TurboQuant ICLR 2026 오픈소스 PyTorch 구현 |
| TurboQuant Triton 커널 | https://github.com/0xSero/turboquant | Triton 커널 + vLLM 통합 구현 |
| TriAttention | https://github.com/WeianMao/triattention | 삼각함수 KV 압축; vLLM 플러그인 포함 |
| AnDPro | https://github.com/MIRALab-USTC/LLM-AnDPro | NeurIPS 2025 앵커 방향 투영 KV 축출 공식 구현 |
| NVIDIA KVPress | https://github.com/NVIDIA/kvpress | NVIDIA 공식 KV 캐시 압축 도구 모음 (다수 기법 통합) |
| Mooncake (vLLM 통합) | https://kvcache-ai.github.io/Mooncake/ | Mooncake Transfer Engine; vLLM v1 KV Connector로 직접 통합 |

### 신규 벤치마크·평가 도구

| 자원 | URL/arXiv | 설명 |
|------|----------|------|
| KV Cache Optimization Strategies 서베이 | https://arxiv.org/abs/2603.20397 | 2026년 기준 5개 방향 분류 체계와 empirical 비교 |
| AIME 2025 (추론 모델 KV 평가) | 공식 경시대회 데이터 | TriAttention·ForesightKV 등 Reasoning KV 평가에 표준 기준으로 사용 |

---

## 7. Reading List

직전 보고서(2026-04-30)의 Reading List(입문~심화 20편)를 그대로 유지하며, 신규 진입 권고 자료를 아래에 추가한다.

### 신규 추가 (심화)

21. **[TurboQuant](https://arxiv.org/abs/2504.19874)** (Google Research, ICLR 2026) — 벡터 양자화의 편향 문제를 QJL 잔차로 해결; KV 양자화의 이론적 기반 심화.
22. **[TriAttention](https://arxiv.org/abs/2604.04921)** (MIT/NVIDIA, arXiv 2026) — RoPE의 수학적 구조를 KV 압축에 활용; Reasoning 모델 특화 KV 연구의 시발점.
23. **[Shadow in the Cache](https://arxiv.org/abs/2508.09442)** (NDSS 2026) — KV 캐시 프라이버시 위험의 최초 체계적 공격·방어 연구; 보안 관점 필독.
24. **[TaiChi](https://arxiv.org/abs/2508.01989)** (arXiv 2025) — 집합·분리 통합 서빙의 이론적 틀; 서빙 시스템 설계자 필독.
25. **[FreeKV](https://arxiv.org/abs/2505.13109)** (SJTU/Huawei, arXiv 2025) — KV 검색 병목 제거 방법론; 알고리즘-시스템 공동 설계 사례 연구.

---

## 8. Methodology

### 검색 쿼리

본 보고서에서 신규 자료 수집에 사용한 검색 쿼리는 다음과 같다.

```
"KV cache optimization" LLM inference 2025 2026 new arxiv
"KV cache quantization" compression LLM 2025 2026 novel method
TurboQuant Google ICLR 2026 KV cache vector quantization arxiv
"prefill decode disaggregation" LLM serving 2025 2026 new system
KV cache eviction token selection LLM 2025 2026 new technique sparse attention
MLA multi-head latent attention architecture KV reduction 2025 2026
KV cache offloading long context GPU CPU NVMe 2025 2026 arxiv
FreeKV arxiv 2505 LLM KV cache retrieval
TRIM-KV learnable token retention KV cache arxiv 2025
KV cache survey 2025 2026 arxiv comprehensive review
KVSwap disk KV cache offloading NVMe arxiv 2511 2025
AnDPro anchor direction projection KV cache eviction NeurIPS 2025
TaiChi LLM serving prefill decode aggregation disaggregation arxiv 2508
AQUA-KV adaptive quantization key value cache Llama 2025
MuxWise prefill decode multiplexing LLM serving arxiv 2504
DuetServe harmonizing prefill decode GPU multiplexing arxiv 2511
"Shadow in the Cache" KV privacy risks LLM arxiv 2508
TriAttention reasoning LLM KV cache memory reduction AIME
CommonKV cross layer parameter sharing KV compression SVD arxiv 2508
Dual-Blade NVMe-direct KV cache offloading edge LLM
PolyKV multi-agent LLM asymmetric compressed KV cache pool
TokenDance multi-agent LLM serving KV cache sharing arxiv 2604
vLLM SGLang 2025 2026 new features KV cache update
KV cache security privacy attack side channel timing 2025 2026
```

### 수집 출처

| 범주 | 출처 |
|------|------|
| ML/시스템 컨퍼런스 | ICLR 2026, NeurIPS 2025, ICML 2025 |
| 보안 컨퍼런스 | NDSS 2026 |
| 프리프린트 | arXiv cs.LG, cs.CL, cs.DC (2025-04 ~ 2026-04) |
| 산업 블로그 | Google Research Blog, vLLM Blog, SGLang/LMSYS Blog, NVIDIA KVPress |
| 집계 사이트 | MarkTechPost (2026-04-29 KV 압축 Top-10), Spheron Blog |

### 신규성 필터 적용 결과

- **비교 대상:** 직전 보고서 `kv-cache-optimization-2026-04-30.md` 78개 항목
- **제외된 기존 항목:** vLLM, SGLang, FlashInfer, KIVI, KVQuant, CQ, ZipCache, MiniCache, Palu, KVTuner, MiniKV, AsymKV, LogQuant, KITTY, xKV, SVDq, MixKVQ, PM-KVQ, KVTC, WKVQuant, RVQ-KV, Quest, MInference, NACL, DuoAttention, HeadKV, HashEvict, Ada-KV, TokenSelect, ChunkKV, RocketKV, FastKV, DefensiveKV, Expected Attention, LAVa, CAOTE, ForesightKV, LookaheadKV, DistServe, Splitwise, Mooncake, CacheGen, CacheBlend, LMCache, FlowKV, BanaServe, TraCT, CXL-SpecKV, ShadowKV, PrefillShare, DualMap, KVShare, Nexus, HydraInfer, DeepSeek-V2(MLA), DeepSeek-V3, TransMLA, MHA2MLA, X-EcoMLA, YOCO, YOCO++, CLA, LCKV, KVSharer, NSA, TPA, MFA, MTLA, InfiniGen, MagicPIG, RetrievalAttention, SpeCache, ScoutAttention, InfiniteHiP, Async KV Prefetch, CXL-PNM, CXL-NDP, MILLION, RAGCache, Cache-Craft, RULER, SCBench, SGLang v0.4, Sarathi-Serve, vAttention, POD-Attention, LServe, QServe, NanoFlow, BatchLLM, TetriInfer, ThunderServe, Preble, EAGLE, EAGLE-2, VIDUR, LMCache, DualMap, Nexus — 총 78건 제외
- **신규 수록 항목:** 총 14개 논문 (Section 3 각 소카테고리 참조)

### 가정 및 한계

- **저자 정보 미확인:** TaiChi(2508.01989), DuetServe(2511.04791), PolyKV(2604.24971), CommonKV(2508.16134), Cache What Lasts(2512.03324), TokenDance(2604.03143), KVSwap(2511.11907), SafeKV(2508.08438) 등 일부 논문의 저자 전체 명단을 검색 스니펫에서 확인하지 못하였다. "저자 확인 필요"로 표기한 항목은 arXiv 원문에서 직접 확인이 필요하다.
- **비공식 TurboQuant 구현:** GitHub 링크(hackimov/turboquant-kv, 0xSero/turboquant)는 Google 공식 코드가 아닌 커뮤니티 구현이다. Google의 공식 코드 공개 여부는 확인 필요.
- **AnDPro arXiv ID:** OpenReview/NeurIPS 2025 공식 링크([Tdl89SZItB](https://openreview.net/forum?id=Tdl89SZItB))는 확인되었으나, 대응하는 arXiv ID(2509.18143로 추정)는 검색 스니펫에서 명시적으로 확인되지 않았다. 확인 필요.
- 수치(배속, 압축률)는 각 논문이 자체 보고한 수치이며, 하드웨어 환경·기준선이 논문마다 상이하므로 직접 비교에 주의가 필요하다.
- time_range 2026-05 이후 논문(예: Dual-Blade 2604.26557, PolyKV 2604.24971, TokenDance 2604.03143, TriAttention 2604.04921)은 기술적으로 2026-04 마감 경계에 걸쳐 있다. 이들은 arXiv 제출 날짜 기준 2026년 4월이므로 time_range 내로 포함하였다.
