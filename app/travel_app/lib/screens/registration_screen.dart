import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/tourist_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passportController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  DateTime _tripStartDate = DateTime.now();
  DateTime _tripEndDate = DateTime.now().add(const Duration(days: 7));

  final List<String> _plannedLocations = [];
  final _locationController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passportController.dispose();
    _nationalityController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _addLocation() {
    if (_locationController.text.trim().isNotEmpty) {
      setState(() {
        _plannedLocations.add(_locationController.text.trim());
        _locationController.clear();
      });
    }
  }

  void _removeLocation(int index) {
    setState(() {
      _plannedLocations.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _tripStartDate : _tripEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _tripStartDate = picked;
          if (_tripEndDate.isBefore(_tripStartDate)) {
            _tripEndDate = _tripStartDate.add(const Duration(days: 1));
          }
        } else {
          _tripEndDate = picked;
        }
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_plannedLocations.isEmpty) {
      _showSnackBar('Please add at least one planned location');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TouristProvider>().registerTourist(
        name: _nameController.text.trim(),
        passportNumber: _passportController.text.trim(),
        nationality: _nationalityController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim(),
        emergencyContactNumber: _emergencyPhoneController.text.trim(),
        tripStartDate: _tripStartDate,
        tripEndDate: _tripEndDate,
        plannedLocations: _plannedLocations,
      );

      if (mounted) {
        _showSnackBar(
          'Registration successful! Digital ID created.',
          isSuccess: true,
        );
        context.go('/home');
      }
    } catch (e) {
      _showSnackBar('Registration failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? Colors.green
            : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourist Registration'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Load demo data
              context.read<TouristProvider>().loadMockData();
              context.go('/home');
            },
            child: const Text('Demo'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Create Digital Tourist ID',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your secure, blockchain-based travel identity',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Personal Information
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _passportController,
                label: 'Passport Number',
                icon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your passport number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nationalityController,
                label: 'Nationality',
                icon: Icons.flag_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your nationality';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Emergency Contact
              _buildSectionHeader('Emergency Contact'),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emergencyContactController,
                label: 'Emergency Contact Name',
                icon: Icons.contact_emergency_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter emergency contact name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emergencyPhoneController,
                label: 'Emergency Contact Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter emergency contact phone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Trip Details
              _buildSectionHeader('Trip Details'),
              const SizedBox(height: 16),

              // Date Selection
              Row(
                children: [
                  Expanded(
                    child: _buildDateSelector(
                      'Trip Start',
                      _tripStartDate,
                      () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateSelector(
                      'Trip End',
                      _tripEndDate,
                      () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Planned Locations
              Text(
                'Planned Locations',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _locationController,
                      label: 'Add location',
                      icon: Icons.location_on_outlined,
                      onSubmitted: (_) => _addLocation(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _addLocation,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location List
              if (_plannedLocations.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: _plannedLocations.asMap().entries.map((entry) {
                      int index = entry.key;
                      String location = entry.value;

                      return ListTile(
                        leading: const Icon(Icons.location_on, size: 20),
                        title: Text(location),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeLocation(index),
                          color: Theme.of(context).colorScheme.error,
                        ),
                        dense: true,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Register Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _isLoading ? null : _register,
                  text: 'Create Digital ID',
                  isLoading: _isLoading,
                  icon: Icons.security,
                ),
              ),
              const SizedBox(height: 16),

              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your digital ID will be securely stored on blockchain and is valid only for your trip duration.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
