import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarberSearchfil extends StatefulWidget {
  const BarberSearchfil({super.key});

  @override
  State<BarberSearchfil> createState() => _BarberSearchfilState();
}

class _BarberSearchfilState extends State<BarberSearchfil> {
  final TextEditingController _searchController=TextEditingController();
  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
  }
  void _performSearch(){
    final vm=context.read<BarberViewModel>();
    vm.onBarberSearch(_searchController.text.trim());
  }
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,vm,_){
      return TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm barber',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
            ?IconButton(icon: const Icon(Icons.clear),
                  onPressed:(){
                    _searchController.clear();
                  }
          ):null,
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12)
           )
        ),
        onSubmitted: (value){
          _performSearch();
        },
      );
    });
  }
}
