import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tourist_provider.dart';
import '../models/location_feedback.dart';
import '../utils/theme.dart';

class FeedbackListScreen extends StatelessWidget {
  const FeedbackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Location Feedbacks',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<TouristProvider>(
        builder: (context, provider, child) {
          final feedbacks = provider.locationFeedbacks;

          if (feedbacks.isEmpty) {
            return _buildEmptyState(context);
          }

          // Sort feedbacks by submission date (newest first)
          final sortedFeedbacks = List<LocationFeedback>.from(feedbacks)
            ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedFeedbacks.length,
            itemBuilder: (context, index) {
              final feedback = sortedFeedbacks[index];
              return _buildFeedbackCard(context, feedback);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Feedback Submitted',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Submit feedback for locations to help other travelers',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, LocationFeedback feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with location name and rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.locationName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${feedback.latitude.toStringAsFixed(4)}, '
                        'Lng: ${feedback.longitude.toStringAsFixed(4)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildRatingDisplay(feedback.safetyRating),
              ],
            ),

            const SizedBox(height: 12),

            // Safety rating label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRatingColor(feedback.safetyRating).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getRatingColor(
                    feedback.safetyRating,
                  ).withOpacity(0.3),
                ),
              ),
              child: Text(
                feedback.safetyLabel,
                style: TextStyle(
                  color: _getRatingColor(feedback.safetyRating),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),

            // Categories
            if (feedback.categories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: feedback.categories.map((category) {
                  return Chip(
                    label: Text(category, style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],

            // Comments
            if (feedback.comments != null && feedback.comments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Comment',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback.comments!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],

            // Submission date
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(feedback.submittedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDisplay(int rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRatingColor(rating),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 16, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            rating.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
