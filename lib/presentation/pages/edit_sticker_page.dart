import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import 'package:provider/provider.dart';
import 'package:star_sticker/models/sticker.dart';
import 'package:star_sticker/presentation/provider/sticker_provider.dart';
import 'package:star_sticker/services/remove_bg_api.dart';
import 'package:star_sticker/sticker_sdk.dart';

class EditStickerPage extends StatefulWidget {
  final File imageFile;

  const EditStickerPage({super.key, required this.imageFile});

  @override
  State<EditStickerPage> createState() => _EditStickerPageState();

  // Hàm mở trang và nhận lại kết quả
  static Future<Sticker?> open(BuildContext context, File imageFile) async {
    return await Navigator.push(context, MaterialPageRoute(builder: (_) => EditStickerPage(imageFile: imageFile)));
  }
}

class _EditStickerPageState extends State<EditStickerPage> {
  bool isLoading = false;
  bool isCutDone = false;
  late File displayedImage;

  Future<void> _handleRemoveBg() async {
    setState(() => isLoading = true);
    final File? removedBg = await RemoveBgService.removeBackground(displayedImage);
    setState(() => isLoading = false);

    if (removedBg != null) {
      setState(() {
        displayedImage = removedBg;
        isCutDone = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể xoá nền ảnh')));
      }
    }
  }

  Future<void> _handleEditImage() async {
    final originalBytes = displayedImage.readAsBytesSync();

    final editorOption = ImageEditorOption()
      ..addOption(FlipOption(horizontal: true))
      ..addOption(RotateOption(90));

    final editedBytes = await ImageEditor.editImage(image: originalBytes, imageEditorOption: editorOption);

    if (editedBytes != null) {
      final tempPath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      final editedFile = await File(tempPath).writeAsBytes(editedBytes);
      setState(() {
        displayedImage = editedFile;
        isCutDone = true;
      });
    }
  }

  void _handleSaveSticker() async {
    setState(() => isLoading = true);

    final sticker = Sticker(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: displayedImage.path,
      categoryId: '11',
      isPremium: false,
      status: 'active',
      usedCount: 0,
      tags: [],
      createdBy: StickerSDK.userId,
    );

    final provider = context.read<StickerProvider>();

    final success = await provider.uploadUserSticker(
      imageFile: displayedImage,
    );

    setState(() => isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, sticker);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể upload sticker')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    displayedImage = widget.imageFile;
  }

  Future<bool> _onWillPop() async {
    if (isCutDone) return true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn thoát?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Thoát')),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final double screenSize = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          leading: BackButton(color: Colors.white),
          title: const Text('Chỉnh sửa sticker', style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.file(displayedImage, fit: BoxFit.contain),
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _handleRemoveBg,
                            icon: const Icon(Icons.cut),
                            label: const Text('Xoá nền ảnh'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _handleEditImage,
                            icon: const Icon(Icons.edit),
                            label: const Text('Chỉnh sửa ảnh'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _handleSaveSticker,
                      icon: const Icon(Icons.check),
                      label: const Text('Dùng sticker này'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: screenSize * 0.035),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
