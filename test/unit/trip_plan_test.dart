import 'package:flutter_test/flutter_test.dart';
import 'package:travel_ai/domain/models/trip_plan.dart';

void main() {
  group('TripPlan', () {
    test('should_store_destination_when_created', () {
      const plan = TripPlan(destination: '도쿄', days: 3, dayPlans: []);
      expect(plan.destination, '도쿄');
    });

    test('should_store_days_when_created', () {
      const plan = TripPlan(destination: '파리', days: 5, dayPlans: []);
      expect(plan.days, 5);
    });

    test('should_have_empty_dayplans_when_given_empty_list', () {
      const plan = TripPlan(destination: '서울', days: 0, dayPlans: []);
      expect(plan.dayPlans, isEmpty);
    });
  });

  group('DayPlan', () {
    test('should_store_day_number_when_created', () {
      const day = DayPlan(day: 2, places: []);
      expect(day.day, 2);
    });

    test('should_store_places_when_given_place_list', () {
      const place = PlaceItem(
        time: '09:00',
        name: '에펠탑',
        category: '관광',
        description: '파리의 상징',
      );
      const day = DayPlan(day: 1, places: [place]);
      expect(day.places.length, 1);
    });
  });

  group('PlaceItem', () {
    test('should_store_all_fields_when_created', () {
      const place = PlaceItem(
        time: '10:00',
        name: '도톤보리',
        category: '맛집·관광',
        description: '오사카의 심장',
      );
      expect(place.time, '10:00');
      expect(place.name, '도톤보리');
      expect(place.category, '맛집·관광');
      expect(place.description, '오사카의 심장');
    });
  });
}
