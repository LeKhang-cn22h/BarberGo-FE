import 'package:barbergofe/viewmodels/barber/barber_viewmodel.dart';
import 'package:barbergofe/views/Barbers/widgets/Barber_AreaChip.dart';
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
  void initState(){
    super.initState();
    context.read<BarberViewModel>().fetchAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BarberViewModel>(builder: (context,vm,_){
      return Scaffold(
        appBar:AppBar(title: Text("Chọn tiệm cắt tóc"),
        centerTitle: true,
        ),
          body: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: vm.areas.map((area){
          return BarberAreachip(onTap: (){
            context.pushNamed('Barbers',extra: area);
            }, title: area);
        }).toList()
      )
      );
    });
  }
}
