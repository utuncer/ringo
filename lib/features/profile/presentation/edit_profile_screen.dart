import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';
import 'profile_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  bool _isLoading = false;
  // Avatar selection logic similar to RegisterScreen
  String _avatarType = 'preset';
  String? _selectedGender;
  Color? _selectedBgColor;

  // Interests
  final List<String> _availableInterests = [
    'Frontend',
    'Backend',
    'Savaşan İHA',
    'Sürü İHA',
    'Mobil',
    'Oyun Tasarımı',
    'Yapay Zeka',
  ];
  final List<String> _selectedInterests = []; // Should be pre-filled

  @override
  void initState() {
    super.initState();
    _avatarType = widget.profile.avatarType ?? 'preset';
    _selectedGender = widget.profile.avatarGender;
    if (widget.profile.avatarBgColor != null) {
      _selectedBgColor = Color(
        int.parse(widget.profile.avatarBgColor!.replaceAll('#', '0xFF')),
      );
    }
    // TODO: Fetch user interests and pre-fill _selectedInterests
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      String? bgColorHex;
      if (_selectedBgColor != null) {
        bgColorHex =
            '#${_selectedBgColor!.value.toRadixString(16).substring(2).toUpperCase()}';
      }

      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            userId: widget.profile.id,
            avatarType: _avatarType,
            avatarGender: _selectedGender,
            avatarBgColor: bgColorHex,
            // Interests update logic
          );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil güncellendi')));
        context.pop();
        // Invalidate the profile to refresh it
        ref.invalidate(profileRepositoryProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Avatar Düzenle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Reuse avatar selection logic from RegisterScreen (refactor to widget ideally)
            _buildAvatarSection(),
            const SizedBox(height: 24),
            const Text(
              'İlgi Alanları',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(interest);
                      } else {
                        _selectedInterests.remove(interest);
                      }
                    });
                  },
                  backgroundColor: AppColors.surfaceDark,
                  selectedColor: AppColors.roleInterests,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Kaydet',
              onPressed: _save,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    // Simplified version for brevity
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Hazır', style: TextStyle(fontSize: 14)),
                value: 'preset',
                groupValue: _avatarType,
                onChanged: (val) => setState(() => _avatarType = val!),
                activeColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Yükle', style: TextStyle(fontSize: 14)),
                value: 'custom',
                groupValue: _avatarType,
                onChanged: (val) => setState(() => _avatarType = val!),
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        if (_avatarType == 'preset') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.face,
                  color: _selectedGender == 'male'
                      ? AppColors.primary
                      : Colors.grey,
                  size: 32,
                ),
                onPressed: () => setState(() => _selectedGender = 'male'),
              ),
              IconButton(
                icon: Icon(
                  Icons.face_3,
                  color: _selectedGender == 'female'
                      ? AppColors.primary
                      : Colors.grey,
                  size: 32,
                ),
                onPressed: () => setState(() => _selectedGender = 'female'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: AppColors.avatarBackgrounds.map((color) {
              return GestureDetector(
                onTap: () => setState(() => _selectedBgColor = color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: _selectedBgColor == color
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
