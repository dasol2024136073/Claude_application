# ADR-0003 — 백엔드: Firebase

- **날짜**: 2026-05-12
- **상태**: 확정

---

## 배경

앱에는 다음 백엔드 기능이 필요하다.

- **인증**: Google / Kakao 소셜 로그인
- **데이터베이스**: 사용자 프로필, 저장된 경로, 커뮤니티 게시글
- **스토리지**: 커뮤니티 게시글 사진
- **실시간 업데이트**: 커뮤니티 피드 좋아요·북마크 반영

MVP 기간(6주)이 짧아 인프라 구축 시간을 최소화해야 한다.

---

## 결정

**Firebase** (Auth + Firestore + Storage)를 선택한다.

---

## 대안

| 대안 | 검토 이유 | 제외 이유 |
|------|-----------|-----------|
| Supabase | PostgreSQL 기반, SQL 쿼리 가능, 오픈소스 | Flutter SDK 성숙도가 Firebase보다 낮음, Row-level security 설정 러닝커브 |
| 직접 구축 (Node.js + PostgreSQL) | 완전한 커스터마이징 | 서버 배포·운영 부담, MVP 기간 내 불가능 |
| AWS Amplify | 엔터프라이즈 수준 확장성 | 설정 복잡도 높음, 무료 티어 한도 예측 어려움 |

---

## 결과

- **장점**: Flutter 공식 FlutterFire 패키지 제공, Google 로그인 Firebase Auth 기본 내장, Firestore 실시간 스트림(`snapshots()`)으로 피드 자동 갱신, 무료 Spark 플랜으로 MVP 개발 가능
- **단점**: Firestore는 관계형 쿼리 불가, 복잡한 JOIN 필요 시 비정규화 필요 → 데이터 설계를 Firestore 구조에 맞게 사전 설계해야 함
- **단점2**: Kakao 로그인은 Firebase Auth 기본 미지원 → Kakao SDK로 토큰 발급 후 Firebase Custom Token으로 연결하는 추가 작업 필요
- **영향**: Firestore 컬렉션 구조 설계를 `docs/architecture.md`에 포함해야 함
