import 'package:flutter/material.dart';
import 'package:barbergofe/models/service/service_model.dart';
import 'package:barbergofe/views/ownerBarber/widgets/owner_service_item.dart';

class OwnerListService extends StatelessWidget {
  final List<ServiceModel> services;
  // Callback trả về object ServiceModel để cha biết đang sửa dịch vụ nào
  final Function(ServiceModel) onEditService;

  const OwnerListService({
    super.key,
    required this.services,
    required this.onEditService,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(child: Text('Chưa có dịch vụ nào'));
    }

    // ShrinkWrap và Physics để nó nằm gọn trong cột của trang Cha
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];

        return OwnerServiceItem(
          index: index,
          name: service.serviceName,
          time: service.formattedDuration,
          price: service.formattedPrice,
          onEdit: () {
            // Báo lên cho cha
            onEditService(service);
          },
        );
      },
    );
  }
}