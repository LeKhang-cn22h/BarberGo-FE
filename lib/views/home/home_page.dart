import 'package:barbergofe/views/home/widgets/FeaturedBarbersSection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/views/home/widgets/AI_section.dart';
import 'package:barbergofe/viewmodels/home/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    await homeViewModel.initializeHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await homeViewModel.refreshHomeData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const AiSection(),
                  const SizedBox(height: 32),
                  // Truyền viewModel từ HomeViewModel xuống FeaturedBarbersSection
                  FeaturedBarbersSection(
                    viewModel: homeViewModel.barberViewModel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}