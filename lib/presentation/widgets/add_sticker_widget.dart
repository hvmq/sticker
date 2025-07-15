import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:star_sticker/presentation/pages/edit_sticker_page.dart';

import '../provider/sticker_provider.dart';

class AddStickerWidget extends StatelessWidget {
  const AddStickerWidget({super.key});

  Future<void> _pickAndOpenSticker(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected.")),
        );
        return;
      }

      final File imageFile = File(pickedFile.path);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: context.read<StickerProvider>(),
            child: EditStickerPage(imageFile: imageFile),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickAndOpenSticker(context),
      child: const Icon(
        Icons.add_reaction_outlined,
        size: 25,
        color: Colors.grey,
      ),
    );
  }
}
