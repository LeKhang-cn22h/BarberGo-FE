import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Map<String, dynamic>? barber;

  @override
  void initState() {
    super.initState();
    loadBarber();
  }

  Future<void> loadBarber() async {
    final jsonString = await rootBundle.loadString('assets/data/barbers.json');
    final List data = jsonDecode(jsonString);

    final result =
    data.firstWhere((e) => e['id'] == widget.id, orElse: () => null);

    setState(() {
      barber = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (barber == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(barber!['name']), // tên barber
      ),
      body: Column(
        children: [
          BarberInfo(
            name: barber!['name'],
            rank: barber!['rank'],
            location: barber!['location'],
            imagePath: barber!['imagePath'],
          ),

          BarberSearch(hint: 'Tìm kiếm dịch vụ'),

          const Text("Dịch vụ"),

          // truyền id và list service
          Expanded(
            child: ListService(
              id: widget.id,
              services: List<Map<String, dynamic>>.from(barber!['services']),
            ),
          ),

          const NextButton(),
        ],
      ),
    );
  }
}
