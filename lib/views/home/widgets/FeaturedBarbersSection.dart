import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
import 'package:barbergofe/views/home/widgets/card_shop.dart';
import 'package:flutter/material.dart';

class FeaturedBarbersSection extends StatefulWidget {
  final BarberViewModel viewModel;

  const FeaturedBarbersSection({
    super.key,
    required this.viewModel,
  });

  @override
  State<FeaturedBarbersSection> createState() => _FeaturedBarbersSectionState();
}

class _FeaturedBarbersSectionState extends State<FeaturedBarbersSection> {
  @override
  void initState() {
    super.initState();
    // Data đã được fetch trong HomeViewModel, không cần fetch lại
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    if (viewModel.isLoading && viewModel.topBarbers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && viewModel.topBarbers.isEmpty) {
      return Column(
        children: [
          Text("Barber nổi bật", style: AppTextStyles.heading),
          const SizedBox(height: 16),
          Text(
            viewModel.error!,
            style: const TextStyle(color: Colors.red),
          ),
          ElevatedButton(
            onPressed: () => viewModel.fetchTopBarbers(),
            child: const Text('Thử lại'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Barber nổi bật", style: AppTextStyles.heading),
            if (viewModel.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (viewModel.topBarbers.isEmpty)
          const Center(
            child: Text('Không có barber nào'),
          )
        else
          Column(
            children: viewModel.topBarbers.map((barber) {
              // Sử dụng đúng property từ BarberModel
              return Column(
                children: [
                  const SizedBox(height: 16),
                  CardShop(
                    id: barber.id,
                    imagePath: barber.imagePath ?? 'assets/images/default_barber.jpg',
                    name: barber.name,
                    location: [
                      barber.area,
                      barber.address,
                    ].where((e) => e != null && e!.isNotEmpty)
                        .join(' - ')
                        .isNotEmpty
                        ? [
                      barber.area,
                      barber.address,
                    ].where((e) => e != null && e!.isNotEmpty).join(' - ')
                        : 'Địa chỉ không xác định',
                    rank: barber.rank ?? 0.0,
                  ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }
}