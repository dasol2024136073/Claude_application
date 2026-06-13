import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/review_repository.dart';
import '../../data/services/trip_repository.dart';
import '../../domain/models/review.dart';

class ReviewViewScreen extends StatefulWidget {
  final SavedTrip trip;
  final Review review;

  const ReviewViewScreen({super.key, required this.trip, required this.review});

  @override
  State<ReviewViewScreen> createState() => _ReviewViewScreenState();
}

class _ReviewViewScreenState extends State<ReviewViewScreen> {
  late Review _review;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
  }

  Future<void> _edit() async {
    final result = await context.push('/review/edit', extra: {
      'trip': widget.trip,
      'review': _review,
    });
    if (result == true) {
      final updated = await ReviewRepository.getByTripId(widget.trip.id);
      if (updated != null) {
        setState(() => _review = updated);
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('후기 삭제'),
        content: const Text('작성한 후기를 삭제하시겠습니까?\n커뮤니티에 공유된 게시물과 댓글도 함께 삭제됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    await ReviewRepository.deleteWithCommunityPost(widget.trip.id);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final review = _review;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('후기', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _edit();
              if (value == 'delete') _delete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('후기 수정')),
              PopupMenuItem(value: 'delete', child: Text('후기 삭제')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.trip.plan.destination, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text('${widget.trip.plan.days}박 ${widget.trip.plan.days + 1}일', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          if (review.title != null && review.title!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.title!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(5, (i) => Icon(
                    i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFFFC107), size: 26,
                  )),
              const SizedBox(width: 10),
              Icon(
                review.visibility == ReviewVisibility.public ? Icons.public : Icons.lock_outline,
                size: 16, color: Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Text(
                review.visibility == ReviewVisibility.public ? '커뮤니티에 공개' : '나만 보기',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          if (review.text != null) ...[
            const SizedBox(height: 20),
            Text(review.text!, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6)),
          ],
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('사진', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
            SizedBox(
              height: 240,
              child: PageView(
                children: review.photos.map((p) => ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        base64Decode(p.split(',').last),
                        fit: BoxFit.cover, width: double.infinity,
                      ),
                    )).toList(),
              ),
            ),
          ],
          if (review.videos.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('동영상', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
            ...review.videos.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black87,
                        child: const Center(
                          child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 48),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 12),
          Text('작성자: ${review.authorName}', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
