import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/service/service_viewmodel.dart';
import 'package:barbergofe/viewmodels/booking/booking_viewmodel.dart';
import 'package:barbergofe/models/service/service_model.dart';
import 'package:barbergofe/core/constants/color.dart';

class ServiceSelectionPage extends StatefulWidget {
  final String barberId;
  final List<int> selectedServiceIds;

  const ServiceSelectionPage({
    super.key,
    required this.barberId,
    required this.selectedServiceIds,
  });

  @override
  State<ServiceSelectionPage> createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends State<ServiceSelectionPage> {
  late List<int> _selectedServiceIds;

  @override
  void initState() {
    super.initState();
    _selectedServiceIds = List.from(widget.selectedServiceIds);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServices();
    });
  }

  void _loadServices() {
    final serviceViewModel = context.read<ServiceViewModel>();
    serviceViewModel.fetchServicesByBarber(widget.barberId);
  }

  @override
  Widget build(BuildContext context) {
    final serviceViewModel = context.watch<ServiceViewModel>();
    final bookingViewModel = context.read<BookingViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn dịch vụ'),
        centerTitle: true,
        actions: [
          // Sửa: Dùng TextButton thay vì IconButton
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () {
                _applySelectedServices(serviceViewModel, bookingViewModel);
              },
              child: const Text(
                'Xong',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary
            if (_selectedServiceIds.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đã chọn: ${_selectedServiceIds.length} dịch vụ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedServiceIds.clear();
                          });
                        },
                        child: const Text(
                          'Bỏ chọn tất cả',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Services list
            Expanded(
              child: _buildServicesList(serviceViewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(ServiceViewModel serviceViewModel) {
    if (serviceViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (serviceViewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              serviceViewModel.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServices,
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
            const Text(
              'Không có dịch vụ nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadServices,
              child: const Text('Tải lại'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: serviceViewModel.barberServices.length,
      itemBuilder: (context, index) {
        final service = serviceViewModel.barberServices[index];
        final isSelected = _selectedServiceIds.contains(service.id);

        return _buildServiceItem(service, isSelected);
      },
    );
  }

  Widget _buildServiceItem(ServiceModel service, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedServiceIds.add(service.id);
                  } else {
                    _selectedServiceIds.remove(service.id);
                  }
                });
              },
            ),

            const SizedBox(width: 12),

            // Service info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.formattedDuration,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Price
            Text(
              service.formattedPrice,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applySelectedServices(
      ServiceViewModel serviceViewModel,
      BookingViewModel bookingViewModel,
      ) {
    final selectedServices = serviceViewModel.barberServices
        .where((service) => _selectedServiceIds.contains(service.id))
        .toList();

    // Update booking viewmodel
    // Clear all current services first
    bookingViewModel.clearServices();

    // Add new selected services
    for (var service in selectedServices) {
      bookingViewModel.addService(service);
    }

    // Navigate back
    Navigator.pop(context);
  }

  // Tính tổng giá
  int _calculateTotalPrice(ServiceViewModel serviceViewModel) {
    return serviceViewModel.barberServices
        .where((service) => _selectedServiceIds.contains(service.id))
        .fold(0, (sum, service) => sum + service.price);
  }

  // Tính tổng thời gian
  int _calculateTotalDuration(ServiceViewModel serviceViewModel) {
    return serviceViewModel.barberServices
        .where((service) => _selectedServiceIds.contains(service.id))
        .fold(0, (sum, service) => sum + service.durationMin);
  }
}