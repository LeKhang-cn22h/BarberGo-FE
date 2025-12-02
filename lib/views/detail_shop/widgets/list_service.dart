import 'package:barbergofe/views/detail_shop/widgets/service_item.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
class ListService extends StatefulWidget {
  final String id;
  final List<Map<String, dynamic>> services;

  const ListService({super.key, required this.id, required this.services});

  @override
  State<ListService> createState() => _ListServiceState();
}

class _ListServiceState extends State<ListService> {
  Set<int> selectedIndex = {};

  @override
  Widget build(BuildContext context) {
    final services = widget.services; // Lấy từ widget

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {

        final service = services[index];
        final bool isSelected = selectedIndex.contains(index);

        return ServiceItem(
          index: index,
          isSelected: isSelected,
          name: service["service_name"],
          time: "${service["duration_min"]} phút",
           price: service["price"].toString(),
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedIndex.remove(index);
              } else {
                selectedIndex.add(index);
              }
            });
          },
        );
      },
    );
  }
}
