import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../models/recording.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                const Text(
                  'الإعدادات',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'تخصيص إعدادات التسجيل والتشغيل',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Recording section
                _buildSectionHeader('إعدادات التسجيل', Icons.mic_rounded),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  children: [
                    _buildDropdownTile<AudioFormat>(
                      icon: Icons.album_rounded,
                      title: 'صيغة التسجيل',
                      subtitle: settings.format.description,
                      value: settings.format,
                      items: AudioFormat.values,
                      itemLabels: AudioFormat.values.map((f) => '${f.label} - ${f.description}').toList(),
                      onChanged: (val) => settings.setFormat(val),
                    ),
                    _buildDivider(),
                    _buildDropdownTile<AudioQuality>(
                      icon: Icons.high_quality_rounded,
                      title: 'جودة الصوت',
                      subtitle: settings.quality.description,
                      value: settings.quality,
                      items: AudioQuality.values,
                      itemLabels: AudioQuality.values.map((q) => '${q.label} - ${q.description}').toList(),
                      onChanged: (val) => settings.setQuality(val),
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.text_fields_rounded,
                      title: 'بادئة اسم الملف',
                      subtitle: settings.filePrefix,
                    ),
                    _buildDivider(),
                    _buildDropdownTile<RecordingCategory>(
                      icon: Icons.category_rounded,
                      title: 'التصنيف الافتراضي',
                      subtitle: settings.defaultCategory.label,
                      value: settings.defaultCategory,
                      items: RecordingCategory.values,
                      itemLabels: RecordingCategory.values.map((c) => c.label).toList(),
                      onChanged: (val) => settings.setDefaultCategory(val),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Audio Processing section
                _buildSectionHeader('معالجة الصوت', Icons.tune_rounded),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.noise_aware_rounded,
                      title: 'كبت الضوضاء',
                      subtitle: 'تقليل الضوضاء المحيطة أثناء التسجيل',
                      value: settings.noiseSuppression,
                      onChanged: (_) => settings.toggleNoiseSuppression(),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.volume_up_rounded,
                      title: 'التحكم التلقائي في الكسب',
                      subtitle: 'ضبط مستوى الصوت تلقائياً',
                      value: settings.autoGainControl,
                      onChanged: (_) => settings.toggleAutoGainControl(),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.surround_sound_rounded,
                      title: 'إلغاء الصدى',
                      subtitle: 'إزالة الصدى من التسجيل',
                      value: settings.echoCancellation,
                      onChanged: (_) => settings.toggleEchoCancellation(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Display section
                _buildSectionHeader('العرض والواجهة', Icons.palette_rounded),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.graphic_eq_rounded,
                      title: 'عرض الموجات الصوتية',
                      subtitle: 'إظهار التمثيل البصري للصوت أثناء التسجيل',
                      value: settings.showWaveform,
                      onChanged: (_) => settings.toggleShowWaveform(),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.save_rounded,
                      title: 'الحفظ التلقائي',
                      subtitle: 'حفظ التسجيل تلقائياً عند الإيقاف',
                      value: settings.autoSave,
                      onChanged: (_) => settings.toggleAutoSave(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // About section
                _buildSectionHeader('حول التطبيق', Icons.info_outline_rounded),
                const SizedBox(height: 12),
                _buildSettingsCard(
                  children: [
                    _buildInfoTile(
                      icon: Icons.apps_rounded,
                      title: 'اسم التطبيق',
                      subtitle: 'صوت برو - مسجل صوت احترافي',
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.verified_rounded,
                      title: 'الإصدار',
                      subtitle: '1.0.0',
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.code_rounded,
                      title: 'مبني بـ',
                      subtitle: 'Flutter & Dart',
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.cyan, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.3)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.surfaceLight.withValues(alpha: 0.3),
      height: 1,
      indent: 56,
    );
  }

  Widget _buildDropdownTile<T>({
    required IconData icon,
    required String title,
    required String subtitle,
    required T value,
    required List<T> items,
    required List<String> itemLabels,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.cyan, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.expand_more, color: AppColors.cyan, size: 22),
            color: AppColors.surfaceMedium,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (ctx) {
              return List.generate(items.length, (i) {
                return PopupMenuItem<int>(
                  value: i,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      itemLabels[i],
                      style: TextStyle(
                        color: items[i] == value ? AppColors.cyan : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: items[i] == value ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              });
            },
            onSelected: (idx) => onChanged(items[idx]),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.cyan, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.cyan,
            activeTrackColor: AppColors.cyan.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.surfaceDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.cyan, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
