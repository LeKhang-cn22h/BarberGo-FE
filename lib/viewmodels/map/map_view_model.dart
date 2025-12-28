  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:latlong2/latlong.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:barbergofe/services/map_service.dart';

  class MapViewModel extends ChangeNotifier {
    final MapService _mapService = MapService();

    // =====================
    // STATE
    // =====================
    LatLng? pointStart;
    LatLng? pointEnd;

    List<LatLng> routePoints = [];

    String? startAddress;
    String? endAddress;

    bool isTracking = false;
    bool isNavigating=false;
    List<String> instructions = []; // Danh sách chỉ dẫn
    int currentInstructionIndex = 0; //  Chỉ dẫn hiện tại
    double? remainingDistance; // Khoảng cách còn lại (km)
    String? estimatedTime; // Thời gian ước tính
    StreamSubscription<Position>? _positionStream;

    // =====================
    // INIT
    // =====================
    Future<void> init({
      double? destinationLat,
      double? destinationLng})
    async {
      //lấy vị trí hiện tại

      final position= await Geolocator.getCurrentPosition();
      pointStart=LatLng(position.latitude, position.longitude);
      startAddress= await _mapService.getAddress(pointStart);

      //nếu có destination, set luôn
      if(destinationLat !=null && destinationLng !=null){
        pointEnd=LatLng(destinationLat, destinationLng);
        endAddress=await _mapService.getAddress(pointEnd);
        await _tryFetchRoute();
      }
      notifyListeners();
    }

    // =====================
    // SET START / END
    // =====================
    void setStartPoint(LatLng point, {String? address}) {
      pointStart = point;
      startAddress = address;
      _tryFetchRoute();
      notifyListeners();
    }

    void setEndPoint(LatLng point, {String? address}) {
      pointEnd = point;
      endAddress = address;
      _tryFetchRoute();
      notifyListeners();
    }

    // =====================
    // FETCH ROUTE (PRIVATE)
    // =====================
    Future<void> _tryFetchRoute() async {
      if (pointStart == null || pointEnd == null) return;

      try {
        final routeData = await _mapService.getRouteWithInstructions(
          pointStart!,
          pointEnd!,
        );

        routePoints = routeData['points'] ?? [];
        instructions = routeData['instructions'] ?? [];
        remainingDistance = routeData['distance']; // km
        estimatedTime = routeData['duration']; // phút

        print('Route fetched: ${routePoints.length} points');
        print('Instructions: ${instructions.length} steps');
        print('Distance: ${remainingDistance?.toStringAsFixed(1)} km');
        print(' Duration: $estimatedTime');

        notifyListeners();
      } catch (e) {
        print('Error fetching route: $e');
        routePoints = [];
        instructions = [];
        notifyListeners();
      }
    }

    // =====================
    // SEARCH PLACE
    // =====================
    Future<void> searchPlace(String query, bool isStartPoint) async {
      final result = await _mapService.searchPlace(query);
      if (result == null) return;

      final LatLng point = result['point'];
      final String name = result['displayName'];

      if (isStartPoint) {
        setStartPoint(point, address: name);
      } else {
        setEndPoint(point, address: name);
      }
    }

    // =====================
    // LIVE TRACKING
    // =====================
    Future<void> toggleLiveTracking() async {
      if (isTracking) {
        await _positionStream?.cancel();
        isTracking = false;
        isNavigating = false;
        notifyListeners();
        return;
      }

      final hasPermission = await _mapService.checkLocationPermission();
      if (!hasPermission) return;

      isTracking = true;
      notifyListeners();

      _positionStream =
          _mapService.getPositionStream().listen((Position position) async {
            pointStart = LatLng(position.latitude, position.longitude);
            String? address = await _mapService.getAddress(pointStart!);
            startAddress = address;

            // Tự động vẽ lại đường nếu đang tracking
            if (pointEnd != null && isNavigating) {
              await _tryFetchRoute();
              _updateCurrentInstruction();
            }
          });
    }
    Future<void> onStartPressed() async {
      if (pointStart == null || pointEnd == null) return;

      // Fetch route nếu chưa có
      if (routePoints.isEmpty) {
        await _tryFetchRoute();
      }

      // Bật chế độ navigation
      isNavigating = true;
      currentInstructionIndex = 0;

      // Tự động bật tracking nếu chưa bật
      if (!isTracking) {
        await toggleLiveTracking();
      }

      notifyListeners();

      print(' Navigation started!');
    }
    void stopNavigation() {
      isNavigating = false;
      currentInstructionIndex = 0;
      notifyListeners();

      print(' Navigation stopped');
    }
    void _updateCurrentInstruction() {
      if (!isNavigating || instructions.isEmpty || pointStart == null) return;

      // Logic đơn giản: tăng index khi gần điểm tiếp theo
      // Bạn có thể cải thiện bằng cách tính khoảng cách thực tế
      if (currentInstructionIndex < instructions.length - 1) {
        // Giả sử mỗi instruction cách nhau ~500m
        final progress = routePoints.isEmpty
            ? 0.0
            : currentInstructionIndex / instructions.length;

        // Auto advance instruction (đơn giản hóa)
        if (progress < 0.9) {
          // Có thể thêm logic phức tạp hơn ở đây
        }
      }
    }

    // =====================
    // GET CURRENT INSTRUCTION
    // =====================
    String? getCurrentInstruction() {
      if (instructions.isEmpty || currentInstructionIndex >= instructions.length) {
        return null;
      }
      return instructions[currentInstructionIndex];
    }

    // =====================
    // MANUAL NEXT INSTRUCTION
    // =====================
    void nextInstruction() {
      if (currentInstructionIndex < instructions.length - 1) {
        currentInstructionIndex++;
        notifyListeners();
      }
    }

    void previousInstruction() {
      if (currentInstructionIndex > 0) {
        currentInstructionIndex--;
        notifyListeners();
      }
    }
    // =====================
    // CLEANUP
    // =====================
    @override
    void dispose() {
      _positionStream?.cancel();
      super.dispose();
    }
  }
