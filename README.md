# AI 여행 경로 추천 앱

취향 프로필 + 실시간 날씨·위치를 AI에 전달해 개인화된 여행 경로를 생성하고 커뮤니티에 공유하는 Flutter 앱.

---

## 기술 스택

| 영역 | 기술 |
|------|------|
| 클라이언트 | Flutter 3.x + Dart 3.x |
| 상태관리 | Riverpod 2.x |
| 백엔드 | Firebase (Auth + Firestore + Storage) |
| 지도 | Google Maps Flutter |
| AI 추천 | Claude API (Anthropic) |

## 실행 방법

```bash
git clone https://github.com/dasol2024136073/Claude_application.git
cd Claude_application
flutter pub get
flutter run
```

자세한 설정은 [docs/setup.md](docs/setup.md) 참조.

## 아키텍처

4계층 레이어드 아키텍처 (Presentation → Application → Domain → Data)

자세한 구조는 [docs/architecture.md](docs/architecture.md) 참조.
