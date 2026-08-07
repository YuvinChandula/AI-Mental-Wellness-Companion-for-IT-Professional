import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _occupationController;
  late TextEditingController _countryController;
  late TextEditingController _languageController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _occupationController = TextEditingController();
    _countryController = TextEditingController();
    _languageController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _occupationController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _populateFields(UserProfile profile) {
    _nameController.text = profile.fullName;
    _phoneController.text = profile.phoneNumber ?? '';
    _dobController.text = profile.dateOfBirth ?? '';
    _genderController.text = profile.gender ?? '';
    _occupationController.text = profile.occupation ?? '';
    _countryController.text = profile.country;
    _languageController.text = profile.preferredLanguage;
    _bioController.text = profile.bio ?? '';
  }

  Future<void> _saveProfile(UserProfile current) async {
    final UserProfile updated = current.copyWith(
      fullName: _nameController.text,
      phoneNumber: _phoneController.text,
      dateOfBirth: _dobController.text,
      gender: _genderController.text,
      occupation: _occupationController.text,
      country: _countryController.text,
      preferredLanguage: _languageController.text,
      bio: _bioController.text,
      updatedAt: DateTime.now(),
    );

    await ref.read(profileStateProvider.notifier).updateProfile(updated);
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  Future<void> _simulateUploadImage() async {
    final Uint8List mockBytes = Uint8List.fromList(List<int>.generate(100, (int i) => i));
    await ref.read(profileStateProvider.notifier).uploadPhoto(mockBytes, 'avatar.jpg');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserProfile>>(profileStateProvider, (AsyncValue<UserProfile>? previous, AsyncValue<UserProfile> next) {
      next.whenData((UserProfile profile) {
        if (!_isEditing) {
          _populateFields(profile);
        }
      });
    });

    final AsyncValue<UserProfile> state = ref.watch(profileStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings & Security',
            onPressed: () => context.push('/settings'),
          ),
          state.maybeWhen(
            data: (UserProfile profile) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: _isEditing
                      ? () => _saveProfile(profile)
                      : () {
                          _populateFields(profile);
                          setState(() => _isEditing = true);
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    _isEditing ? 'Save' : 'Edit',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: state.when(
        data: (UserProfile profile) {
          if (!_isEditing && (_nameController.text.isEmpty || _nameController.text != profile.fullName)) {
            _populateFields(profile);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Profile Avatar Photo Frame
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          backgroundImage: (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                              ? NetworkImage(profile.photoUrl!) as ImageProvider
                              : null,
                          child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                              ? Icon(Icons.person, size: 56, color: theme.colorScheme.primary)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Material(
                          elevation: 3,
                          shape: const CircleBorder(),
                          color: theme.colorScheme.primary,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _simulateUploadImage,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                  TextButton(
                    onPressed: () => ref.read(profileStateProvider.notifier).removePhoto(),
                    child: const Text('Remove Photo', style: TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                const SizedBox(height: 8),
                Text(
                  profile.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (profile.occupation != null && profile.occupation!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    profile.occupation!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Form details
                _buildFormSection(theme),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load profile: $err')),
      ),
    );
  }

  Widget _buildFormSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildField('Full Name', _nameController, Icons.person_outline),
        _buildField('Occupation', _occupationController, Icons.work_outline),
        _buildField('Bio', _bioController, Icons.info_outline, maxLines: 3),
        _buildField('Phone Number', _phoneController, Icons.phone_outlined, keyboard: TextInputType.phone),
        _buildField('Date of Birth', _dobController, Icons.calendar_month_outlined),
        _buildField('Gender', _genderController, Icons.face_outlined),
        _buildField('Country', _countryController, Icons.flag_outlined),
        _buildField('Language', _languageController, Icons.translate_outlined),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          labelStyle: TextStyle(
            color: _isEditing ? theme.colorScheme.primary : Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              bottom: maxLines > 1 ? 40.0 : 0.0,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          filled: true,
          fillColor: _isEditing
              ? theme.colorScheme.primary.withOpacity(0.04)
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.4)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

