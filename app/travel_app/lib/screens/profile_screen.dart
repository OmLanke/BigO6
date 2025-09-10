import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/tourist_provider.dart';
import '../models/loyalty_reward.dart';
import '../services/loyalty_rewards_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Consumer<TouristProvider>(
        builder: (context, touristProvider, child) {
          final profile = touristProvider.currentProfile;

          if (profile == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  profile.nationality,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Details
                _buildInfoCard(context, 'Personal Information', [
                  _InfoItem('Full Name', profile.name),
                  _InfoItem('Passport Number', profile.passportNumber),
                  _InfoItem('Nationality', profile.nationality),
                  _InfoItem('Digital ID', touristProvider.digitalId ?? 'N/A'),
                ]),
                const SizedBox(height: 16),

                _buildInfoCard(context, 'Emergency Contact', [
                  _InfoItem('Contact Name', profile.emergencyContact),
                  _InfoItem('Phone Number', profile.emergencyContactNumber),
                ]),
                const SizedBox(height: 16),

                _buildInfoCard(context, 'Trip Information', [
                  _InfoItem('Start Date', _formatDate(profile.tripStartDate)),
                  _InfoItem('End Date', _formatDate(profile.tripEndDate)),
                  _InfoItem(
                    'Duration',
                    '${profile.tripEndDate.difference(profile.tripStartDate).inDays} days',
                  ),
                  _InfoItem(
                    'Status',
                    touristProvider.isTripActive ? 'Active' : 'Upcoming',
                  ),
                ]),
                const SizedBox(height: 16),

                // Loyalty Rewards Section
                _buildLoyaltyRewardsSection(context),
                const SizedBox(height: 16),

                _buildInfoCard(
                  context,
                  'Planned Locations',
                  profile.plannedLocations
                      .map(
                        (location) => _InfoItem('', location, showLabel: false),
                      )
                      .toList(),
                  showMapButton: true,
                ),
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showLogoutDialog(context, touristProvider),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<_InfoItem> items, {
    bool showMapButton = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (showMapButton)
                  ElevatedButton.icon(
                    onPressed: () => _showLocationsOnMap(context),
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('View on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: item.showLabel
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.value,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLoyaltyRewardsSection(BuildContext context) {
    final userPoints = LoyaltyRewardsData.getUserPoints();
    final nextReward = LoyaltyRewardsData.getNextReward();

    return Column(
      children: [
        // Points Overview Card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loyalty Points',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${userPoints.totalPoints} points',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Safety Score',
                      '${userPoints.safetyScore}%',
                      Icons.shield,
                    ),
                    _buildStatItem(
                      context,
                      'Streak',
                      '${userPoints.currentStreakDays} days',
                      Icons.trending_up,
                    ),
                    _buildStatItem(
                      context,
                      'Trips',
                      '${userPoints.totalTrips}',
                      Icons.flight_takeoff,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Next Reward Card
        if (nextReward != null)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(nextReward.iconName),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Reward: ${nextReward.title}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          nextReward.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Need ${(nextReward.pointsRequired - userPoints.totalPoints).clamp(0, double.infinity).toInt()} more points',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Recent Achievements
        _buildRecentAchievements(context, userPoints),
        const SizedBox(height: 16),

        // View All Rewards Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showAllRewardsDialog(context),
            icon: const Icon(Icons.card_giftcard),
            label: const Text('View All Rewards'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildRecentAchievements(BuildContext context, UserPoints userPoints) {
    final recentRewards =
        userPoints.unlockedRewards
            .where((reward) => reward.unlockedDate != null)
            .toList()
          ..sort((a, b) => b.unlockedDate!.compareTo(a.unlockedDate!));

    final recentThree = recentRewards.take(3).toList();

    if (recentThree.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Achievements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...recentThree
                .map(
                  (reward) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getIconData(reward.iconName),
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reward.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _formatRewardDate(reward.unlockedDate!),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${reward.pointsRequired}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shield':
        return Icons.shield;
      case 'location_on':
        return Icons.location_on;
      case 'medical_services':
        return Icons.medical_services;
      case 'warning':
        return Icons.warning;
      case 'star':
        return Icons.star;
      case 'report':
        return Icons.report;
      case 'rate_review':
        return Icons.rate_review;
      case 'people':
        return Icons.people;
      case 'report_problem':
        return Icons.report_problem;
      case 'badge':
        return Icons.badge;
      case 'verified':
        return Icons.verified;
      case 'explore':
        return Icons.explore;
      case 'language':
        return Icons.language;
      case 'trending_up':
        return Icons.trending_up;
      case 'check_circle':
        return Icons.check_circle;
      case 'flight_takeoff':
        return Icons.flight_takeoff;
      case 'card_travel':
        return Icons.card_travel;
      case 'emoji_events':
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  String _formatRewardDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAllRewardsDialog(BuildContext context) {
    final allRewards = LoyaltyRewardsData.getAllRewards();
    final categories = allRewards.map((r) => r.category).toSet().toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Rewards',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DefaultTabController(
                  length: categories.length,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        tabs: categories
                            .map((category) => Tab(text: category))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: categories.map((category) {
                            final categoryRewards =
                                LoyaltyRewardsData.getRewardsByCategory(
                                  category,
                                );
                            return ListView.builder(
                              itemCount: categoryRewards.length,
                              itemBuilder: (context, index) {
                                final reward = categoryRewards[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: reward.isUnlocked
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getIconData(reward.iconName),
                                        color: reward.isUnlocked
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.grey,
                                      ),
                                    ),
                                    title: Text(
                                      reward.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: reward.isUnlocked
                                            ? null
                                            : Colors.grey,
                                      ),
                                    ),
                                    subtitle: Text(reward.description),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${reward.pointsRequired} pts',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: reward.isUnlocked
                                                    ? Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                    : Colors.grey,
                                              ),
                                        ),
                                        if (reward.isUnlocked)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationsOnMap(BuildContext context) {
    // Navigate to map screen and show planned locations
    context.go('/map');

    // Show a snackbar with instructions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tap the blue map button to view all planned locations',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  void _showLogoutDialog(
    BuildContext context,
    TouristProvider touristProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? This will remove your digital ID from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              touristProvider.logout();
              Navigator.of(context).pop();
              context.go('/onboarding');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final bool showLabel;

  _InfoItem(this.label, this.value, {this.showLabel = true});
}
