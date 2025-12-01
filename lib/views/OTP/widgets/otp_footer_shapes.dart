import 'package:barbergofe/core/constants/color.dart';
import 'package:flutter/material.dart';

class OtpFooterShapes extends StatelessWidget {
  const OtpFooterShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
              bottom: -170,
              left: -50,
              child:
              Container(
                width: 560,
                height: 410,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              )),
          Positioned(
            left: -90,
            bottom: 10,
            child:
                Transform.rotate(angle: 0.7853981633974483,
            child:
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Color(0xFF77E0D9),
                borderRadius: BorderRadius.circular(20),
              ),
            )
          )
          ),
          // Hình tròn lớn
          Positioned(
            right: -100,
            bottom: 10,
            child:
          Container(
            width: 275,
            height: 275,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0B64FF),
            ),
          ),),

          // Hình tròn màu khác


        ],
      ),
    );
  }
}


