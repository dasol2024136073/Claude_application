class TripPlan {
  final String destination;
  final int days;
  final List<DayPlan> dayPlans;

  const TripPlan({
    required this.destination,
    required this.days,
    required this.dayPlans,
  });
}

class DayPlan {
  final int day;
  final List<PlaceItem> places;

  const DayPlan({required this.day, required this.places});
}

class PlaceItem {
  final String time;
  final String name;
  final String category;
  final String description;

  const PlaceItem({
    required this.time,
    required this.name,
    required this.category,
    required this.description,
  });
}
