import 'dart:developer' as developer;

class Medicine {
  final String name;
  final String dosage;
  final String formulation;
  final double costOfBranded;
  final double costOfGeneric;
  final double? costDifference;
  final double? savings;
  final String type;
  final String uses;
  final String sideEffects;

  Medicine({
    required this.name,
    required this.dosage,
    required this.formulation,
    required this.costOfBranded,
    required this.costOfGeneric,
    this.costDifference,
    this.savings,
    required this.type,
    required this.uses,
    required this.sideEffects,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    try {
      if (value is num) return value.toDouble();
      if (value is String) return double.parse(value);
      return null;
    } catch (e) {
      developer.log('Error parsing double', error: {'value': value, 'error': e});
      return null;
    }
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  factory Medicine.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Medicine.fromJson: json cannot be null');
    }

    try {
      return Medicine(
        name: _parseString(json['Name']),
        dosage: _parseString(json['Dosage']),
        formulation: _parseString(json['Formulation']),
        costOfBranded: _parseDouble(json['Cost of branded']) ?? 0.0,
        costOfGeneric: _parseDouble(json['Cost of generic']) ?? 0.0,
        costDifference: _parseDouble(json['Cost difference']),
        savings: _parseDouble(json['Savings']),
        type: _parseString(json['Type']),
        uses: _parseString(json['Uses']),
        sideEffects: _parseString(json['Side Effects']),
      );
    } catch (e) {
      developer.log('Error creating Medicine from JSON', error: {'json': json, 'error': e});
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'Name': name,
        'Dosage': dosage,
        'Formulation': formulation,
        'Cost of branded': costOfBranded,
        'Cost of generic': costOfGeneric,
        'Cost difference': costDifference,
        'Savings': savings,
        'Type': type,
        'Uses': uses,
        'Side Effects': sideEffects,
      };
    } catch (e) {
      developer.log('Error converting Medicine to JSON', error: e);
      rethrow;
    }
  }

  @override
  String toString() {
    return 'Medicine(name: $name, type: $type, formulation: $formulation, dosage: $dosage)';
  }

  // Getters for backward compatibility with old field names
  String get Name => name;
  String get Dosage => dosage;
  String get Formulation => formulation;
  double get Cost_of_branded => costOfBranded;
  double get Cost_of_generic => costOfGeneric;
  double? get Cost_difference => costDifference;
  double? get Savings => savings;
  String get Type => type;
  String get Uses => uses;
  String get Side_Effects => sideEffects;
} 