import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
import 'package:barbergofe/viewmodels/service/service_viewmodel.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'widgets/barber_info.dart';
import 'widgets/barber_search.dart';
import 'widgets/list_service.dart';
import 'widgets/next_button.dart';

class DetailShopPage extends StatefulWidget {
  // ID của barber cần hiển thị
  final String id;

  // Danh sách ID dịch vụ đã chọn từ màn trước (optional)
  // Dùng khi user quay lại từ trang booking
  final List<String>? selectedServiceIds;

  const DetailShopPage({
    super.key,
    required this.id,
    this.selectedServiceIds,
  });

  @override
  State<DetailShopPage> createState() => _DetailShopPageState();
}

class _DetailShopPageState extends State<DetailShopPage> {

  // Flag để đảm bảo _initializeData() chỉ chạy 1 lần
  bool _isInitialized = false;

  bool _isLoading = false;

  String? _error;

  // Danh sách ID các dịch vụ mà user đã chọn trong trang này
  List<int> _selectedServiceIds = [];


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Lấy ViewModels từ Provider
      final barberViewModel = context.read<BarberViewModel>();
      final serviceViewModel = context.read<ServiceViewModel>();

      // Kiểm tra cache trước, nếu không có thì fetch từ API
      await _ensureBarberLoaded(barberViewModel);

      //  Load danh sách dịch vụ của barber này
      print('Loading services for barber: ${widget.id}');
      await serviceViewModel.fetchServicesByBarber(widget.id);
      print('Loaded ${serviceViewModel.barberServices.length} services');

      //  Xử lý initialServiceIds nếu có
      // Trường hợp: user đã chọn services ở màn trước rồi quay lại
      if (widget.selectedServiceIds != null &&
          widget.selectedServiceIds!.isNotEmpty) {

        // Convert từ List<String> sang List<int>
        _selectedServiceIds = widget.selectedServiceIds!
            .map((id) => int.tryParse(id))  // Parse string to int
            .whereType<int>()               // Lọc bỏ null values
            .toList();
        print('Pre-selected ${_selectedServiceIds.length} services');
      }
      // Tắt loading state
      setState(() {
        _isLoading = false;
      });

      print('Data initialization complete!');
      print('-------------------------------------------\n');

    } catch (e) {
      // Bắt lỗi và hiển thị cho user
      print('ERROR in _initializeData: $e');

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }


  Future<void> _ensureBarberLoaded(BarberViewModel viewModel) async {
    // KIỂM TRA 1: Tìm trong danh sách topBarbers (cache)
    BarberModel? barber = viewModel.topBarbers
        .cast<BarberModel?>()
        .firstWhere(
          (b) => b?.id == widget.id,
      orElse: () => null,
    );

    if (barber != null) {
      print('Found in topBarbers: ${barber.name}');
      // Set làm selectedBarber trong ViewModel
      viewModel.selectBarber(barber);
      return; // Tìm thấy và không cần tìm nữa
    }
//kiểm tra trong area có cache không
    barber = viewModel.areaBarbers
        .cast<BarberModel?>()
        .firstWhere(
          (b) => b?.id == widget.id,
      orElse: () => null,
    );

    if (barber != null) {
      print('Found in areaBarbers: ${barber.name}');
      viewModel.selectBarber(barber);
      return; // Tìm thấy rồi
    }

    print('WARNING: Barber not in cache, fetching from API...');
    await viewModel.fetchBarberById(widget.id);

    // Sau khi fetch, kiểm tra xem có lấy được không
    if (viewModel.selectedBarber != null) {
      print('Fetched barber from API: ${viewModel.selectedBarber!.name}');
    } else {
      // Throw error nếu vẫn không tìm thấy
      throw Exception('Không tìm thấy thông tin tiệm tóc');
    }
  }
  @override
  Widget build(BuildContext context) {
    // Watch cả 2 ViewModels để UI tự động rebuild khi data thay đổi
    final barberViewModel = context.watch<BarberViewModel>();
    final serviceViewModel = context.watch<ServiceViewModel>();
    // Hiển thị loading indicator khi đang tải data
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải thông tin...'),
            ],
          ),
        ),
      );
    }
    // Hiển thị error message và nút thử lại
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lỗi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.goNamed('home'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Reset state để chạy lại _initializeData()
                  setState(() {
                    _isInitialized = false;
                    _error = null;
                  });
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Lấy barber từ ViewModel
    final barber = barberViewModel.selectedBarber;
    // Không tìm thấy thông tin barber
    if (barber == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết Barber')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Không tìm thấy thông tin tiệm tóc'),
              Text('ID: ${widget.id}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goNamed('home'),
                child: const Text('Quay về trang chủ'),
              ),
            ],
          ),
        ),
      );
    }
    // Hiển thị thông tin barber và danh sách dịch vụ
    return Scaffold(
      // AppBar với tên barber
      appBar: AppBar(
        title: Text(barber.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
      ),

      body: Column(
        children: [
          // SECTION 1: Thông tin barber (avatar, tên, địa chỉ, rating)
          BarberInfo(
            name: barber.name,
            rank: barber.rank ?? 0.0,
            location: _getLocation(barber),
            imagePath: _getImagePath(barber),
          ),

          // SECTION 2: Thanh tìm kiếm dịch vụ
          const BarberSearch(hint: 'Tìm kiếm dịch vụ'),

          // SECTION 3: Header của danh sách dịch vụ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text "Dịch vụ"
                const Text(
                  "Dịch vụ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // Loading indicator nếu đang tải services
                if (serviceViewModel.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),

                // Số lượng dịch vụ
                if (serviceViewModel.barberServices.isNotEmpty)
                  Text(
                    '${serviceViewModel.barberServices.length} dịch vụ',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
              ],
            ),
          ),

          // SECTION 4: Hiển thị số dịch vụ đã chọn
          if (_selectedServiceIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Đã chọn ${_selectedServiceIds.length} dịch vụ',
                    style: TextStyle(color: Colors.green[700], fontSize: 14),
                  ),
                ],
              ),
            ),

          // SECTION 5: Danh sách dịch vụ (scrollable)
          Expanded(
            child: _buildServicesContent(serviceViewModel),
          ),

          // SECTION 6: Nút "Tiếp tục" đến trang booking
          // Chỉ enable khi đã chọn ít nhất 1 dịch vụ
          NextButton(
            onPressed: _selectedServiceIds.isNotEmpty
                ? () => _navigateToBooking(barber)
                : null, // null = disabled button
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Lấy location string từ barber object
  /// Ưu tiên: location -> area -> address -> default
  String _getLocation(BarberModel barber) {
    if (barber.location?.isNotEmpty == true) return barber.location!;
    if (barber.area?.isNotEmpty == true) return barber.area!;
    if (barber.address?.isNotEmpty == true) return barber.address!;
    return 'Địa chỉ không xác định';
  }

  /// Lấy image path từ barber object
  /// Nếu không có thì dùng default image
  String _getImagePath(BarberModel barber) {
    return barber.imagePath?.isNotEmpty == true
        ? barber.imagePath!
        : 'assets/images/default_barber.jpg';
  }

  /// Build nội dung phần danh sách dịch vụ
  /// Xử lý 3 trạng thái: loading, error, success
  Widget _buildServicesContent(ServiceViewModel serviceViewModel) {
    // CASE 1: Đang loading và chưa có data
    if (serviceViewModel.isLoading &&
        serviceViewModel.barberServices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // CASE 2: Có error và chưa có data
    if (serviceViewModel.error != null &&
        serviceViewModel.barberServices.isEmpty) {
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

    // CASE 3: Không có dịch vụ nào
    if (serviceViewModel.barberServices.isEmpty) {
      return const Center(child: Text('Chưa có dịch vụ nào'));
    }

    // CASE 4: Có dịch vụ - hiển thị danh sách
    return ListService(
      id: widget.id,
      services: serviceViewModel.barberServices,
      initialSelectedIds: _selectedServiceIds, // Pass danh sách đã chọn
      onSelectionChanged: (selectedIds) {
        // Callback khi user chọn/bỏ chọn dịch vụ
        setState(() {
          _selectedServiceIds = selectedIds;
        });
      },
    );
  }

  /// Điều hướng đến trang booking
  /// Truyền thông tin barber và danh sách dịch vụ đã chọn
  void _navigateToBooking(BarberModel barber) {
    print('-------------------------------------------');
    print('Navigating to booking...');
    print('   Barber: ${barber.name}');
    print('   Selected services: $_selectedServiceIds');
    print('-------------------------------------------');

    // Push đến trang booking với dữ liệu
    context.pushNamed(
      'booking',
      extra: {
        // Truyền BarberModel object (không phải chỉ ID)
        'initialBarber': barber,

        // Truyền danh sách service IDs dưới dạng string
        // (vì extra params thường là string)
        'initialServiceIds': _selectedServiceIds
            .map((id) => id.toString())
            .toList(),
      },
    );
  }
}