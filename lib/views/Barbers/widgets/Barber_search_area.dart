import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';

class BarberSearch extends StatefulWidget {
  const BarberSearch({super.key});

  @override
  State<BarberSearch> createState() => _BarberSearchState();
}

class _BarberSearchState extends State<BarberSearch> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final vm = context.read<BarberViewModel>();
    vm.onAreaSearch(_searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BarberViewModel>(
      builder: (context, vm, _) {
        return TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm tỉnh thành',
            prefixIcon: const Icon(Icons.search),

            // THÊM nút clear
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                vm.onAreaSearch(''); // Clear search
              },
            )
                : null,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Search khi nhấn Enter
          onSubmitted: (value) {
            _performSearch();
          },
        );
      },
    );
  }
}