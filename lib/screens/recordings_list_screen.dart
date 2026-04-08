import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recording_provider.dart';
import '../theme/app_theme.dart';
import '../models/recording.dart';
import 'player_screen.dart';

class RecordingsListScreen extends StatefulWidget {
  const RecordingsListScreen({super.key});

  @override
  State<RecordingsListScreen> createState() => _RecordingsListScreenState();
}

class _RecordingsListScreenState extends State<RecordingsListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingProvider>(
      builder: (context, provider, _) {
        final recordings = provider.recordings;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _isSearching
                                ? TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    style: const TextStyle(color: AppColors.textPrimary),
                                    textDirection: TextDirection.rtl,
                                    decoration: InputDecoration(
                                      hintText: 'ابحث في التسجيلات...',
                                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                                      filled: true,
                                      fillColor: AppColors.surfaceMedium,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.search, color: AppColors.cyan),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                                        onPressed: () {
                                          setState(() {
                                            _isSearching = false;
                                            _searchController.clear();
                                            provider.setSearchQuery('');
                                          });
                                        },
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    onChanged: (val) => provider.setSearchQuery(val),
                                  )
                                : const Text(
                                    'التسجيلات',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                          if (!_isSearching) ...[
                            const SizedBox(width: 12),
                            _buildActionIcon(
                              Icons.search,
                              () => setState(() => _isSearching = true),
                            ),
                            _buildActionIcon(
                              provider.showBookmarksOnly ? Icons.bookmark : Icons.bookmark_border,
                              () => provider.toggleBookmarksOnly(),
                              isActive: provider.showBookmarksOnly,
                            ),
                            _buildActionIcon(
                              Icons.sort,
                              () => _showSortSheet(context, provider),
                            ),
                            _buildActionIcon(
                              Icons.filter_list,
                              () => _showFilterSheet(context, provider),
                              isActive: provider.filterCategory != null,
                            ),
                          ],
                        ],
                      ),

                      // Stats bar
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMedium.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildStat('الإجمالي', '${provider.allRecordings.length}'),
                            Container(width: 1, height: 20, color: AppColors.surfaceLight),
                            _buildStat('المعروضة', '${recordings.length}'),
                            Container(width: 1, height: 20, color: AppColors.surfaceLight),
                            _buildStat('المفضلة', '${provider.allRecordings.where((r) => r.isBookmarked).length}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Category chips
                if (!_isSearching)
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildCategoryChip(null, 'الكل', provider),
                        ...RecordingCategory.values.map(
                          (cat) => _buildCategoryChip(cat, cat.label, provider),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Recording list
                Expanded(
                  child: recordings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: recordings.length,
                          itemBuilder: (context, index) {
                            return _buildRecordingTile(context, recordings[index], provider);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.cyan.withValues(alpha: 0.15) : AppColors.surfaceMedium,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isActive ? AppColors.cyan : AppColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: AppColors.cyan, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(RecordingCategory? category, String label, RecordingProvider provider) {
    final isSelected = provider.filterCategory == category;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () => provider.setFilterCategory(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cyan.withValues(alpha: 0.15) : AppColors.surfaceMedium,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.cyan : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.cyan : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingTile(BuildContext context, Recording recording, RecordingProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          provider.playRecording(recording);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlayerScreen(recording: recording)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Play icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: AppColors.cyan, size: 28),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recording.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (recording.isBookmarked)
                          const Icon(Icons.bookmark, color: AppColors.amber, size: 16),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _buildMiniTag(recording.category.label, AppColors.purple),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, color: AppColors.textTertiary, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          recording.formattedDuration,
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          recording.formattedSize,
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          recording.formattedDate,
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMedium,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            recording.format.label,
                            style: const TextStyle(color: AppColors.cyan, fontSize: 9, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // More options
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textTertiary, size: 20),
                color: AppColors.surfaceMedium,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (ctx) => [
                  _buildPopupItem('rename', Icons.edit, 'إعادة تسمية'),
                  _buildPopupItem(
                    'bookmark',
                    recording.isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
                    recording.isBookmarked ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                  ),
                  _buildPopupItem('category', Icons.category, 'تغيير التصنيف'),
                  _buildPopupItem('info', Icons.info_outline, 'معلومات الملف'),
                  _buildPopupItem('delete', Icons.delete_outline, 'حذف', isDestructive: true),
                ],
                onSelected: (val) => _handleMenuAction(context, val, recording, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String text, {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? AppColors.redAccent : AppColors.textSecondary, size: 18),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: isDestructive ? AppColors.redAccent : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, Recording recording, RecordingProvider provider) {
    switch (action) {
      case 'rename':
        _showRenameDialog(context, recording, provider);
        break;
      case 'bookmark':
        provider.toggleBookmark(recording.id);
        break;
      case 'category':
        _showCategoryDialog(context, recording, provider);
        break;
      case 'info':
        _showInfoDialog(context, recording);
        break;
      case 'delete':
        _showDeleteDialog(context, recording, provider);
        break;
    }
  }

  void _showRenameDialog(BuildContext context, Recording recording, RecordingProvider provider) {
    final controller = TextEditingController(text: recording.title);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('إعادة تسمية', style: TextStyle(color: AppColors.textPrimary)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary),
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceMedium,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cyan),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.renameRecording(recording.id, controller.text);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan, foregroundColor: AppColors.background),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, Recording recording, RecordingProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تغيير التصنيف', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: RecordingCategory.values.map((cat) {
              return ListTile(
                onTap: () {
                  provider.updateCategory(recording.id, cat);
                  Navigator.pop(ctx);
                },
                leading: Icon(
                  recording.category == cat ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: recording.category == cat ? AppColors.cyan : AppColors.textTertiary,
                ),
                title: Text(cat.label, style: const TextStyle(color: AppColors.textPrimary)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, Recording recording) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.cyan),
              SizedBox(width: 10),
              Text('معلومات الملف', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('الاسم', recording.title),
              _buildInfoRow('المدة', recording.formattedDuration),
              _buildInfoRow('الحجم', recording.formattedSize),
              _buildInfoRow('الصيغة', recording.format.label),
              _buildInfoRow('الجودة', recording.quality.label),
              _buildInfoRow('التصنيف', recording.category.label),
              _buildInfoRow('التاريخ', recording.formattedDate),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق', style: TextStyle(color: AppColors.cyan)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Recording recording, RecordingProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('حذف التسجيل', style: TextStyle(color: AppColors.textPrimary)),
          content: Text(
            'هل أنت متأكد من حذف "${recording.title}"؟\nلا يمكن التراجع عن هذا الإجراء.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deleteRecording(recording.id);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.redAccent),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context, RecordingProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('ترتيب حسب', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildSortOption(ctx, provider, SortOption.dateDesc, 'الأحدث أولاً', Icons.arrow_downward),
              _buildSortOption(ctx, provider, SortOption.dateAsc, 'الأقدم أولاً', Icons.arrow_upward),
              _buildSortOption(ctx, provider, SortOption.nameAsc, 'الاسم (أ-ي)', Icons.sort_by_alpha),
              _buildSortOption(ctx, provider, SortOption.nameDesc, 'الاسم (ي-أ)', Icons.sort_by_alpha),
              _buildSortOption(ctx, provider, SortOption.durationDesc, 'الأطول مدة', Icons.timer),
              _buildSortOption(ctx, provider, SortOption.sizeDesc, 'الأكبر حجماً', Icons.storage),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, RecordingProvider provider, SortOption option, String label, IconData icon) {
    final isSelected = provider.sortOption == option;
    return ListTile(
      onTap: () {
        provider.setSortOption(option);
        Navigator.pop(context);
      },
      leading: Icon(icon, color: isSelected ? AppColors.cyan : AppColors.textTertiary),
      title: Text(label, style: TextStyle(color: isSelected ? AppColors.cyan : AppColors.textPrimary)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.cyan) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _showFilterSheet(BuildContext context, RecordingProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('تصفية حسب التصنيف', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ListTile(
                onTap: () {
                  provider.setFilterCategory(null);
                  Navigator.pop(ctx);
                },
                leading: Icon(Icons.all_inclusive, color: provider.filterCategory == null ? AppColors.cyan : AppColors.textTertiary),
                title: Text('عرض الكل', style: TextStyle(color: provider.filterCategory == null ? AppColors.cyan : AppColors.textPrimary)),
                trailing: provider.filterCategory == null ? const Icon(Icons.check, color: AppColors.cyan) : null,
              ),
              ...RecordingCategory.values.map((cat) {
                final isSelected = provider.filterCategory == cat;
                return ListTile(
                  onTap: () {
                    provider.setFilterCategory(cat);
                    Navigator.pop(ctx);
                  },
                  leading: Icon(Icons.label, color: isSelected ? AppColors.cyan : AppColors.textTertiary),
                  title: Text(cat.label, style: TextStyle(color: isSelected ? AppColors.cyan : AppColors.textPrimary)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.cyan) : null,
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_off_rounded, color: AppColors.textTertiary.withValues(alpha: 0.3), size: 80),
          const SizedBox(height: 16),
          const Text(
            'لا توجد تسجيلات',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بتسجيل صوتك من شاشة التسجيل',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
