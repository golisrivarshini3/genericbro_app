import 'package:flutter/material.dart';
import 'generic_medicine_finder.dart';
import 'pharmacy_locator.dart';
import '../utils/responsive_utils.dart';

const Color primaryColor = Color(0xFF02899D);
const Color primaryLightColor = Color(0xFF03A7C0);
const Color buttonBackgroundColor = Color(0xFFE1F5F8);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildButton(BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: ResponsiveUtils.getResponsiveButtonWidth(context),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          foregroundColor: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF1A1A1A),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Swecha Logo
                Image.asset(
                  'Swecha_Logo_English.png',
                  width: ResponsiveUtils.getResponsiveImageSize(context),
                  color: Colors.white,
                ),
                const SizedBox(height: 40),
                // Generic Medicine Finder Button
                _buildButton(
                  context,
                  text: 'Generic Medicine Finder',
                  icon: Icons.medication,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GenericMedicineFinder()),
                  ),
                ),
                // Pharmacy Locator Button
                _buildButton(
                  context,
                  text: 'Pharmacy Locator',
                  icon: Icons.location_on,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PharmacyLocator()),
                  ),
                ),
                // Prescription Reader Button
                _buildButton(
                  context,
                  text: 'Prescription Reader',
                  icon: Icons.description,
                  onPressed: () {
                    // TODO: Implement Prescription Reader
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prescription Reader coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 