import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tourist_provider.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showClearDialog(context),
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Consumer<TouristProvider>(
        builder: (context, touristProvider, child) {
          final allAlerts = touristProvider.alerts;
          final activeAlerts = touristProvider.activeAlerts;

          if (allAlerts.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Summary Cards
              if (activeAlerts.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${activeAlerts.length} active alert${activeAlerts.length > 1 ? 's' : ''} requiring attention',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Alerts List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = allAlerts[index];
                    return _buildAlertCard(context, alert, touristProvider);
                  },
                ),
              ),
            ],
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
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Alerts',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up! No alerts to show.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    dynamic alert,
    TouristProvider touristProvider,
  ) {
    final isActive = !alert.isResolved;
    final priorityColor = _getPriorityColor(alert.priority);
    final typeIcon = _getTypeIcon(alert.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isActive ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: priorityColor.withOpacity(0.5), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, size: 20, color: priorityColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? null
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      Text(
                        _formatTime(alert.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? priorityColor.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? priorityColor.withOpacity(0.5)
                          : Colors.green.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    isActive ? 'ACTIVE' : 'RESOLVED',
                    style: TextStyle(
                      color: isActive ? priorityColor : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              alert.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive
                    ? null
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            // Location (if available)
            if (alert.latitude != null && alert.longitude != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${alert.latitude!.toStringAsFixed(4)}, ${alert.longitude!.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],

            // Resolution Info
            if (alert.isResolved) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resolved by ${alert.resolvedBy} at ${_formatTime(alert.resolvedAt!)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons
            if (isActive) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (alert.type.toString() == 'AlertType.sos') ...[
                    ElevatedButton.icon(
                      onPressed: () =>
                          _resolveAlert(context, alert.id, touristProvider),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark Safe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: () =>
                          _resolveAlert(context, alert.id, touristProvider),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Acknowledge'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(dynamic priority) {
    switch (priority.toString()) {
      case 'AlertPriority.critical':
        return Colors.red;
      case 'AlertPriority.high':
        return Colors.deepOrange;
      case 'AlertPriority.medium':
        return Colors.orange;
      case 'AlertPriority.low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(dynamic type) {
    switch (type.toString()) {
      case 'AlertType.sos':
        return Icons.emergency;
      case 'AlertType.geofence':
        return Icons.location_on;
      case 'AlertType.deviation':
        return Icons.route;
      case 'AlertType.inactivity':
        return Icons.access_time;
      case 'AlertType.lowBattery':
        return Icons.battery_alert;
      case 'AlertType.restricted':
        return Icons.block;
      default:
        return Icons.notification_important;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _resolveAlert(
    BuildContext context,
    String alertId,
    TouristProvider touristProvider,
  ) {
    touristProvider.resolveAlert(alertId, 'Tourist');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert resolved successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Resolved Alerts'),
        content: const Text(
          'This will remove all resolved alerts from the list. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TouristProvider>().clearResolvedAlerts();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resolved alerts cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
