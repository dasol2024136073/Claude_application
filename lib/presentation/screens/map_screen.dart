import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/models/trip_plan.dart';

class MapScreen extends StatefulWidget {
  final TripPlan tripPlan;
  const MapScreen({super.key, required this.tripPlan});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedDay = 0; // 0 = 전체

  static const _dayColors = [
    Color(0xFF4A90D9),
    Color(0xFFE8734A),
    Color(0xFF22C55E),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  Color _colorForDay(int dayIndex) => _dayColors[dayIndex % _dayColors.length];

  List<DayPlan> get _visibleDays => _selectedDay == 0
      ? widget.tripPlan.dayPlans
      : widget.tripPlan.dayPlans.where((d) => d.day == _selectedDay).toList();

  List<PlaceItem> get _allVisiblePlaces =>
      _visibleDays.expand((d) => d.places).toList();

  LatLng get _mapCenter {
    final places = _allVisiblePlaces.where((p) => p.hasCoordinates).toList();
    if (places.isEmpty) return const LatLng(35.6895, 139.6917);
    final lat = places.map((p) => p.latitude!).reduce((a, b) => a + b) / places.length;
    final lng = places.map((p) => p.longitude!).reduce((a, b) => a + b) / places.length;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords = _allVisiblePlaces.any((p) => p.hasCoordinates);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '${widget.tripPlan.destination} 경로 지도',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _DaySelector(
            totalDays: widget.tripPlan.days,
            selectedDay: _selectedDay,
            colorForDay: _colorForDay,
            onSelect: (day) => setState(() => _selectedDay = day),
          ),
          Expanded(
            child: hasCoords
                ? _buildMap()
                : const Center(child: Text('지도에 표시할 좌표 정보가 없습니다')),
          ),
          _PlaceList(
            visibleDays: _visibleDays,
            colorForDay: _colorForDay,
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final markers = <Marker>[];
    final polylines = <Polyline>[];

    for (final dayPlan in _visibleDays) {
      final dayIndex = dayPlan.day - 1;
      final color = _colorForDay(dayIndex);
      final points = <LatLng>[];
      int seq = 1;

      for (final place in dayPlan.places) {
        if (!place.hasCoordinates) continue;
        final pos = LatLng(place.latitude!, place.longitude!);
        points.add(pos);

        final seqNum = seq++;
        markers.add(Marker(
          point: pos,
          width: 36,
          height: 36,
          child: _NumberedMarker(number: seqNum, color: color),
        ));
      }

      if (points.length >= 2) {
        polylines.add(Polyline(
          points: points,
          color: color.withValues(alpha: 0.8),
          strokeWidth: 3.0,
        ));
      }
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.travel_ai',
        ),
        PolylineLayer(polylines: polylines),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

class _NumberedMarker extends StatelessWidget {
  final int number;
  final Color color;
  const _NumberedMarker({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final int totalDays;
  final int selectedDay;
  final Color Function(int) colorForDay;
  final ValueChanged<int> onSelect;

  const _DaySelector({
    required this.totalDays,
    required this.selectedDay,
    required this.colorForDay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(label: '전체', selected: selectedDay == 0, color: const Color(0xFF64748B), onTap: () => onSelect(0)),
            const SizedBox(width: 8),
            ...List.generate(totalDays, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: 'Day ${i + 1}',
                selected: selectedDay == i + 1,
                color: colorForDay(i),
                onTap: () => onSelect(i + 1),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PlaceList extends StatelessWidget {
  final List<DayPlan> visibleDays;
  final Color Function(int) colorForDay;

  const _PlaceList({required this.visibleDays, required this.colorForDay});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                for (final day in visibleDays)
                  for (int i = 0; i < day.places.length; i++)
                    _PlaceCard(
                      place: day.places[i],
                      index: i + 1,
                      color: colorForDay(day.day - 1),
                      dayLabel: visibleDays.length > 1 ? 'Day ${day.day}' : null,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final PlaceItem place;
  final int index;
  final Color color;
  final String? dayLabel;

  const _PlaceCard({required this.place, required this.index, required this.color, this.dayLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text('$index', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              if (dayLabel != null) ...[
                const SizedBox(width: 4),
                Text(dayLabel!, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(place.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(place.time, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(place.category, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
