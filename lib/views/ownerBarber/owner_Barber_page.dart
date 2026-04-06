  import 'package:barbergofe/core/globals.dart';
import 'package:barbergofe/core/utils/image_picker_helper.dart';
import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:go_router/go_router.dart';
  import 'package:barbergofe/viewmodels/barber/owner_barber_viewmodel.dart';
  import 'package:barbergofe/models/service/service_model.dart';
  import 'package:barbergofe/models/barber/barber_model.dart';
  import 'widgets/owner_barber_info.dart';
  import 'widgets/owner_list_service.dart';
  import 'widgets/edit_barber_name_dialog.dart';
  import 'widgets/edit_service_dialog.dart';
  import 'widgets/add_service_dialog.dart';

  class OwnerBarberPage extends StatefulWidget {
    const OwnerBarberPage({super.key});

    @override
    State<OwnerBarberPage> createState() => _OwnerBarberPageState();
  }

  class _OwnerBarberPageState extends State<OwnerBarberPage> {
    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OwnerBarberViewModel>().initialize();
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: () => context.read<OwnerBarberViewModel>().refresh(),
          child: Consumer<OwnerBarberViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && !viewModel.hasBarber) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null && !viewModel.hasBarber) {
                return _buildErrorState(viewModel);
              }

              if (!viewModel.hasBarber) {
                return _buildNoBarberState();
              }

              final barber = viewModel.myBarber!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OwnerBarberInfo(
                      name: barber.name,
                      location: barber.address ?? barber.area ?? 'Chưa cập nhật địa chỉ',
                      rank: barber.rank ?? 0.0,
                      imagePath: barber.imagePath ?? 'https://via.placeholder.com/150',
                      onEditImage: () => _handleEditImage(viewModel),
                      onEditName: () => _handleEditName(viewModel, barber.name),
                      onEditLocation: () => _handleEditLocation(viewModel),
                      onTapStar: () => _navigateToRatings(barber.id),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Danh sách dịch vụ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _handleAddService(viewModel),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (viewModel.services.isEmpty)
                      _buildEmptyServices()
                    else
                      OwnerListService(
                        services: viewModel.services,
                        onEditService: (service) => _handleEditService(
                          viewModel,
                          service,
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    Widget _buildErrorState(OwnerBarberViewModel viewModel) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.error ?? 'Có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    Widget _buildNoBarberState() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có cửa hàng nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang phát triển')),
                );
              },
              child: const Text('Tạo cửa hàng'),
            ),
          ],
        ),
      );
    }

    Widget _buildEmptyServices() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.cut, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Chưa có dịch vụ nào',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _handleAddService(
                  context.read<OwnerBarberViewModel>(),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm dịch vụ đầu tiên'),
              ),
            ],
          ),
        ),
      );
    }

    // ==================== DEBUG VERSION ====================
    Future<void> _handleEditName(
        OwnerBarberViewModel viewModel,
        String currentName,
        ) async {
      print(' [VIEW] Current name: "$currentName"');

      final newName = await showDialog<String>(
        context: context,
        builder: (context) => EditBarberNameDialog(currentName: currentName),
      );

      print(' [VIEW] Dialog returned: "$newName"');

      if (newName != null && newName.isNotEmpty && newName != currentName) {
        print(' [VIEW] Creating request with name: "$newName"');

        // Tạo request với tên mới
        final request = BarberUpdateRequest(name: newName);

        // Debug: In ra để xem request có đúng không
        print('[VIEW] Request created - checking request.name: "${request.name}"');

        final success = await viewModel.updateinforBarber(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? ' Đã cập nhật tên thành "$newName"' : ' Cập nhật thất bại',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } else {
        print('[VIEW] Update cancelled or same name');
      }
    }

    Future<void> _handleEditLocation(OwnerBarberViewModel viewModel) async {
      final barber = viewModel.myBarber;
      if (barber == null) return;

      final result = await context.pushNamed(
        'location_picker',
        queryParameters: {
          if (barber.lat != null) 'lat': barber.lat.toString(),
          if (barber.lng != null) 'lng': barber.lng.toString(),
          if (barber.address != null) 'address': barber.address,
        },
      );

      if (result != null && result is Map<String, dynamic>) {
        final lat = result['lat'] as double?;
        final lng = result['lng'] as double?;

        if (lat != null && lng != null) {
          try {
            await viewModel.updateBarberLocation(lat, lng);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(' Đã cập nhật vị trí'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(' Cập nhật thất bại: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    }

    Future<void> _handleEditImage(OwnerBarberViewModel viewModel) async {
      final imageFile = await ImagePickerHelper.pickFromGallery(context);

      if (imageFile != null) {
        // Show loading dialog với GlobalKey
        AppGlobals.scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text('Đang tải ảnh lên...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );

        try {
          final success = await viewModel.uploadBarberImage(imageFile);

          AppGlobals.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

          if (mounted) {
            AppGlobals.scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Đã cập nhật ảnh đại diện'
                      : 'Cập nhật ảnh thất bại',
                ),
                backgroundColor: success ? Colors.green : Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          AppGlobals.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

          if (mounted) {
            AppGlobals.scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(' Lỗi: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    }

    Future<void> _handleAddService(OwnerBarberViewModel viewModel) async {
      final barber = viewModel.myBarber;
      if (barber == null) return;

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AddServiceDialog(barberId: barber.id),
      );

      if (result != null) {
        final request = ServiceCreateRequest(
          barberId: result['barberId'] as String,
          serviceName: result['serviceName'] as String,
          price: result['price'] as int,
          durationMin: result['durationMin'] as int,
        );

        final success = await viewModel.createService(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? ' Đã thêm dịch vụ' : ' Thêm thất bại',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    }

    Future<void> _handleEditService(
        OwnerBarberViewModel viewModel,
        ServiceModel service,
        ) async {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => EditServiceDialog(service: service),
      );

      if (result != null) {
        final action = result['action'] as String;

        if (action == 'delete') {
          final confirmDelete = await _confirmDelete(service.serviceName);
          if (confirmDelete == true) {
            final success = await viewModel.deleteService(service.id.toString());

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? ' Đã xóa dịch vụ' : ' Xóa thất bại',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          }
        } else if (action == 'update') {
          final request = ServiceUpdateRequest(
            serviceName: result['serviceName'] as String?,
            price: result['price'] as int?,
            durationMin: result['durationMin'] as int?,
          );

          final success = await viewModel.updateService(service.id, request);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success ? ' Đã cập nhật dịch vụ' : ' Cập nhật thất bại',
                ),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        }
      }
    }

    Future<bool?> _confirmDelete(String serviceName) {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa dịch vụ "$serviceName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );
    }

    void _navigateToRatings(String barberId) {
      context.pushNamed('owner_rating', pathParameters: {'barberId': barberId});
    }
  }
