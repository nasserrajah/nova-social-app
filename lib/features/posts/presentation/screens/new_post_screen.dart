import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../data/repositories/posts_repository.dart';
import '../bloc/create_post_bloc.dart';
import '../bloc/create_post_event.dart';
import '../bloc/create_post_state.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _picker = ImagePicker();
  final _contentController = TextEditingController();
  final _notificationController = TopNotificationController();

  File? _imageFile;
  bool _showTextField = false;

  @override
  void dispose() {
    _notificationController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _submit() {
    context.read<CreatePostBloc>().add(
      CreatePostSubmitted(
        content: _contentController.text,
        image: _imageFile,
        isArabic: context.isArabic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final purple = Colors.purple.shade400;

    return BlocListener<CreatePostBloc, CreatePostState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        _notificationController.show(
          context,
          message: state.message!,
          isSuccess: state.isSuccess,
        );

        if (state.isSuccess) {
          final navigator = Navigator.of(context);
          Future<void>.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) navigator.pop();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                purple.withValues(alpha: 0.15),
                Colors.black,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.2, 0.8],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(isArabic, purple),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStoryElement(
                            isArabic ? 'نص' : 'Text',
                            Icons.text_fields,
                            purple,
                            Colors.amber,
                            onTap: () {
                              setState(() => _showTextField = !_showTextField);
                            },
                          ),
                          const SizedBox(width: 30),
                          _buildStoryElement(
                            isArabic ? 'المعرض' : 'Gallery',
                            Icons.photo_library,
                            purple,
                            Colors.amber,
                            onTap: _pickImage,
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      if (_showTextField) ...[
                        TextField(
                          controller: _contentController,
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          textDirection: context.appTextDirection,
                          decoration: InputDecoration(
                            hintText: isArabic
                                ? 'اكتب محتوى المنشور هنا'
                                : 'Write your post here',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.grey.shade900.withValues(
                              alpha: 0.6,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: purple, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          maxLines: 5,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_imageFile != null)
                        Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: purple.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(isArabic, purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArabic, Color purple) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [purple, Colors.amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            isArabic ? 'منشور جديد' : 'New Post',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isArabic, Color purple) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: Text(isArabic ? 'اختر صورة' : 'Pick Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: Colors.amber.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BlocBuilder<CreatePostBloc, CreatePostState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: purple.withValues(alpha: 0.5),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isArabic ? 'نشر' : 'Post'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryElement(
    String title,
    IconData icon,
    Color backgroundColor,
    Color iconColor, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: backgroundColor),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.2),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: backgroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Convenience wrapper that provides [CreatePostBloc] to the screen.
class NewPostPage extends StatelessWidget {
  const NewPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CreatePostBloc(repository: context.read<PostsRepository>()),
      child: const NewPostScreen(),
    );
  }
}
