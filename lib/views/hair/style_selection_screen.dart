import 'dart:io';
import 'package:barbergofe/models/hair/hairstyle_model.dart';
import 'package:barbergofe/models/hair/hairstyle_repository.dart';
import 'package:barbergofe/views/hair/%20widgets/style/style_grid_view.dart';
import 'package:barbergofe/views/hair/%20widgets/style/style_image_preview.dart';
import 'package:barbergofe/views/hair/%20widgets/style/style_selected_info.dart';
import 'package:flutter/material.dart';

import 'result_screen.dart';

class StyleSelectionScreen extends StatefulWidget {
  final File capturedImage;

  StyleSelectionScreen({required this.capturedImage});

  @override
  _StyleSelectionScreenState createState() => _StyleSelectionScreenState();
}

class _StyleSelectionScreenState extends State<StyleSelectionScreen> {
  String? _selectedStyleId;
  int _steps = 30;
  double _denoisingStrength = 0.35;
  bool _isLoading = false;
  bool _isLoadingStyles = true;
  List<HairStyleInfo> _styles = [];
  String? _errorMessage;

  final HairStyleRepository _repository = HairStyleRepository();

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  Future<void> _loadStyles() async {
    try {
      List<HairStyleInfo> allStyles = await _repository.getAvailableStyles();

      _styles = allStyles.where((style) {
        String gender = style.gender.toLowerCase();
        String name = style.name.toLowerCase();

        bool isMaleStyle = gender.contains('male') ||
            gender.contains('unisex') ||
            gender.contains('man') ||
            !gender.contains('female');

        bool isNotFemaleStyle = !name.contains('bob') &&
            !name.contains('pixie') &&
            !name.contains('long') &&
            !name.contains('feminine');

        return isMaleStyle && isNotFemaleStyle;
      }).toList();

      if (_styles.isEmpty) {
        _styles = _getDefaultMaleStyles();
      }
    } catch (e) {
      _errorMessage = 'Failed to load styles: $e';
      _styles = _getDefaultMaleStyles();
    } finally {
      setState(() => _isLoadingStyles = false);
    }
  }

  List<HairStyleInfo> _getDefaultMaleStyles() {
    return [
      HairStyleInfo(
        id: 'short_crop',
        name: 'Short Crop',
        description: '',
        gender: 'male',
        category: 'short',
      ),
      HairStyleInfo(
        id: 'undercut',
        name: 'Undercut',
        description: '',
        gender: 'male',
        category: 'short',
      ),
      HairStyleInfo(
        id: 'crew_cut',
        name: 'Crew Cut',
        description: '',
        gender: 'male',
        category: 'short',
      ),
      HairStyleInfo(
        id: 'fade',
        name: 'Fade',
        description: '',
        gender: 'male',
        category: 'short',
      ),
      HairStyleInfo(
        id: 'pompadour',
        name: 'Pompadour',
        description: '',
        gender: 'male',
        category: 'medium',
      ),
      HairStyleInfo(
        id: 'quiff',
        name: 'Quiff',
        description: '',
        gender: 'male',
        category: 'medium',
      ),
    ];
  }

  Future<void> _generateHairStyle() async {
    if (_selectedStyleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn kiểu tóc')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _repository.generateHairStyle(
        imageFile: widget.capturedImage,
        style: _selectedStyleId!,
        steps: _steps,
        denoisingStrength: _denoisingStrength,
        returnMask: false,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            originalImage: widget.capturedImage,
            resultImage: result,
            styleName: _styles.firstWhere((s) => s.id == _selectedStyleId).name,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn kiểu tóc'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original image preview
            StyleImagePreview(image: widget.capturedImage),
            SizedBox(height: 12),

            // Style grid
            Expanded(
              child: StyleGridView(
                isLoading: _isLoadingStyles,
                errorMessage: _errorMessage,
                styles: _styles,
                selectedStyleId: _selectedStyleId,
                onStyleSelected: (styleId) {
                  setState(() => _selectedStyleId = styleId);
                },
              ),
            ),

            SizedBox(height: 16),

            // Selected style info
            if (_selectedStyleId != null)
              StyleSelectedInfo(
                styleName: _styles.firstWhere((s) => s.id == _selectedStyleId).name,
              ),

            SizedBox(height: 16),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateHairStyle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : Text(
                  'Tạo kiểu tóc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 8),

            // Back button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Chụp ảnh khác',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}