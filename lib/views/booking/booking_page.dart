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

class BookingPage extends StatefulWidget {
  final BarberModel? initialBarber;
  final List<String>? initialServiceIds;

  const BookingPage({
    super.key,
    this.initialBarber,
    this.initialServiceIds,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('✅ BookingPage initState');
    print('   initialBarber: ${widget.initialBarber?.name}');
    print('   initialServiceIds: ${widget.initialServiceIds}');
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
    print('🚀 _initializeData started');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        setState(() {
          _isLoading = true;
          _error = null;
        });

        final bookingViewModel = context.read<BookingViewModel>();
        final serviceViewModel = context.read<ServiceViewModel>();

        print('🎯 Starting data initialization...');

        // 1. Set barber nếu có
        if (widget.initialBarber != null) {
          print('👤 Setting barber: ${widget.initialBarber!.name}');
          bookingViewModel.selectBarber(widget.initialBarber!);

          // 2. Tải services cho barber này TRƯỚC KHI chọn
          print('🔄 Loading services for barber: ${widget.initialBarber!.id}');
          await serviceViewModel.fetchServicesByBarber(widget.initialBarber!.id);
          print('✅ Services loaded: ${serviceViewModel.barberServices.length}');

          // 3. Set services nếu có initialServiceIds
          if (widget.initialServiceIds != null && widget.initialServiceIds!.isNotEmpty) {
            print('🔧 Setting services from IDs: ${widget.initialServiceIds}');

            final List<ServiceModel> selectedServices = [];
            for (var serviceIdStr in widget.initialServiceIds!) {
              final serviceId = int.tryParse(serviceIdStr);
              if (serviceId != null) {
                try {
                  final service = serviceViewModel.barberServices.firstWhere(
                        (s) => s.id == serviceId,
                    orElse: () {
                      return ServiceModel(
                        id: serviceId,
                        barberId: widget.initialBarber!.id,
                        serviceName: 'Service #$serviceId',
                        price: 0,
                        durationMin: 30,
                      );
                    },
                  );
                  selectedServices.add(service);
                  print('   ✅ Added service: ${service.serviceName} (ID: $serviceId)');
                } catch (e) {
                  print('   ❌ Error finding service $serviceId: $e');
                }
              }
            }

            if (selectedServices.isNotEmpty) {
              bookingViewModel.selectServices(selectedServices);
              print('📋 Total services selected: ${selectedServices.length}');
            }
          }

          // 4. Fetch time slots
          print('🕐 Fetching time slots...');
          await bookingViewModel.fetchAvailableTimeSlots();
          print('✅ Time slots fetched: ${bookingViewModel.availableTimeSlots.length}');
        }

        setState(() {
          _isLoading = false;
        });

        print('🎉 Data initialization complete!');

      } catch (e) {
        print('❌ Error in _initializeData: $e');
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    });
  }

  Future<void> _handleBookingCreation(BookingViewModel bookingViewModel) async {
    print('📝 Starting booking creation...');

    try {
      // Gọi API tạo booking và CHỜ kết quả
      final bookingResponse = await bookingViewModel.createBooking();

      print('✅ Booking created successfully');
      print('   Response: ${bookingResponse?.toString()}');

      // Kiểm tra response có dữ liệu không
      if (bookingResponse != null && bookingResponse.booking != null) {
        // Hiển thị dialog thành công với thông tin chi tiết
        if (mounted) {
          _showSuccessDialog(bookingResponse);
        }
      } else {
        // Response null hoặc booking null
        print('⚠️ Warning: bookingResponse or booking is null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đặt lịch thành công nhưng không nhận được thông tin chi tiết'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context); // Quay về trang trước
        }
      }

    } catch (e) {
      print('❌ Error creating booking: $e');
      // Hiển thị lỗi
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

  void _showSuccessDialog(BookingCreateResponse response) {
    final booking = response.booking;

    print('🎉 Showing success dialog');
    print('   Booking ID: ${booking.id}');
    print('   Barber: ${booking.barberName}');
    print('   Services: ${booking.servicesSummary}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đặt lịch thành công',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  response.message ?? 'Lịch hẹn của bạn đã được xác nhận',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 8),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vui lòng đến đúng giờ và mang theo mã đơn hàng này!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.goNamed('home');
              },
              child: Text('OK'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.goNamed("home");
              },
              child: Text('Xem chi tiết'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookingDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingViewModel = context.watch<BookingViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('home'),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoading()
            : _error != null
            ? _buildError()
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Step 1: Chọn tiệm tóc
              Step1Booking(
                nameStep: '1. Chọn tiệm tóc',
                hint: 'Chọn tiệm tóc',
                content: bookingViewModel.selectedBarber?.name,
                onTap: () {
                  final barberViewModel = context.read<BarberViewModel>();
                  _showBarberSelection(barberViewModel, bookingViewModel);
                },
              ),

              const SizedBox(height: 24),

              // Step 2: Chọn dịch vụ
              Step1Booking(
                nameStep: '2. Chọn dịch vụ',
                hint: 'Chọn dịch vụ',
                content: bookingViewModel.selectedServices.isEmpty
                    ? null
                    : bookingViewModel.selectedServices
                    .map((s) => s.serviceName)
                    .join(', '),
                onTap: () {
                  if (bookingViewModel.selectedBarber != null) {
                    _showServiceSelection(bookingViewModel);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng chọn tiệm tóc trước'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 24),

              // Step 3: Chọn thời gian
              Step1Booking(
                nameStep: '3. Chọn thời gian',
                hint: 'Chọn thời gian',
                content: bookingViewModel.selectedTimeSlot?.displayText,
                onTap: () {
                  if (bookingViewModel.selectedBarber != null) {
                    _showTimeSlotSelection(bookingViewModel);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng chọn tiệm tóc trước'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 32),

              // Tóm tắt đặt lịch
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

              // Nút xác nhận
              ConfirmButton(
                canConfirm: bookingViewModel.canBook,
                isLoading: bookingViewModel.isLoading,
                error: bookingViewModel.error,
                onConfirm: () async {
                  // QUAN TRỌNG: Phải await để đợi API hoàn thành
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

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tải thông tin...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _error ?? 'Không thể tải dữ liệu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isInitialized = false;
                _error = null;
              });
            },
            icon: Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showBarberSelection(BarberViewModel barberViewModel, BookingViewModel bookingViewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BarberSelectionSheet(
          barbers: barberViewModel.topBarbers,
          onSelect: (barber) async {
            Navigator.pop(context);

            setState(() {
              _isLoading = true;
            });

            try {
              bookingViewModel.selectBarber(barber);
              final serviceViewModel = context.read<ServiceViewModel>();
              await serviceViewModel.fetchServicesByBarber(barber.id);
              await bookingViewModel.fetchAvailableTimeSlots();

              setState(() {
                _isLoading = false;
              });

            } catch (e) {
              setState(() {
                _isLoading = false;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _showServiceSelection(BookingViewModel bookingViewModel) {
    Navigator.pushNamed(
      context,
      '/service-selection',
      arguments: {
        'barberId': bookingViewModel.selectedBarber!.id,
        'selectedServiceIds': bookingViewModel.selectedServices.map((s) => s.id).toList(),
      },
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _showTimeSlotSelection(BookingViewModel bookingViewModel) {
    if (bookingViewModel.availableTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Không có khung giờ trống. Vui lòng thử lại sau.'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TimeSlotSelectionSheet(
          timeSlots: bookingViewModel.availableTimeSlots,
          selectedTimeSlot: bookingViewModel.selectedTimeSlot,
          onSelect: (timeSlot) {
            bookingViewModel.selectTimeSlot(timeSlot);
            Navigator.pop(context);
          },
          onRefresh: () async {
            Navigator.pop(context);
            setState(() {
              _isLoading = true;
            });

            await bookingViewModel.fetchAvailableTimeSlots();

            setState(() {
              _isLoading = false;
            });

            _showTimeSlotSelection(bookingViewModel);
          },
          isLoading: bookingViewModel.isLoading,
        );
      },
    );
  }
}