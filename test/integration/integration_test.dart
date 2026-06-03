// 사용자 시나리오 없는 관점의 통합 테스트
// 데이터 레이어(MockTripData)와 도메인 레이어(TripPlan) 간 연동 구조 검증
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_ai/data/mock/mock_trip_data.dart';
import 'package:travel_ai/domain/models/trip_plan.dart';

void main() {
  group('Data→Domain 레이어 연동: 반환 타입 검증', () {
    test('MockTripData.generate가 TripPlan 인스턴스를 반환한다', () {
      final result = MockTripData.generate('오사카', 1);
      expect(result, isA<TripPlan>());
    });

    test('TripPlan.dayPlans의 각 요소가 DayPlan 타입이다', () {
      final plan = MockTripData.generate('도쿄', 2);
      for (final day in plan.dayPlans) {
        expect(day, isA<DayPlan>());
      }
    });

    test('DayPlan.places의 각 요소가 PlaceItem 타입이다', () {
      final plan = MockTripData.generate('파리', 1);
      for (final place in plan.dayPlans.first.places) {
        expect(place, isA<PlaceItem>());
      }
    });
  });

  group('Data→Domain 레이어 연동: 4개 목적지 구조 일관성', () {
    final destinations = ['오사카', '제주', '도쿄', '파리'];

    for (final dest in destinations) {
      test('$dest 1일 플랜의 모든 PlaceItem 필드가 비어있지 않다', () {
        final plan = MockTripData.generate(dest, 1);
        for (final place in plan.dayPlans.first.places) {
          expect(place.name, isNotEmpty, reason: '$dest — name이 비어있음');
          expect(place.time, isNotEmpty, reason: '$dest — time이 비어있음');
          expect(place.category, isNotEmpty, reason: '$dest — category가 비어있음');
          expect(place.description, isNotEmpty, reason: '$dest — description이 비어있음');
        }
      });
    }

    test('4개 목적지 모두 days 필드가 요청값과 일치한다', () {
      for (final dest in destinations) {
        final plan = MockTripData.generate(dest, 1);
        expect(plan.days, 1, reason: '$dest의 days가 1이 아님');
      }
    });
  });
}
