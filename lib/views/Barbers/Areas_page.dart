import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
import 'package:barbergofe/views/Barbers/widgets/Barber_AreaChip.dart';
import 'package:barbergofe/views/Barbers/widgets/Barber_search_area.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AreasPage extends StatefulWidget {
  const AreasPage({super.key});

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BarberViewModel>().fetchAreas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BarberViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Chọn tiệm cắt tóc"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                const BarberSearch(),
                const SizedBox(height: 16),

                // Loading indicator
                if (vm.isLoading)
                  const Center(child: CircularProgressIndicator())

                // Error message
                else if (vm.error != null)
                  Center(
                    child: Text(
                      'Lỗi: ${vm.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )

                //  DÙNG filteredAreas thay vì areas
                else if (vm.fillteredAreas.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('Không tìm thấy kết quả'),
                      ),
                    )

                  else
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: vm.fillteredAreas.map((area) {
                            return BarberAreachip(
                              onTap: () {
                                context.pushNamed('Barbers', extra: area);
                              },
                              title: area,
                            );
                          }).toList(),
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