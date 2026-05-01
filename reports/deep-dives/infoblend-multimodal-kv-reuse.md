---
type: deep-dive
title: "InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction"
slug: infoblend-multimodal-kv-reuse
authors: ["Anonymous (ICLR 2026 submission)", "Shiju Zhao", "Junhao Hu", "Rongxiao Huang", "Jiaqi Zheng", "Guihai Chen"]
venue: "ICLR 2026 (under review) / arXiv:2502.01960 (선행/공개판: MPIC)"
year: 2026
source_url: "https://openreview.net/forum?id=bld5GVRad0"
code_url: ""
parent_topic: "LLM KV Cache Management & Optimization"
date: 2026-05-01
one_line_summary: "멀티모달 LLM 추론에서 이미지·텍스트 KV 캐시를 위치(prefix) 제약 없이 디스크에 저장·재사용하면서, 이미지 토큰 앞부분의 anchor 토큰만 선택적으로 재계산해 정확도 손실은 최소화하고 TTFT는 최대 54.1% 줄이며 처리량을 약 2.0배 향상."
---

# InfoBlend: Storing and Reusing KV Caches of Multimodal Information without Positional Restriction

> 저자: Anonymous (ICLR 2026 더블블라인드 투고) — 비익명 선행 공개판은 Shiju Zhao, Junhao Hu, Rongxiao Huang, Jiaqi Zheng, Guihai Chen (Nanjing University, State Key Laboratory for Novel Software Technology) · ICLR 2026 (under review) / arXiv:2502.01960 v1 (Feb 2025) · [OpenReview](https://openreview.net/forum?id=bld5GVRad0) · [arXiv MPIC](https://arxiv.org/abs/2502.01960) · 코드: 미공개(확인 필요)

> **식별 메모.** 본 보고서가 분석하는 OpenReview 투고작 *InfoBlend* (forum id `bld5GVRad0`)의 abstract·핵심 결과(54.1% TTFT 감소, 2.0× 처리량, 정확도 손실 13.6% 이내)·시스템 구성·실험 설계가 arXiv:2502.01960 *"MPIC: Position-Independent Multimodal Context Caching System for Efficient MLLM Serving"* (Zhao et al., 2025, Nanjing University)와 거의 정확히 일치한다. ICLR 2026 더블블라인드 정책에 따라 OpenReview 페이지 자체에는 저자가 익명으로 표기되지만, 본 보고서는 해당 비익명 arXiv 버전을 동일 연구의 권위 있는 사본으로 간주하고 분석한다(이 동일성 자체는 분석자 추정이며, 추후 카메라레디 단계에서 확정될 수 있다).

---

## 1. TL;DR
- 멀티모달 LLM(MLLM) 추론에서 prefix-only 컨텍스트 캐시는 이미지·텍스트가 인터리브되거나 multimodal RAG처럼 "공유 지식 청크 + 가변 prefix" 구조에서 prefix가 조금만 달라져도 KV를 전부 재계산해야 한다.
- InfoBlend(=MPIC)는 KV 캐시를 **위치 무관(position-independent)** 하게 디스크에 저장해 두고 임의 위치에서 재사용한다. 시스템은 KV 적재(I/O)와 잔여 토큰 prefill을 **병렬 파이프라인**으로 겹친다.
- 정확도 손상을 막기 위해 알고리즘 측면에서는 **이미지 토큰 앞부분의 attention sink anchor**를 식별해 그 부분만 선택적으로 재계산하는 selective-attention 기반 partial recompute를 도입한다(고-deviation·고-attention 토큰 선별).
- LLaVA-1.6-vicuna-7B / LLaVA-1.6-mistral-7B + MMDU·다중 이미지 / multimodal-RAG 워크로드에서 prefix caching 대비 **TTFT 최대 54.1% 단축, 처리량 2.0× 향상**, 점수 손실은 13.6% 이내(해석에 따라 "negligible") 수준.
- LLM 전용 위치 무관 캐시(EPIC, CacheBlend) 라인을 멀티모달로 확장한 첫 번째 본격 시스템이며, anchor 토큰 통찰은 attention sink 효과(ICLR'25 후속 라인)와 직접 연결된다.

## 2. 문제 정의

### 2.1 현행 prefix caching의 한계
현 MLLM 서빙 스택(vLLM, SGLang 등)은 **prefix(접두) KV 캐시 재사용**만 지원한다. 즉 여러 요청이 동일한 시작 토큰열(시스템 프롬프트, 첫 번째 이미지 등)을 공유할 때만 KV가 재사용되고, prefix가 한 토큰이라도 달라지면 그 시점부터 끝까지 전체 prefill을 다시 수행해야 한다. 멀티모달 시나리오에서는 이 가정이 자주 깨진다.

대표 시나리오 두 가지:
1. **Interleaved text & images**: 사용자가 동일한 이미지 집합을 다른 순서·다른 텍스트와 함께 다시 보내는 경우. 이미지가 prompt의 중간이나 후반부에 있으면 prefix caching은 무용지물.
2. **Multimodal RAG (MRAG)**: 질의에 따라 검색된 이미지/문서 청크가 매번 달라지는데, 동일한 청크라도 prompt에 등장하는 위치가 다르면 재사용 불가.

이미지 토큰은 텍스트 토큰보다 한 장당 수백~수천 개 단위로 매우 길기 때문에(LLaVA-1.6의 anyres 패치, InternVL의 멀티 패치 등) 재계산 비용이 크다. KV 계산은 GPU 자원을 점유하면서 TTFT(Time-To-First-Token)를 끌어올리고 처리량을 끌어내린다.

### 2.2 KV 캐시 재사용의 두 축
저자들의 분류는 다음과 같다(섹션·페이지 번호 확인 필요).
- **System level**: KV를 디스크/원격에 저장하고 추론 시 GPU 메모리로 다시 로드하는 I/O 파이프라인 — 디스크 대역폭이 GPU prefill보다 느릴 때 어떻게 hide할 것인가.
- **Algorithm level**: 위치가 다른 컨텍스트에서 재사용된 KV는 원래 위치 인코딩과 cross-attention 가정이 깨져 정확도가 하락 — 어떤 토큰을 다시 계산해서 메워야 하는가.

InfoBlend는 두 축을 동시에 푸는 통합 시스템이다.

## 3. 핵심 아이디어
"멀티모달 KV 캐시를 disk-resident object로 만들고, 추론 시 **임의 위치에 끼워 넣되**(position-independent), 이미지 토큰의 **앞부분 anchor 몇 개만 재계산**해서 attention sink 효과를 복원한다." 이 한 줄에 시스템과 알고리즘 두 기여가 모두 들어 있다.

- 시스템: KV 캐시를 multimodal asset처럼 다루는 **Static/Dynamic Library + Retriever + Linker** 추상화. 디스크에서 KV를 가져오는 시간(I/O)과 GPU에서 잔여 텍스트를 prefill하는 시간을 동시 진행한다.
- 알고리즘: 모든 토큰을 다시 계산하지 않고도 attention sink 영향이 큰 **첫 k개 image token**(anchor)을 표적 재계산하는 selective attention. CacheBlend의 "high-deviation token recompute"와 유사하지만, 이미지 토큰의 시각적 attention 분포 분석에서 출발했다는 점이 차별적.

## 4. 방법

### 4.1 시스템 구조 (5개 컴포넌트)

검색된 본문 정보 기준 InfoBlend는 5개 컴포넌트로 구성된다(figure / 정확한 다이어그램은 PDF 직접 확인 필요).

1. **MLLM Inference Serving System** — 출력 토큰을 생성하는 본체. 스케줄러는 사용자 쿼리를 관리하고 PagedAttention·continuous batching 같은 기존 vLLM 기법을 활용. 구현은 **vLLM 0.9.0 기반**.
2. **Static Context Library** — 사용자가 업로드한 파일(이미지·문서)에서 미리 계산해 둔 KV 캐시 저장소. 사용자가 쿼리에서 참조하면 Linker가 KV를 끼워 넣음. 비유적으로 정적 라이브러리(static library) 역할.
3. **Dynamic Library** — multimedia 참조와 KV 캐시를 보관, 멀티모달 RAG(MRAG)에서 검색돼 들어오는 동적 콘텐츠를 담당. 동적 링크 라이브러리(dynamic-linked library)에 대응.
4. **Retriever** — 쿼리에 맞는 관련 멀티모달 정보를 검색. 비유적으로 프로그램 실행 시 동적 라이브러리 주소를 찾는 relocation table 역할.
5. **Linker** — 검색된 멀티모달 정보의 KV 캐시를 사용자 쿼리 컨텍스트에 연결. 위치 메타데이터(rotary position offset, RoPE 회전 위상 등)를 맞추는 단계로 추정 — **확인 필요**.

### 4.2 위치 무관 KV 재사용을 어떻게 달성했는가

핵심 통찰은 **"이미지 토큰의 attention 분포는 위치 변경에 강건하지만, 이미지 토큰의 맨 앞 일부는 attention sink 역할을 해 위치가 바뀌면 큰 오류를 만든다"** 는 것이다.

전체 reuse(precomputed KV를 그대로 끼움)는 latency 최저지만 정확도 하락 큼. 전체 recompute는 정확도 최고지만 latency 이득 없음. InfoBlend는 그 사이에서 **partial reuse**를 한다.

- 미리 다른 위치 가정으로 계산해 둔 KV를 새 위치에서 재사용할 때, **선두 k개 image token**의 K(키) 텐서를 새 위치 가정 하에 다시 계산해 캐시 일부를 덮어쓴다.
- 그 결과 attention matrix의 첫 k행이 정확해지고, 이 토큰들은 더 이상 "sentence의 시작"이라는 잘못된 신호로 attention을 흡수하지 않는다.
- 추가로 토큰 선택 시 **attention deviation이 크고 attention score가 높은 토큰**(즉 변화에 민감하고 영향력도 큰 토큰)을 우선 재계산한다(CacheBlend 류 selectivity와 유사).

이 selective-attention 통합 단계는 vLLM 어텐션 커널 안에 한 번의 attention 호출로 합쳐서, "남은 텍스트 토큰의 prefill + reuse된 KV에 대한 attention + recompute된 anchor의 K 갱신"을 한 step에 처리한다(구현 디테일은 PDF 4~5장 확인 필요).

### 4.3 디스크 I/O와 prefill 병렬화

```
시간 →
GPU prefill (잔여 텍스트 / anchor 재계산):  [████████]
Disk → GPU KV 적재 (이미지 KV 캐시):       [████████████]
                                          ^겹침으로 critical path 단축
```

- 사용자가 멀티모달 데이터(이미지·문서)를 업로드하면 그 시점에 KV 캐시를 prefill해 디스크에 저장한다(오프라인/백그라운드 비용).
- 추론 시 Retriever/Linker가 어떤 KV 청크가 필요할지 결정하고, **GPU에서 잔여 텍스트 prefill·anchor recompute를 수행하는 동안 동일 시간에 디스크에서 KV를 GPU 메모리로 로드**한다.
- 디스크 I/O가 prefill 시간을 넘지 않을 정도면 critical path는 prefill 시간으로 결정되며, 이를 통해 prefix caching 대비 큰 TTFT 절감 효과.

### 4.4 의사 코드 (논문 본문 그림에서 재구성, 분석자 추정)

```text
# offline (when multimodal asset is uploaded)
KV_chunk = MLLM.prefill(asset_tokens, position_offset = 0)
disk.store(asset_id, KV_chunk)

# online inference for query Q referring to asset_id
async with parallel:
    task_io:    KV_chunk = disk.load(asset_id)        # I/O bound
    task_gpu:   ctx_text_KV = MLLM.prefill(Q.text)    # compute bound
                anchor_K_new = MLLM.recompute_K(asset_tokens[:k],
                                                 position_offset = pos_in(Q))
KV_used = splice(KV_chunk, ctx_text_KV,
                 override_first_k_K = anchor_K_new,
                 position_in_Q)
output = MLLM.decode(KV_used, Q)
```

> **분석자 의견.** 위 가짜 코드는 검색된 스니펫에서 얻은 5개 컴포넌트, 병렬 I/O, 선두 k anchor 재계산을 종합해 재구성한 것이며 실제 함수 시그니처는 논문 4장에서 확인이 필요하다.

## 5. 실험

### 5.1 세팅

| 항목 | 값 |
| --- | --- |
| 모델 | LLaVA-1.6-vicuna-7B, LLaVA-1.6-mistral-7B (둘 다 멀티 이미지·고해상도 anyres 처리) |
| 추론 프레임워크 | vLLM 0.9.0 기반 커스텀 빌드 |
| 하드웨어 | NVIDIA H800-80GB GPU 1장, Intel Xeon Platinum 20-core CPU, 100 GB DRAM |
| 데이터셋 / 워크로드 | MMDU 등 multi-image / multi-turn 대화 벤치마크. interleaved 멀티모달 입력 + multimodal RAG 시나리오를 합성한 트레이스 (정확한 데이터셋 셋업은 PDF 5장 확인 필요) |
| 평가 지표 | TTFT(ms), 처리량(req/s 또는 tokens/s), 응답 정확도/품질 점수(GPT-4o 또는 강력한 judge 모델로 평가) |
| 베이스라인 | (a) Prefix caching, (b) Full recompute, (c) Full reuse, (d) CacheBlend (NLP용 위치 무관 캐시) |

### 5.2 주요 결과 (스니펫에서 추출, 정확 수치는 PDF 표 확인 필요)

- **TTFT**: prefix caching 대비 최대 **54.1% 감소** (구체 비교 군: MPIC-32 설정).
- **처리량**: 온라인 서빙 시뮬레이션에서 **2.0× 향상** (state-of-the-art 대비).
- **정확도**: prefix caching 대비 점수 손실 **13.6% 이내** — 저자들은 이를 "negligible or no quality degradation"으로 표현하지만, 분석자 의견으로는 13.6%는 일부 태스크에선 결코 작지 않다(아래 한계 참고).
- **베이스라인 대비**: CacheBlend보다 다양한 설정에서 TTFT·점수 모두 더 우수 (Figure 9 참조, 정확한 수치는 PDF 확인 필요).

### 5.3 Ablation·분석 (스니펫 기반 요약)

- **재계산 anchor 개수 k**: k가 0이면 full reuse(정확도 하락 큼), k가 전체이면 full recompute(latency 이득 없음). 스위트 스폿이 존재하며 LLaVA-1.6 계열에서 k가 비교적 작은 값(예: 첫 32 이미지 토큰)으로도 효과적이라는 결과.
- **토큰 선택 기준**: 단순 attention score top-k vs. attention deviation top-k vs. 두 신호의 조합. 두 신호의 조합이 가장 좋다는 결과 (CacheBlend의 deviation-only보다 우월하다는 것이 저자 주장).
- **attention sink 가설 검증**: 이미지 토큰 중 맨 앞 몇 개가 비정상적으로 큰 attention을 흡수한다는 측정. 이 영역만 정확히 갱신하면 후속 토큰들의 attention 분포가 크게 정상화됨.
- **시스템 ablation**: 디스크 I/O와 GPU prefill을 직렬로 두면 latency 이득이 사라진다는 결과 — 병렬 파이프라인이 시스템 측 핵심 기여임을 입증.

> 정확한 세팅(데이터셋 이름, judge 모델, request rate 등)과 표 수치는 OpenReview PDF/arXiv PDF 5장에서 직접 확인 필요.

## 6. 한계와 가정

저자가 명시한 것 + 분석에서 드러난 것:

1. **정확도 손실 13.6%는 결코 작지 않다.** 정밀한 multi-hop VQA·과학 QA에서 13.6%는 정답률을 크게 흔든다. 저자가 이를 "negligible"이라고 표현한 것은 일부 태스크 평균값에 가까운 해석으로 보이며, 태스크별로 손실이 더 큰 경우(특히 텍스트 정렬이 중요한 OCR 같은 작업)에 대한 추가 ablation이 필요. **분석자 의견.**
2. **모델 범위**: 검증은 LLaVA-1.6 계열에 집중. anyres image patch 토큰화가 다른 InternVL2/3, Qwen2-VL/Qwen3-VL, MiniCPM-V 등에서 anchor의 위치·개수가 어떻게 달라지는지 미검증.
3. **하드웨어 가정**: 디스크 → GPU 적재가 GPU prefill보다 빠르다는 전제. NVMe SSD가 아닌 HDD/네트워크 스토리지 환경, 혹은 매우 짧은 prompt에서는 I/O가 critical path가 될 수 있다.
4. **재사용 키 식별**: "동일한 이미지/문서 청크"를 재인식하는 cache lookup은 보통 hash-based id에 의존. 이미지가 살짝 변형(리사이즈, 다른 압축)되면 캐시 미스. 의미 기반(semantic) 캐시 매칭은 다루지 않음.
5. **위치 인코딩 의존성**: 모델이 RoPE를 쓸 때 K 텐서를 새 위치에 맞게 회전해야 함. 절대 위치 인코딩이나 ALiBi 등에서는 별도 처리 필요. 다양한 position embedding scheme에 대한 일반성은 미검증.
6. **prefill 외 단계**: 본 논문의 이득은 TTFT(=prefill 단계)에 집중. 디코드 phase의 generation latency나 output 길이가 긴 워크로드에서의 영향은 작을 가능성.
7. **MRAG 워크로드의 합성성**: 워크로드 트레이스가 합성된 것으로 보여(확인 필요), 실제 프로덕션 분포와의 격차는 외부 검증이 필요.

## 7. 선행/경쟁 연구와의 차별점

| 시스템 | 위치 무관 재사용 | 멀티모달 지원 | 토큰 선택 기준 | 디스크 오프로드 |
| --- | --- | --- | --- | --- |
| **PromptCache** (Gim et al., 2023, MLSys'24) | 부분(템플릿/슬롯) | × | 더미 prefix로 슬롯별 prefill | × |
| **CacheBlend** (Yao et al., 2024 → EuroSys'25 best paper) | ○ | × (NLP RAG) | 레이어별 high-deviation token | 부분 |
| **EPIC** (Hu et al., 2024 → ICML'25) | ○ | × | 문서 경계 anchor token | × |
| **A3** (Zhou et al., 2025) | ○ | × | real-time query-document attention | × |
| **SAM-KV** (Cao et al., 2025) | ○ (계층 압축) | × | hierarchical compression | × |
| **InfoBlend / MPIC** (본 논문) | ○ | **○** (interleaved + MRAG) | 이미지 토큰 anchor + attention deviation·score 조합 | **○** (Static/Dynamic Library + 병렬 파이프라인) |

핵심 차별점:
- **멀티모달로의 첫 본격 확장.** 텍스트 청크(문서)는 attention 분포가 위치에 비교적 둔감했지만, 이미지 토큰은 길이도 길고 sink 효과도 다르다. 이 점을 데이터·attention 분석으로 명시적으로 공략한 것이 새롭다.
- **시스템 추상화: Static / Dynamic Library + Retriever + Linker.** 동적 링커 비유는 사용자에게 선언적 API를 제공하기 좋고, 디스크 I/O를 일급 시민으로 다룬다. CacheBlend는 동일 GPU 노드 내 KV pool을 가정하는 데 비해 더 외부 스토리지 친화적.
- **이미지 attention sink 통찰**. ICLR'25 *"When Attention Sink Emerges"* 같은 일반 LLM 분석 라인을 멀티모달 KV 재사용이라는 시스템 문제에 적용한 사례.

## 8. 재현성

- **코드**: OpenReview/논문에 명시된 공식 저장소를 직접 확인하지 못함. 검색에서 *"공식 GitHub repo"*가 잡히지 않으며 paperswithcode 페이지에도 코드 링크가 비어 있음 — **확인 필요**. ICLR 더블블라인드 단계에서 supplementary로만 제공됐을 가능성 높음.
- **데이터셋**: MMDU(공개), 그 외 합성 multimodal RAG 트레이스(논문에서 정의된 그대로 재구성 필요).
- **하드웨어**: H800-80GB 1장, Intel Xeon Platinum 20코어, 100GB DRAM. 더 작은 GPU(예: A100-40GB)에서는 LLaVA-1.6-7B의 KV 캐시가 일부 OOM 위험.
- **소프트웨어**: vLLM 0.9.0(또는 EPIC가 사용한 0.4.1과 분리해 새 버전 기준). attention 커널을 직접 수정하므로 vLLM 버전 호환성에 주의.
- **라이선스**: 별도 명시 미확인. arXiv 버전(MPIC)도 라이선스 표기 — **확인 필요**.

## 9. 확장 아이디어

> 모두 **분석자 의견**이며, 저자 명시 future work는 PDF 7~8장 확인 필요.

1. **anchor 식별의 모델 범용화**. LLaVA-1.6 외 InternVL3, Qwen3-VL, MiniCPM-V 4 등에서 이미지 토큰의 attention sink 위치를 자동 탐색하는 메타 알고리즘. 모델·해상도별 anchor 길이 k 추천 함수.
2. **Semantic cache key**. 이미지 hash 대신 CLIP/SigLIP embedding 기반의 fuzzy lookup으로 "같은 의미 이미지의 약간 다른 사본"을 적중률 높게 재사용.
3. **계층화 스토리지**. GPU HBM → CPU DRAM → NVMe → 원격 스토리지의 4-tier에서 LRU/LFU+속성 기반 admission. LMCache 류 인프라와의 결합.
4. **압축**. KV Cache Transform Coding(ICLR'26)이나 8-bit/INT4 KV quantization과 결합해 디스크 footprint와 I/O 대역폭을 동시에 축소.
5. **decode-stage 활용**. 본 논문은 prefill 절감에 초점. 긴 출력 생성에서 정기적으로 anchor refresh를 수행해 누적 drift를 잡는 디코드-단계 변종.
6. **cross-modal anchor**. 이미지 토큰뿐 아니라 audio/video 토큰에서도 sink 효과가 있는지 검증, 멀티모달 일반화. Qwen2-Audio·Video-LLaMA 류 확장.
7. **공정 평가용 multi-image MRAG 벤치**. MMDU + InfoSeek + WebQA를 결합한 공식 KV 재사용 벤치마크가 부재 — 후속 연구가 만들 만함.

## 10. 참고 문헌

- [InfoBlend OpenReview submission (forum bld5GVRad0)](https://openreview.net/forum?id=bld5GVRad0) — ICLR 2026 under review (anonymous).
- [MPIC: Position-Independent Multimodal Context Caching System for Efficient MLLM Serving](https://arxiv.org/abs/2502.01960) — Shiju Zhao et al., arXiv:2502.01960 (2025). InfoBlend의 비익명 선행/공개판으로 추정.
- [CacheBlend: Fast Large Language Model Serving for RAG with Cached Knowledge Fusion](https://arxiv.org/abs/2405.16444) — Yao et al., EuroSys 2025 (Best Paper).
- [EPIC: Efficient Position-Independent Caching for Serving Large Language Models](https://arxiv.org/abs/2410.15332) — Hu et al., ICML 2025.
- [PromptCache: Modular Attention Reuse for Low-Latency Inference](https://arxiv.org/abs/2311.04934) — Gim et al., MLSys 2024.
- [LMCache: An Efficient KV Cache Layer for Enterprise-Scale LLM Inference](https://arxiv.org/abs/2510.09665) — KV cache layer 인프라.
- [When Attention Sink Emerges](https://proceedings.iclr.cc/paper_files/paper/2025/file/f1b04face60081b689ba740d39ea8f37-Paper-Conference.pdf) — ICLR 2025, attention sink 이론적 배경.
- [MMDU: A Multi-Turn Multi-Image Dialog Understanding Benchmark](https://arxiv.org/abs/2406.11833) — 평가 데이터셋 가운데 하나.
- [LLaVA-1.6 / LLaVA-NeXT](https://llava-vl.github.io/blog/2024-01-30-llava-next/) — 평가 대상 MLLM.
- [MEPIC: Memory Efficient Position Independent Caching for LLM Serving](https://arxiv.org/abs/2512.16822) — 후속 메모리 절약 라인(NLP 위주, 본 논문과 동시기).
- [VLCache: Computing 2% Vision Tokens and Reusing 98% for Vision-Language Inference](https://arxiv.org/abs/2512.12977) — 비전 토큰 재사용 후속 라인.

## 11. Methodology

### 사용한 자료와 인용 출처
- 식별: OpenReview 검색 결과 forum id `bld5GVRad0` 및 동일 제목 검색.
- 본문 내용 추출: 직접 PDF/OpenReview HTML 접근은 사이트 차단(403/Host not in allowlist)으로 실패. 대신 다수의 WebSearch 스니펫(arxiv.org/html/2502.01960, paperswithcode, ADS, 2차 인용 논문) 결과를 교차 검증해 정성적 정보(54.1% TTFT 감소, 2.0× throughput, 13.6% 점수 손실, 5개 컴포넌트, anchor 토큰 재계산, vLLM 0.9.0 기반, H800-80GB 환경, LLaVA-1.6-vicuna/mistral 7B, MMDU 사용 등)를 추출.
- 비교 대상 라인업(CacheBlend·EPIC·A3·SAM-KV·PromptCache 비교)은 후속 논문 KV Packet, MEPIC, LMCache survey 등의 비교 표·관련연구에서 InfoBlend/MPIC를 어떻게 자리매김하는지 통해 재구성.

### 미확인·접근 불가 자료 (직접 PDF 확인 필요)
- OpenReview PDF (`https://openreview.net/pdf?id=bld5GVRad0`) — 사이트 정책상 sandbox에서 접근 차단.
- arXiv:2502.01960 PDF/HTML 본문(섹션 3 알고리즘 의사코드, 섹션 4 시스템 figure, 섹션 5 실험 표 정확 수치).
- 공식 코드 저장소 존재 여부 및 라이선스.
- OpenReview 리뷰·rebuttal·결정 결과(현재 더블블라인드 진행 중).
- 합성 워크로드의 정확한 request-rate, prompt 길이, 이미지 수 분포.

### 추정·해석으로 보강한 부분(분석자 의견)
- "anchor 토큰" 재계산의 의사 코드 재구성.
- 5개 컴포넌트 중 Linker의 RoPE 위상 처리 추정.
- 13.6% 점수 손실의 한계 해석.
- 후속 연구 아이디어 7건 모두 분석자 제안.
