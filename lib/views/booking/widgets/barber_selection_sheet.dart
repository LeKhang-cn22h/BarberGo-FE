import 'package:barbergofe/views/home/widgets/card_shop.dart';
import 'package:flutter/material.dart';
import 'package:barbergofe/models/barber/barber_model.dart';
import 'package:go_router/go_router.dart';

class BarberSelectionSheet extends StatefulWidget {
  final List<BarberModel> barbers;
  final Function(BarberModel) onSelect;

  const BarberSelectionSheet({
    super.key,
    required this.barbers,
    required this.onSelect,
  });

  @override
  State<BarberSelectionSheet> createState() => _BarberSelectionSheetState();
}

class _BarberSelectionSheetState extends State<BarberSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chọn tiệm tóc',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.barbers.isEmpty
                ? const Center(
              child: Text('Không có tiệm tóc nào'),
            )
                : ListView.builder(
              itemCount: widget.barbers.length,
              itemBuilder: (context, index) {
                final barber = widget.barbers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CardShop(
                    id: barber.id,
                    imagePath: barber.imagePath ?? 'assets/images/default_barber.jpg',
                    name: barber.name,
                    location: barber.location ?? barber.area ?? barber.address ?? 'Địa chỉ',
                    rank: barber.rank ?? 0.0,
                    onTap: () {
                      widget.onSelect(barber);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}