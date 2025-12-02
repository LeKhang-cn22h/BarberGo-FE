import 'package:flutter/material.dart';

class BarberInfo extends StatelessWidget {
  final String name;
  final String location;
  final double rank;
  final String imagePath;
  const BarberInfo({super.key, required this.name, required this.imagePath, required this.location, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 336,
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.store),
                        const SizedBox(width: 4),
                        Text(name)
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_pin),
                        const SizedBox(width: 4),
                        Text(location)
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF3B51C)),
                        const SizedBox(width: 4,),
                        Text(rank.toString(), style: const TextStyle(fontWeight: FontWeight.bold),)
                      ],
                    )

                  ],
                ),
              ),

              Transform.translate(offset: const Offset(0, -20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(imagePath,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  )
              )
            ],
          ),
        )
      ],
    );
  }
}