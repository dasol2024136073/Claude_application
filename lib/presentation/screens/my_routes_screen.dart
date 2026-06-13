import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/review_repository.dart';
import '../../data/services/trip_events.dart';
import '../../data/services/trip_repository.dart';
import '../../domain/models/review.dart';
import '../theme/app_theme.dart';

enum _RouteFilter { all, saved, visited }

class MyRoutesScreen extends StatefulWidget {
  const MyRoutesScreen({super.key});

  @override
  State<MyRoutesScreen> createState() => _MyRoutesScreenState();
}

class _MyRoutesScreenState extends State<MyRoutesScreen> {
  List<SavedTrip> _trips = [];
  Map<String, Review> _reviews = {};
  bool _loading = true;

  final _searchController = TextEditingController();
  _RouteFilter _filter = _RouteFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
    TripEvents.changed.addListener(_load);
  }

  @override
  void dispose() {
    TripEvents.changed.removeListener(_load);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final trips = await TripRepository.getAll();
    final reviews = await ReviewRepository.getAll();
    if (!mounted) return;
    setState(() {
      _trips = trips;
      _reviews = {for (final r in reviews) r.tripId: r};
      _loading = false;
    });
  }

  List<SavedTrip> get _filteredTrips {
    var trips = _trips;
    switch (_filter) {
      case _RouteFilter.saved:
        trips = trips.where((t) => !t.visited).toList();
        break;
      case _RouteFilter.visited:
        trips = trips.where((t) => t.visited).toList();
        break;
      case _RouteFilter.all:
        break;
    }

    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      trips = trips.where((t) {
        if (t.plan.destination.toLowerCase().contains(q)) return true;
        final review = _reviews[t.id];
        if (review == null) return false;
        if ((review.title ?? '').toLowerCase().contains(q)) return true;
        if ((review.text ?? '').toLowerCase().contains(q)) return true;
        return false;
      }).toList();
    }
    return trips;
  }

  Future<void> _delete(String id) async {
    final messenger = ScaffoldMessenger.of(context);
    await TripRepository.deleteCascade(id);

    await _load();
    messenger.showSnackBar(
      const SnackBar(content: Text('경로가 삭제되었습니다'), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _toggleVisited(SavedTrip trip) async {
    if (trip.visited) {
      final review = _reviews[trip.id];
      if (review != null) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('다녀옴 취소'),
            content: const Text('다녀옴 취소를 하면 작성한 후기도 함께 삭제됩니다.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (confirmed != true) return;
        await ReviewRepository.deleteWithCommunityPost(trip.id);
      }
    }
    await TripRepository.setVisited(trip.id, !trip.visited);
    await _load();
  }

  Future<void> _unsave(SavedTrip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장 취소'),
        content: const Text('저장된 경로를 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    await _delete(trip.id);
  }

  Future<void> _openReviewEditor(SavedTrip trip) async {
    final result = await context.push('/review/edit', extra: {
      'trip': trip,
      'review': _reviews[trip.id],
    });
    if (result == true) _load();
  }

  void _viewReview(SavedTrip trip, Review review) {
    context.push('/review/view', extra: {'trip': trip, 'review': review});
  }

  @override
  Widget build(BuildContext context) {
    final trips = _filteredTrips;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('내 경로', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '여행지로 검색',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                _FilterChip(label: '전체', selected: _filter == _RouteFilter.all, onTap: () => setState(() => _filter = _RouteFilter.all)),
                const SizedBox(width: 8),
                _FilterChip(label: '저장된 경로', selected: _filter == _RouteFilter.saved, onTap: () => setState(() => _filter = _RouteFilter.saved)),
                const SizedBox(width: 8),
                _FilterChip(label: '다녀온 경로', selected: _filter == _RouteFilter.visited, onTap: () => setState(() => _filter = _RouteFilter.visited)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: trips.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            children: const [_EmptyState()],
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            children: [
                              Text('${trips.length}개의 경로',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                              const SizedBox(height: 12),
                              ...trips.map((trip) => _TripCard(
                                    trip: trip,
                                    review: _reviews[trip.id],
                                    onTap: () => context.push('/route/result', extra: {
                                      'destination': trip.plan.destination,
                                      'days': trip.plan.days,
                                      'tripPlan': trip.plan,
                                      'tripId': trip.id,
                                    }),
                                    onDelete: () => _delete(trip.id),
                                    onToggleVisited: () => _toggleVisited(trip),
                                    onUnsave: () => _unsave(trip),
                                    onReview: () => _openReviewEditor(trip),
                                    onViewReview: (review) => _viewReview(trip, review),
                                  )),
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : const Color(0xFFE8E8E8)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final SavedTrip trip;
  final Review? review;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleVisited;
  final VoidCallback onUnsave;
  final VoidCallback onReview;
  final void Function(Review review) onViewReview;

  const _TripCard({
    required this.trip,
    required this.review,
    required this.onTap,
    required this.onDelete,
    required this.onToggleVisited,
    required this.onUnsave,
    required this.onReview,
    required this.onViewReview,
  });

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final hasPhoto = review != null && review!.photos.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(trip.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
        ),
        onDismissed: (_) => onDelete(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: hasPhoto
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(
                                base64Decode(review!.photos.first.split(',').last),
                                width: 48, height: 48, fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              trip.visited ? Icons.check_circle : Icons.flight_takeoff_rounded,
                              color: AppTheme.primary, size: 24,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(trip.plan.destination,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                              if (trip.visited) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                  child: Text('다녀옴', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${trip.plan.days}박 ${trip.plan.days + 1}일 • ${_formatDate(trip.savedAt)} 저장',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          if (review?.title != null && review!.title!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              review!.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
              if (review != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => onViewReview(review!),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                                i < review!.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                color: const Color(0xFFFFC107), size: 18,
                              )),
                          const SizedBox(width: 8),
                          Icon(
                            review!.visibility == ReviewVisibility.public ? Icons.public : Icons.lock_outline,
                            size: 14, color: Colors.grey[400],
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
                        ],
                      ),
                      if (review!.text != null) ...[
                        const SizedBox(height: 6),
                        Text(review!.text!,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
              ],
              if (!trip.visited)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onToggleVisited,
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('다녀온 경로로 표시', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          side: const BorderSide(color: Color(0xFFE8E8E8)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onUnsave,
                        icon: const Icon(Icons.bookmark_remove_outlined, size: 16),
                        label: const Text('저장 취소', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[400],
                          side: BorderSide(color: Colors.red[200]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onToggleVisited,
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('다녀옴 취소', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: const BorderSide(color: Color(0xFFE8E8E8)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (trip.visited && review == null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.edit_note, size: 16),
                    label: const Text('후기 작성', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(Icons.map_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('저장된 경로가 없습니다', style: TextStyle(fontSize: 14, color: Colors.grey[400], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('홈에서 첫 번째 경로를 만들어보세요', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
