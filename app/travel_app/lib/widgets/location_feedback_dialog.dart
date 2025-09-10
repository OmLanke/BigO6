import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tourist_provider.dart';
import '../utils/theme.dart';

class LocationFeedbackDialog extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? locationName;

  const LocationFeedbackDialog({
    super.key,
    required this.latitude,
    required this.longitude,
    this.locationName,
  });

  @override
  State<LocationFeedbackDialog> createState() => _LocationFeedbackDialogState();
}

class _LocationFeedbackDialogState extends State<LocationFeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _locationNameController = TextEditingController();
  final _commentsController = TextEditingController();

  int _safetyRating = 3;
  final List<String> _selectedCategories = [];

  final List<String> _availableCategories = [
    'Well Lit',
    'Police Presence',
    'Crowded Area',
    'Clean Environment',
    'Good Transportation',
    'Tourist Friendly',
    'Safe for Women',
    'Emergency Services Nearby',
    'Good Mobile Network',
    'CCTV Coverage',
  ];

  @override
  void initState() {
    super.initState();
    _locationNameController.text = widget.locationName ?? 'Unknown Location';
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationNameField(),
                      const SizedBox(height: 20),
                      _buildSafetyRatingSection(),
                      const SizedBox(height: 20),
                      _buildCategoriesSection(),
                      const SizedBox(height: 20),
                      _buildCommentsField(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safety Feedback',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Help other travelers by sharing your experience',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationNameField() {
    return TextFormField(
      controller: _locationNameController,
      decoration: const InputDecoration(
        labelText: 'Location Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
      validator: (value) =>
          value?.isEmpty == true ? 'Location name is required' : null,
    );
  }

  Widget _buildSafetyRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Safety Rating',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      return GestureDetector(
                        onTap: () => setState(() => _safetyRating = rating),
                        child: Column(
                          children: [
                            Icon(
                              Icons.star,
                              size: 32,
                              color: rating <= _safetyRating
                                  ? _getRatingColor(rating)
                                  : Colors.grey[300],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: rating == _safetyRating
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: rating <= _safetyRating
                                    ? _getRatingColor(rating)
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingLabel(_safetyRating),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getRatingColor(_safetyRating),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What makes this location safe/unsafe?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentsField() {
    return TextFormField(
      controller: _commentsController,
      decoration: const InputDecoration(
        labelText: 'Additional Comments (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.comment),
        hintText: 'Share your experience or tips for other travelers...',
      ),
      maxLines: 3,
      maxLength: 500,
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Submit Feedback'),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return AppColors.safeTone;
      case 4:
        return AppColors.safeTone.withOpacity(0.8);
      case 3:
        return AppColors.cautionTone;
      case 2:
        return AppColors.dangerTone.withOpacity(0.8);
      case 1:
        return AppColors.dangerTone;
      default:
        return Colors.grey;
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Very Safe';
      case 4:
        return 'Safe';
      case 3:
        return 'Moderate';
      case 2:
        return 'Unsafe';
      case 1:
        return 'Very Unsafe';
      default:
        return 'Unknown';
    }
  }

  void _submitFeedback() {
    if (_formKey.currentState?.validate() == true) {
      final provider = context.read<TouristProvider>();

      provider.submitLocationFeedback(
        locationName: _locationNameController.text,
        latitude: widget.latitude,
        longitude: widget.longitude,
        safetyRating: _safetyRating,
        comments: _commentsController.text.isEmpty
            ? null
            : _commentsController.text,
        categories: _selectedCategories,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: AppColors.safeTone,
        ),
      );
    }
  }
}
