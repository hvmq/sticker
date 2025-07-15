import 'package:flutter/material.dart';

import '../../models/sticker.dart';
import '../provider/sticker_provider.dart';

class StickerPreviewOverlay extends StatefulWidget {
  final Sticker sticker;
  final VoidCallback onDismiss;
  final Function(Sticker) onSend;
  final StickerProvider stickerProvider;

  const StickerPreviewOverlay({
    super.key,
    required this.sticker,
    required this.onDismiss,
    required this.onSend,
    required this.stickerProvider,
  });

  @override
  State<StickerPreviewOverlay> createState() => _StickerPreviewOverlayState();
}

class _StickerPreviewOverlayState extends State<StickerPreviewOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await Future.wait([
      _scaleController.reverse(),
      _fadeController.reverse(),
      _slideController.reverse(),
    ]);
    widget.onDismiss();
  }

  void _handleAction(String action) async {
    switch (action) {
      case 'send':
        widget.onSend(widget.sticker);
        break;
      case 'favorite':
        await widget.stickerProvider
            .toggleFavorite(stickerId: widget.sticker.id);
        break;
      case 'collection':
        // TODO: Implement collection functionality
        print('Add to collection: ${widget.sticker.id}');
        break;
      case 'detail':
        // TODO: Implement detail view
        print('Show detail: ${widget.sticker.id}');
        break;
    }

    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _dismiss, // Tap outside to dismiss
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Container(
              color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
              child: Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from bubbling up
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Enlarged Sticker
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  widget.sticker.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Compact Action Buttons
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildCompactActionButton(
                                    icon: Icons.send,
                                    label: 'Gửi Sticker',
                                    isDivider: true,
                                    onTap: () => _handleAction('send'),
                                  ),
                                  const SizedBox(width: 4),
                                  _buildCompactActionButton(
                                    icon: widget.stickerProvider
                                            .isFavorite(widget.sticker.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    label: 'Yêu thích',
                                    isDivider: false,
                                    onTap: () => _handleAction('favorite'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDivider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
            if (isDivider)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Divider(
                  color: Colors.grey,
                  height: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
