import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, 'Privacy & Security', [
            _buildSettingTile(
              context,
              'Location Permissions',
              'Manage location access',
              Icons.location_on_outlined,
              () {},
            ),
            _buildSettingTile(
              context,
              'Emergency Contacts',
              'Manage emergency contacts',
              Icons.contact_emergency_outlined,
              () {},
            ),
            _buildSettingTile(
              context,
              'Data Privacy',
              'Control your data sharing',
              Icons.privacy_tip_outlined,
              () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'Notifications', [
            _buildSettingTile(
              context,
              'Push Notifications',
              'Enable/disable notifications',
              Icons.notifications_outlined,
              () {},
            ),
            _buildSettingTile(
              context,
              'Alert Sounds',
              'Customize alert tones',
              Icons.volume_up_outlined,
              () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'App Settings', [
            _buildSettingTile(
              context,
              'Language',
              'Change app language',
              Icons.language_outlined,
              () {},
            ),
            _buildSettingTile(
              context,
              'Theme',
              'Dark/Light mode',
              Icons.dark_mode_outlined,
              () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
