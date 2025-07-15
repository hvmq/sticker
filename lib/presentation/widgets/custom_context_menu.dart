import 'package:flutter/material.dart';

class CustomContextMenu extends StatefulWidget {
  final Widget child;
  final List<ContextMenuItem> actions;
  final Duration animationDuration;

  const CustomContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<CustomContextMenu> createState() => _CustomContextMenuState();
}

class _CustomContextMenuState extends State<CustomContextMenu>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  OverlayEntry? _overlayEntry;
  bool _isMenuVisible = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: widget.animationDuration,
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
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _hideMenu();
    super.dispose();
  }

  void _showMenu() {
    if (_isMenuVisible) return;

    _isMenuVisible = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    _fadeController.forward();
    _scaleController.forward();
  }

  void _hideMenu() {
    if (!_isMenuVisible) return;

    _isMenuVisible = false;
    _fadeController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
    _scaleController.reverse();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => _MenuOverlay(
        fadeAnimation: _fadeAnimation,
        scaleAnimation: _scaleAnimation,
        actions: widget.actions,
        onDismiss: _hideMenu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (_) => _showMenu(),
      onLongPressStart: (_) => _showMenu(),
      child: widget.child,
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final List<ContextMenuItem> actions;
  final VoidCallback onDismiss;

  const _MenuOverlay({
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.actions,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([fadeAnimation, scaleAnimation]),
      builder: (context, child) {
        return Material(
          color: Colors.black.withValues(alpha: 0.3 * fadeAnimation.value),
          child: GestureDetector(
            onTap: onDismiss,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Transform.scale(
                  scale: scaleAnimation.value,
                  child: Opacity(
                    opacity: fadeAnimation.value,
                    child: _MenuContent(
                      actions: actions,
                      onDismiss: onDismiss,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MenuContent extends StatelessWidget {
  final List<ContextMenuItem> actions;
  final VoidCallback onDismiss;

  const _MenuContent({
    required this.actions,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 280,
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tùy chọn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            ...actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              final isLast = index == actions.length - 1;

              return _MenuItem(
                action: action,
                onDismiss: onDismiss,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final ContextMenuItem action;
  final VoidCallback onDismiss;
  final bool isLast;

  const _MenuItem({
    required this.action,
    required this.onDismiss,
    required this.isLast,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          widget.onDismiss();
          widget.action.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue[50] : Colors.transparent,
            border: widget.isLast
                ? null
                : Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
          ),
          child: Row(
            children: [
              if (widget.action.icon != null) ...[
                Icon(
                  widget.action.icon,
                  size: 20,
                  color: _isHovered ? Colors.blue[600] : Colors.grey[600],
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  widget.action.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _isHovered ? Colors.blue[600] : Colors.black87,
                  ),
                ),
              ),
              if (widget.action.trailing != null) widget.action.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class ContextMenuItem {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback onTap;

  const ContextMenuItem({
    required this.title,
    this.icon,
    this.trailing,
    required this.onTap,
  });
}
