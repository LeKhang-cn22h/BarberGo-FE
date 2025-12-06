import 'dart:io';
import 'dart:typed_data';
import 'package:barbergofe/models/hair/hairstyle_model.dart';
import 'package:barbergofe/models/hair/hairstyle_repository.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

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
      setState(() {
        _isLoadingStyles = false;
      });
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

  Widget _buildStyleButtons() {
    if (_isLoadingStyles) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
      );
    }

    if (_styles.isEmpty) {
      return Center(
        child: Text('No styles available', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.0, // Tỉ lệ cho button chỉ có text
      ),
      itemCount: _styles.length,
      itemBuilder: (context, index) {
        final style = _styles[index];
        final isSelected = _selectedStyleId == style.id;

        return _buildStyleButton(style, isSelected);
      },
    );
  }

  Widget _buildStyleButton(HairStyleInfo style, bool isSelected) {
    return Container(
      margin: EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selectedStyleId = style.id);
        },
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

  Widget _buildSimpleStyleButtons() {
    if (_isLoadingStyles) {
      return Center(child: CircularProgressIndicator());
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _styles.map((style) {
        final isSelected = _selectedStyleId == style.id;

        return ChoiceChip(
          label: Text(style.name),
          selected: isSelected,
          selectedColor: Colors.blue,
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          onSelected: (selected) {
            setState(() => _selectedStyleId = style.id);
          },
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      }).toList(),
    );
  }

  Widget _buildVerticalList() {
    if (_isLoadingStyles) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
      );
    }

    if (_styles.isEmpty) {
      return Center(
        child: Text('No styles available', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: _styles.length,
      itemBuilder: (context, index) {
        final style = _styles[index];
        final isSelected = _selectedStyleId == style.id;

        return Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ElevatedButton(
            onPressed: () {
              setState(() => _selectedStyleId = style.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? Colors.blue[700] : Colors.white,
              foregroundColor: isSelected ? Colors.white : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? Colors.yellow : Colors.blue,
                  width: isSelected ? 2 : 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: Text(
              style.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(widget.capturedImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ảnh của bạn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),



            // // Title for styles
            // Text(
            //   'Men\'s Hair Styles',
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.blue[800],
            //   ),
            // ),
            // SizedBox(height: 8),
            // Text(
            //   'Tap to select a style',
            //   style: TextStyle(
            //     fontSize: 12,
            //     color: Colors.grey[600],
            //   ),
            // ),

            SizedBox(height: 12),

            // Style buttons - Chọn 1 trong 3 cách
            Expanded(
              child: _buildStyleButtons(), // Cách 1: Grid buttons
              // child: _buildSimpleStyleButtons(), // Cách 2: Wrap chips
              // child: _buildVerticalList(), // Cách 3: Vertical list
            ),

            SizedBox(height: 16),

            // Selected style info
            if (_selectedStyleId != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Chọn: ${_styles.firstWhere((s) => s.id == _selectedStyleId).name}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
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