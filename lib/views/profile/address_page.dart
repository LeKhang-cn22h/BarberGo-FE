import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  // ==================== PICK LOCATION ====================

  Future<void> _pickLocation() async {
    final result = await context.pushNamed('location_picker');

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _selectedAddress = result['address'];
      });

      print(' Location selected:');
      print('   Address: $_selectedAddress');
      print('   Lat: $_latitude, Lng: $_longitude');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD4B5B5),
      appBar: AppBar(
        backgroundColor: Color(0xFF5B4B8A),
        title: Text('Địa chỉ', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display selected address
            if (_selectedAddress != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF5B4B8A)),
                          SizedBox(width: 8),
                          Text(
                            'Địa chỉ đã chọn:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(_selectedAddress!),
                      SizedBox(height: 4),
                      Text(
                        'Tọa độ: $_latitude, $_longitude',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 16),

            // Pick location button
            ElevatedButton.icon(
              onPressed: _pickLocation,
              icon: Icon(Icons.map),
              label: Text('Chọn vị trí trên bản đồ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B4B8A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}