   import 'package:barbergofe/viewmodels/map/map_view_model.dart';
    import 'package:flutter/material.dart';
    import 'package:flutter_map/flutter_map.dart';
    import 'package:latlong2/latlong.dart';

    class OpenMapScreen extends StatefulWidget {
      final double? destinationLat;
      final double? destinationLng;
      const OpenMapScreen({super.key, this.destinationLat, this.destinationLng});

      @override
      State<OpenMapScreen> createState() => _OpenMapScreenState();
    }

    class _OpenMapScreenState extends State<OpenMapScreen> {
      final MapViewModel _viewModel = MapViewModel();
      final MapController _mapController = MapController();
      final TextEditingController _startController = TextEditingController();
      final TextEditingController _endController = TextEditingController();
      final LatLng defaultPoint = const LatLng(10.7721, 106.6983);

      @override
      void initState() {
        super.initState();
        _viewModel.init();
        _viewModel.addListener(_onViewModelChanged);
        _viewModel.init(
          destinationLat: widget.destinationLat,
          destinationLng: widget.destinationLng

        );
      }

      @override
      void dispose() {
        _viewModel.removeListener(_onViewModelChanged);
        _viewModel.dispose();
        _mapController.dispose();
        _startController.dispose();
        _endController.dispose();
        super.dispose();
      }

      void _onViewModelChanged() {
        // Chỉ update text nếu người dùng KHÔNG đang gõ (để tránh conflict)
        if (_viewModel.startAddress != null &&
            _startController.text != _viewModel.startAddress &&
            !_viewModel.isTracking) { // Nếu đang tracking thì hạn chế update text liên tục gây giật
          _startController.text = _viewModel.startAddress!;
        }
        // Nếu tracking đang bật, mình ưu tiên hiển thị text từ ViewModel cập nhật
        if (_viewModel.isTracking && _viewModel.startAddress != null) {
          _startController.text = _viewModel.startAddress!;
        }

        if (_viewModel.endAddress != null &&
            _endController.text != _viewModel.endAddress) {
          _endController.text = _viewModel.endAddress!;
        }

        if (_viewModel.isNavigating && _viewModel.pointStart != null) {
          try {
            // Follow user với zoom cao hơn khi navigation
            _mapController.move(_viewModel.pointStart!, 17.0);
          } catch (e) {
            print('Error moving camera: $e');
          }
        } else if (_viewModel.pointStart != null && _viewModel.pointEnd != null) {
          // Fit bounds khi chưa navigation
          try {
            final bounds = LatLngBounds.fromPoints([
              _viewModel.pointStart!,
              _viewModel.pointEnd!,
            ]);
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(50),
              ),
            );
          } catch (e) {
            print('Error fitting bounds: $e');
          }
        }
      }

      @override
      Widget build(BuildContext context) {
        return ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            List<Marker> markers = [];
            if (_viewModel.pointStart != null) {
              markers.add(Marker(
                point: _viewModel.pointStart!,
                width: 60, height: 60,
                child: Icon(
                  _viewModel.isNavigating
                      ? Icons.navigation
                      : (_viewModel.isTracking ? Icons.gps_fixed : Icons.my_location),
                  color: _viewModel.isNavigating ? Colors.green : Colors.blue,
                  size: 40,
                ),            ));
            }
            if (_viewModel.pointEnd != null) {
              markers.add(Marker(
                point: _viewModel.pointEnd!,
                width: 60, height: 60,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ));
            }

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(_viewModel.isNavigating ? "Đang Dẫn Đường" : "Bản Đồ"),
                actions: [
                  if (_viewModel.isNavigating)
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: () => _viewModel.stopNavigation(),
                      tooltip: 'Dừng dẫn đường',
                    ),
                ],
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      // Control Panel - Ẩn khi đang navigation
                      if (!_viewModel.isNavigating) _buildControlPanel(),

                      // Bản đồ
                      Expanded(
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _viewModel.pointStart ?? defaultPoint,
                            initialZoom: 15.0,
                            // Tắt gesture khi navigation để tránh conflict
                            interactionOptions: InteractionOptions(
                              flags: _viewModel.isNavigating
                                  ? InteractiveFlag.none
                                  : InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.barbergofe.map',
                            ),
                            if (_viewModel.routePoints.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: _viewModel.routePoints,
                                    strokeWidth: 5.0,
                                    color: _viewModel.isNavigating
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                ],
                              ),
                            MarkerLayer(markers: markers),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Instruction Panel - Hiện khi đang navigation
                  if (_viewModel.isNavigating) _buildInstructionPanel(),
                ],
              ),
            );
          },
        );
      }

      // =====================
      // CONTROL PANEL
      // =====================
      Widget _buildControlPanel() {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              )
            ],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Điểm bắt đầu
              Row(
                children: [
                  const Icon(Icons.my_location, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _startController,
                      decoration: const InputDecoration(
                        labelText: "Điểm bắt đầu",
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (val) => _viewModel.searchPlace(val, true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _viewModel.toggleLiveTracking(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _viewModel.isTracking
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _viewModel.isTracking
                            ? Icons.gps_fixed
                            : Icons.gps_not_fixed,
                        color:
                        _viewModel.isTracking ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Điểm đến
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _endController,
                      decoration: const InputDecoration(
                        labelText: "Điểm đến",
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (val) => _viewModel.searchPlace(val, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () =>
                        _viewModel.searchPlace(_endController.text, false),
                    icon: const Icon(Icons.search),
                  )
                ],
              ),

              const SizedBox(height: 16),

              // Nút bắt đầu
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: (_viewModel.pointStart != null &&
                      _viewModel.pointEnd != null)
                      ? () => _viewModel.onStartPressed()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.navigation),
                  label: const Text(
                    "BẮT ĐẦU ĐI",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Thông tin route
              if (_viewModel.routePoints.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (_viewModel.remainingDistance != null)
                      Row(
                        children: [
                          const Icon(Icons.straighten, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${_viewModel.remainingDistance!.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    if (_viewModel.estimatedTime != null)
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _viewModel.estimatedTime!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      }

      // =====================
      // INSTRUCTION PANEL
      // =====================
      Widget _buildInstructionPanel() {
        final instruction = _viewModel.getCurrentInstruction();

        return Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Chỉ dẫn hiện tại
                  Row(
                  children: [
                  Icon(
                  Icons.navigation,
                    color: Colors.green[700],
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      instruction ?? 'Đang tải chỉ dẫn...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ],
                ),

                const SizedBox(height: 12),

                // Thông tin khoảng cách và thời gian
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_viewModel.remainingDistance != null)
                      Row(
                        children: [
                          const Icon(Icons.straighten, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${_viewModel.remainingDistance!.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    if (_viewModel.estimatedTime != null)
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _viewModel.estimatedTime!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    Text(
                      '${_viewModel.currentInstructionIndex + 1}/${_viewModel.instructions.length}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

                // Nút điều hướng instruction (tùy chọn)
                if (_viewModel.instructions.length > 1)
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _viewModel.currentInstructionIndex > 0
        ? () => _viewModel.previousInstruction()
            : null,
        iconSize: 20,
        ),
        IconButton(
        icon: const Icon(Icons.arrow_forward),
        onPressed: _viewModel.currentInstructionIndex<
        _viewModel.instructions.length - 1
        ? () => _viewModel.nextInstruction()
            : null,
        iconSize: 20,
        ),
        ],
        ),
        ],
        ),
        ),
        ),
        );
      }
    }
