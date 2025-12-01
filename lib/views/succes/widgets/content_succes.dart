import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class ContentSucces extends StatelessWidget {
  const ContentSucces({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Hình chữ nhật trắng
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
        ),

        // Hình chữ nhật xanh ở trên cùng sát viền
        Positioned(
          top: 0,
          child: Container(
            width: 320,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(40),
                bottom: Radius.circular(40),
              ),
            ),
          ),
        ),

        // Icon check tròn ở giữa
        Container(
          width: 135,
          height: 135,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline_outlined,
            color: Colors.green,
            size: 130,
          ),
        ),
        Positioned(
            top: 250,
            left: 0,
            right: 0,
            child:
        (Text("ĐỔI MẬT KHẨU THÀNH CÔNG",
        textAlign: TextAlign.center,
        style: TextStyle(

          fontSize: 20,
          fontWeight: FontWeight.bold
        ),)))
      ],
    );
  }
}