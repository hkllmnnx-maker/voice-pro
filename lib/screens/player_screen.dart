import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recording_provider.dart';
import '../theme/app_theme.dart';
import '../models/recording.dart';
import '../widgets/waveform_player.dart';

class PlayerScreen extends StatelessWidget {
  final Recording recording;

  const PlayerScreen({super.key, required this.recording});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingProvider>(
      builder: (context, provider, _) {
        final isPlaying = provider.isPlaying;
        final position = provider.playerPosition;
        final duration = recording.duration;
        final speed = provider.playbackSpeed;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
              onPressed: () {
                provider.stopPlayback();
                Navigator.pop(context);
              },
            ),
            title: const Text('المشغل', style: TextStyle(color: AppColors.textPrimary)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  recording.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: recording.isBookmarked ? AppColors.amber : AppColors.textSecondary,
                ),
                onPressed: () => provider.toggleBookmark(recording.id),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Album art placeholder
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cyan.withValues(alpha: 0.15),
                          AppColors.purple.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isPlaying ? Icons.graphic_eq : Icons.mic_rounded,
                          color: AppColors.cyan,
                          size: 60,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMedium,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recording.format.label,
                            style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Title and info
                  Text(
                    recording.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoTag(recording.category.label, AppColors.purple),
                      const SizedBox(width: 8),
                      _buildInfoTag(recording.quality.label, AppColors.teal),
                      const SizedBox(width: 8),
                      _buildInfoTag(recording.formattedSize, AppColors.amber),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Waveform
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMedium.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: WaveformPlayer(
                      duration: duration,
                      position: position,
                      isPlaying: isPlaying,
                      onSeek: (pos) => provider.seekTo(pos),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Time labels
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(color: AppColors.cyan, fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'monospace'),
                        ),
                        Text(
                          '-${_formatDuration(duration - position)}',
                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 13, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Speed control
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMedium,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('السرعة', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(width: 12),
                        ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                          final isActive = speed == s;
                          return GestureDetector(
                            onTap: () => provider.setPlaybackSpeed(s),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.cyan : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${s}x',
                                style: TextStyle(
                                  color: isActive ? AppColors.background : AppColors.textTertiary,
                                  fontSize: 11,
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Playback controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Backward 10s
                      _buildControlBtn(
                        icon: Icons.replay_10_rounded,
                        size: 52,
                        onTap: () => provider.seekBackward(),
                      ),

                      const SizedBox(width: 24),

                      // Play/Pause
                      GestureDetector(
                        onTap: () => provider.togglePlayPause(),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.cyanGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Forward 10s
                      _buildControlBtn(
                        icon: Icons.forward_10_rounded,
                        size: 52,
                        onTap: () => provider.seekForward(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildControlBtn({required IconData icon, double size = 48, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceMedium,
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: size * 0.5),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
