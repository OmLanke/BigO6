import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tourist_provider.dart';
import '../models/family_member.dart';
import '../utils/theme.dart';

class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Family Members',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<TouristProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: provider.familyMembers.isEmpty
                    ? _buildEmptyState(context)
                    : _buildFamilyMembersList(context, provider.familyMembers),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFamilyMemberDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Family Members Added',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add family members to include them in your travel plans',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddFamilyMemberDialog(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Add First Member'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersList(
    BuildContext context,
    List<FamilyMember> members,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : 'F',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  member.relationship,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.nationality} • ${member.passportNumber}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditFamilyMemberDialog(context, member);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, member);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddFamilyMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FamilyMemberDialog(),
    );
  }

  void _showEditFamilyMemberDialog(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => FamilyMemberDialog(member: member),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: Text(
          'Are you sure you want to remove ${member.name} from your family members?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TouristProvider>().removeFamilyMember(member.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${member.name} removed successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class FamilyMemberDialog extends StatefulWidget {
  final FamilyMember? member;

  const FamilyMemberDialog({super.key, this.member});

  @override
  State<FamilyMemberDialog> createState() => _FamilyMemberDialogState();
}

class _FamilyMemberDialogState extends State<FamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passportController;
  late TextEditingController _nationalityController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyContactNumberController;
  late TextEditingController _emergencyContactRelationshipController;

  String _selectedRelationship = 'Spouse';
  final List<String> _relationships = [
    'Spouse',
    'Child',
    'Parent',
    'Sibling',
    'Grandparent',
    'Grandchild',
    'Other',
  ];

  DateTime _tripStartDate = DateTime.now();
  DateTime _tripEndDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _passportController = TextEditingController(
      text: widget.member?.passportNumber ?? '',
    );
    _nationalityController = TextEditingController(
      text: widget.member?.nationality ?? '',
    );
    _emergencyContactController = TextEditingController(
      text: widget.member?.emergencyContact ?? '',
    );
    _emergencyContactNumberController = TextEditingController(
      text: widget.member?.emergencyContactNumber ?? '',
    );
    _emergencyContactRelationshipController = TextEditingController(
      text: widget.member?.emergencyContactRelationship ?? '',
    );

    if (widget.member != null) {
      _selectedRelationship = widget.member!.relationship;
      _tripStartDate = widget.member!.tripStartDate;
      _tripEndDate = widget.member!.tripEndDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passportController.dispose();
    _nationalityController.dispose();
    _emergencyContactController.dispose();
    _emergencyContactNumberController.dispose();
    _emergencyContactRelationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                widget.member == null
                    ? 'Add Family Member'
                    : 'Edit Family Member',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty == true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRelationship,
                        decoration: const InputDecoration(
                          labelText: 'Relationship',
                          border: OutlineInputBorder(),
                        ),
                        items: _relationships.map((relationship) {
                          return DropdownMenuItem(
                            value: relationship,
                            child: Text(relationship),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRelationship = value!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passportController,
                        decoration: const InputDecoration(
                          labelText: 'Passport Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Passport number is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nationalityController,
                        decoration: const InputDecoration(
                          labelText: 'Nationality',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Nationality is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyContactController,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Contact Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Emergency contact is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyContactNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Contact Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty == true
                            ? 'Emergency contact number is required'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
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
                    onPressed: _saveFamilyMember,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(widget.member == null ? 'Add' : 'Update'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveFamilyMember() {
    if (_formKey.currentState?.validate() == true) {
      final provider = context.read<TouristProvider>();

      if (widget.member == null) {
        // Add new family member
        provider.addFamilyMember(
          name: _nameController.text,
          passportNumber: _passportController.text,
          nationality: _nationalityController.text,
          relationship: _selectedRelationship,
          emergencyContact: _emergencyContactController.text,
          emergencyContactNumber: _emergencyContactNumberController.text,
          emergencyContactRelationship:
              _emergencyContactRelationshipController.text.isEmpty
              ? null
              : _emergencyContactRelationshipController.text,
          tripStartDate: _tripStartDate,
          tripEndDate: _tripEndDate,
          plannedLocations: [], // Use same as main user or ask separately
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member added successfully')),
        );
      } else {
        // Update existing family member
        final updatedMember = widget.member!.copyWith(
          name: _nameController.text,
          passportNumber: _passportController.text,
          nationality: _nationalityController.text,
          relationship: _selectedRelationship,
          emergencyContact: _emergencyContactController.text,
          emergencyContactNumber: _emergencyContactNumberController.text,
          emergencyContactRelationship:
              _emergencyContactRelationshipController.text.isEmpty
              ? null
              : _emergencyContactRelationshipController.text,
          tripStartDate: _tripStartDate,
          tripEndDate: _tripEndDate,
        );

        provider.updateFamilyMember(updatedMember);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family member updated successfully')),
        );
      }

      Navigator.pop(context);
    }
  }
}
