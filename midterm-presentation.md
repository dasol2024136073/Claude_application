---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section {
    font-family: 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif;
    background: #ffffff;
    color: #0f172a;
    padding: 52px 72px;
    font-size: 20px;
  }
  h1 { font-size: 2.4em; font-weight: 800; color: #0f172a; margin-bottom: 12px; }
  h2 { font-size: 1.55em; font-weight: 700; color: #1e3a8a;
       border-bottom: 3px solid #3b82f6; padding-bottom: 10px; margin-bottom: 28px; }
  h3 { font-size: 1.1em; font-weight: 600; color: #334155; margin-bottom: 8px; }
  p  { line-height: 1.7; }
  ul { padding-left: 1.2em; }
  li { margin-bottom: 6px; line-height: 1.6; }
  table { width: 100%; border-collapse: collapse; font-size: 0.82em; }
  th { background: #1e3a8a; color: #ffffff; padding: 10px 16px; text-align: left; }
  td { padding: 9px 16px; border-bottom: 1px solid #e2e8f0; color: #1e3a8a; }
  tr:nth-child(even) td { background: #f8fafc; }
  blockquote {
    border-left: 4px solid #3b82f6;
    background: #eff6ff;
    color: #1e3a8a;
    padding: 14px 22px;
    border-radius: 0 8px 8px 0;
    margin: 20px 0;
    font-style: normal;
  }
  strong { color: #1e3a8a; }
  section.cover { background: #0f172a; color: #ffffff; justify-content: center; }
  section.cover h1 { color: #ffffff; font-size: 2.8em; }
  section.cover p  { color: #94a3b8; font-size: 1.1em; margin-top: 8px; }
  section.cover .sub { color: #60a5fa; font-size: 1.05em; }
  section.qa { background: #1e3a8a; color: #ffffff; }
  section.qa h2 { color: #ffffff; border-color: #60a5fa; }
  section.qa li { color: #e2e8f0; }
  section.qa strong { color: #93c5fd; }
  section.qa th { background: rgba(255,255,255,0.18); color: #ffffff; }
  section.qa td { color: #e2e8f0; border-bottom-color: rgba(255,255,255,0.15); }
  section.qa tr:nth-child(even) td { background: rgba(255,255,255,0.08); }
  section.end { background: #0f172a; color: #ffffff; justify-content: center; text-align: center; }
  section.end h2 { border: none; color: #60a5fa; }
---

<!-- _class: cover -->

# AI 여행 경로 추천 앱

<br>

나의 취향 프로필과 실시간 날씨·위치를 반영해  
**AI가 10초 만에 나만의 특별한 여행 동선을 설계합니다**

<br>

**임다솔** · Flutter · 2026년 중간 발표

---

## 우리가 해결하는 문제

| 문제 | 현실 | 우리 앱의 답 |
|---|---|---|
| **계획 피로** | 여행지·식당·동선 검색에 수십 개 탭을 연다 | AI가 원클릭으로 전체 동선 생성 |
| **획일적 추천** | 블로그·유튜브는 모두에게 같은 코스를 준다 | 취향 프로필 기반 개인화 경로 |
| **상황 대응 불가** | 갑자기 비가 와도 처음부터 다시 검색해야 한다 | 실시간 날씨·위치 반영 경로 재추천 |

<br>

> **한 줄 가치 제안**  
> 당신의 발걸음을 AI가 별자리처럼 이어, 이 세상 어디에도 없던 하나뿐인 여행을 그려드립니다.

---

## 사용자 시나리오

**지수 (25세, 직장인)** — *"오사카 3박 4일, 맛집 위주로 계획해야 하는데…"*

<br>

| 단계 | 행동 | 결과 |
|---|---|---|
| **① 로그인** | Google 계정으로 탭 한 번 | 바로 앱 시작 |
| **② 취향 설정** | 맛집·카페 선호 / 혼자 / 여유 예산 선택 | 프로필 저장 |
| **③ 목적지 입력** | "오사카" + 3박 선택 → 경로 생성 버튼 탭 | AI 호출 시작 |
| **④ AI 응답** | 10초 이내 일별 경로 수신 | 도톤보리 → 구로몬 → 신사이바시 |
| **⑤ 저장** | 마음에 드는 장소 교체 후 최종 저장 | 내 경로 보관함 추가 |

<br>

> **결과** — 수십 개 탭 검색 없이, 취향 맞춤 오사카 동선을 10초 만에 완성

---

## 기술 스택 — 왜 이걸 선택했나요?

**앱 프레임워크 비교 — Flutter vs 대안**

| 항목 | ✅ Flutter (선택) | React Native | 네이티브 Swift/Kotlin |
|---|---|---|---|
| 코드베이스 | **단일 코드 → iOS·Android 동시 빌드** | 단일 코드, JS 브리지 성능 손실 | 플랫폼별 별도 코드 (공수 2배) |
| UI 렌더링 | **자체 엔진 — OS 무관 픽셀 일치** | 네이티브 위젯 위임 → OS별 차이 | 완전 네이티브 |
| 지도·Firebase | **공식 SDK 안정 제공** | 공식 SDK 있으나 안정성 낮음 | 공식 SDK 있음 |
| 개발 속도 | **Hot Reload — 빠른 프로토타입** | 비슷 | 느림 (컴파일 사이클) |
| **결론** | **MVP를 혼자·빠르게·두 플랫폼에** | JS 미숙 + 브리지 오버헤드 | 개발 공수 감당 불가 |

<br>

**나머지 스택 선택 근거**

| 영역 | 선택 | 이유 | 제외한 대안 |
|---|---|---|---|
| 상태관리 | **Riverpod 2.x** | AsyncValue로 로딩·오류·데이터 타입 안전 처리 | BLoC(보일러플레이트 과다), GetX(테스트 어려움) |
| 백엔드 | **Firebase** | Auth·Firestore 즉시 사용, 무료 플랜 MVP 가능 | Supabase(SDK 성숙도), 직접 구축(배포 부담) |
| AI 엔진 | **Claude API** | 자연어 → 구조화된 JSON 일정 생성 | GPT-4o 검토, 수업 취지상 Claude 선택 |
| 네비게이션 | **GoRouter** | 선언형 URL 라우팅, 딥링크·웹 지원 | — |
| 날씨 | **OpenWeatherMap** | 무료 API, 실시간 기온·강수 | — |

> ADR-0001 (Flutter) · ADR-0002 (Riverpod) · ADR-0003 (Firebase) — `.planning/decisions/` 참조

---

## 아키텍처 — 4계층 레이어드 구조

**[ 화면·UI ] → [ 비즈니스 로직 ] → [ 도메인 모델 ] ← [ 데이터·API ]**

<br>

| 레이어 | 한 줄 역할 | 현재 구현 |
|---|---|---|
| **Presentation** | 사용자가 보고 탭하는 화면 | 로그인 · 취향설정 · 홈 · 경로입력 · 결과 (5개) |
| **Application** | 기능 흐름 조율 ("무엇을 어떤 순서로") | 미구현 → 다음 단계 |
| **Domain** | 앱의 핵심 데이터 구조와 규칙 | TripPlan · DayPlan · PlaceItem |
| **Data** | 외부 API·DB와 실제 통신 | Mock 더미 → Claude API · Firebase 예정 |

<br>

> **핵심 원칙** — 화면은 데이터 출처를 모릅니다.  
> Firebase를 다른 백엔드로 바꿔도 화면 코드는 그대로입니다.

---

## 현재 진행 상황

**완료** (Must 기능 기준 ~40%)

- 기획 전체 — 비전·요구사항·WBS·위험관리·ADR 3종
- Flutter 4계층 프로젝트 구조 · 웹 빌드 성공 (`flutter build web`)
- 화면 5개 구현 — 로그인 · 취향설정 · 홈 · 경로입력 · 경로결과
- GoRouter 라우팅 연결 · 도메인 모델 · Mock 데이터 레이어 분리

<br>

**진행 예정** (13주차 우선순위)

- Claude API 실제 연동 — 프롬프트 설계 · JSON 파싱 · 결과 렌더링
- Firebase Auth · Firestore — 실제 로그인 · 경로 저장·조회
- Google Maps SDK — 경로 핀 · 이동선 시각화
- 날씨 API · 경로 편집 UI · 단위 테스트 스위트

---

## 데모

지금 바로 보여드리겠습니다.

<br>

| 단계 | 화면 | 확인 포인트 |
|---|---|---|
| ① | 로그인 | Google 버튼 탭 → 즉시 취향 설정으로 이동 |
| ② | 취향 설정 | 여행 스타일 · 예산 · 동행 유형 선택 |
| ③ | 홈 | "새 여행 경로 만들기" 버튼 |
| ④ | 경로 입력 | "오사카" 입력 · 3박 선택 · 생성 버튼 |
| ⑤ | 로딩 | "AI가 경로를 설계하는 중…" |
| ⑥ | 경로 결과 | 일별 장소 목록 · 저장 버튼 |

<br>

> **현재 상태** — AI 응답은 Mock 데이터. 13주차에 Claude API 실제 연동 예정

---

## 남은 일정과 우선순위

| 주차 | 핵심 목표 | 주요 산출물 |
|---|---|---|
| **13주차** | API 실제 연동 + 테스트 | Claude API · Firebase · 날씨 · 경로 편집 · 단위 테스트 |
| **14주차** | 기능 마무리 + 배포 | 커뮤니티 피드 · Google Maps · UAT · Play Store 빌드 |
| **15주차** | 최종 발표 | 라이브 데모 · KPT 회고 문서 · 가산점 어필 |

<br>

**Must 기능 완성 목표** — 13주차 말 (현재 ~40% → 목표 90%)

<br>

> 가장 큰 위험 — R05 (13주차 시험·과제 폭주 주간 겹침)  
> 대응 — Must 기능 우선 완성, Should 기능은 14주차로 이월

---

<!-- _class: qa -->

## Q&A

**Q1. 왜 Flutter인가요?**
단일 코드로 iOS·Android 동시 빌드, Maps·Firebase 공식 SDK 안정 제공.
React Native는 JS 브리지 성능 손실, 네이티브는 코드 공수 2배 → 둘 다 제외.

**Q2. 지금 화면 데이터는 어디서 오나요?**
현재는 Mock 더미. 13주차에 Claude API 연동으로 실제 JSON 응답으로 교체 예정.

**Q3. 가장 큰 위험은?**
AI가 짠 코드를 내가 완전히 이해 못하는 것.
대응 — 생성 직후 직접 주석 달기, 핵심 로직은 직접 타이핑해서 이해 확인.

**Q4. AI가 만든 것 vs 내가 결정한 것?**

| 🙋 내가 한 것 | 🤖 AI (Claude Code)가 한 것 |
|---|---|
| 앱 주제 기획 · 타겟 사용자 설정 | 화면 5개 UI 코드 구현 |
| Flutter · Firebase 기술 스택 최종 결정 | 라우팅 설정 · 도메인 모델 · 더미 데이터 |
| 한 줄 가치 제안 · UX 흐름 방향 설정 | 기획 문서 · ADR 초안 · 아키텍처 설계 |
| 생성 코드 리뷰 · 오류 수정 · 품질 검수 | deprecated API 대안 제시 · 리팩터링 |

---

<!-- _class: end -->

## 감사합니다

<br>

**임다솔** · AI 여행 경로 추천 앱 · 2026 중간 발표

<br>

`github.com/dasol2024136073/Claude_application`
