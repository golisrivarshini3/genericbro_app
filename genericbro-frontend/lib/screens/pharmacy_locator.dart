import 'package:flutter/material.dart';

class PharmacyLocator extends StatefulWidget {
  const PharmacyLocator({super.key});

  @override
  State<PharmacyLocator> createState() => _PharmacyLocatorState();
}

class _PharmacyLocatorState extends State<PharmacyLocator> {
  final _pinController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  String _pharmacyType = 'All';
  bool _useGPS = false;

  @override
  void dispose() {
    _pinController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pharmacy Locator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PHARMACY\nLOCATOR',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D40),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Choose your location',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // PIN Code Input
            const Text(
              'Enter 6-digit PIN code',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'PIN code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              '...or type an area / locality',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _areaController,
              decoration: InputDecoration(
                hintText: 'Area / Locality',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              '...or start typing a city',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Pharmacy Type
            const Text(
              'Pharmacy type',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRadioOption('All', 'All'),
                const SizedBox(width: 20),
                _buildRadioOption('Chain only', 'Chain'),
                const SizedBox(width: 20),
                _buildRadioOption('Local only', 'Local'),
              ],
            ),

            const SizedBox(height: 24),
            // GPS Option
            GestureDetector(
              onTap: () {
                setState(() {
                  _useGPS = !_useGPS;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _useGPS ? Colors.teal : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: _useGPS
                        ? Container(
                            margin: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.teal,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Row(
                    children: [
                      Icon(Icons.gps_fixed, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Use GPS',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Search radius (km)',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _pharmacyType = value;
        });
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _pharmacyType == value ? Colors.teal : Colors.grey,
                width: 2,
              ),
            ),
            child: _pharmacyType == value
                ? Container(
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.teal,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
} 