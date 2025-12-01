import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:barbergofe/views/home/widgets/Card_shop.dart';
import 'package:flutter/material.dart';

class Featuredbarberssection extends StatelessWidget {
  const Featuredbarberssection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Barber nổi bật", style: AppTextStyles.heading,),
        CardShop(
          name: "Barber 1",
          location: "Hà Nội",
          rank: 4.5,
          imagePath: "assets/images/logos/logoIntro.png",
        ),
        const SizedBox(height: 24,),
        CardShop(
          name: "Barber 1",
          location: "HCM",
          rank: 4.7,
          imagePath: "assets/images/logos/logoIntro.png",
        ),
        const SizedBox(height: 24,),
        CardShop(
          name: "Barber 1",
          location: "HCM",
          rank: 4.7,
          imagePath: "assets/images/logos/logoIntro.png",
        ),
      ],
    );
  }
}
