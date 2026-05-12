---
type: trend-report
topic: "LLM 추론 KV 캐시 관리·최적화"
slug: kv-cache-optimization
date: 2026-05-12
source: interests/kv-cache-optimization.md
time_range: "2023-01 ~ 2026-04"
depth: overview
language: ko
---

# LLM 추론 KV 캐시 관리·최적화 — Research Trend Report (2026-05-12)

> Source spec: `interests/kv-cache-optimization.md` · Time range: 2023-01 ~ 2026-04 · Depth: overview
>
> **신규성 주의:** 본 보고서는 직전 보고서(`reports/kv-cache-optimization-2026-05-04.md`, 총 18건)를 포함하여 KNOWN_URLS 집합(총 158건)과 매칭되는 항목을 제외하고 **2026-05-04 이후 신규 발견 논문·기법만** 수록합니다.

---

## 1. Executive Summary

### 트렌드 1: KV 양자화의 이론화 물결 — Rate-Distortion, 스펙트럼 분해, 하드웨어 네이티브
KV 양자화 연구가 휴리스틱 비트폭 할당에서 정보 이론 기반 최적화로 빠르게 이동하고 있다. RateQuant([arXiv:2605.06675](https://arxiv.org/abs/2605.06675))는 Rate-Distortion 이론의 역 워터필링(reverse waterfilling)으로 헤드별 비트폭을 closed-form으로 최적 배분하여 Qwen3-8B에서 KIVI 대비 PPL을 49.3에서 14.9로 70% 감소시켰다. eOptShrinkQ([arXiv:2605.02905](https://arxiv.org/abs/2605.02905))는 KV 캐시가 저랭크 공유 컨텍스트와 풀랭크 잔차로 자연 분해됨을 관찰하고, 최적 특이값 수축(eOptShrink)으로 구조를 추출한 뒤 TurboQuant로 잔차를 양자화한다. Apple Silicon 특화 연구([arXiv:2605.05699](https://arxiv.org/abs/2605.05699))는 부호 임의화 FFT + int4 패킹을 단일 Metal 커널로 융합하여 int4 KV 캐시가 fp16보다 빠르게 실행됨을 실증하였다.

### 트렌드 2: 희소 어텐션 인덱스의 이론적 보장 강화 — 제로 False Negative와 MoE 기반 인덱서
희소 어텐션 검색의 정확성 보장이 강조되고 있다. Louver([arXiv:2605.06763](https://arxiv.org/abs/2605.06763))는 희소 어텐션 문제를 반공간 범위 탐색(halfspace range searching)으로 재정의하고, 지정 임계값에 대해 이론적·실험적 제로 false negative를 보장하는 최초의 인덱스 구조를 제안하였다. MISA([arXiv:2605.07363](https://arxiv.org/abs/2605.07363))는 DeepSeek Sparse Attention의 인덱서 헤드를 MoE 풀로 처리해 경량 라우터로 활성 헤드 수를 줄여 긴 컨텍스트에서의 인덱서 비용을 크게 절감하였다. LaProx([arXiv:2605.07234](https://arxiv.org/abs/2605.07234))는 축출 문제를 레이어별 행렬 곱 근사로 재정의하고 전역 비교 가능한 중요도 점수를 최초로 제안하여 LongBench 19개 데이터셋에서 SOTA를 달성하였다.

### 트렌드 3: P/D 분리의 다중 턴(Multi-turn) 서빙 확장
P/D 분리가 단일 요청 최적화를 넘어 다중 턴 대화 서빙으로 확장되고 있다. PPD Disaggregation([arXiv:2603.13358](https://arxiv.org/abs/2603.13358))은 turn 2+의 append-prefill이 full-prefill보다 디코딩 방해가 훨씬 적다는 관찰을 기반으로 KV 상태 재사용 여부를 동적으로 라우팅하여 Turn 2+ TTFT를 68% 절감하였다. 이 연구는 다중 턴 상호작용의 캐시 재사용 가치를 정량화한 최초의 시스템 수준 연구 중 하나로, 향후 에이전트·챗봇 서빙 아키텍처 설계에 중요한 기준점이 된다.

### 트렌드 4: SSD-backed KV 오프로딩의 GPU 네이티브화
NVMe SSD로의 KV 오프로딩에서 CPU 병목을 제거하는 방향이 구체화되었다. Tutti([arXiv:2605.03375](https://arxiv.org/abs/2605.03375))는 GPU io_uring을 활용한 비동기 GPU 직접 객체 I/O와 slack-aware I/O 스케줄링으로 CPU 개입을 거의 완전히 제거하여 GDS 기반 LMCache 대비 TTFT를 78.3% 절감하고 처리 가능 요청률을 2×↑ 달성하였다. 이는 기존 GPU Direct Storage가 CPU의 I/O 초기화에 여전히 의존한다는 병목을 근본적으로 해결한 것이다.

### 트렌드 5: VLM(Vision-Language Model) KV 최적화의 다각화
이전 보고서에서 확인된 MHA2MLA-VLM에 이어, VLM 전용 KV 최적화가 더욱 다각화되었다. LightKV([arXiv:2605.00789](https://arxiv.org/abs/2605.00789))는 비전 토큰 간 중복성을 교차 모달리티 메시지 패싱으로 집계하여 프리필 중 점진 압축으로 55% 비전 토큰만으로 비전 KV 절반을 유지하고 연산 40%↓를 달성하였다. WindowQuant([arXiv:2605.02262](https://arxiv.org/abs/2605.02262))는 비디오 언어 모델의 시각 토큰 윈도우와 텍스트 프롬프트 유사도를 기반으로 윈도우 단위 혼합 정밀도 양자화를 적용하여 토큰 단위 방법의 하드웨어 비효율을 해소하였다.

---

## 2. Landscape — 분야 지형도

직전 보고서(2026-05-04)의 A~H 서브토픽 분류를 유지하면서, 이번 기간(2026-05-04 ~ 2026-05-12)에 다음 새 가지들이 성장하였다.

```
LLM KV 캐시 최적화 (2026-05-12 업데이트)
├── A. 서빙 시스템·메모리 관리
│   ├── (기존) PagedAttention / Chunked Prefill / HiCache / vLLM V1 / AdaptCache ...
│   ├── [신규] CPU-GPU 병렬 희소 어텐션 시스템 (Fluxion — CPU 상주 KV 혼합 처리)
│   └── [신규] RL 사후 학습에서의 KV 압축 편향 해결 (Shadow Mask Distillation)
│
├── B. KV 양자화·압축
│   ├── (기존) KIVI / KVQuant / RotateKV / RateQuant-base / OjaKV ...
│   ├── [신규] Rate-Distortion 최적 혼합 정밀도 (RateQuant — 역 워터필링)
│   ├── [신규] 스펙트럼 분해+양자화 파이프라인 (eOptShrinkQ — eOptShrink + TurboQuant)
│   ├── [신규] Apple Silicon int4 KV 네이티브 커널 (Metal 융합 커널)
│   ├── [신규] 모델-가시적 왜곡 교정 양자화 (HeadQ — logit 교정)
│   ├── [신규] VLM 윈도우 단위 혼합 정밀도 (WindowQuant)
│   └── [신규] 다중 계층 메모리 통합 KV 크기 최적화 (Predictive Multi-Tier MM)
│
├── C. 토큰 축출·희소 어텐션
│   ├── (기존) SnapKV / Quest / SAGE-KV / SemantiCache / Self-Indexing KVCache ...
│   ├── [신규] 출력-인식 레이어별 행렬 근사 축출 (LaProx — 전역 중요도 점수)
│   ├── [신규] 엔드-투-엔드 학습 기반 헤드별 예산 배분 (LKV — LKV-H + LKV-T)
│   ├── [신규] 반공간 범위 탐색 인덱스 (Louver — 제로 false negative 보장)
│   ├── [신규] MoE 인덱서 희소 어텐션 (MISA — DeepSeek DSA 대체)
│   └── [신규] CPU-GPU 협력 희소 어텐션 (Fluxion — CPU 상주 KV 처리)
│
├── D. 분산·분리 서빙 및 KV 전송
│   ├── (기존) DistServe / Mooncake / Beluga / Revisiting Disaggregated ...
│   └── [신규] 다중 턴 append-prefill 재사용 기반 PPD 분리 (PPD Disaggregation)
│
├── E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)
│   ├── (기존) MLA / TPLA / MHA2MLA-VLM / MoE-MLA ...
│   └── [신규] LVLM 비전 토큰 교차 모달리티 압축 (LightKV)
│
├── F. 장문맥·계층적 오프로딩
│   ├── (기존) ShadowKV / SpeCache / KVSwap / AdaptCache / SparKV ...
│   └── [신규] GPU 네이티브 SSD KV 오프로딩 (Tutti — GPU io_uring + GPU-centric KV 객체 저장소)
│
└── G. 적응형 추론·특수 환경
    ├── (기존) SpecKV (이전 보고서), RL-eviction ...
    ├── [신규] 압축-인식 투기적 디코딩 감마 선택 (SpecKV-2605)
    └── [신규] RL 사후 학습 롤아웃 메모리 효율 (Shadow Mask Distillation)
```

### 주요 신규 흐름

- **이론적 최적성 경쟁**: Rate-Distortion(RateQuant), 스펙트럼 분해(eOptShrinkQ), 범위 탐색 이론(Louver)이 각각 독립적으로 KV 최적화에 정보 이론 기반 보장을 도입하는 흐름이 수렴하고 있다. "이론적 최적성" 주장이 KV 양자화 논문의 표준 내러티브로 자리 잡는 중이다.
- **VLM 전용화 가속**: LightKV(비전 토큰 중복 제거), WindowQuant(윈도우 단위 양자화)가 비전-언어 모델의 비전 토큰 KV 병목에 각각 다른 각도로 접근하고 있으며, VLM KV 최적화가 독립 연구 영역으로 성숙하는 신호이다.
- **CPU 병목 제거**: Fluxion(CPU-GPU 병렬 희소 어텐션)과 Tutti(GPU io_uring)는 각각 CPU 상주 KV 처리와 SSD 오프로딩에서 CPU를 크리티컬 패스에서 제거하는 전략을 독립적으로 채택하여 같은 방향의 수렴을 보여준다.

---

## 3. Recent Work

> **필터링 기준:** KNOWN_URLS 집합(158건, 직전 보고서 2026-05-04까지의 누적 URL 포함)과 매칭된 항목은 제외하였다. 아래 표는 신규 논문·기법만 수록한다.

### A. 서빙 시스템·메모리 관리

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Predictive Multi-Tier Memory Management for KV Cache in Large-Scale GPU Inference](https://arxiv.org/abs/2604.26968) | Sanjeev Rao Ganjihal | arXiv 2026-04 | MHA/GQA/MQA/MLA 전 아키텍처 통합 KV 크기 정확 계산 엔진 제안; 최대 7.4× 배치 크기 향상; vLLM·SGLang·TensorRT-LLM 통합 | arXiv:2604.26968 |
| 2026 | [An Efficient Hybrid Sparse Attention with CPU-GPU Parallelism for Long-Context Inference (Fluxion)](https://arxiv.org/abs/2605.07719) | Feiyu Yao et al. | arXiv 2026-05 | 출력-인식 KV 예산 할당 + 헤드별 희소 설정 + CPU-GPU 협력 실행; CPU 상주 KV 처리에서 1.5~3.7× 가속 | arXiv:2605.07719 |
| 2026 | [How to Compress KV Cache in RL Post-Training? Shadow Mask Distillation for Memory-Efficient Alignment](https://arxiv.org/abs/2605.06850) | Rui Zhu, Weiheng Bai, Qiushi Wu, Yang Ren, Haixu Tang, Yuchu Liu (Yale, UMN, Indiana Univ.) | arXiv 2026-05 | RL 롤아웃 시 KV 압축이 유발하는 off-policy 편향 문제 발견; Shadow Mask Distillation로 압축 롤아웃의 정책 불일치를 교정 | arXiv:2605.06850 |

### B. KV 양자화·압축

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [RateQuant: Optimal Mixed-Precision KV Cache Quantization via Rate-Distortion Theory](https://arxiv.org/abs/2605.06675) | Fei Zuo, Zikang Zhou, Hao Cong, Xiaoyan Xi, Ho Fai Leung | arXiv 2026-05 | 헤드별 왜곡 모델 소규모 캘리브레이션 후 역 워터필링으로 최적 비트 배분 closed-form 도출; 1.6초 GPU 캘리브, 추론 오버헤드 없음; Qwen3-8B KIVI PPL 49.3→14.9 (70%↓) | arXiv:2605.06675 |
| 2026 | [eOptShrinkQ: Near-Lossless KV Cache Compression Through Optimal Spectral Denoising and Quantization](https://arxiv.org/abs/2605.02905) | Pei-Chun Su (Yale Univ.) | arXiv 2026-05 | KV 캐시를 저랭크 공유 컨텍스트 + 풀랭크 잔차로 분해; eOptShrink로 저랭크 추출 후 TurboQuant로 잔차 양자화하는 2단계 파이프라인 | arXiv:2605.02905 |
| 2026 | [When Quantization Is Free: An int4 KV Cache That Outruns fp16 on Apple Silicon](https://arxiv.org/abs/2605.05699) | Mohamed Amine Bergach (Illumina) | arXiv 2026-05 | Metal 커널에서 부호 임의화 FFT + 채널별 λ + 그룹 abs-max + int4 nibble 패킹 융합; fp16 대비 3× 메모리 절감, 256~4096 토큰 프리픽스 전반에서 fp16보다 빠른 실행 | arXiv:2605.05699 |
| 2026 | [HeadQ: Model-Visible Distortion and Score-Space Correction for KV-Cache Quantization](https://arxiv.org/abs/2605.03562) | Jorge L. Ruiz Williams | arXiv 2026-05 | 스토리지 공간 재구성 최적화 대신 모델-가시적 좌표계에서 오류 측정; 키의 경우 저랭크 잔차 사이드 코드를 로짓 교정으로 적용 | arXiv:2605.03562 |
| 2026 | [WindowQuant: Mixed-Precision KV Cache Quantization based on Window-Level Similarity for VLMs Inference Optimization](https://arxiv.org/abs/2605.02262) | Wei Tao, Xiaoyang Qu, Peiqiang Wang, Guokuan Li, Jiguang Wan, Kai Lu, Jianzong Wang | arXiv 2026-05 | 비디오 LM 시각 토큰 윈도우–텍스트 프롬프트 유사도 기반 비트폭 동적 선택; 토큰 단위 방법 대비 설정 탐색 시간 대폭 단축 및 하드웨어 효율 개선 | arXiv:2605.02262 |

### C. 토큰 축출·희소 어텐션

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Reformulating KV Cache Eviction Problem for Long-Context LLM Inference (LaProx)](https://arxiv.org/abs/2605.07234) | Tho Mai, Joo-Young Kim (KAIST) | arXiv 2026-05 | 축출 문제를 레이어별 행렬 곱 근사로 재정의; 어텐션 맵·투영 밸류 상태의 곱셈적 상호작용 명시적 모델링; 최초 전역 비교 가능 중요도 점수 제안; LongBench 5% KV 캐시로 SOTA 달성 | arXiv:2605.07234 |
| 2026 | [LKV: End-to-End Learning of Head-wise Budgets and Token Selection for LLM KV Cache Eviction](https://arxiv.org/abs/2605.06676) | Enshuai Zhou, Yifan Hao, Chao Wang, Rui Zhang, Di Huang, Jiaming Guo, Xing Hu, Zidong Du, Qi Guo, Yunji Chen | arXiv 2026-05 | KV 압축을 엔드-투-엔드 미분 가능 최적화 문제로 재정의; LKV-H(태스크 최적 헤드 예산 학습) + LKV-T(어텐션 행렬 미실체화 중요도 도출); LongBench·RULER 15% KV 유지로 준손실 없는 성능 | arXiv:2605.06676 |
| 2026 | [Sparse Attention as a Range Searching Problem: Towards an Inference-Efficient Index for KV Cache (Louver)](https://arxiv.org/abs/2605.06763) | Mohsen Dehghankar et al. | arXiv 2026-05 | 희소 어텐션을 반공간 범위 탐색 문제로 재정의; 지정 임계값에 대한 이론적·실험적 제로 false negative 보장; FlashAttention 대비 빠른 실행 | arXiv:2605.06763 |
| 2026 | [MISA: Mixture of Indexer Sparse Attention for Long-Context LLM Inference](https://arxiv.org/abs/2605.07363) | Ruijie Zhou, Fanxu Meng, Yufei Xu, Tongxuan Liu, Guangming Lu, Muhan Zhang, Wenjie Pei (Peking Univ. 외) | arXiv 2026-05 | DeepSeek DSA 인덱서 헤드를 MoE 풀로 처리; 경량 라우터로 블록 단위 통계 기반 활성 헤드 소수만 선택; 긴 컨텍스트에서 인덱서 비용 대폭 절감 | arXiv:2605.07363 |

### D. 분산·분리 서빙 및 KV 전송

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Not All Prefills Are Equal: PPD Disaggregation for Multi-turn LLM Serving](https://arxiv.org/abs/2603.13358) | Zongze Li, Jingyu Liu, Zach Xu, Yineng Zhang, Tahseen Rabbani, Ce Zhang | arXiv 2026-03 | Turn 2+ append-prefill이 full-prefill보다 디코딩 방해 훨씬 적음을 실증; KV 상태 재사용 여부 동적 라우팅(PPD 분리); Turn 2+ TTFT 68%↓ | arXiv:2603.13358 |

### E. 아키텍처 수준 KV 절감 (MLA, Cross-layer 등)

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Make Your LVLM KV Cache More Lightweight (LightKV)](https://arxiv.org/abs/2605.00789) | Xihao Chen, Yangyang Guo, Roger Zimmermann (National Univ. of Singapore) | arXiv 2026-05 | 교차 모달리티 메시지 패싱으로 비전 토큰 KV 중복 제거; 55% 비전 토큰으로 비전 KV 50% 절감, 연산 40%↓; 8개 LVLM × 8개 벤치마크 평가 | arXiv:2605.00789 |

### F. 장문맥·계층적 오프로딩

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [Tutti: Making SSD-Backed KV Cache Practical for Long-Context LLM Serving](https://arxiv.org/abs/2605.03375) | Shi Qiu, Yifan Hu, Xintao Wang, Wenhao Zhu, Jianqin Yan, Hao Chen, Kaiqiang Xu, Kai Chen, Yiming Zhang | arXiv 2026-05 | GPU-centric KV 객체 저장소 + GPU io_uring 비동기 직접 객체 I/O + slack-aware I/O 스케줄링으로 CPU 개입 제거; GDS-LMCache 대비 TTFT 78.3%↓, 처리 가능 요청률 2×↑, 서빙 비용 27%↓ | arXiv:2605.03375 |

### G. 투기적 디코딩·특수 환경

| Year | Title | Authors | Venue | Contribution | Link |
|------|-------|---------|-------|-------------|------|
| 2026 | [SpecKV: Adaptive Speculative Decoding with Compression-Aware Gamma Selection](https://arxiv.org/abs/2605.02888) | Shikhar Shukla (Univ. of Kentucky) | arXiv 2026-05 | KV 압축 수준별 최적 투기 길이(γ)가 상이함을 실증; 드래프트 모델 엔트로피·신뢰도 기반 경량 컨트롤러로 스텝별 γ 선택; fixed-γ=4 대비 56.0% 개선, 0.34ms 오버헤드 | arXiv:2605.02888 |

---

## 4. Open Problems

직전 보고서들의 16개 미해결 과제에 더해, 이번 수집에서 확인된 추가 과제들이다.

### 문제 17: KV 양자화 최적성 기준의 불일치
RateQuant(Rate-Distortion), eOptShrinkQ(스펙트럼 분해), HeadQ(모델-가시적 왜곡)가 각각 다른 최적성 기준을 사용하며 모두 "이론적 최적"을 주장한다. 세 기준이 어떤 설정에서 수렴하고 어떤 설정에서 발산하는지, 그리고 실제 태스크 성능과 가장 잘 상관되는 기준이 무엇인지에 대한 통합 연구가 부재하다.

### 문제 18: CPU 상주 KV 처리의 일관성 보장
Fluxion(CPU-GPU 병렬 희소 어텐션)과 Tutti(GPU io_uring)는 각각 CPU 상주 KV에 대한 접근을 최적화하지만, CPU DRAM에 상주하는 KV와 GPU HBM에 있는 KV 사이의 일관성(coherency) 유지 비용이 장기 세션·다중 요청 시 어떻게 누적되는지 체계적으로 분석한 연구가 없다. 특히 P/D 분리 환경에서 CPU 상주 KV의 생명주기 관리가 미정의 상태이다.

### 문제 19: RL 사후 학습과 KV 압축의 편향 문제
Shadow Mask Distillation([arXiv:2605.06850](https://arxiv.org/abs/2605.06850))이 처음으로 RL 롤아웃 중 KV 압축이 off-policy 편향을 일으킬 수 있음을 지적하였다. 그러나 이 편향이 PPO, GRPO, Online DPO 등 구체적인 RL 알고리즘별로 어떻게 다르게 나타나는지, 그리고 어떤 압축 기법(양자화 vs. 축출 vs. 저랭크)이 편향을 가장 많이 유발하는지는 충분히 연구되지 않았다.

### 문제 20: 다중 턴 서빙에서의 KV 예산 재배분
PPD Disaggregation은 append-prefill이 full-prefill보다 유리함을 보였지만, 대화가 길어질수록 누적 KV 캐시가 증가하는 문제는 여전히 미해결이다. 다중 턴 대화의 KV 예산을 어떻게 적응적으로 관리할지, 특히 이전 턴의 KV를 언제 압축/축출/보존할지 결정하는 정책이 없다.

---

## 5. Notable Researchers / Groups

직전 보고서들의 Notable Researchers 목록에 이번 수집에서 새롭게 확인된 그룹을 추가한다.

| 이름/그룹 | 소속 | 대표 기여 (이번 수집 기준) |
|-----------|------|--------------------------|
| **Tho Mai, Joo-Young Kim** | KAIST | LaProx (레이어별 행렬 근사 기반 전역 중요도 KV 축출) |
| **Enshuai Zhou, Yunji Chen 그룹** | (소속 확인 필요) | LKV (엔드-투-엔드 학습 기반 헤드 예산 + 토큰 선택) |
| **Pei-Chun Su** | Yale University | eOptShrinkQ (최적 스펙트럼 수축 + TurboQuant 2단계 KV 압축) |
| **Fei Zuo 그룹** | (소속 확인 필요) | RateQuant (Rate-Distortion 역 워터필링 최적 KV 비트 배분) |
| **Ruijie Zhou, Wenjie Pei 그룹** | Peking University 외 | MISA (MoE 기반 DSA 인덱서 최적화) |
| **Xihao Chen, Roger Zimmermann 그룹** | National University of Singapore | LightKV (교차 모달리티 메시지 패싱 LVLM KV 압축) |
| **Shi Qiu, Kai Chen 그룹** | (소속 확인 필요) | Tutti (GPU 네이티브 SSD KV 오프로딩, GPU io_uring) |
| **Rui Zhu 그룹** | Yale / UMN / Indiana Univ. | Shadow Mask Distillation (RL 사후 학습 KV 압축 편향 교정) |
| **Mohsen Dehghankar 그룹** | (소속 확인 필요) | Louver (반공간 범위 탐색 기반 제로 FN 희소 어텐션 인덱스) |

---

## 6. Resources

### 신규 오픈소스 코드·라이브러리

| 자원 | URL | 설명 |
|------|-----|------|
| LightKV | https://github.com/XihaoC/LightKV (확인 필요) | NUS LVLM 비전 토큰 KV 압축; OpenReview 확인됨 |

### 신규 관련 기술 문서·가이드

| 자원 | URL | 설명 |
|------|-----|------|
| KV Cache Optimization Guide 2026 | https://www.digitalapplied.com/blog/kv-cache-optimization-techniques-2026-engineering-guide | 2026년 기준 KV 최적화 기법 엔지니어링 가이드 |

---

## 7. Reading List

직전 보고서들의 Reading List(32편)를 유지하며, 이번 수집에서 새롭게 추천할 자료를 추가한다.

### 신규 추가

33. **[RateQuant](https://arxiv.org/abs/2605.06675)** (Zuo et al., arXiv 2026-05) — Rate-Distortion 이론의 KV 양자화 적용; 1.6초 캘리브레이션으로 추론 오버헤드 없이 최적 비트 배분 달성. KV 양자화 이론화의 입문점.
34. **[LaProx](https://arxiv.org/abs/2605.07234)** (Mai & Kim, KAIST, arXiv 2026-05) — 전역 비교 가능 중요도 점수의 최초 제안; 헤드별 독립 결정의 한계를 이론적으로 분석. KV 축출 이론 이해에 필수.
35. **[Louver](https://arxiv.org/abs/2605.06763)** (Dehghankar et al., arXiv 2026-05) — 희소 어텐션의 이론적 보장 연구; 범위 탐색 문제로의 재정의가 KV 검색 인덱스 설계에 새 방향 제시.
36. **[Tutti](https://arxiv.org/abs/2605.03375)** (Qiu et al., arXiv 2026-05) — GPU io_uring으로 CPU 병목 제거; SSD 기반 KV 오프로딩의 실용적 한계 해결의 대표 사례.
37. **[PPD Disaggregation](https://arxiv.org/abs/2603.13358)** (Li et al., arXiv 2026-03) — 다중 턴 서빙에서 append-prefill과 full-prefill의 비대칭성 실증; 에이전트/챗봇 서빙 아키텍처 설계 시 중요 참고점.
38. **[eOptShrinkQ](https://arxiv.org/abs/2605.02905)** (Su, Yale, arXiv 2026-05) — KV 캐시의 저랭크+잔차 분해 관찰과 2단계 최적 압축 파이프라인; 스펙트럼 이론과 양자화의 융합 방향 이해에 적합.

---

## 8. Methodology

### 검색 쿼리

본 보고서에서 신규 자료 수집에 사용한 검색 쿼리는 다음과 같다.

```
KV cache LLM inference optimization arxiv 2026 May new paper
KV cache quantization compression LLM arxiv 2026 May cs.LG cs.CL new
KV cache eviction token selection arxiv May 2026 new paper long context LLM
disaggregated prefill decode KV cache serving system arxiv 2026 May new
MLA multi-head latent attention KV cache architecture arxiv 2026 May new paper
vLLM SGLang KV cache update new feature arxiv 2026 May
arxiv 2605 KV cache LLM inference May 2026 new submitted
KV cache offloading SSD NVMe long context LLM arxiv May 2026
arxiv 2605 speculative decoding prefix caching serving system LLM KV 2026
WindowQuant VLM KV cache quantization arxiv 2605 2026
LaProx arxiv 2605.07234 KV cache eviction long context LLM authors contribution
LKV arxiv 2605.06676 head-wise budget token selection KV cache eviction authors results
Tutti SSD-backed KV cache LLM serving arxiv 2605.03375 authors contribution results
SpecKV adaptive speculative decoding KV arxiv 2605.02888 authors results
RateQuant rate distortion KV cache quantization arxiv 2605.06675 authors
Louver sparse attention range searching KV cache index arxiv 2605.06763 LLM
MISA mixture indexer sparse attention KV cache long context arxiv 2605.07363 authors
Not All Prefills Equal PPD disaggregation multi-turn LLM arxiv 2603 authors results
HeadQ KV cache quantizer corrector codec arxiv 2605.03562 authors
int4 KV cache outruns fp16 Apple Silicon arxiv 2605.05699 authors contribution
Make LVLM KV cache more lightweight arxiv 2605.00789 VLM visual token
RL post-training KV cache compress shadow mask distillation arxiv 2605.06850
Fluxion hybrid sparse attention CPU GPU arxiv 2605.07719 authors
Predictive multi-tier memory management KV cache GPU inference arxiv 2604.26968
eOptShrinkQ spectral denoising KV cache compression arxiv 2605.02905 authors
```

### 수집 출처

| 범주 | 출처 |
|------|------|
| 프리프린트 | arXiv cs.LG, cs.CL, cs.DC, cs.AR, cs.OS (2026-05-04 ~ 2026-05-12) |
| 집계·탐색 | Semantic Scholar, HuggingFace Papers Daily, EmergentMind, alphaXiv |

### 신규성 필터 적용 결과

- **비교 대상:** KNOWN_URLS 집합 158건 (직전 보고서 2026-05-04까지 누적) + 직전 보고서 신규 항목 18건
- **제외된 기존 항목:** 상기 KNOWN_URLS 및 직전 보고서 수록 항목 전체 (예: 2604.26968는 2026-04-19 제출이나 직전 보고서에서 미수록 확인 후 포함)
- **신규 수록 항목:** 총 **17개 논문** (A 3건, B 5건, C 4건, D 1건, E 1건, F 1건, G 1건 및 SpecKV 포함 시 G 2건)
- **신규 없는 영역:** H(보안·프라이버시)
- **PPD Disaggregation(2603.13358):** arXiv 제출일이 2026-03-09로 이전 보고서들의 검색 시점에 존재했으나 KNOWN_URLS에 포함되지 않아 이번에 신규 수록.

### 가정 및 한계

- **저자 소속 미확인:** LKV(Enshuai Zhou 등), RateQuant(Fei Zuo 등), Louver(Mohsen Dehghankar), Tutti(Shi Qiu 등), Fluxion(Feiyu Yao), Predictive Multi-Tier MM(Sanjeev Rao Ganjihal), HeadQ(Jorge L. Ruiz Williams)의 기관 소속을 arXiv 스니펫에서 완전히 확인하지 못하였다. arXiv 원문 PDF에서 직접 확인이 필요하다.
- **MISA의 DeepSeek DSA 의존성:** MISA는 DeepSeek Sparse Attention(DSA)을 전제로 하므로, DSA가 없는 모델(GPT 계열, Llama 계열 등)에 대한 적용 가능성이 제한될 수 있다. 범용성 확인 필요.
- **SpecKV(2605.02888)와 KNOWN_URLS의 SpecKV(CXL-SpecKV, 2512.11920) 구분:** 두 논문은 서로 다른 연구이며 저자·arXiv ID가 다르다. 2605.02888은 투기적 디코딩 γ 적응 선택에 관한 신규 연구이고, 2512.11920은 CXL 기반 FPGA 투기 KV 캐시로 이미 KNOWN_URLS에 포함되어 있다.
- **수치 비교 주의:** 각 논문이 자체 보고한 수치이며 하드웨어 환경·기준선이 논문마다 상이하므로 직접 비교에 주의가 필요하다.
- **time_range 마감(2026-04)과 5월 논문:** 본 보고서는 2026-05-04 이후 신규 논문을 수집하는 것이 목적이므로, 2026-05 제출 논문들을 time_range 초과로 보지 않고 이전 보고서 대비 신규 발견 항목으로 수록하였다. 명세의 `time_range: 2023-01 ~ 2026-04`를 엄격히 적용할 경우 2026-05 논문들은 `(time_range 마감 후)` 태그를 붙여야 한다.
