import 'package:barbergofe/viewmodels/owner_home/owner_home_viewmodel.dart';
import 'package:barbergofe/views/ownerHome/widgets/owner_header_card.dart';
import 'package:barbergofe/views/ownerHome/widgets/schedule_list.dart';
import 'package:barbergofe/views/ownerHome/widgets/stats_row.dart';
import 'package:barbergofe/views/ownerHome/widgets/upcoming_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerHomeViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OwnerHomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.todayTimeSlots.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.initialize(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header với toggle
                  OwnerHeaderCard(viewModel: viewModel),

                  const SizedBox(height: 16),

                  // 3 stats cards
                  StatsRow(viewModel: viewModel),

                  const SizedBox(height: 24),

                  // Upcoming section
                  UpcomingSection(viewModel: viewModel),

                  const SizedBox(height: 24),

                  // Schedule header
                  const Text(
                    'Lịch trình hôm nay',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Schedule list
                  ScheduleList(viewModel: viewModel),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}