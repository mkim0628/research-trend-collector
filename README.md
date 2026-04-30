# Research Trend Collector

연구 동향을 매일 수집하고, 누적된 결과를 이 README의 인덱스에서 한눈에 보기 위한 워크스페이스입니다. 일일 보고서는 `reports/`에 쌓이고, 특정 논문에 대한 심층 분석은 `reports/deep-dives/`에 분리되어 저장됩니다. 두 결과 모두 아래 *Reports Index* 영역에 자동으로 정리됩니다.

## 사용법

| 커맨드 | 설명 |
| --- | --- |
| `/collect-trends interests/<file>` | 관심 분야 명세 파일을 읽어 일일 동향 보고서를 생성하고 README 인덱스를 갱신합니다. |
| `/deep-dive <논문 \| URL \| arXiv ID>` | 특정 연구물을 심층 분석한 보고서를 `reports/deep-dives/`에 저장하고 인덱스에 반영합니다. |
| `/index-reports` | `reports/`를 스캔해 README의 인덱스 영역만 재생성합니다(보고서 본문은 건드리지 않음). |

상세 운영 규칙·보고서 형식·작업 원칙은 [`CLAUDE.md`](CLAUDE.md)를 참고하세요. 관심 분야 명세 예시는 [`interests/example.yaml`](interests/example.yaml), [`interests/example.md`](interests/example.md)에 있습니다.

## Reports Index

> 아래 영역은 `report-indexer` 서브에이전트가 자동 갱신합니다. 마커 사이만 교체되며, 그 밖의 내용은 보존됩니다.

<!-- BEGIN: AUTO-INDEX -->
_아직 보고서가 없습니다. `interests/`에 명세를 작성하고 `/collect-trends interests/<파일명>`을 실행해 보세요._
<!-- END: AUTO-INDEX -->
