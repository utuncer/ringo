import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; // NEW IMPORT
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
  String? _selectedGender = 'male'; // Default Male
  Color? _selectedBgColor = AppColors.avatarBackgrounds[1]; // Default Blue
  XFile? _customImageFile;

  // PREVIEW PERSISTENCE: Track what to show in preview independently of current tab selection
  // This ensures that switching tabs doesn't immediately clear the preview until a new selection is made.
  ImageProvider? _previewImageProvider = const AssetImage('assets/images/icon_m.png'); // Default Male
  Color? _previewBgColor = AppColors.avatarBackgrounds[1]; // Default Blue

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

  bool get _isFormValid {
    if (_usernameController.text.isEmpty) return false;
    if (_fullNameController.text.isEmpty) return false;
    if (_emailController.text.isEmpty || !_emailController.text.contains('@'))
      return false;
    if (_passwordController.text.length < 6) return false;
    if (_selectedInterests.isEmpty) return false;

    // Validation needs to ensure we have a valid avatar setup either in preset or custom
    // If we are on preset tab, we need gender/color.
    // If we are on custom tab, we need a file.
    // HOWEVER: The user might have set up a valid preset, then switched to custom tab to look,
    // but decided to go back.
    // The requirement says "preview en son ne yaptıysak orada kalsın".
    // So strictly speaking, we should probably validate based on what is currently *shown* or *intended*.
    // Simple approach: Validate based on current _avatarType.
    if (_avatarType == 'preset') {
      if (_selectedGender == null || _selectedBgColor == null) return false;
    } else {
      if (_customImageFile == null) return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateState);
    _fullNameController.addListener(_updateState);
    _emailController.addListener(_updateState);
    _passwordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateState);
    _fullNameController.removeListener(_updateState);
    _emailController.removeListener(_updateState);
    _passwordController.removeListener(_updateState);
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // CROP IMAGE LOGIC
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Fotoğrafı Düzenle',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle, // Moved here
          ),
          IOSUiSettings(
            title: 'Fotoğrafı Düzenle',
            cropStyle: CropStyle.circle, // Moved here
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _customImageFile = XFile(croppedFile.path);
          // Update Preview persistence
          _previewImageProvider = FileImage(File(croppedFile.path));
          _previewBgColor = Colors.transparent;
        });
      }
    }
  }

  // Update preview when Preset changes
  void _updatePresetPreview() {
    // Logic handled in build via state variables
    // But we need to update the persistence if we are in preset mode
    // Current implementation in _buildProfilePreview handles the display logic dynamically based on _previewImageProvider checks
    // IF we want to persist "Preset vs Custom" choice, we should track it.
    // The current code puts FileImage or AssetImage into _previewImageProvider.
    if (_selectedGender != null) {
      String assetName = _selectedGender == 'male'
          ? 'assets/images/icon_m.png'
          : 'assets/images/icon_w.png';
      _previewImageProvider = AssetImage(assetName);
    }
    if (_selectedBgColor != null) {
      _previewBgColor = _selectedBgColor;
    }
    setState(() {});
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      String? bgColorHex;
      if (_selectedBgColor != null) {
        bgColorHex =
            '#${_selectedBgColor!.value.toRadixString(16).substring(2).toUpperCase()}';
      }

      await ref.read(authRepositoryProvider).signUp(
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
        if (e.toString().contains('user_role')) {
          errorMessage += 'Rol seçimi geçersiz.';
        } else if (e.toString().contains('username')) {
          errorMessage += 'Kullanıcı adı alınmış.';
        } else if (e.toString().contains('email')) {
          errorMessage += 'Email zaten kayıtlı.';
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
              _buildProfilePreview(),
              const SizedBox(height: 24),
              _buildAvatarSection(),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _usernameController,
                label: 'Kullanıcı Adı',
                hint: 'username',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Gerekli';
                  if (value.contains(' ')) return 'Boşluk içeremez';
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
                  color: Colors.white70,
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
                onPressed: _isFormValid ? _register : null,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Hesabın var mı?',
                      style: TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePreview() {
    // Colors based on role
    final bool isTeam = _selectedRole == 'team';
    final Color usernameColor = isTeam
        ? const Color(0xFFDA291C)
        : AppColors.primary; // Team Red or Primary

    // Role Style
    final Color roleBorderColor =
        isTeam ? const Color(0xFFDA291C) : AppColors.primary;
    final Color roleBgColor = roleBorderColor.withOpacity(0.2);
    final Color roleTextColor =
        isTeam ? roleBorderColor : AppColors.primary; // Red if Team (Matched style)

    // Interest Style
    final Color interestColor = const Color(0xFFFFB81C); // Yellow

    Widget avatarChild;
    ImageProvider? bgImage;

    // Determine Avatar Content
    if (_previewImageProvider is FileImage) {
      bgImage = _previewImageProvider;
      avatarChild = Container(); // Empty child, image is background
    } else {
      // Preset asset or null
      // If it is an Asset (from Preset), we want it SMALLER (child)
      // _previewImageProvider holds AssetImage or null
      bgImage =
          null; // No background image for preset to allow background color to show
      if (_previewImageProvider is AssetImage) {
        avatarChild = Image(
          image: _previewImageProvider!,
          // ICON BOYUTUNU BURADAN DUZENLEYEBILIRSINIZ
          width: 60, // Reduced size for preset icon in preview
          height: 60,
        );
      } else {
        avatarChild = const Icon(Icons.person, size: 60, color: Colors.white);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text(
            'Profil Önizleme',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: _previewBgColor ?? AppColors.primary,
            backgroundImage: bgImage, // Only if FileImage
            child: avatarChild,
          ),
          const SizedBox(height: 12),
          Text(
            _fullNameController.text.isNotEmpty
                ? _fullNameController.text
                : 'Ad Soyad',
            style: const TextStyle(
              color: Colors.white, // Always White
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${_usernameController.text.isNotEmpty ? _usernameController.text : 'username'}',
            style: TextStyle(
              color: usernameColor, // Red if Team
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: roleBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roleBorderColor),
            ),
            child: Text(
              _getRoleDisplay(_selectedRole),
              style: TextStyle(color: roleTextColor, fontSize: 12),
            ),
          ),
          if (_selectedInterests.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: _selectedInterests
                  .map((interest) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: interestColor
                              .withOpacity(0.2), // Yellow Bg Opacity
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: interestColor), // Yellow Border
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                              color: interestColor,
                              fontSize: 10), // Yellow Text
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _getRoleDisplay(String role) {
    switch (role) {
      case 'competitor':
        return 'Yarışmacı';
      case 'instructor':
        return 'Eğitmen';
      case 'team':
        return 'Takım';
      default:
        return role;
    }
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Avatar Seçimi', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildAvatarTypeTab('Hazır', 'preset'),
              _buildAvatarTypeTab('Yükle', 'custom'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_avatarType == 'preset') ...[
          const Text('Cinsiyet', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildGenderOption(
                      'Erkek', 'male', 'assets/images/icon_m.png')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildGenderOption(
                      'Kadın', 'female', 'assets/images/icon_w.png')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Arka Plan Rengi',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AppColors.avatarBackgrounds.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedBgColor = color);
                  _updatePresetPreview();
                },
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 20,
                  child: _selectedBgColor == color
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ] else ...[
          // Custom Upload
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white24, style: BorderStyle.solid),
              ),
              child: _customImageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_customImageFile!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 40, color: Colors.white54),
                        SizedBox(height: 8),
                        Text('Galeriden Seç',
                            style: TextStyle(color: Colors.white54)),
                      ],
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarTypeTab(String title, String value) {
    final isSelected = _avatarType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _avatarType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String label, String value, String assetPath) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedGender = value);
        _updatePresetPreview();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Kullanıcı istegi uzerine ikon boyutu kucultuldu
            Image.asset(
              assetPath,
              width: 48, // Reverted to original 48
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rol', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          dropdownColor: AppColors.surfaceDark,
          items: _roles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(
                _getRoleDisplay(role),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedRole = value!),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    const Color yellowHighlight = Color(0xFFFFB81C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('İlgi Alanları',
                style: TextStyle(color: Colors.white70)),
            Text(
              '${_selectedInterests.length} seçildi',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
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
              selectedColor: yellowHighlight, // Yellow Background when selected
              checkmarkColor: Colors.black, // Contrast for yellow
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70, // Contrast
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}
