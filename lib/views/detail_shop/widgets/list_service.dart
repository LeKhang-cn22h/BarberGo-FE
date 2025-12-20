import 'package:barbergofe/views/detail_shop/widgets/service_item.dart';
import 'package:flutter/material.dart';
import 'package:barbergofe/models/service/service_model.dart';

class ListService extends StatefulWidget {
  final String id;
  final List<ServiceModel> services;
  final ValueChanged<List<int>>? onSelectionChanged;
  final List<int>? initialSelectedIds;

  const ListService({
    super.key,
    required this.id,
    required this.services,
    this.onSelectionChanged,
    this.initialSelectedIds,
  });

  @override
  State<ListService> createState() => _ListServiceState();
}

class _ListServiceState extends State<ListService> {
  Set<int> selectedServiceIds = {};

  @override
  Widget build(BuildContext context) {
    final services = widget.services;

    if (services.isEmpty) {
      return const Center(
        child: Text('Không có dịch vụ nào'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final bool isSelected = selectedServiceIds.contains(service.id);

        return ServiceItem(
          index: index,
          isSelected: isSelected,
          name: service.serviceName,
          time: service.formattedDuration,
          price: service.formattedPrice,
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedServiceIds.remove(service.id);
              } else {
                selectedServiceIds.add(service.id);
              }
            });

            widget.onSelectionChanged?.call(selectedServiceIds.toList());
          },
        );
      },
    );
  }
}