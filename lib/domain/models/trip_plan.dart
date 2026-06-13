class TripPlan {
  final String destination;
  final int days;
  final List<DayPlan> dayPlans;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? arrivalTime; // "HH:mm"
  final String? departureTime; // "HH:mm"
  final String? accommodation;

  const TripPlan({
    required this.destination,
    required this.days,
    required this.dayPlans,
    this.startDate,
    this.endDate,
    this.arrivalTime,
    this.departureTime,
    this.accommodation,
  });

  Map<String, dynamic> toJson() => {
        'destination': destination,
        'days': days,
        'dayPlans': dayPlans.map((d) => d.toJson()).toList(),
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (arrivalTime != null) 'arrivalTime': arrivalTime,
        if (departureTime != null) 'departureTime': departureTime,
        if (accommodation != null) 'accommodation': accommodation,
      };

  factory TripPlan.fromJson(Map<String, dynamic> json) => TripPlan(
        destination: json['destination'] as String,
        days: json['days'] as int,
        dayPlans: (json['dayPlans'] as List<dynamic>)
            .map((d) => DayPlan.fromJson(d as Map<String, dynamic>))
            .toList(),
        startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
        arrivalTime: json['arrivalTime'] as String?,
        departureTime: json['departureTime'] as String?,
        accommodation: json['accommodation'] as String?,
      );
}

class DayPlan {
  final int day;
  final List<PlaceItem> places;

  const DayPlan({required this.day, required this.places});

  Map<String, dynamic> toJson() => {
        'day': day,
        'places': places.map((p) => p.toJson()).toList(),
      };

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
        day: json['day'] as int,
        places: (json['places'] as List<dynamic>)
            .map((p) => PlaceItem.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}

class PlaceItem {
  final String time;
  final String name;
  final String category;
  final String description;
  final double? latitude;
  final double? longitude;

  const PlaceItem({
    required this.time,
    required this.name,
    required this.category,
    required this.description,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  Map<String, dynamic> toJson() => {
        'time': time,
        'name': name,
        'category': category,
        'description': description,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  factory PlaceItem.fromJson(Map<String, dynamic> json) => PlaceItem(
        time: json['time'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
