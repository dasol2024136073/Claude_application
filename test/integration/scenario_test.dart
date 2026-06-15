// 사용자 시나리오 관점의 통합 테스트
// "사용자가 ~하면 ~이 된다" 형식으로 실제 사용 흐름을 검증
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_ai/data/mock/mock_trip_data.dart';

void main() {
  group('시나리오: 사용자가 오사카 2박3일 여행 경로를 요청한다', () {
    test('일정이 생성되고 3일치(2박3일) dayPlans가 반환된다', () {
      final plan = MockTripData.generate('오사카', 2);

      expect(plan.destination, '오사카');
      expect(plan.dayPlans.length, 3);
    });

    test('각 일차에 최소 1개 이상의 장소가 있다', () {
      final plan = MockTripData.generate('오사카', 2);

      for (final day in plan.dayPlans) {
        expect(day.places, isNotEmpty, reason: '${day.day}일차에 장소가 없습니다');
      }
    });

    test('1일차 일정에 대표 명소 도톤보리가 포함된다', () {
      final plan = MockTripData.generate('오사카', 2);

      final day1Names = plan.dayPlans.first.places.map((p) => p.name).toList();
      expect(day1Names, contains('도톤보리'));
    });

    test('2박3일 요청 시 정확히 3일치(4일차 이상 없음)만 포함된다', () {
      final plan = MockTripData.generate('오사카', 2);

      expect(plan.dayPlans.length, 3);
    });
  });

  group('시나리오: 사용자가 처음 방문하는 도시(뉴욕) 여행 경로를 요청한다', () {
    test('알 수 없는 도시도 generic 일정으로 생성된다 (3박4일)', () {
      final plan = MockTripData.generate('뉴욕', 3);

      expect(plan.destination, '뉴욕');
      expect(plan.dayPlans.length, 4);
    });

    test('generic 일정도 각 일차에 장소가 있어 일정표로 사용 가능하다', () {
      final plan = MockTripData.generate('뉴욕', 3);

      for (final day in plan.dayPlans) {
        expect(day.places, isNotEmpty);
        for (final place in day.places) {
          expect(place.name, isNotEmpty);
          expect(place.time, isNotEmpty);
        }
      }
    });
  });
}
