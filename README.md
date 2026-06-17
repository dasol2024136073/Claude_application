# Tripia — AI 여행 경로 추천 앱

취향 프로필 + 실시간 날씨를 Gemini AI에 전달해 개인화된 여행 경로를 생성·저장하는 Flutter 웹 앱.

---

## 기술 스택

| 영역 | 기술 | 비고 |
|------|------|------|
| 클라이언트 | Flutter 3.x + Dart 3.x | 웹 빌드 주력 (`flutter build web`) |
| 상태관리 | StatefulWidget | Riverpod는 미사용 |
| 네비게이션 | GoRouter 14.x | 8개 경로 |
| AI 추천 | Gemini 2.5 Flash | `gemini_service.dart`, thinkingBudget:0 |
| 날씨 | OpenWeatherMap API | `weather_service.dart`, 국내외 60+ 도시 매핑 |
| 지도 | flutter_map + OpenStreetMap | API 키 불필요 |
| 저장/인증 | SharedPreferences | 로컬 JSON 직렬화, 이메일/비밀번호 인증 |
| HTTP | Dio 5.x | |

## 주요 기능

- 이메일/비밀번호 로그인·회원가입 (성별·전화번호·생년월일 입력)
- Gemini API 기반 실시간 여행 경로 생성
- 경로 저장·조회·삭제 (마이페이지)
- flutter_map + OpenStreetMap 기반 경로 지도 시각화
- 실시간 날씨 반영 경로 추천 + 날씨 변화 감지 재추천 알림
- 날씨 검색 화면 (시간별·5일 예보)

## 실행 방법

```bash
git clone https://github.com/dasol2024136073/Claude_application.git
cd Claude_application
flutter pub get
flutter run -d chrome
```

API 키(`lib/core/config.dart`) 등 자세한 설정은 [docs/setup.md](docs/setup.md) 참조.

## 아키텍처

3계층 구조 (Presentation → Domain → Data, Application 레이어 없음). 화면이 서비스를 직접 호출.

자세한 구조는 [docs/architecture.md](docs/architecture.md) 참조.

## 빌드 / 배포

빌드 종류, 환경 설정, 배포 채널, 버전 관리(SemVer), 롤백 방법은 [docs/deploy.md](docs/deploy.md) 참조.

## 테스트

테스트 실행 방법과 구조는 [docs/testing.md](docs/testing.md) 참조. (총 38개, 전부 통과)

## AI Agent 활용

이 프로젝트는 기획·코드·문서 전 과정에 AI Agent(Claude Code)를 적극 활용했습니다.

| 파일 | 내용 |
|------|------|
| [AGENTS.md](AGENTS.md) | AI Agent 컨텍스트 파일 (프로젝트 구조·규칙·명령어) |
| [AUTHORING.임다솔.v0.5.0.md](AUTHORING.임다솔.v0.5.0.md) | 본인만의 AI Agent 운영 방법론 (agent/skills/rules/commands/workflow 통합, v0.1.0~v0.5.0) |
| [notes/](notes/) | LLM Wiki — 주차별 암묵지 관리 (week10~week14, 프롬프트 패턴·실패 사례·개선 기록) |
| [BONUS.md](BONUS.md) | 가산점 항목별 증거 자료 트래킹 |

## 기획 문서

| 문서 | 내용 |
|------|------|
| [기획서 · 비전](.planning/00-vision.md) | 앱 비전, 핵심 목표, 타깃 사용자 |
| [요구사항](.planning/01-requirements.md) | 사용자 시나리오, MoSCoW 요구사항 |
| [WBS · 일정](.planning/02-wbs.md) | 작업 분류 체계(WBS), 주차별 일정 |
| [일정 계획](.planning/04-schedule.md) | 9주차~15주차 마일스톤 및 스프린트 계획 |
| [아키텍처 결정 기록 (ADR)](.planning/decisions/) | ADR-0001 ~ ADR-0004 (프레임워크·상태관리·백엔드·저장소) |

## 라이선스

본 프로젝트는 교육 목적의 기말 프로젝트입니다.
