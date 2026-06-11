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

이 프로젝트는 AI Agent와 함께 작업합니다. 컨텍스트는 [AGENTS.md](AGENTS.md), 본인만의 운영 방법론은 [AUTHORING.임다솔.v0.4.0.md](AUTHORING.임다솔.v0.4.0.md) 참조.

## 라이선스

본 프로젝트는 교육 목적의 기말 프로젝트입니다.
