import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/post_repository.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Mock user interests for now. In real app, fetch from user profile.
  final List<String> _userInterests = ['Frontend', 'Backend', 'Mobil'];
  final List<String> _selectedTags = [];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }
  // create_post_screen.dart dosyanızdaki _createPost fonksiyonunu bununla değiştirin:

  Future<void> _createPost() async {
    // 1. Kontrolleri yap
    final content = _contentController.text.trim();
    final hasImage = _selectedImage != null;

    // Veritabanı kuralını kontrol et: Resim yoksa içerik en az 50 karakter olmalı.
    if (!hasImage && content.length < 50) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.actionError,
            content: Text('Görsel yoksa en az 50 karakter yazmalısınız.'),
          ),
        );
      }
      return; // İşlemi durdur
    }

    setState(() => _isLoading = true);

    try {
      // 2. Repository üzerinden gönderiyi oluştur
      // content boşsa null gönder, doluysa içeriği gönder.
      // Bu, veritabanına boş string gitmesini engeller.
      await ref
          .read(postRepositoryProvider)
          .createPost(
            content: content.isEmpty ? null : content,
            imageFile: _selectedImage,
            tags:
                _selectedTags, // Etiketleri ID'lere çevirme mantığı repository'de olmalı
          );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gönderi paylaşıldı!')));
        context.pop(); // Başarılı olursa ekrandan çık
      }
    } catch (e) {
      // 3. Hata yönetimi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gönderi oluşturulamadı: ${e.toString()}'),
            backgroundColor: AppColors.actionError,
          ),
        );
      }
    } finally {
      // 4. Yüklenme durumunu kapat
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderi Oluştur'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              maxLength: 200,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Neler düşünüyorsun?',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.surfaceDark,
              ),
            ),
            const SizedBox(height: 16),

            // Image Selection
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _selectedImage = null),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: AppColors.primary),
                label: const Text(
                  'Görsel Ekle',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.all(16),
                ),
              ),

            const SizedBox(height: 24),

            // Tags
            const Text(
              'Etiketler (İlgi Alanların)',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _userInterests.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
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
              text: 'Paylaş',
              onPressed: _createPost,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
