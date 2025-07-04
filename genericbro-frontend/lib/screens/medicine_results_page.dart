import 'package:flutter/material.dart';
import '../models/medicine.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

class MedicineResultsPage extends StatelessWidget {
  final List<Medicine> medicines;
  final Medicine? exactMatch;
  final String? uses;
  final String? sideEffects;
  final String searchCriteria;

  const MedicineResultsPage({
    super.key,
    required this.medicines,
    this.exactMatch,
    this.uses,
    this.sideEffects,
    required this.searchCriteria,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: const Color(0xFF02899D),
      ),
      body: Column(
        children: [
          // Search criteria summary
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE1F5F8),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF02899D)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Results for: $searchCriteria',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                Text(
                  '${medicines.length} found',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          
          // Results list
          Expanded(
            child: medicines.isEmpty
                ? const Center(
                    child: Text(
                      'No medicines found matching your criteria',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF718096),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = medicines[index];
                      final isExactMatch = medicine == exactMatch;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: isExactMatch ? 4 : 2,
                        child: Container(
                          decoration: BoxDecoration(
                            border: isExactMatch
                                ? Border.all(color: const Color(0xFF02899D), width: 2)
                                : null,
                          ),
                          child: ExpansionTile(
                            title: Text(
                              medicine.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicine.formulation,
                                  style: const TextStyle(color: Color(0xFF718096)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Type: ${medicine.type}',
                                  style: const TextStyle(color: Color(0xFF718096)),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPriceComparison(medicine),
                                    if (isExactMatch && uses != null) ...[
                                      const SizedBox(height: 16),
                                      _buildInfoSection('Uses', uses!),
                                    ],
                                    if (isExactMatch && sideEffects != null) ...[
                                      const SizedBox(height: 16),
                                      _buildInfoSection('Side Effects', sideEffects!),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceComparison(Medicine medicine) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
      locale: 'en_IN',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Branded Price:',
                style: TextStyle(color: Color(0xFF718096)),
              ),
              Text(
                currencyFormat.format(medicine.costOfBranded),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Generic Price:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02899D),
                ),
              ),
              Text(
                currencyFormat.format(medicine.costOfGeneric),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF02899D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'You Save:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                '${(medicine.savings ?? 0.0).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }
} 