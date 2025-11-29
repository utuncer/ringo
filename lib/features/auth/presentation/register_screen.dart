import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Avatar Selection
  String _avatarType = 'preset'; // 'preset' or 'custom'
  String? _selectedGender; // 'male', 'female'
  Color? _selectedBgColor;
  // File? _customImageFile; // For custom image picker (TODO: Implement ImagePicker)

  // Role Selection
  String _selectedRole = 'competitor'; // Default
  final List<String> _roles = ['competitor', 'instructor', 'team'];

  // Interest Selection
  final List<String> _availableInterests = [
    'Frontend',
    'Backend',
    'Savaşan İHA',
    'Sürü İHA',
    'Mobil',
    'Oyun Tasarımı',
    'Yapay Zeka',
  ];
  final List<String> _selectedInterests = [];

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_avatarType == 'preset' &&
        (_selectedGender == null || _selectedBgColor == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen avatar cinsiyeti ve rengi seçiniz'),
        ),
      );
      return;
    }

    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az 1 ilgi alanı seçmelisiniz')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Rengi DB için onaltılık dizeye dönüştür
      String? bgColorHex;
      if (_selectedBgColor != null) {
        bgColorHex =
            '#${_selectedBgColor!.value.toRadixString(16).substring(2).toUpperCase()}';
      }

      await ref
          .read(authRepositoryProvider)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
            fullName: _fullNameController.text.trim(),
            role: _selectedRole,
            avatarType: _avatarType,
            avatarGender: _selectedGender,
            avatarBgColor: bgColorHex,
            interestIds: _selectedInterests,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Lütfen emailinizi doğrulayın.'),
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Kayıt hatası: ';

        // Hata mesajını daha spesifik mesajlar için ayrıştır
        if (e.toString().contains('user_role')) {
          errorMessage += 'Rol seçimi geçersiz. Lütfen tekrar deneyin.';
        } else if (e.toString().contains('username')) {
          errorMessage += 'Kullanıcı adı zaten alınmış veya geçersiz.';
        } else if (e.toString().contains('email')) {
          errorMessage += 'Email zaten kayıtlı veya geçersiz.';
        } else {
          errorMessage += e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.actionError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _usernameController,
                label: 'Kullanıcı Adı',
                hint: 'username',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Gerekli';
                  if (value.contains(' ')) return 'Boşluk içeremez';

                  // YENİ EKLENEN KISIM: SQL Regex ile uyumlu kontrol
                  // Sadece İngilizce harf, rakam ve alt çizgi
                  final validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
                  if (!validCharacters.hasMatch(value)) {
                    return 'Sadece kelime, sayı ve _ kullanılabilir';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _fullNameController,
                label: 'Ad Soyad',
                hint: 'Adınız Soyadınız',
                validator: (value) => value?.isEmpty == true ? 'Gerekli' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'email@ornek.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value?.contains('@') == true ? null : 'Geçersiz email',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Şifre',
                hint: '******',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) =>
                    (value?.length ?? 0) < 6 ? 'Min 6 karakter' : null,
              ),
              const SizedBox(height: 24),
              _buildRoleSection(),
              const SizedBox(height: 24),
              _buildInterestsSection(),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Kayıt Ol',
                onPressed: _register,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Avatar Seçimi', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Hazır', style: TextStyle(fontSize: 14)),
                value: 'preset',
                groupValue: _avatarType,
                onChanged: (val) => setState(() => _avatarType = val!),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Yükle', style: TextStyle(fontSize: 14)),
                value: 'custom',
                groupValue: _avatarType,
                onChanged: (val) => setState(() => _avatarType = val!),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        if (_avatarType == 'preset') ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGenderOption('male', Icons.face),
              _buildGenderOption('female', Icons.face_3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: AppColors.avatarBackgrounds.map((color) {
              return GestureDetector(
                onTap: () => setState(() => _selectedBgColor = color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: _selectedBgColor == color
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          // Custom upload placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: const Center(child: Text('Görsel Yükleme Alanı (Yakında)')),
          ),
        ],
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Icon(
          icon,
          size: 32,
          color: isSelected ? AppColors.primary : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rol Seçimi', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          dropdownColor: AppColors.surfaceDark,
          items: _roles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedRole = val!),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İlgi Alanları (Min 1)',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: Colors.black,
            );
          }).toList(),
        ),
      ],
    );
  }
}
