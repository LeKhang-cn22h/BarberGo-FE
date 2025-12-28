// lib/views/barbers/barbers_page.dart
import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
import 'package:barbergofe/viewmodels/service/service_viewmodel.dart';
import 'package:barbergofe/views/Barbers/widgets/Barber_card.dart';
import 'package:barbergofe/views/Barbers/widgets/Barber_search.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BarbersPage extends StatefulWidget {
  final String area;
  const BarbersPage({super.key, required this.area});

  @override
  State<BarbersPage> createState() => _BarbersPageState();
}

class _BarbersPageState extends State<BarbersPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  ///  Load barbers và price ranges
  Future<void> _loadData() async {
    final barberVM = context.read<BarberViewModel>();
    final serviceVM = context.read<ServiceViewModel>();

    // 1. Fetch barbers
    await barberVM.fetchBarbersByArea(widget.area);

    // 2. Fetch price ranges cho tất cả barbers
    final barberIds = barberVM.areaBarbers.map((b) => b.id.toString()).toList();
    if (barberIds.isNotEmpty) {
      await serviceVM.fetchPriceRangesForBarbers(barberIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BarberViewModel, ServiceViewModel>(
      builder: (context, barberVM, serviceVM, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Chọn tiệm cắt tóc"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const BarberSearchfil(),
                const SizedBox(height: 16),

                // ===== LOADING =====
                if (barberVM.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )

                // ===== ERROR =====
                else if (barberVM.error != null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            "Lỗi: ${barberVM.error}",
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: Icon(Icons.refresh),
                            label: Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )

                // ===== EMPTY =====
                else if (barberVM.filteredBarberAreas.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text("Không tìm thấy kết quả"),
                      ),
                    )

                  // ===== BARBER LIST =====
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.separated(
                          itemCount: barberVM.filteredBarberAreas.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final barber = barberVM.filteredBarberAreas[index];
                            final barberId = barber.id.toString();

                            return BarberCard(
                              id: barberId,
                              imagePath: barber.imagePath,
                              name: barber.name,
                              // location: barber.location,
                              area: barber.area,
                              address: barber.address,
                              rank: barber.rank,
                              // Lấy price range từ cache
                              priceRange: serviceVM.getFormattedPriceRange(barberId),
                              onTap: () =>context.goNamed('detail', pathParameters: {'id': barberId})
                              ,
                            );
                          },
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}