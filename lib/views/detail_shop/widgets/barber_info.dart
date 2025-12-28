// lib/pages/detail_shop/widgets/barber_info.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/rating/rating_viewmodel.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';

class BarberInfo extends StatefulWidget {
  final String barberId;
  final String name;
  final String location;
  final double rank;
  final String imagePath;
  final double? lat;
  final double? lng;

  const BarberInfo({
    super.key,
    required this.barberId,
    required this.name,
    required this.imagePath,
    required this.location,
    required this.rank,
    this.lat,
    this.lng,
  });

  @override
  State<BarberInfo> createState() => _BarberInfoState();
}

class _BarberInfoState extends State<BarberInfo> {
  double? _userRating; // Rating hiện tại của user
  bool _isLoadingRating = false;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  /// Load rating của user cho barber này
  Future<void> _loadUserRating() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) return;

    final ratingViewModel = context.read<RatingViewModel>();
    await ratingViewModel.checkUserRating(userId, widget.barberId);

    if (mounted) {
      setState(() {
        _userRating = ratingViewModel.currentUserRating?.score;
      });
    }
  }

  /// Hiển thị dialog đánh giá
  Future<void> _showRatingDialog() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) {
      _showLoginRequiredDialog();
      return;
    }

    final ratingViewModel = context.read<RatingViewModel>();
    final existingRating = ratingViewModel.currentUserRating;

    double selectedRating = _userRating ?? 0.0;

    final result = await showDialog<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingRating != null ? 'Cập nhật đánh giá' : 'Đánh giá'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                existingRating != null
                    ? 'Bạn đã đánh giá ${existingRating.score?.toStringAsFixed(1)} sao'
                    : 'Bạn chưa đánh giá',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text('Chọn số sao:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1.0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      selectedRating = star;
                    });
                  },
                  child: Icon(
                    selectedRating >= star ? Icons.star : Icons.star_border,
                    color: const Color(0xFFF3B51C),
                    size: 40, // chỉnh kích thước sao
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 10),
              Text(
                selectedRating > 0
                    ? '${selectedRating.toStringAsFixed(1)} sao'
                    : 'Chưa chọn',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            if (existingRating != null)
              TextButton(
                onPressed: () => Navigator.pop(context, -1.0), // Signal delete
                child: const Text('Xóa đánh giá', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: selectedRating > 0
                  ? () => Navigator.pop(context, selectedRating)
                  : null,
              child: Text(existingRating != null ? 'Cập nhật' : 'Gửi'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      if (result == -1.0) {
        // Delete rating
        await _deleteRating(existingRating!.id as String);
      } else if (existingRating != null) {
        // Update rating
        await _updateRating(existingRating.id as String, result);
      } else {
        // Create new rating
        await _createRating(userId, result);
      }
    }
  }

  /// Tạo đánh giá mới
  Future<void> _createRating(String userId, double score) async {
    setState(() => _isLoadingRating = true);

    final ratingViewModel = context.read<RatingViewModel>();
    final success = await ratingViewModel.createRating(widget.barberId, userId, score);

    if (mounted) {
      setState(() {
        _isLoadingRating = false;
        if (success) {
          _userRating = score;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? ' Đánh giá thành công' : ' ${ratingViewModel.error}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Cập nhật đánh giá
  Future<void> _updateRating(String ratingId, double newScore) async {
    setState(() => _isLoadingRating = true);

    final ratingViewModel = context.read<RatingViewModel>();
    final success = await ratingViewModel.updateRating(ratingId, newScore, widget.barberId);

    if (mounted) {
      setState(() {
        _isLoadingRating = false;
        if (success) {
          _userRating = newScore;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? ' Cập nhật thành công' : ' ${ratingViewModel.error}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Xóa đánh giá
  Future<void> _deleteRating(String ratingId) async {
    setState(() => _isLoadingRating = true);

    final ratingViewModel = context.read<RatingViewModel>();
    final success = await ratingViewModel.deleteRating(ratingId, widget.barberId);

    if (mounted) {
      setState(() {
        _isLoadingRating = false;
        if (success) {
          _userRating = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã xóa đánh giá' : ' ${ratingViewModel.error}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Hiển thị dialog yêu cầu đăng nhập
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu đăng nhập'),
        content: const Text('Bạn cần đăng nhập để đánh giá'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.goNamed('login');
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          height: 160,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tên shop
                    Row(
                      children: [
                        const Icon(Icons.store, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Địa chỉ
                    Row(
                      children: [
                        const Icon(Icons.location_pin, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Rating - Có thể click để đánh giá
                    InkWell(
                      onTap: _isLoadingRating ? null : _showRatingDialog,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: Row(
                          children: [
                            Icon(
                              _userRating != null ? Icons.star : Icons.star_border,
                              color: const Color(0xFFF3B51C),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.rank.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (_userRating != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '(Bạn: ${_userRating!.toStringAsFixed(1)})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            if (_isLoadingRating) ...[
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Nút xem bản đồ
                    if (widget.lat != null && widget.lng != null)
                      IconButton(
                        onPressed: () {
                          context.pushNamed('Map', extra: {
                            'destinationLat': widget.lat,
                            'destinationLng': widget.lng
                          });
                        },
                        icon: const Icon(Icons.map),
                        tooltip: 'Xem bản đồ',
                      )
                  ],
                ),
              ),

              // Avatar
              Transform.translate(
                offset: const Offset(0, -10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.imagePath,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 140,
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, size: 60),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}