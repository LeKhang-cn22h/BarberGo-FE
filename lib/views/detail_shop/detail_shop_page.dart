import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
import 'package:barbergofe/viewmodels/service/service_viewmodel.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:barbergofe/services/barber_service.dart'; // Thêm import này
import 'widgets/barber_info.dart';
import 'widgets/barber_search.dart';
import 'widgets/list_service.dart';
import 'widgets/next_button.dart';

class DetailShopPage extends StatefulWidget {
  final String id;
  const DetailShopPage({super.key, required this.id});

  @override
  State<DetailShopPage> createState() => _DetailShopPageState();
}

class _DetailShopPageState extends State<DetailShopPage> {
  BarberModel? _barber;
  bool _isLoading = true;
  String? _error;
  List<int> _selectedServiceIds = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final barberViewModel = Provider.of<BarberViewModel>(context, listen: false);
      final serviceViewModel = Provider.of<ServiceViewModel>(context, listen: false);
      final barberService = BarberService(); // Tạo service instance

      print('=== DETAIL PAGE INITIALIZATION ===');
      print('Looking for barber with id: ${widget.id}');

      // 1. Tìm barber trong ViewModel (từ cache)
      BarberModel? foundBarber;
      for (var barber in barberViewModel.topBarbers) {
        if (barber.id == widget.id) {
          foundBarber = barber;
          print('Found barber in topBarbers: ${barber.name}');
          break;
        }
      }

      if (foundBarber == null) {
        for (var barber in barberViewModel.areaBarbers) {
          if (barber.id == widget.id) {
            foundBarber = barber;
            print('Found barber in areaBarbers: ${barber.name}');
            break;
          }
        }
      }

      // 2. Nếu không tìm thấy trong ViewModel, gọi API để lấy barber chi tiết
      // Trong _initializeData() method - SỬA DÒNG 86
      if (foundBarber == null) {
        print('Barber not found in ViewModel, fetching from API...');

        try {
          // Gọi API lấy barber chi tiết
          print('Calling API: GET barber/${widget.id}');
          final response = await barberService.getBarberById(widget.id);

          // SỬA: Dùng response.barber (single) trực tiếp
          if (response.barber != null) {
            foundBarber = response.barber; // <-- SỬA: response.barber trực tiếp, không có .first
            print('✅ Found barber from API: ${foundBarber!.name}');
            print('   Location: ${foundBarber.location}');
            print('   Area: ${foundBarber.area}');
            print('   Address: ${foundBarber.address}');
            print('   Rank: ${foundBarber.rank}');
            print('   Image: ${foundBarber.imagePath}');
          } else {
            print('❌ Barber not found in API either');
          }
        } catch (e) {
          print('Error fetching barber from API: $e');
          // Vẫn tiếp tục với mock data nếu API fail
        }
      }

      // 3. Nếu vẫn không có barber, dùng mock (fallback)
      if (foundBarber == null) {
        print('Using fallback mock barber');
        foundBarber = BarberModel(
          id: widget.id,
          userId: '',
          name: 'Barber Shop',
          location: 'Địa chỉ',
          area: 'Khu vực',
          address: 'Address',
          imagePath: 'assets/images/default_barber.jpg',
          rank: 4.5,
          status: true,
        );
      }

      // 4. Fetch services (luôn luôn fetch)
      print('Fetching services for barber: ${foundBarber.id}');
      await serviceViewModel.fetchServicesByBarber(widget.id);

      if (mounted) {
        setState(() {
          _barber = foundBarber;
          _isLoading = false;
        });
      }

    } catch (e) {
      print('Error in DetailShopPage: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceViewModel = context.watch<ServiceViewModel>();

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.goNamed('home'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: ()=>context.goNamed('home'), icon:Icon(Icons.chevron_left)),
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_barber == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết Barber')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Không tìm thấy thông tin barber'),
              Text('ID: ${widget.id}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Helper functions
    double getRank() => _barber!.rank ?? 0.0;

    String getLocation() {
      // Ưu tiên: location -> area -> address -> default
      if (_barber!.location != null && _barber!.location!.isNotEmpty) {
        return _barber!.location!;
      }
      if (_barber!.area != null && _barber!.area!.isNotEmpty) {
        return _barber!.area!;
      }
      if (_barber!.address != null && _barber!.address!.isNotEmpty) {
        return _barber!.address!;
      }
      return 'Địa chỉ không xác định';
    }

    String getImagePath() {
      if (_barber!.imagePath != null && _barber!.imagePath!.isNotEmpty) {
        // Nếu là URL, hiển thị bằng NetworkImage
        if (_barber!.imagePath!.startsWith('http')) {
          return _barber!.imagePath!;
        }
        // Nếu là asset path
        return _barber!.imagePath!;
      }
      return 'assets/images/default_barber.jpg';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_barber!.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
      ),
      body: Column(
        children: [
          BarberInfo(
            name: _barber!.name,
            rank: getRank(),
            location: getLocation(),
            imagePath: getImagePath(),
          ),

          const BarberSearch(hint: 'Tìm kiếm dịch vụ'),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dịch vụ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (serviceViewModel.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (serviceViewModel.barberServices.isNotEmpty)
                  Text(
                    '${serviceViewModel.barberServices.length} dịch vụ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),

          if (_selectedServiceIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Đã chọn ${_selectedServiceIds.length} dịch vụ',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          if (serviceViewModel.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                serviceViewModel.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          Expanded(
            child: _buildServicesContent(serviceViewModel),
          ),

          NextButton(
            onPressed: _selectedServiceIds.isNotEmpty
                ? () {
              print('=== NAVIGATING TO BOOKING ===');
              print('Barber ID: ${_barber!.id}');
              print('Barber Name: ${_barber!.name}');
              print('Selected Services: $_selectedServiceIds');

              try {
                context.pushNamed('booking', extra: {
                  'barber': _barber,
                  'serviceIds': _selectedServiceIds,
                });
                print('Navigation called successfully');
              } catch (e) {
                print('Navigation error: $e');
              }
            }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesContent(ServiceViewModel serviceViewModel) {
    if (serviceViewModel.isLoading && serviceViewModel.barberServices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (serviceViewModel.error != null && serviceViewModel.barberServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(serviceViewModel.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => serviceViewModel.fetchServicesByBarber(widget.id),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (serviceViewModel.barberServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Chưa có dịch vụ nào'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => serviceViewModel.fetchServicesByBarber(widget.id),
              child: const Text('Tải lại'),
            ),
          ],
        ),
      );
    }

    return ListService(
      id: widget.id,
      services: serviceViewModel.barberServices,
      onSelectionChanged: (selectedIds) {
        print('DetailShopPage received selected services: $selectedIds');
        setState(() {
          _selectedServiceIds = selectedIds;
        });
      },
    );
  }
}