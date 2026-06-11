# ADR-0004 — 상태관리/백엔드 피벗: Riverpod/Firebase → StatefulWidget/SharedPreferences

- **날짜**: 2026-06-09
- **상태**: 확정 (ADR-0002, ADR-0003을 구현 단계에서 수정)

---

## 배경

ADR-0002(Riverpod), ADR-0003(Firebase)는 기획 단계(10주차, 6주 일정 가정)에서 내린 결정이다.
12주차 구현 시작 시점에 1인 개발 + 7주(9~15주차) 일정 + 화면 7~9개 규모를 재평가한 결과:

- Riverpod 도입 비용(Provider 설계, DI 구조) 대비 화면 수가 적어 StatefulWidget만으로 충분
- Firebase 프로젝트 설정·Auth 연동·과금 정책 확인에 드는 시간이 남은 일정 대비 과도함
- 발표 데모 환경에서는 "팀원 누구나 즉시 실행 가능"(API 키 1개만 설정)이 더 중요한 가치

---

## 결정

- **상태관리**: StatefulWidget 사용 (Riverpod는 pubspec 의존성만 남기고 미사용)
- **저장소/인증**: SharedPreferences 기반 로컬 JSON 저장 (Firebase 미연동)
  - 컬렉션 구조는 추후 Firestore 마이그레이션을 고려해 `users`, `saved_trips` 등 동일한 형태로 설계

---

## 대안

| 대안 | 검토 이유 | 제외 이유 |
|------|-----------|-----------|
| 원래 계획대로 진행 (Riverpod + Firebase) | ADR-0002/0003 일관성 유지 | 설정·연동에 소요되는 시간이 핵심 기능(AI 추천, 날씨 연동) 구현 시간을 잠식 |
| Riverpod만 도입, Firebase는 보류 | 상태관리 확장성 확보 | 화면 7~9개 규모에서 Provider 보일러플레이트 대비 이득 적음 |

---

## 결과

- **장점**: 외부 계정/키 설정 없이 `lib/core/config.dart` 1개 파일만으로 즉시 실행 가능, 디버깅 단순, 데모 이식성 높음
- **단점**: 비밀번호 평문 저장(SharedPreferences) — 출시 시 Firebase Auth 등으로 교체 필요 (AUTHORING.임다솔.v0.4.0.md 사례 3 참조)
- **단점2**: 기기 간 동기화 불가, 다중 사용자 동시 편집 불가
- **영향**:
  - `docs/architecture.md`: Application 레이어 제거, 3계층(Presentation→Domain→Data)으로 갱신
  - `AGENTS.md`: "StatefulWidget 사용, Riverpod Provider 생성 금지" 코딩 규칙 명시
  - 향후 실서비스 전환 시 ADR-0002/0003 방향(Riverpod+Firebase)으로 재검토 가능 — 저장소 스키마를 Firestore 호환 형태로 미리 설계해둠
