// 디버깅 테스트: 경계값·예외 케이스에서 앱이 올바르게 동작하는지 확인
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_ai/data/mock/mock_trip_data.dart';

void main() {
  group('MockTripData — 경계값', () {
    test('days=0(당일치기)이면 dayPlans가 1개다', () {
      final plan = MockTripData.generate('오사카', 0);
      expect(plan.dayPlans.length, 1);
    });

    test('days=1(1박2일)이면 dayPlans가 정확히 2개다', () {
      final plan = MockTripData.generate('도쿄', 1);
      expect(plan.dayPlans.length, 2);
    });

    test('저장된 일수(3일)를 초과 요청해도 최대 보유 일수까지만 반환한다', () {
      // 제주 mock은 최대 3일치 보유 — 5일 요청 시 3일까지만 반환
      final plan = MockTripData.generate('제주', 5);
      expect(plan.dayPlans.length, lessThanOrEqualTo(3));
    });

    test('알 수 없는 목적지는 generic 플랜으로 처리된다 (3박4일)', () {
      final plan = MockTripData.generate('뉴욕', 3);
      expect(plan.destination, '뉴욕');
      expect(plan.dayPlans.length, 4);
    });

    test('알 수 없는 목적지의 generic 플랜도 각 일차에 장소가 있다', () {
      final plan = MockTripData.generate('베를린', 2);
      for (final day in plan.dayPlans) {
        expect(day.places, isNotEmpty, reason: '${day.day}일차에 장소가 없습니다');
      }
    });

    test('대문자 영문 키워드도 목적지를 인식한다 (OSAKA → 오사카)', () {
      final plan = MockTripData.generate('OSAKA', 1);
      expect(plan.destination, '오사카');
    });

    test('키워드가 긴 문자열 안에 포함돼도 인식한다 (오사카 맛집 → 오사카)', () {
      final plan = MockTripData.generate('오사카 맛집 여행', 1);
      expect(plan.destination, '오사카');
    });
  });
}
