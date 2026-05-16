---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-16
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-16)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview
>
> **신규성 주의:** 본 보고서는 직전 다섯 편의 보고서(`2026-04-30` 78건, `2026-05-02` 29건, `2026-05-03` 14건, `2026-05-04` 18건, `2026-05-14` 18건, 총 157건)를 기준으로 **신규 발견 논문·기법만** 수록합니다.

---

## 1. Executive Summary

### 트렌드 1: 에이전틱(Agentic) 워크플로우 전용 KV 관리의 부상
단일 요청 기반 KV 관리 연구가 다중 단계 에이전트 워크플로우로 확장되고 있다. PBKV([arXiv:2605.06472](https://arxiv.org/abs/2605.06472))는 동적 워크플로우에서 미래 에이전트 호출을 예측해 재사용 가능성이 높은 KV를 GPU에 선제 유지하는 방법으로, LRU 대비 1.85× 가속을 달성하였다. SideQuest([arXiv:2602.22603](https://arxiv.org/abs/2602.22603))는 LRM 자체가 KV 중요도를 추론하는 모델 주도 방식으로, 복잡한 에이전트 벤치마크에서 KV 60% 절감과 정확도 무손실을 실현하였다. 이 흐름은 "어떤 토큰이 중요한가"라는 질문을 단일 요청 시야에서 다중 에이전트 대화 전체 시야로 확장하는 패러다임 전환을 나타낸다.

### 트렌드 2: 도메인 특화 KV 압축 — 코드·비디오·추론 모델 전용 기법의 다양화
범용 eviction·양자화에서 벗어나, 특정 도메인의 구조적 특성을 KV 관리에 직접 활용하는 연구가 집중 등장하였다. CodeComp([arXiv:2604.10235](https://arxiv.org/abs/2604.10235))는 코드 속성 그래프(CPG)를 통해 콜 사이트·분기 조건 등 구조적으로 중요한 토큰을 보호하여, 에이전틱 코딩 벤치마크에서 어텐션 기반 기준선을 일관되게 상회한다. VidKV([arXiv:2503.16257](https://arxiv.org/abs/2503.16257))는 비디오 LLM 시각 토큰을 1.5~1.58-bit까지 압축하여 FP16 대비 성능 저하 없음을 달성하였다. 이처럼 코드·비디오·수학 추론 각 도메인에 특화된 KV 압축 기법이 독립 서브필드로 성숙하고 있다.

### 트렌드 3: 입력 활성화 재구체화(Rematerialization) — KV 캐시 저장 패러다임의 전환
KV 텐서 자체를 저장하는 대신 입력 활성화 X를 양자화·캐시하고 필요 시 K·V를 온더플라이로 재계산하는 XQuant([arXiv:2508.10395](https://arxiv.org/abs/2508.10395))가 10~12.5× 메모리 절감(vs FP16)과 PPL 저하 0.1 미만을 달성하였다. 하나의 텐서(X)만 저장하면 K와 V를 따로 저장할 때보다 기본적으로 2× 메모리 이점이 발생하며, X는 KV보다 극저비트 양자화에 더 친화적이다. 이는 "KV를 압축하는" 대신 "KV 생성 원료를 압축하는" 방향으로의 패러다임 전환으로, 기존 양자화 연구와 직교적인 접근이다.

### 트렌드 4: 분산·분리 서빙의 이론·구현 완성도 향상
KVDirect([arXiv:2501.14743](https://arxiv.org/abs/2501.14743))는 단일 노드 제약을 넘어 다중 노드 분산 P/D 분리 추론을 가능하게 하는 텐서 중심 통신 메커니즘을 제안, KV 전송 오버헤드를 총 지연의 0.5~1.1%로 최소화하고 요청당 지연을 55% 절감하였다. 아울러 vLLM의 Q2 2026 로드맵은 Mooncake Store 통합(교차 인스턴스 KV 공유 엔진)과 Hybrid Memory Allocator 전면 활성화를 목표로 하고 있어, 분산 KV 관리가 서빙 엔진의 핵심 기능으로 내재화되는 추세가 더욱 강화되고 있다.

### 트렌드 5: 구조적 복합 토큰(Composite Token)을 통한 KV 축출의 엔진 호환성 확보
KVCompose([arXiv:2509.05165](https://arxiv.org/abs/2509.05165))는 헤드별로 독립적인 토큰 선택을 수행한 뒤, 결과를 기존 추론 엔진이 요구하는 균일 텐서 구조로 정렬하는 복합 토큰 방식을 제안하였다. 이는 기존 헤드별 비균일 eviction이 특수 커널을 요구하던 한계를 극복하여, 헤드 수준 세밀도와 엔진 호환성을 동시에 달성한다. 이 방향은 알고리즘 정교화와 시스템 통합 사이의 오랜 갈등을 해소하는 실용적 전략으로 주목된다.

---

## 2. Landscape — 분야 지형도

직전 보고서(2026-05-14)에서 확립한 A~H 서브토픽 분류를 유지하면서, 2026년 5월 중하순 기준 다음과 같은 새 흐름이 관찰된다.

```
LLM KV 캐시 최적화 (2026-05-16 업데이트)
├── A. 서빙 시스템·메모리 관리
│   ├── (기존) vLLM V1 / SGLang HiCache / PPD Disaggregation ...
│   ├── [신규] 동적 에이전트 워크플로우 예측 기반 KV 관리 (PBKV)
│   └── [신규] KV 제약 온라인 스케줄링 이론 (Online Scheduling for LLM KV)
│
├── B. KV 양자화·압축
│   ├── (기존) KIVI / KVQuant / TurboQuant / RateQuant / FibQuant ...
│   ├── [신규] 입력 활성화 재구체화 방식 (XQuant / XQuant-CL)
│   ├── [신규] 엔트로피 코딩 결합 LLM 인식 압축 (KVComp)
│   ├── [신규] 복합 토큰 구조적 압축 (KVCompose)
│   └── [신규] 비디오 LLM 전용 1.x-bit (VidKV)
│
├── C. 토큰 축출·희소 어텐션
│   ├── (기존) LKV / LaProx / Louver / MISA / StreamIndex ...
│   ├── [신규] 글로벌 리텐션 게이트 학습 (DBTrimKV / Make Each Token Count)
│   ├── [신규] 모델 주도 에이전틱 KV 관리 (SideQuest)
│   └── [신규] 코드 속성 그래프 기반 구조 보호 (CodeComp)
│
├── D. 분산·분리 서빙 및 KV 전송
│   ├── (기존) DistServe / Mooncake / FlowKV / KVDirect(신규) ...
│   └── [신규] 다중 노드 분산 P/D 분리 텐서 중심 통신 (KVDirect)
│
├── E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)
│   ├── (기존) MLA / TransMLA / YOCO / TPA / MTLA / MHA2MLA ...
│   └── [신규] 잠재 공간 임베딩 게이팅 MLA 확장 (EG-MLA)
│
├── F. 장문맥·계층적 오프로딩
│   └── (기존) Tutti / KV-Fold / Fluxion / KVSwap / Dual-Blade ...
│       (이번 수집에서 신규 없음)
│
└── G. VLM·멀티모달 KV 관리
    ├── (기존) LightKV / RetentiveKV / WindowQuant ...
    └── [신규] 비디오 LLM 채널별 혼합 정밀도 (VidKV)
```

### 주요 신규 흐름

- **에이전트 워크플로우 단위 캐시 계획**: PBKV·SideQuest는 "현재 요청 내" KV 관리 단위를 "다중 턴 에이전트 실행 전체"로 확장한다. 이는 KV 관리의 시간 지평(time horizon)을 근본적으로 확대하는 패러다임 전환이다.
- **재구체화(Rematerialization) 방향**: XQuant는 KV를 저장하지 않고 입력 X를 저장·재계산함으로써, 기존 양자화 연구의 분류 체계 밖에 위치하는 새로운 방향을 제시하였다. 이는 추론 시간 증가(재계산)와 메모리 절감 사이의 트레이드오프를 명시적으로 인정하고 활용한다.
- **도메인별 구조적 사전 지식 통합**: CodeComp(코드 속성 그래프), VidKV(비디오 채널별 특성), DBTrimKV(미래 유용성 학습)는 모두 "어텐션 가중치만으로는 도메인별 중요도를 포착할 수 없다"는 공통 인식을 공유한다.

---

## 3. Recent Work

> **필터링 기준:** 누적 KNOWN_URLS 157건(2026-04-30 78건 + 2026-05-02 29건 + 2026-05-03 14건 + 2026-05-04 18건 + 2026-05-14 18건)의 URL/제목/기법명 집합과 매칭된 항목은 제외하였다. 아래 표는 신규 논문·기법만 수록한다.

### A. 서빙 시스템·메모리 관리

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Efficient Serving for Dynamic Agent Workflows with Prediction-based KV-Cache Management](https://arxiv.org/abs/2605.06472) | Haoyu Zheng et al. | arXiv 2026-05 | 동적 에이전트 워크플로우에서 히스토리·컨텍스트 융합으로 미래 에이전트 호출 예측; 재사용 가능성 높은 KV GPU 유지 + 보수적 prefetch; LRU 대비 1.85×↑, SOTA KVFlow 대비 1.26×↑ | arXiv:2605.06472 |
| 2025 | [Online Scheduling for LLM Inference with KV Cache Constraints](https://arxiv.org/abs/2502.07115) | Patrick Jaillet et al. (MIT) | arXiv 2025-02 | KV 제약 하 최적 배치·스케줄링 이론; 반온라인 모델에서 평균 지연 exact 최적성, 풀 온라인 확률적 도착 시 상수 후회 보증 | arXiv:2502.07115 |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [XQuant: Breaking the Memory Wall for LLM Inference with KV Cache Rematerialization](https://arxiv.org/abs/2508.10395) | — | arXiv 2025-08 | KV 대신 입력 활성화 X를 양자화·캐시 후 K/V 온더플라이 재구체화; 7.7× 메모리 절감(PPL↑<0.1), XQuant-CL 변형 12.5× 절감(PPL↑<0.1) vs. FP16 | arXiv:2508.10395 |
| 2025 | [KVComp: A High-Performance, LLM-Aware, Lossy Compression Framework for KV Cache](https://arxiv.org/abs/2509.00579) | Bo Jiang et al. (Temple Univ., Univ. of Houston) | arXiv 2025-08 | 오류 제어 양자화 + GPU 기반 고속 엔트로피 인코딩 + 캐시 내 압축 해제 공동 설계; SOTA 대비 압축률 최대 83%↑, 속도 저하 무시 수준 | arXiv:2509.00579 |
| 2025 | [KVCompose: Efficient Structured KV Cache Compression with Composite Tokens](https://arxiv.org/abs/2509.05165) | Dmitry Akulov et al. | arXiv 2025-09 | 어텐션 점수 기반 헤드별 독립 토큰 선택 후 균일 복합 토큰으로 정렬; 특수 커널 없이 기존 엔진 호환, 장문맥 전반 SOTA 초과 | arXiv:2509.05165 |
| 2025 | [VidKV: Plug-and-Play 1.x-Bit KV Cache Quantization for Video Large Language Models](https://arxiv.org/abs/2503.16257) | — (KD-TAO) | arXiv 2025-03 | 비디오 LLM Key: 채널별 2-bit(비정상) + FFT 1-bit(정상) 혼합; Value: 1.58-bit 채널별 양자화 + 시맨틱 중요 토큰 선택 보존; FP16 동등 성능 달성 | arXiv:2503.16257 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Make Each Token Count: Towards Improving Long-Context Performance with KV Cache Eviction](https://arxiv.org/abs/2605.09649) | Ngoc Bui, Hieu Trung Nguyen, Arman Cohan, Rex Ying (Yale / CUHK) | arXiv 2026-05 | 글로벌 리텐션 게이트로 레이어·헤드 전역 토큰 미래 유용성 학습(DBTrimKV); "풀 캐시가 항상 최적이 아님"을 실증, 선택적 eviction으로 장문맥 성능 개선 | arXiv:2605.09649 |
| 2026 | [SideQuest: Model-Driven KV Cache Management for Long-Horizon Agentic Reasoning](https://arxiv.org/abs/2602.22603) | Sanjay Kariyappa, G. Edward Suh | arXiv 2026-02 | LRM이 병렬 부채널 컨텍스트에서 KV 중요도를 직접 추론하는 모델 주도 압축; 에이전틱 벤치마크 KV 60%↓, 정확도 손실 무시 수준 | arXiv:2602.22603 |
| 2026 | [CodeComp: Structural KV Cache Compression for Agentic Coding](https://arxiv.org/abs/2604.10235) | — | arXiv 2026-04 | 코드 속성 그래프(CPG) 기반 스팬 수준 구조 보호 + 예산 할당; 어텐션 only 기준선 대비 결함 위치 파악·패치 생성 전반 우위, SGLang 통합 | arXiv:2604.10235 |

### D. 분산·분리 서빙 및 KV 전송

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [KVDirect: Distributed Disaggregated LLM Inference](https://arxiv.org/abs/2501.14743) | Shiyang Chen et al. | arXiv 2025-01 | 다중 노드 분산 P/D 분리를 위한 텐서 중심 통신 메커니즘 + Pull 기반 KV 전송; KV 전송이 총 지연의 0.5~1.1%에 불과, 기준선 대비 요청 지연 55%↓ | arXiv:2501.14743 |

### E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2025 | [EG-MLA: Embedding-Gated Multi-head Latent Attention for Scalable and Efficient LLMs](https://arxiv.org/abs/2509.16686) | Zhengge Cai, Haowen Hou | arXiv 2025-09 | MLA 잠재 공간에 토큰별 임베딩 게이팅 추가; MHA 대비 KV 요소 91.6%↓, MLA 대비 59.9%↓ 추가 절감, 표현력 향상 | arXiv:2509.16686 |

### F. 장문맥·계층적 오프로딩

> 이번 수집 기간에 해당 서브토픽 전용 신규 논문은 발견되지 않았다. VidKV(비디오 LLM 양자화)는 B 섹션에, PBKV(에이전트 워크플로우)는 A 섹션에 수록하였다.

---

## 4. Open Problems

직전 보고서들의 20개 미해결 과제에 더해, 이번 수집에서 확인된 추가 과제들이다.

### 문제 21: 에이전트 워크플로우 KV 예측의 분포 외 일반화
PBKV는 히스토리 워크플로우에서 미래 에이전트 호출을 예측하지만, 실제 운영 환경에서는 새로운 유형의 워크플로우나 드문 에이전트 조합이 등장할 수 있다. 예측 오류 시 잘못 유지된 KV가 메모리를 점유하면 GPU 활용도가 오히려 저하된다. 분포 외 워크플로우에서의 fallback 정책과 예측 불확실성 추정이 미해결 문제이다.

### 문제 22: 재구체화(Rematerialization)의 추론 모델 누적 편향
XQuant는 X 양자화 후 K·V를 재계산하지만, Reasoning 모델의 수만 토큰 생성 과정에서 양자화 오차가 재계산을 거쳐 누적되는지 체계적으로 검증되지 않았다. 특히 레이어를 거듭할수록 오차가 증폭되는 "오차 전파(error propagation)" 문제가 장문 추론 체인에서 어떻게 발현되는지 분석이 필요하다.

### 문제 23: 코드·도메인 특화 KV 압축의 멀티파일·멀티언어 일반화
CodeComp는 CPG를 Joern으로 추출하지만, 멀티파일 코드베이스(함수 호출 그래프가 파일 경계를 넘는 경우)나 비Python/JavaScript 언어에 대한 CPG 지원이 제한적이다. 또한 CPG 추출 오버헤드가 긴 코드베이스에서 추론 지연에 미치는 영향이 정량화되지 않았다.

### 문제 24: 복합 토큰(Composite Token) 방식의 의미 정합성 보장
KVCompose는 서로 다른 위치의 토큰을 합산·재정렬하여 복합 토큰을 생성하지만, 이 과정에서 위치 인코딩(RoPE)과의 정합성이 깨질 수 있다. 복합 토큰이 원래 시퀀스의 위치 관계를 보존하는지, 그리고 이 위반이 어텐션 마스킹 정확도에 미치는 영향이 충분히 분석되지 않았다.

---

## 5. Notable Researchers / Groups

직전 보고서들의 Notable Researchers 목록에 이번 수집에서 새롭게 확인된 그룹을 추가한다.

| 이름/그룹 | 소속 | 대표 기여 (이번 수집 기준) |
|-----------|------|--------------------------|
| **Patrick Jaillet 그룹** | MIT | Online Scheduling for LLM Inference with KV Cache Constraints — KV 제약 하 최적 스케줄링 이론 |
| **Bo Jiang, Sian Jin 그룹** | Temple University / Univ. of Houston | KVComp — LLM 인식 손실 압축 프레임워크 (엔트로피 코딩 결합) |
| **Sanjay Kariyappa, G. Edward Suh** | (소속 확인 필요) | SideQuest — 모델 주도 에이전틱 KV 관리 |
| **Zhengge Cai, Haowen Hou** | (소속 확인 필요) | EG-MLA — 임베딩 게이팅 MLA 확장 |
| **Ngoc Bui, Rex Ying 그룹** | Yale University / CUHK | DBTrimKV (Make Each Token Count) — 글로벌 리텐션 게이트 학습 |
| **KD-TAO 팀** | (소속 확인 필요) | VidKV — 비디오 LLM 1.x-bit KV 양자화 |
| **Shiyang Chen 그룹** | (소속 확인 필요) | KVDirect — 다중 노드 분산 P/D 분리 텐서 통신 |

---

## 6. Resources

### 신규 오픈소스 코드·라이브러리

| 자원 | URL | 설명 |
|------|-----|------|
| VidKV | https://github.com/KD-TAO/VidKV | 비디오 LLM용 1.x-bit KV 캐시 양자화 공식 구현 |
| KVDirect | https://github.com/TensorDirect/KVDirect | 다중 노드 분산 P/D 분리 추론 오픈소스 프레임워크 |

### 시스템 업데이트 (프레임워크)

| 자원 | URL | 설명 |
|------|-----|------|
| vLLM Q2 2026 로드맵 | https://github.com/vllm-project/vllm/issues/39749 | Mooncake Store 통합, HMA 전면 활성화, Model Runner V2(v0.20.0+, 처리량 56%↑ on GB200) |
| SGLang TurboQuant 통합 이슈 | https://github.com/sgl-project/sglang/issues/21618 | SGLang에 TurboQuant KV 양자화 통합 논의 진행 중 |

---

## 7. Reading List

직전 보고서들의 Reading List(39편)를 유지하며, 이번 수집에서 새롭게 추천할 자료를 추가한다.

### 신규 추가

40. **[XQuant](https://arxiv.org/abs/2508.10395)** (arXiv 2025-08) — KV를 저장하는 대신 입력 X를 양자화하는 재구체화 패러다임; 기존 KV 양자화 분류 체계 밖의 독창적 접근.
41. **[SideQuest](https://arxiv.org/abs/2602.22603)** (Kariyappa & Suh, arXiv 2026-02) — LRM 자체가 KV 관리를 수행하는 모델 주도 방식; 에이전틱 KV 관리 연구의 이론적 전환점.
42. **[DBTrimKV / Make Each Token Count](https://arxiv.org/abs/2605.09649)** (Bui et al., Yale/CUHK, arXiv 2026-05) — 풀 캐시가 항상 최적이 아님을 실증; 글로벌 리텐션 게이트 학습 방법론 입문.
43. **[KVCompose](https://arxiv.org/abs/2509.05165)** (Akulov et al., arXiv 2025-09) — 복합 토큰으로 헤드별 eviction과 엔진 호환성을 동시 달성; 시스템 배포 친화적 eviction 설계 사례.
44. **[CodeComp](https://arxiv.org/abs/2604.10235)** (arXiv 2026-04) — 코드 속성 그래프를 KV 압축에 통합; 도메인 구조적 사전 지식 활용의 선구적 사례.

---

## 8. Methodology

### 검색 쿼리

본 보고서에서 신규 자료 수집에 사용한 주요 검색 쿼리는 다음과 같다.

```
KV cache LLM inference optimization arxiv 2026 May new paper site:arxiv.org
KV cache quantization compression LLM arxiv 2026 May new method
KV cache eviction token selection sparse attention LLM arxiv 2026 May new paper
prefill decode disaggregation KV transfer serving system arxiv 2026 May new
MLA multi-head latent attention KV architecture 2026 May arxiv new
long context KV cache offload NVMe CPU arxiv 2026 May new paper
vLLM SGLang KV cache new feature update serving 2026 May
arxiv 2605 KV cache new paper 2026 May token eviction sparse attention new
KV cache distributed serving CXL RDMA new system arxiv 2605 2026 May
KV cache speculative decoding scheduling SLO aware LLM arxiv 2026 May new
EG-MLA embedding gated multi-head latent attention arxiv 2509.16686
XQuant KV cache rematerialization LLM arxiv 2508.10395 quantization
KVComp KV cache compression framework LLM arxiv 2509.00579 high performance
KV cache online scheduling LLM inference arxiv 2502.07115 key contribution
KVCompose composite tokens KV cache compression arxiv 2509.05165
CodeComp structural KV cache compression agentic coding arxiv 2604.10235
SideQuest model driven KV cache management agentic reasoning arxiv 2602.22603
KVDirect distributed disaggregated LLM inference arxiv 2501.14743
efficient serving dynamic agent workflows prediction KV cache arxiv 2605.06472
VidKV plug-and-play KV cache quantization video LLM arxiv 2503.16257
Make Each Token Count arxiv 2605.09649 DBTrimKV authors affiliation
arxiv 2605 LLM serving KV new paper 2026 May disaggregated scheduling
KV cache architecture cross-layer sharing MLA new arxiv 2605 2026
```

### 수집 출처

| 범주 | 출처 |
|------|------|
| 프리프린트 | arXiv cs.LG, cs.CL, cs.DC, cs.AR, cs.OS (2025-01 ~ 2026-05-16) |
| 집계·탐색 | Semantic Scholar, arXiv 검색, EmergentMind, HuggingFace Papers, alphaXiv |
| 프레임워크 공식 채널 | vLLM GitHub 로드맵 이슈, SGLang GitHub 이슈 |
| 기관 자료 | MIT, Temple University, Yale University 저자 소속 검색 |

### 신규성 필터 적용 결과

- **비교 대상:** 누적 KNOWN_URLS 157건 (2026-04-30 78건 + 2026-05-02 29건 + 2026-05-03 14건 + 2026-05-04 18건 + 2026-05-14 18건)
- **제외된 기존 항목:** 157건 (누적 보고서에 이미 수록된 모든 URL·기법명)
- **신규 수록 항목:** 총 **10개 논문** (A 2건, B 4건, C 3건, D 1건, E 1건, F 0건)
- **신규 없는 영역:** F(장문맥·오프로딩), G(VLM — VidKV는 B에 수록), H(보안·프라이버시)

### 가정 및 한계

- **저자·소속 미확인:** XQuant(2508.10395), KVCompose(2509.05165), CodeComp(2604.10235), VidKV(2503.16257), KVDirect(2501.14743), EG-MLA(2509.16686), SideQuest(2602.22603)의 소속 기관 일부가 검색 스니펫에서 완전히 확인되지 않았다. arXiv 원문에서 직접 확인이 필요하다.
- **KVDirect(2501.14743) venue:** arXiv 제출일이 2024-12-13이며 최종 게재지가 확인되지 않아 "arXiv 2025-01"로 표기하였다.
- **Online Scheduling for LLM KV(2502.07115):** 복수 버전이 arXiv에 존재하며(v2~v5), MIT Jaillet 그룹의 작업이지만 최종 게재지는 확인 필요.
- **VidKV(2503.16257):** OpenReview에서 리뷰 진행 중인 것으로 확인되며 최종 게재지 미확정.
- **수치 직접 비교 주의:** 모든 성능 수치(배속, 압축률, PPL)는 각 논문이 자체 보고한 수치이며, 하드웨어 환경·기준선·데이터셋이 논문마다 상이하므로 직접 비교에 주의가 필요하다.
- **VidKV 분류:** 비디오 VLM 전용 양자화로 B(양자화)와 G(VLM) 양쪽에 해당하나, 양자화 기법이 주요 기여이므로 B 섹션에 단독 수록하고 G 섹션에는 별도 기재하지 않았다.
- **F 서브토픽 신규 없음:** 이번 수집 기간에 장문맥·오프로딩 전용 신규 논문이 발견되지 않았다. Tutti(2605.03375), KV-Fold(2605.12471), Fluxion(2605.07719)은 직전 보고서(2026-05-14)에 수록되어 있다.
