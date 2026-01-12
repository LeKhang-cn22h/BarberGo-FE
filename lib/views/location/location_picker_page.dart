// lib/views/location/location_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:barbergofe/services/map_service.dart';

class LocationPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;

  const LocationPickerPage({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialAddress,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final MapService _mapService = MapService();

  late LatLng _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = false;

  // Default: Hồ Chí Minh
  final LatLng _defaultLocation = const LatLng(10.7721, 106.6983);

  @override
  void initState() {
    super.initState();

    // Khởi tạo vị trí
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLng!);
      _selectedAddress = widget.initialAddress;
    } else {
      _selectedLocation = _defaultLocation;
      _getCurrentLocation();
    }

    if (widget.initialAddress != null) {
      _searchController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final hasPermission = await _mapService.checkLocationPermission();
      if (!hasPermission) {
        _showError('Cần cấp quyền truy cập vị trí');
        setState(() => _isLoading = false);
        return;
      }

      final position = await _mapService.getPositionStream().first;
      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = location;
        _isLoading = false;
      });

      _mapController.move(_selectedLocation, 15.0);
      _updateAddress();
    } catch (e) {
      print('❌ Error getting location: $e');
      setState(() => _isLoading = false);
      _showError('Không thể lấy vị trí hiện tại');
    }
  }

  // Cập nhật địa chỉ từ tọa độ
  Future<void> _updateAddress() async {
    setState(() => _isLoading = true);

    try {
      final address = await _mapService.getAddress(_selectedLocation);
      setState(() {
        _selectedAddress = address ?? 'Không xác định được địa chỉ';
        _searchController.text = _selectedAddress!;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error getting address: $e');
      setState(() => _isLoading = false);
    }
  }

  // Tìm kiếm địa điểm
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await _mapService.searchPlace(query);

      if (result != null) {
        final point = result['point'] as LatLng;
        final name = result['displayName'] as String;

        setState(() {
          _selectedLocation = point;
          _selectedAddress = name;
          _searchController.text = name;
          _isLoading = false;
        });

        _mapController.move(point, 15.0);
      } else {
        _showError('Không tìm thấy địa điểm');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Search error: $e');
      setState(() => _isLoading = false);
      _showError('Lỗi tìm kiếm');
    }
  }

  // Xử lý tap trên bản đồ
  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    _updateAddress();
  }

  // Xác nhận chọn vị trí
  void _confirmLocation() {
    context.pop({
      'lat': _selectedLocation.latitude,
      'lng': _selectedLocation.longitude,
      'address': _selectedAddress,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí cửa hàng'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Bản đồ
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onTap: _handleMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.barbergofe.map',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search bar ở trên
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm địa điểm...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: _searchLocation,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Info panel ở dưới
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'Vị trí đã chọn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Địa chỉ
                  if (_selectedAddress != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedAddress!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Tọa độ
                  Row(
                    children: [
                      const Icon(Icons.gps_fixed, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                            'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Buttons
                  Row(
                    children: [
                      // Nút lấy vị trí hiện tại
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 18),
                          label: const Text('Vị trí hiện tại'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Nút xác nhận
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _confirmLocation,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Xác nhận'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}