import 'package:flutter/material.dart';
import 'colors.dart';
import 'motion.dart';
import 'radius.dart';

class QuantumSidebarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const QuantumSidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

class QuantumSidebar extends StatelessWidget {
  final List<QuantumSidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final String userName;
  final String userEmail;
  final VoidCallback? onProfileTap;

  const QuantumSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userName,
    required this.userEmail,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: QuantumColors.secondaryBackground,
        border: Border(right: BorderSide(color: QuantumColors.glassBorder, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [QuantumColors.primaryAccent, QuantumColors.violet],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: QuantumColors.primaryAccent.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FinPilot AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: QuantumColors.primaryText,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Quantum Finance Engine',
                      style: TextStyle(
                        fontSize: 10,
                        color: QuantumColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Navigation Items List
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedIndex == index;

                return _QuantumSidebarTile(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),

          // Bottom User Profile Card
          MouseRegion(
            cursor: onProfileTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: onProfileTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedIndex == items.length ? QuantumColors.primaryAccent.withValues(alpha: 0.18) : QuantumColors.glassSurface,
                  borderRadius: QuantumRadius.borderMd,
                  border: Border.all(
                    color: selectedIndex == items.length ? QuantumColors.primaryAccent : QuantumColors.glassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: QuantumColors.primaryAccent,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: QuantumColors.primaryText, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            userEmail,
                            style: const TextStyle(fontSize: 10, color: QuantumColors.mutedText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantumSidebarTile extends StatefulWidget {
  final QuantumSidebarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuantumSidebarTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_QuantumSidebarTile> createState() => _QuantumSidebarTileState();
}

class _QuantumSidebarTileState extends State<_QuantumSidebarTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isSelected ? QuantumColors.primaryAccent : (_isHovered ? QuantumColors.cyan : QuantumColors.mutedText);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: QuantumMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? QuantumColors.primaryAccent.withValues(alpha: 0.18)
                : (_isHovered ? QuantumColors.glassSurface : Colors.transparent),
            borderRadius: QuantumRadius.borderMd,
            border: Border.all(
              color: widget.isSelected
                  ? QuantumColors.primaryAccent.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.isSelected ? widget.item.selectedIcon : widget.item.icon,
                size: 20,
                color: activeColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    color: widget.isSelected ? QuantumColors.primaryText : activeColor,
                    fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: QuantumColors.primaryAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: QuantumColors.primaryAccent, blurRadius: 6),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
