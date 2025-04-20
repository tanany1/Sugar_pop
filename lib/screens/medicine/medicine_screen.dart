import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final TextEditingController _medicine1Controller = TextEditingController();
  final TextEditingController _medicine2Controller = TextEditingController();

  // Focus nodes to manage keyboard behavior
  final FocusNode _medicine1FocusNode = FocusNode();
  final FocusNode _medicine2FocusNode = FocusNode();

  @override
  void dispose() {
    _medicine1Controller.dispose();
    _medicine2Controller.dispose();
    _medicine1FocusNode.dispose();
    _medicine2FocusNode.dispose();
    super.dispose();
  }

  // Database of incompatible medicine pairs and their warning messages
  final Map<String, Map<String, String>> _incompatibilityDatabase = {
    'aspirin': {
      'glimepiride': 'Aspirin increases effects of glimepiride by unknown mechanism. Risk of hypoglycemia.',
      'glyburide': 'Aspirin increases effects of glyburide by plasma protein binding competition. Large dose of salicylate may cause issues.',
      'insulin degludec': 'Aspirin increases effects of insulin degludec by pharmacodynamic synergism. Coadministration with high doses of salicylates may increase risk for hypoglycemia.',
    },
    'statins': {
      'sulfonylureas': 'May enhance hypoglycemic effect (rare, but possible).',
      'insulin': 'Generally safe, but high-dose statins may increase insulin resistance and slightly raise the risk of new-onset type 2 diabetes.',
      'metformin': 'Generally safe, but high-dose statins may increase insulin resistance and slightly raise the risk of new-onset type 2 diabetes.',
    },
    'atorvastatin': {
      'glipizide': 'May enhance hypoglycemic effect (rare, but possible).',
      'glimepiride': 'May enhance hypoglycemic effect (rare, but possible).',
      'insulin': 'Generally safe, but high-dose statins may increase insulin resistance.',
      'metformin': 'Generally safe, but high-dose statins may increase insulin resistance.',
    },
    'simvastatin': {
      'glipizide': 'May enhance hypoglycemic effect (rare, but possible).',
      'glimepiride': 'May enhance hypoglycemic effect (rare, but possible).',
      'insulin': 'Generally safe, but high-dose statins may increase insulin resistance.',
      'metformin': 'Generally safe, but high-dose statins may increase insulin resistance.',
    },
    'fibrates': {
      'insulin': 'May enhance hypoglycemic effect, increasing risk of low blood sugar.',
      'sulfonylureas': 'May enhance hypoglycemic effect, increasing risk of low blood sugar.',
      'statins': 'Significantly increases the risk of myopathy or rhabdomyolysis, especially in diabetic patients.',
    },
    'gemfibrozil': {
      'insulin': 'May enhance hypoglycemic effect, increasing risk of low blood sugar.',
      'sulfonylureas': 'May enhance hypoglycemic effect, increasing risk of low blood sugar.',
      'statins': 'Significantly increases the risk of myopathy or rhabdomyolysis, especially in diabetic patients.',
      'atorvastatin': 'Significantly increases the risk of myopathy or rhabdomyolysis, especially in diabetic patients.',
      'simvastatin': 'Significantly increases the risk of myopathy or rhabdomyolysis, especially in diabetic patients.',
    },
    'fenofibrate': {
      'insulin': 'May enhance hypoglycemic effect, increasing risk of low blood sugar.',
      'sulfonylureas': 'May enhance hypoglycemic effect, increasing risk of low blood sugar.',
      'statins': 'Increases the risk of myopathy or rhabdomyolysis, especially in diabetic patients.',
      'atorvastatin': 'Increases the risk of myopathy or rhabdomyolysis, especially in diabetic patients.',
      'simvastatin': 'Increases the risk of myopathy or rhabdomyolysis, especially in diabetic patients.',
    },
    'niacin': {
      'metformin': 'Can worsen glycemic control by reducing glucose tolerance; may increase blood glucose levels.',
      'insulin': 'Can worsen glycemic control by reducing glucose tolerance; may increase blood glucose levels.',
      'sulfonylureas': 'Can worsen glycemic control by reducing glucose tolerance; may increase blood glucose levels.',
    },
    'bile acid sequestrants': {
      'metformin': 'Can reduce the absorption of oral antidiabetic drugs - timing of administration should be managed carefully.',
      'sulfonylureas': 'Can reduce the absorption of oral antidiabetic drugs - timing of administration should be managed carefully.',
    },
    'cholestyramine': {
      'metformin': 'Can reduce the absorption of oral antidiabetic drugs - timing of administration should be managed carefully.',
      'sulfonylureas': 'Can reduce the absorption of oral antidiabetic drugs - timing of administration should be managed carefully.',
    },
    'omeprazole': {
      'metformin': 'Long-term use can lead to Vitamin B12 deficiency, which might affect Metformin\'s efficacy.',
      'glipizide': 'May increase the effect of Sulfonylureas, which could lead to an increased risk of hypoglycemia.',
      'glyburide': 'May increase the effect of Sulfonylureas, which could lead to an increased risk of hypoglycemia.',
    },
    'esomeprazole': {
      'metformin': 'Long-term use can lead to Vitamin B12 deficiency, which might affect Metformin\'s efficacy.',
      'glipizide': 'May increase the effect of Sulfonylureas, which could lead to an increased risk of hypoglycemia.',
      'glyburide': 'May increase the effect of Sulfonylureas, which could lead to an increased risk of hypoglycemia.',
    },
    'lansoprazole': {
      'metformin': 'Long-term use can lead to Vitamin B12 deficiency, which might affect Metformin\'s efficacy.',
      'glipizide': 'May increase the effect of Sulfonylureas, which could lead to an increased risk of hypoglycemia.',
      'glyburide': 'May increase the effect of Sulfonylureas, which could lead to an increased risk of hypoglycemia.',
    },
    'rabeprazole': {
      'metformin': 'Long-term use can lead to Vitamin B12 deficiency, which might affect Metformin\'s efficacy.',
      'glipizide': 'May increase the effect of Sulfonylureas, which could lead to an increased risk of hypoglycemia.',
      'glyburide': 'May increase the effect of Sulfonylureas, which could lead to an increased risk of hypoglycemia.',
    },
    'propranolol': {
      'glimepiride': 'Propranolol decreases effects of glimepiride by pharmacodynamic antagonism. Non-selective beta blockers may also mask the symptoms of hypoglycemia.',
    },
    'amlodipine': {
      'metformin': 'Amlodipine decreases effects of metformin by pharmacodynamic antagonism. Patient should be closely observed for loss of blood glucose control.',
    },
    'losartan': {
      'insulin aspart': 'Losartan increases effects of insulin aspart. Concomitant use of insulin and ARBs may require insulin dosage adjustment and increased glucose monitoring.',
    },
  };

  // Check if two medicines are incompatible
  String? _checkIncompatibility(String medicine1, String medicine2) {
    medicine1 = medicine1.toLowerCase().trim();
    medicine2 = medicine2.toLowerCase().trim();

    // Check direct incompatibility
    if (_incompatibilityDatabase.containsKey(medicine1) &&
        _incompatibilityDatabase[medicine1]!.containsKey(medicine2)) {
      return _incompatibilityDatabase[medicine1]![medicine2];
    }

    // Check reverse incompatibility
    if (_incompatibilityDatabase.containsKey(medicine2) &&
        _incompatibilityDatabase[medicine2]!.containsKey(medicine1)) {
      return _incompatibilityDatabase[medicine2]![medicine1];
    }

    // No incompatibility found
    return null;
  }

  void _checkCompatibility() {
    String medicine1 = _medicine1Controller.text;
    String medicine2 = _medicine2Controller.text;

    if (medicine1.isEmpty || medicine2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter both medicines',
            style: TextStyle(color: AppColors.primary1),
          ),
          backgroundColor: AppColors.primary3,
        ),
      );
      return;
    }

    String? incompatibilityWarning = _checkIncompatibility(medicine1, medicine2);

    if (incompatibilityWarning != null) {
      _showIncompatibilityDialog(incompatibilityWarning);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'These medicines appear to be compatible',
            style: TextStyle(color: AppColors.primary1),
          ),
          backgroundColor: AppColors.primary3,
        ),
      );
    }
  }

  void _showIncompatibilityDialog(String warning) {
    bool expanded = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Potential Drug Interaction',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Check with your doctor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (expanded) ...[
                    const Text(
                      'Interaction Details:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      warning,
                      style: const TextStyle(color: AppColors.textColor),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Important: This is for informational purposes only. Always consult with your healthcare provider before making any changes to your medication.',
                      style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textColor),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  child: Text(
                    expanded ? "Show Less" : "Read More",
                    style: const TextStyle(color: AppColors.accentColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Close",
                    style: TextStyle(color: AppColors.accentColor),
                  ),
                ),
              ],
              backgroundColor: AppColors.primary1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medicine Compatibility',
          style: TextStyle(color: AppColors.textColor),
        ),
        backgroundColor: AppColors.primary1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accentColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: AppColors.primary5,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Check if your medications interact with each other',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _medicine1Controller,
                  focusNode: _medicine1FocusNode,
                  decoration: InputDecoration(
                    labelText: 'First Medicine',
                    labelStyle: const TextStyle(color: AppColors.textColor),
                    hintText: 'Enter first medicine name',
                    hintStyle: TextStyle(color: AppColors.textColor.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.primary1,
                    prefixIcon: const Icon(Icons.medication, color: AppColors.accentColor),
                  ),
                  style: const TextStyle(color: AppColors.textColor),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_medicine2FocusNode);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _medicine2Controller,
                  focusNode: _medicine2FocusNode,
                  decoration: InputDecoration(
                    labelText: 'Second Medicine',
                    labelStyle: const TextStyle(color: AppColors.textColor),
                    hintText: 'Enter second medicine name',
                    hintStyle: TextStyle(color: AppColors.textColor.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.primary1,
                    prefixIcon: const Icon(Icons.medication_liquid, color: AppColors.accentColor),
                  ),
                  style: const TextStyle(color: AppColors.textColor),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    _checkCompatibility();
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _checkCompatibility,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: AppColors.textColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Check Compatibility',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This tool provides information about potential drug interactions, but it is not a substitute for professional medical advice. Always consult with your healthcare provider.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}