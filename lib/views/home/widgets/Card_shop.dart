import 'package:barbergofe/core/constants/color.dart';
import 'package:flutter/material.dart';

class CardShop extends StatelessWidget {
  final String name;
  final String location;
  final double rank;
  final String imagePath;

  const CardShop({
    super.key,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 336,
          height: 150,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 20,
                offset: Offset( 0, 1.0), // Shadow position
              )
            ]
          ),
          child: Row(
            children: [
              // LEFT SIDE
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.store),
                        const SizedBox(width: 4),
                        Text(name),
                      ]),
                      Row(children: [
                        const Icon(Icons.location_pin),
                        const SizedBox(width: 4),
                        Text(location),
                      ]),
                      Row(children: [
                        const Icon(Icons.star, color: Color(0xFFF3B51C)),
                        const SizedBox(width: 4),
                        Text(rank.toString(), style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),),
                      ]),
                      TextButton(onPressed: (){}, child: Text("Xem chi tiết"), style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimaryLight,

                      ),)
                    ],
                  ),
                ),
              ),

              // RIGHT SIDE IMAGE (nhô lên)
              Transform.translate(
                offset: const Offset(0, -20), // ảnh nhô lên 20px
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
