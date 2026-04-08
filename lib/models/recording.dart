import 'package:uuid/uuid.dart';

enum RecordingCategory {
  meeting('اجتماع', 'business'),
  interview('مقابلة', 'person'),
  lecture('محاضرة', 'school'),
  music('موسيقى', 'music_note'),
  personal('شخصي', 'person_outline'),
  memo('مذكرة', 'note'),
  other('أخرى', 'folder');

  final String label;
  final String iconName;
  const RecordingCategory(this.label, this.iconName);
}

enum AudioFormat {
  wav('WAV', 'غير مضغوط - جودة عالية'),
  mp3('MP3', 'مضغوط - حجم صغير'),
  aac('AAC', 'مضغوط - جودة متوسطة'),
  flac('FLAC', 'بدون فقد - جودة ممتازة');

  final String label;
  final String description;
  const AudioFormat(this.label, this.description);
}

enum AudioQuality {
  low('منخفضة', '16 كيلوهرتز / 64 كيلوبت'),
  standard('قياسية', '22 كيلوهرتز / 128 كيلوبت'),
  high('عالية', '44.1 كيلوهرتز / 256 كيلوبت'),
  ultra('فائقة', '48 كيلوهرتز / 320 كيلوبت');

  final String label;
  final String description;
  const AudioQuality(this.label, this.description);
}

class Recording {
  final String id;
  final String title;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;
  final int fileSizeBytes;
  final AudioFormat format;
  final AudioQuality quality;
  final RecordingCategory category;
  final bool isBookmarked;
  final String? notes;

  Recording({
    String? id,
    required this.title,
    required this.filePath,
    required this.createdAt,
    required this.duration,
    required this.fileSizeBytes,
    this.format = AudioFormat.mp3,
    this.quality = AudioQuality.standard,
    this.category = RecordingCategory.other,
    this.isBookmarked = false,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  String get formattedDuration {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes بايت';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} ك.ب';
    if (fileSizeBytes < 1024 * 1024 * 1024) return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} م.ب';
    return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} ج.ب';
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  Recording copyWith({
    String? title,
    bool? isBookmarked,
    RecordingCategory? category,
    String? notes,
  }) {
    return Recording(
      id: id,
      title: title ?? this.title,
      filePath: filePath,
      createdAt: createdAt,
      duration: duration,
      fileSizeBytes: fileSizeBytes,
      format: format,
      quality: quality,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
        'duration': duration.inMilliseconds,
        'fileSizeBytes': fileSizeBytes,
        'format': format.index,
        'quality': quality.index,
        'category': category.index,
        'isBookmarked': isBookmarked,
        'notes': notes,
      };

  factory Recording.fromJson(Map<String, dynamic> json) => Recording(
        id: json['id'] as String,
        title: json['title'] as String,
        filePath: json['filePath'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        duration: Duration(milliseconds: json['duration'] as int),
        fileSizeBytes: json['fileSizeBytes'] as int,
        format: AudioFormat.values[json['format'] as int],
        quality: AudioQuality.values[json['quality'] as int],
        category: RecordingCategory.values[json['category'] as int],
        isBookmarked: json['isBookmarked'] as bool? ?? false,
        notes: json['notes'] as String?,
      );
}
