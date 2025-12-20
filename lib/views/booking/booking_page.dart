import 'package:barbergofe/models/service/service_model.dart';
import 'package:barbergofe/viewmodels/service/service_viewmodel.dart';
import 'package:barbergofe/views/booking/widgets/barber_selection_sheet.dart';
import 'package:barbergofe/views/booking/widgets/time_slot_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/booking/booking_viewmodel.dart';
import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:barbergofe/models/booking/booking_model.dart';
import 'widgets/step1_booking.dart';
import 'widgets/booking_summary.dart';
import 'widgets/confirm_button.dart';

// Màn hình Đặt lịch (Booking Page)
class BookingPage extends StatefulWidget {
  // Dữ liệu ban đầu (nếu được truyền từ màn hình Home)
  final BarberModel? initialBarber;       // Thợ cắt tóc đã chọn trước
  final List<String>? initialServiceIds;  // Danh sách ID dịch vụ đã chọn trước

  const BookingPage({
    super.key,
    this.initialBarber,
    this.initialServiceIds,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // Biến kiểm soát trạng thái
  bool _isInitialized = false; // Đánh dấu xem dữ liệu đã được khởi tạo chưa
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Log để debug xem dữ liệu đầu vào có nhận được không
    print('BookingPage initState');
    print('   initialBarber: ${widget.initialBarber?.name}');
    print('   initialServiceIds: ${widget.initialServiceIds}');
  }

  // Hàm này chạy khi các dependencies (như Provider) đã sẵn sàng
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Chỉ chạy khởi tạo dữ liệu 1 lần duy nhất
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeData();
    }
  }

  // ==========================================
  // PHẦN 1: LOGIC KHỞI TẠO DỮ LIỆU (QUAN TRỌNG)
  // ==========================================
  Future<void> _initializeData() async {
    print(' _initializeData started');

    // addPostFrameCallback: Đợi UI vẽ xong frame đầu tiên rồi mới chạy logic
    // (Tránh lỗi gọi setState hoặc Provider khi widget chưa build xong)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        setState(() {
          _isLoading = true; // Bắt đầu loading
          _error = null;
        });

        // Lấy các ViewModel cần thiết
        final bookingViewModel = context.read<BookingViewModel>();
        final serviceViewModel = context.read<ServiceViewModel>();

        print(' Starting data initialization...');

        // 1. Xử lý Barber (Thợ)
        if (widget.initialBarber != null) {
          print('Setting barber: ${widget.initialBarber!.name}');
          // Cập nhật thợ vào ViewModel
          bookingViewModel.selectBarber(widget.initialBarber!);

          // 2. Tải danh sách dịch vụ của thợ này (Bắt buộc có bước này để chọn dịch vụ)
          print('Loading services for barber: ${widget.initialBarber!.id}');
          await serviceViewModel.fetchServicesByBarber(widget.initialBarber!.id);
          print(' Services loaded: ${serviceViewModel.barberServices.length}');

          // 3. Xử lý Services (Dịch vụ) từ ID truyền vào
          if (widget.initialServiceIds != null && widget.initialServiceIds!.isNotEmpty) {
            print(' Setting services from IDs: ${widget.initialServiceIds}');

            final List<ServiceModel> selectedServices = [];
            // Duyệt qua từng ID dịch vụ
            for (var serviceIdStr in widget.initialServiceIds!) {
              final serviceId = int.tryParse(serviceIdStr);
              if (serviceId != null) {
                try {
                  // Tìm dịch vụ trong danh sách đã tải về
                  final service = serviceViewModel.barberServices.firstWhere(
                        (s) => s.id == serviceId,
                    orElse: () {
                      // Nếu không tìm thấy (trường hợp hiếm), tạo object tạm
                      return ServiceModel(
                        id: serviceId,
                        barberId: widget.initialBarber!.id,
                        serviceName: 'Service $serviceId',
                        price: 0,
                        durationMin: 30,
                      );
                    },
                  );
                  selectedServices.add(service);
                  print('Added service: ${service.serviceName} (ID: $serviceId)');
                } catch (e) {
                  print(' Error finding service $serviceId: $e');
                }
              }
            }

            // Nếu tìm thấy dịch vụ hợp lệ thì cập nhật vào ViewModel
            if (selectedServices.isNotEmpty) {
              bookingViewModel.selectServices(selectedServices);
              print('Total services selected: ${selectedServices.length}');
            }
          }

          // 4. Tải các khung giờ rảnh (Time Slots)
          print(' Fetching time slots...');
          await bookingViewModel.fetchAvailableTimeSlots();
          print(' Time slots fetched: ${bookingViewModel.availableTimeSlots.length}');
        }

        // Kết thúc loading
        setState(() {
          _isLoading = false;
        });

        print('Data initialization complete!');

      } catch (e) {
        print(' Error in _initializeData: $e');
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    });
  }

  // ==========================================
  // PHẦN 2: LOGIC XỬ LÝ ĐẶT LỊCH (GỌI API)
  // ==========================================
    Future<void> _handleBookingCreation(BookingViewModel bookingViewModel) async {
    print(' Starting booking creation...');

    try {
      // Gọi API tạo booking và CHỜ kết quả trả về
      final bookingResponse = await bookingViewModel.createBooking();

      print(' Booking created successfully');
      print('   Response: ${bookingResponse?.toString()}');

      // Kiểm tra xem phản hồi có hợp lệ không
      if (bookingResponse != null && bookingResponse.booking != null) {
        // Nếu thành công và widget vẫn còn hiển thị -> Hiện Dialog thành công
        if (mounted) {
          _showSuccessDialog(bookingResponse);
        }
      }
    } catch (e) {
      // Bắt lỗi khi gọi API thất bại
      print('Error creating booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt lịch thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Hiển thị Popup thông báo đặt thành công
  void _showSuccessDialog(BookingCreateResponse response) {
    final booking = response.booking;

    showDialog(
      context: context,
      barrierDismissible: false, // Không cho bấm ra ngoài để tắt
      builder: (context) {
        return AlertDialog(
          // ... (Phần UI hiển thị thông tin thành công) ...
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('Đặt lịch thành công', style: TextStyle(fontSize: 18))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(response.message ?? 'Lịch hẹn của bạn đã được xác nhận', style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                Divider(),
                // ... (Các UI chi tiết khác) ...
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vui lòng đến đúng giờ và mang theo mã đơn hàng này!',
                          style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Nút OK -> Về trang chủ
            TextButton(
              onPressed: () => context.goNamed('home'),
              child: Text('OK'),
            ),
            // Nút Chi tiết -> Về trang chủ (có thể sửa lại để đi đến trang chi tiết đơn hàng)
            ElevatedButton(
              onPressed: () => context.goNamed("home"),
              child: Text('Xem chi tiết'),
            ),
          ],
        );
      },
    );
  }
  // ==========================================
  // PHẦN 3: GIAO DIỆN CHÍNH (BUILD)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi từ BookingViewModel để vẽ lại UI
    final bookingViewModel = context.watch<BookingViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'), // Quay về Home
        ),
      ),
      body: SafeArea(
        // Kiểm tra 3 trạng thái: Đang tải -> Lỗi -> Hiển thị nội dung
        child: _isLoading
            ? _buildLoading() // Widget quay tròn loading
            : _error != null
            ? _buildError() // Widget hiển thị lỗi
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // =========== BƯỚC 1: CHỌN TIỆM TÓC/THỢ ===========
              Step1Booking(
                nameStep: '1. Chọn tiệm tóc',
                hint: 'Chọn tiệm tóc',
                content: bookingViewModel.selectedBarber?.name, // Hiển thị tên nếu đã chọn
                onTap: () async {
                  final result= await context.pushNamed('ListArea');
                  if(result !=null && result is BarberModel){
                    setState(() {
                      _isLoading=true;
                    });
                    try{
                      //cập nhật barber đã chọn
                      bookingViewModel.selectBarber(result);
                      //tải lại service của barber này
                      final serviceVM=context.read<ServiceViewModel>();
                      await serviceVM.fetchServicesByBarber(result.id);

                      //tải lại timeslots
                      await bookingViewModel.fetchAvailableTimeSlots();

                      setState(() {
                        _isLoading=false;
                      });
                    }catch(e){
                        setState(() {
                          _isLoading=false;
                        });
                        if(mounted){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Lỗi: $e"),
                              backgroundColor: Colors.red,
                            ),

                          );
                        }
                    }
                  }
                },
              ),

              const SizedBox(height: 24),

              // =========== BƯỚC 2: CHỌN DỊCH VỤ ===========
              Step1Booking(
                nameStep: '2. Chọn dịch vụ',
                hint: 'Chọn dịch vụ',
                // Nối tên các dịch vụ bằng dấu phẩy
                content: bookingViewModel.selectedServices.isEmpty
                    ? null
                    : bookingViewModel.selectedServices.map((s) => s.serviceName).join(', '),
                onTap: () {
                  // Chỉ cho chọn dịch vụ nếu đã chọn Thợ
                  if (bookingViewModel.selectedBarber != null) {
                    _showServiceSelection(bookingViewModel);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn tiệm tóc trước'), backgroundColor: Colors.orange),
                    );
                  }
                },
              ),

              const SizedBox(height: 24),

              // =========== BƯỚC 3: CHỌN THỜI GIAN ===========
              Step1Booking(
                nameStep: '3. Chọn thời gian',
                hint: 'Chọn thời gian',
                content: bookingViewModel.selectedTimeSlot?.displayText,
                onTap: () {
                  if (bookingViewModel.selectedBarber != null) {
                    _showTimeSlotSelection(bookingViewModel);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn tiệm tóc trước'), backgroundColor: Colors.orange),
                    );
                  }
                },
              ),

              const SizedBox(height: 32),

              // =========== TÓM TẮT ĐƠN HÀNG ===========
              // Chỉ hiện khi đã chọn ít nhất 1 thông tin
              if (bookingViewModel.selectedBarber != null ||
                  bookingViewModel.selectedServices.isNotEmpty ||
                  bookingViewModel.selectedTimeSlot != null)
                BookingSummary(
                  barber: bookingViewModel.selectedBarber,
                  services: bookingViewModel.selectedServices,
                  timeSlot: bookingViewModel.selectedTimeSlot,
                  totalPrice: bookingViewModel.totalPrice,
                  totalDuration: bookingViewModel.totalDuration,
                ),

              const SizedBox(height: 32),

              // =========== NÚT XÁC NHẬN ===========
              ConfirmButton(
                canConfirm: bookingViewModel.canBook, // Kiểm tra logic (đủ thông tin chưa?)
                isLoading: bookingViewModel.isLoading,
                error: bookingViewModel.error,
                onConfirm: () async {
                  // QUAN TRỌNG: Gọi hàm đặt lịch và đợi kết quả
                  await _handleBookingCreation(bookingViewModel);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Loading ---
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          const SizedBox(height: 16),
          Text('Đang tải thông tin...', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // --- Widget Error ---
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 64),
          const SizedBox(height: 16),
          Text('Có lỗi xảy ra', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          // ... (Hiển thị chi tiết lỗi và nút thử lại) ...
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(_error ?? 'Không thể tải dữ liệu', textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Reset trạng thái để chạy lại initData
              setState(() {
                _isInitialized = false;
                _error = null;
              });
            },
            icon: Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CÁC HÀM HIỂN THỊ POPUP / BOTTOM SHEET
  // ==========================================

  // Hiển thị danh sách chọn Thợ (Barber)
  void _showBarberSelection(BarberViewModel barberViewModel, BookingViewModel bookingViewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return BarberSelectionSheet(
          barbers: barberViewModel.topBarbers,
          onSelect: (barber) async {
            context.pop(); // Đóng Sheet

            setState(() { _isLoading = true; }); // Hiện loading

            try {
              // Logic khi đổi Barber:
              // 1. Set Barber mới
              bookingViewModel.selectBarber(barber);
              // 2. Tải lại danh sách dịch vụ của Barber mới
              final serviceViewModel = context.read<ServiceViewModel>();
              await serviceViewModel.fetchServicesByBarber(barber.id);
              // 3. Tải lại giờ rảnh
              await bookingViewModel.fetchAvailableTimeSlots();

              setState(() { _isLoading = false; }); // Tắt loading

            } catch (e) {
              setState(() { _isLoading = false; });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red));
              }
            }
          },
        );
      },
    );
  }

  // Điều hướng sang màn hình chọn Dịch vụ (Sử dụng Navigator.pushNamed)
  void _showServiceSelection(BookingViewModel bookingViewModel) {
    context.pushNamed(
      'detail',
      extra: {
        'barberId': bookingViewModel.selectedBarber!.id,
        // Truyền danh sách ID các dịch vụ đang chọn để hiển thị tick chọn sẵn
        'selectedServiceIds': bookingViewModel.selectedServices.isNotEmpty?
            bookingViewModel.selectedServices.map((s)=>s.id).toList():null
      },
    ).then((_) {
      // Khi quay lại từ trang chọn dịch vụ, rebuild lại trang này để cập nhật UI
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Hiển thị danh sách chọn Giờ (Time Slot)
  void _showTimeSlotSelection(BookingViewModel bookingViewModel) {
    if (bookingViewModel.availableTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có khung giờ trống. Vui lòng thử lại sau.'), backgroundColor: Colors.orange),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return TimeSlotSelectionSheet(
          timeSlots: bookingViewModel.availableTimeSlots,
          selectedTimeSlot: bookingViewModel.selectedTimeSlot,
          onSelect: (timeSlot) {
            bookingViewModel.selectTimeSlot(timeSlot);
            Navigator.pop(context);
          },
          // Logic nút làm mới (Refresh) trong BottomSheet
          onRefresh: () async {
            Navigator.pop(context);
            setState(() { _isLoading = true; });

            await bookingViewModel.fetchAvailableTimeSlots();

            setState(() { _isLoading = false; });
            // Hiện lại BottomSheet sau khi tải xong
            _showTimeSlotSelection(bookingViewModel);
          },
          isLoading: bookingViewModel.isLoading,
        );
      },
    );
  }
}