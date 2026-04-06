import 'package:flutter/material.dart';
import 'package:barbergofe/models/hair/hairstyle_model.dart';

class StyleGridView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<HairStyleInfo> styles;
  final String? selectedStyleId;
  final Function(String) onStyleSelected;

  const StyleGridView({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.styles,
    required this.selectedStyleId,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
      );
    }

    if (styles.isEmpty) {
      return Center(
        child: Text('No styles available', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.0,
      ),
      itemCount: styles.length,
      itemBuilder: (context, index) {
        final style = styles[index];
        final isSelected = selectedStyleId == style.id;

        return _buildStyleButton(style, isSelected);
      },
    );
  }

  Widget _buildStyleButton(HairStyleInfo style, bool isSelected) {
    return Container(
      margin: EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () => onStyleSelected(style.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue[700] : Colors.blue[400],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Colors.yellow : Colors.transparent,
              width: 2,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
        child: Text(
          style.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}