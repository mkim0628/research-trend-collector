---
description: reports 디렉터리를 스캔해 README의 자동 인덱스 영역을 재생성합니다
---

`report-indexer` 서브에이전트(Agent 도구, `subagent_type: report-indexer`)를 호출해 `README.md`의 `<!-- BEGIN: AUTO-INDEX -->` ~ `<!-- END: AUTO-INDEX -->` 사이만 재생성하세요.

지시사항:
1. `README.md`가 존재하지 않으면 사용자에게 알리고 중단하세요(인덱서가 README를 새로 만들지 않습니다).
2. 직접 README를 수정하지 말고 반드시 서브에이전트에게 위임하세요.
3. 작업이 끝나면 사용자에게 다음만 보고하세요.
   - 갱신된 토픽 수, 추가된 논문 수, deep-dive 수
   - 파싱 실패한 보고서가 있다면 파일명과 사유
