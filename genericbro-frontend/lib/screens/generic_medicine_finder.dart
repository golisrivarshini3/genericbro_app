import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/medicine.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:developer' as developer;

// Define theme colors
const Color primaryColor = Color(0xFF02899D);
const Color primaryLightColor = Color(0xFF03A7C0);
const Color primaryVeryLightColor = Color(0xFFE1F5F8);
const Color textColor = Color(0xFF2D3748);
const Color subtitleColor = Color(0xFF718096);

enum SearchMode {
  name,
  formulation,
}

enum PriceSort {
  none,
  lowToHigh,
  highToLow,
}

extension PriceSortExtension on PriceSort {
  String get apiValue {
    switch (this) {
      case PriceSort.lowToHigh:
        return 'low_to_high';
      case PriceSort.highToLow:
        return 'high_to_low';
      case PriceSort.none:
        return 'none';
    }
  }
}

class GenericMedicineFinder extends StatefulWidget {
  const GenericMedicineFinder({super.key});

  @override
  State<GenericMedicineFinder> createState() => _GenericMedicineFinderState();
}

class _GenericMedicineFinderState extends State<GenericMedicineFinder>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  List<String> typeOptions = [];
  List<String> dosageOptions = [];
  Medicine? exactMatch;
  List<Medicine> similarFormulations = [];
  bool isLoading = false;
  String? errorMessage;
  String? uses;
  String? sideEffects;
  Timer? _debounceTimer;
  bool _isInitialized = false;
  PriceSort _selectedPriceSort = PriceSort.none;
  SearchMode _searchMode = SearchMode.name;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _handleSearchModeChange(SearchMode mode) {
    if (mode != _searchMode) {
      setState(() {
        _searchMode = mode;
        _searchController.clear();
        _typeController.clear();
        _dosageController.clear();
        exactMatch = null;
        similarFormulations = [];
        uses = null;
        sideEffects = null;
        errorMessage = null;
      });
    }
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final types = await ApiService.fetchSuggestions('Type', '');
      final dosages = await ApiService.fetchSuggestions('Dosage', '');

      if (mounted) {
        setState(() {
          typeOptions = types;
          dosageOptions = dosages;
          isLoading = false;
          _isInitialized = true;
        });
      }
    } catch (e) {
      developer.log('Error loading initial data', error: e);
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load initial data. Please try again.';
          isLoading = false;
        });
      }
    }
  }

  Future<List<String>> _getSuggestions(String pattern, String field) async {
    if (pattern.isEmpty) {
      return field == 'Type' ? typeOptions : field == 'Dosage' ? dosageOptions : [];
    }

    try {
      final suggestions = await ApiService.fetchSuggestions(field, pattern);
      developer.log('Got suggestions for $field', error: {'pattern': pattern, 'suggestions': suggestions});
      return suggestions;
    } catch (e) {
      developer.log('Error getting suggestions', error: {'field': field, 'pattern': pattern, 'error': e});
      return [];
    }
  }

  List<Medicine> _sortMedicines(List<Medicine> medicines) {
    if (_selectedPriceSort == PriceSort.none) return medicines;

    final sortedList = List<Medicine>.from(medicines);
    sortedList.sort((a, b) {
      // Use generic price for sorting
      final priceA = a.costOfGeneric;
      final priceB = b.costOfGeneric;
      
      if (_selectedPriceSort == PriceSort.lowToHigh) {
        return priceA.compareTo(priceB);
      } else {
        return priceB.compareTo(priceA);
      }
    });
    return sortedList;
  }

  Future<void> _searchMedicines() async {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Validate input
    if (_searchController.text.isEmpty && 
        _typeController.text.isEmpty && 
        _dosageController.text.isEmpty) {
      setState(() {
        errorMessage = _searchMode == SearchMode.name
            ? 'Please enter a medicine name, type, or dosage'
            : 'Please enter a formulation, type, or dosage';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      exactMatch = null;
      similarFormulations = [];
      uses = null;
      sideEffects = null;
    });

    try {
      // If only type is provided, use the dedicated type endpoint
      if (_typeController.text.isNotEmpty &&
          _searchController.text.isEmpty &&
          _dosageController.text.isEmpty) {
        developer.log('Using dedicated type endpoint', error: {
          'type': _typeController.text,
          'sort_order': _selectedPriceSort.apiValue
        });
        
        final medicines = await ApiService.getMedicinesByType(
          _typeController.text,
          sortOrder: _selectedPriceSort.apiValue
        );
        
        if (mounted) {
          setState(() {
            isLoading = false;
            similarFormulations = medicines;
            // For type searches, show uses and side effects of the first medicine if available
            if (medicines.isNotEmpty) {
              uses = medicines[0].uses;
              sideEffects = medicines[0].sideEffects;
            }
          });
        }
        return;
      }

      // Otherwise, use the regular search endpoint
      final searchParams = {
        'name': _searchMode == SearchMode.name ? _searchController.text : null,
        'formulation': _searchMode == SearchMode.formulation ? _searchController.text : null,
        'type': _typeController.text,
        'dosage': _dosageController.text,
      };
      
      developer.log('Searching medicines with params', error: searchParams);

      final searchResult = await ApiService.searchMedicines(
        name: searchParams['name'],
        formulation: searchParams['formulation'],
        type: searchParams['type'],
        dosage: searchParams['dosage'],
        sortOrder: _selectedPriceSort.apiValue,
      );

      developer.log('Search result', error: {
        'exact_match': searchResult['exact_match'],
        'similar_count': (searchResult['similar_formulations'] as List).length,
      });

      if (mounted) {
        setState(() {
          exactMatch = searchResult['exact_match'] as Medicine?;
          similarFormulations = List<Medicine>.from(searchResult['similar_formulations']);
          uses = searchResult['Uses'] as String?;
          sideEffects = searchResult['Side Effects'] as String?;
          isLoading = false;
          
          if (exactMatch == null && similarFormulations.isEmpty) {
            errorMessage = 'No medicines found matching your criteria';
          }
        });
      }
    } catch (e) {
      developer.log('Error searching medicines', error: e);
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to search medicines. Please try again.';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _typeController.dispose();
    _dosageController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: subtitleColor),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildClearButton(TextEditingController controller) {
    return controller.text.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              controller.clear();
              _searchMedicines();
            },
          )
        : const SizedBox.shrink();
  }

  String _cleanTypeValue(String type) {
    // Remove the prefix letter and hyphen, and clean up spaces
    if (type.contains('-')) {
      final parts = type.split('-');
      if (parts.length > 1) {
        return parts.sublist(1).join('-').trim();
      }
    }
    return type.trim();
  }

  Widget _buildTypeField(double width) {
    return SizedBox(
      width: width,
      child: TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _typeController,
          decoration: _buildInputDecoration(
            'Medicine Type',
            Icons.category,
            suffix: _buildClearButton(_typeController),
          ),
        ),
        suggestionsCallback: (pattern) async {
          final suggestions = await _getSuggestions(pattern, 'Type');
          // Sort suggestions by the cleaned type name
          suggestions.sort((a, b) => _cleanTypeValue(a).compareTo(_cleanTypeValue(b)));
          return suggestions;
        },
        itemBuilder: (context, String suggestion) {
          final cleanedType = _cleanTypeValue(suggestion);
          return ListTile(
            title: Text(
              cleanedType,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              suggestion,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
          );
        },
        onSuggestionSelected: (String suggestion) {
          _typeController.text = suggestion;
          _searchMedicines();
        },
        noItemsFoundBuilder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No medicine types found',
            style: TextStyle(color: subtitleColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchModeToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Search by Name',
              isSelected: _searchMode == SearchMode.name,
              onTap: () => _handleSearchModeChange(SearchMode.name),
              icon: Icons.medication,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: primaryColor.withOpacity(0.2),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Search by Formulation',
              isSelected: _searchMode == SearchMode.formulation,
              onTap: () => _handleSearchModeChange(SearchMode.formulation),
              icon: Icons.science,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine, {bool isExactMatch = false}) {
    // Calculate savings percentage
    double savingsPercentage = ((medicine.costOfBranded - medicine.costOfGeneric) / medicine.costOfBranded) * 100;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isExactMatch ? 4 : 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isExactMatch
              ? Border.all(color: primaryColor, width: 2)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isExactMatch)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Exact Match',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              medicine.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Formulation: ${medicine.formulation}'),
            Text('Type: ${medicine.type}'),
            Text('Dosage: ${medicine.dosage}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryVeryLightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Branded Cost',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${medicine.costOfBranded.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Generic Cost',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${medicine.costOfGeneric.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Savings',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${savingsPercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (medicine.uses.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Uses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(medicine.uses),
            ],
            if (medicine.sideEffects.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Side Effects',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(medicine.sideEffects),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortingDropdown() {
    return DropdownButtonFormField<PriceSort>(
      value: _selectedPriceSort,
      decoration: InputDecoration(
        labelText: 'Sort by Branded Price',
        labelStyle: const TextStyle(color: textColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem(
          value: PriceSort.none,
          child: Text('No sorting', style: TextStyle(color: textColor)),
        ),
        DropdownMenuItem(
          value: PriceSort.lowToHigh,
          child: Text('Price: Low to High', style: TextStyle(color: textColor)),
        ),
        DropdownMenuItem(
          value: PriceSort.highToLow,
          child: Text('Price: High to Low', style: TextStyle(color: textColor)),
        ),
      ],
      onChanged: (PriceSort? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedPriceSort = newValue;
          });
          _searchMedicines();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final contentWidth = isLargeScreen
        ? ResponsiveUtils.getScreenWidth(context) * 0.8
        : ResponsiveUtils.getScreenWidth(context);

    final fieldWidth = isLargeScreen
        ? (contentWidth - padding.horizontal - 16) / 2
        : contentWidth - padding.horizontal;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generic Medicine Finder',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: contentWidth,
            padding: padding,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Mode Toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: SegmentedButton<SearchMode>(
                      segments: const [
                        ButtonSegment(
                          value: SearchMode.name,
                          label: Text('Search by Name'),
                        ),
                        ButtonSegment(
                          value: SearchMode.formulation,
                          label: Text('Search by Formulation'),
                        ),
                      ],
                      selected: {_searchMode},
                      onSelectionChanged: (Set<SearchMode> newSelection) {
                        _handleSearchModeChange(newSelection.first);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(MaterialState.selected)) {
                              return primaryColor;
                            }
                            return Colors.white;
                          },
                        ),
                      ),
                    ),
                  ),

                  // Search Fields
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: isLargeScreen
                            ? (contentWidth - padding.horizontal - 16) / 2
                            : contentWidth - padding.horizontal,
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _searchController,
                            decoration: _buildInputDecoration(
                              _searchMode == SearchMode.name
                                  ? 'Medicine Name'
                                  : 'Formulation',
                              Icons.search,
                              suffix: _buildClearButton(_searchController),
                            ),
                          ),
                          suggestionsCallback: (pattern) => _getSuggestions(
                            pattern,
                            _searchMode == SearchMode.name ? 'Name' : 'Formulation',
                          ),
                          itemBuilder: (context, String suggestion) {
                            return ListTile(title: Text(suggestion));
                          },
                          onSuggestionSelected: (String suggestion) {
                            _searchController.text = suggestion;
                            _searchMedicines();
                          },
                        ),
                      ),
                      _buildTypeField(fieldWidth),
                      SizedBox(
                        width: isLargeScreen
                            ? (contentWidth - padding.horizontal - 16) / 2
                            : contentWidth - padding.horizontal,
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _dosageController,
                            decoration: _buildInputDecoration(
                              'Dosage',
                              Icons.medical_information,
                              suffix: _buildClearButton(_dosageController),
                            ),
                          ),
                          suggestionsCallback: (pattern) =>
                              _getSuggestions(pattern, 'Dosage'),
                          itemBuilder: (context, String suggestion) {
                            return ListTile(title: Text(suggestion));
                          },
                          onSuggestionSelected: (String suggestion) {
                            _dosageController.text = suggestion;
                            _searchMedicines();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_searchController.text.isEmpty && 
                            _typeController.text.isEmpty && 
                            _dosageController.text.isEmpty) {
                          setState(() {
                            errorMessage = _searchMode == SearchMode.name
                                ? 'Please enter a medicine name, type, or dosage'
                                : 'Please enter a formulation, type, or dosage';
                          });
                          return;
                        }
                        _searchMedicines();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sort Options
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildSortingDropdown(),
                  ),

                  // Loading and Error States
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Results
                  if (exactMatch != null) ...[
                    const SizedBox(height: 16),
                    _buildMedicineCard(exactMatch!, isExactMatch: true),
                  ],

                  if (similarFormulations.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Similar Medicines',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...similarFormulations.map((medicine) =>
                        _buildMedicineCard(medicine)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 