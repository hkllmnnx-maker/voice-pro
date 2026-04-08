import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recording_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/waveform_visualizer.dart';
import '../widgets/circular_level_indicator.dart';
import '../models/recording.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecordingProvider, SettingsProvider>(
      builder: (context, recorder, settings, _) {
        final isRecording = recorder.state == RecordingState.recording;
        final isPaused = recorder.state == RecordingState.paused;
        final isActive = isRecording || isPaused;

        if (isRecording && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        } else if (!isRecording && _pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.reset();
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.mic, color: AppColors.cyan, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'صوت برو',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'مسجل صوت احترافي',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Quality badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMedium,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.high_quality, color: AppColors.cyan, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              settings.formatLabel,
                              style: const TextStyle(
                                color: AppColors.cyan,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Text(
                        recorder.formattedTimer,
                        style: TextStyle(
                          color: isRecording ? AppColors.redAccent : AppColors.textPrimary,
                          fontSize: 52,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'monospace',
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: isRecording
                              ? AppColors.redAccent.withValues(alpha: 0.15)
                              : isPaused
                                  ? AppColors.amber.withValues(alpha: 0.15)
                                  : AppColors.surfaceMedium,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isRecording
                                    ? AppColors.redAccent
                                    : isPaused
                                        ? AppColors.amber
                                        : AppColors.textTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isRecording ? 'جارٍ التسجيل...' : isPaused ? 'متوقف مؤقتاً' : 'جاهز للتسجيل',
                              style: TextStyle(
                                color: isRecording
                                    ? AppColors.redAccent
                                    : isPaused
                                        ? AppColors.amber
                                        : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Circular Level Indicator
                Expanded(
                  child: Center(
                    child: CircularLevelIndicator(
                      level: recorder.currentLevel,
                      size: 220,
                    ),
                  ),
                ),

                // Waveform
                if (isActive && recorder.waveformData.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMedium.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: WaveformVisualizer(
                      waveformData: recorder.waveformData,
                      height: 70,
                      isRecording: isRecording,
                    ),
                  ),

                const SizedBox(height: 16),

                // Info chips
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(Icons.album, settings.formatLabel),
                        const SizedBox(width: 10),
                        _buildInfoChip(Icons.speed, settings.qualityLabel),
                        const SizedBox(width: 10),
                        _buildInfoChip(Icons.graphic_eq, '${recorder.currentDb.toStringAsFixed(0)} dB'),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isActive) ...[
                        // Cancel
                        _buildControlButton(
                          icon: Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 52,
                          onTap: () => recorder.cancelRecording(),
                          tooltip: 'إلغاء',
                        ),
                        const SizedBox(width: 24),
                      ],

                      // Main record button
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isRecording ? _pulseAnimation.value : 1.0,
                            child: child,
                          );
                        },
                        child: GestureDetector(
                          onTap: () {
                            if (!isActive) {
                              recorder.startRecording();
                            } else if (isRecording) {
                              recorder.pauseRecording();
                            } else if (isPaused) {
                              recorder.resumeRecording();
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isRecording ? AppColors.recordGradient : AppColors.cyanGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: (isRecording ? AppColors.redAccent : AppColors.cyan).withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isRecording
                                  ? Icons.pause_rounded
                                  : isPaused
                                      ? Icons.play_arrow_rounded
                                      : Icons.mic_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                      ),

                      if (isActive) ...[
                        const SizedBox(width: 24),
                        // Stop / Save
                        _buildControlButton(
                          icon: Icons.stop_rounded,
                          color: AppColors.green,
                          size: 52,
                          onTap: () => _showSaveDialog(context, recorder, settings),
                          tooltip: 'حفظ',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceMedium,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.cyan, size: 14),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    double size = 48,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: color, size: size * 0.5),
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, RecordingProvider recorder, SettingsProvider settings) {
    final controller = TextEditingController(
      text: '${settings.filePrefix}_${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
    );
    RecordingCategory selectedCategory = settings.defaultCategory;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.save_rounded, color: AppColors.cyan),
                SizedBox(width: 10),
                Text('حفظ التسجيل', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  style: const TextStyle(color: AppColors.textPrimary),
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'اسم التسجيل',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceMedium,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cyan),
                    ),
                    prefixIcon: const Icon(Icons.edit, color: AppColors.cyan),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMedium,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<RecordingCategory>(
                    value: selectedCategory,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceMedium,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.expand_more, color: AppColors.cyan),
                    items: RecordingCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat.label, style: const TextStyle(color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCategory = val);
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  recorder.stopRecording(
                    controller.text.isEmpty ? 'تسجيل بدون عنوان' : controller.text,
                    settings.format,
                    settings.quality,
                    selectedCategory,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.green),
                          SizedBox(width: 8),
                          Text('تم حفظ التسجيل بنجاح', style: TextStyle(fontFamily: 'Roboto')),
                        ],
                      ),
                      backgroundColor: AppColors.surfaceMedium,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
