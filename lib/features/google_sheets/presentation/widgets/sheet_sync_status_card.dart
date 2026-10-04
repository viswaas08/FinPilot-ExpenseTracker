import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/google_sheets/data/models/google_sheets_config.dart';

class SheetSyncStatusCard extends StatefulWidget {
  final GoogleSheetsConfig config;
  final bool isSyncing;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onSyncNow;
  final VoidCallback onOpenSpreadsheet;
  final ValueChanged<String>? onSaveSheetUrl;

  const SheetSyncStatusCard({
    super.key,
    required this.config,
    required this.isSyncing,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSyncNow,
    required this.onOpenSpreadsheet,
    this.onSaveSheetUrl,
  });

  @override
  State<SheetSyncStatusCard> createState() => _SheetSyncStatusCardState();
}

class _SheetSyncStatusCardState extends State<SheetSyncStatusCard> {
  late final TextEditingController _urlController;
  bool _isEditingUrl = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.config.spreadsheetUrl ?? '');
  }

  @override
  void didUpdateWidget(covariant SheetSyncStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.spreadsheetUrl != widget.config.spreadsheetUrl && !_isEditingUrl) {
      _urlController.text = widget.config.spreadsheetUrl ?? '';
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final isConnected = widget.config.isConnected;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sync_rounded, color: AppColors.goldPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Live Google Sheets Sync & URL Link',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.income.withValues(alpha: 0.15)
                      : AppColors.goldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isConnected
                        ? AppColors.income.withValues(alpha: 0.4)
                        : AppColors.goldPrimary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isConnected ? AppColors.income : AppColors.goldPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? 'Active & Synced' : 'Ready to Connect',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isConnected ? AppColors.income : AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Spreadsheet URL input
          Text(
            'Link Your Google Sheet (Paste Spreadsheet URL or ID):',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _urlController,
                    onChanged: (_) => setState(() => _isEditingUrl = true),
                    style: TextStyle(fontSize: 12, color: textColor, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'https://docs.google.com/spreadsheets/d/.../edit',
                      hintStyle: TextStyle(fontSize: 12, color: subTextColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.table_view_rounded, size: 18, color: AppColors.goldPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (widget.onSaveSheetUrl != null) {
                    widget.onSaveSheetUrl!(_urlController.text);
                    setState(() => _isEditingUrl = false);
                  } else {
                    widget.onConnect();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Save & Link', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Sheet Target', style: TextStyle(fontSize: 11, color: subTextColor)),
                    Flexible(
                      child: Text(
                        widget.config.spreadsheetId ?? 'FinPilot Master Sheet (Auto-Linked)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Last Synced', style: TextStyle(fontSize: 11, color: subTextColor)),
                    Text(
                      widget.config.lastSyncTime != null
                          ? DateFormatter.formatRelative(widget.config.lastSyncTime!)
                          : 'Just now',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.isSyncing ? null : widget.onSyncNow,
                  icon: widget.isSyncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16, color: Colors.black),
                  label: Text(
                    widget.isSyncing ? 'Synchronizing...' : 'Sync Live Data Now',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: widget.onOpenSpreadsheet,
                icon: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.goldPrimary),
                label: const Text(
                  'Open in Google Sheets',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.goldPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                ),
              ),
              if (isConnected) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Disconnect',
                  onPressed: widget.onDisconnect,
                  icon: const Icon(Icons.link_off_rounded, color: AppColors.error, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
