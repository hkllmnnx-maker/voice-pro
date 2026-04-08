import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recording.dart';

enum RecordingState { idle, recording, paused }

enum SortOption { dateDesc, dateAsc, nameAsc, nameDesc, durationDesc, sizeDesc }

class RecordingProvider extends ChangeNotifier {
  RecordingState _state = RecordingState.idle;
  Duration _currentDuration = Duration.zero;
  Timer? _timer;
  Timer? _waveformTimer;
  double _currentLevel = 0.0;
  final List<double> _waveformData = [];
  List<Recording> _recordings = [];
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dateDesc;
  RecordingCategory? _filterCategory;
  bool _showBookmarksOnly = false;

  // Player state
  Recording? _currentlyPlaying;
  bool _isPlaying = false;
  Duration _playerPosition = Duration.zero;
  double _playbackSpeed = 1.0;

  // Getters
  RecordingState get state => _state;
  Duration get currentDuration => _currentDuration;
  double get currentLevel => _currentLevel;
  List<double> get waveformData => List.unmodifiable(_waveformData);
  List<Recording> get recordings => _getFilteredRecordings();
  List<Recording> get allRecordings => _recordings;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  RecordingCategory? get filterCategory => _filterCategory;
  bool get showBookmarksOnly => _showBookmarksOnly;
  Recording? get currentlyPlaying => _currentlyPlaying;
  bool get isPlaying => _isPlaying;
  Duration get playerPosition => _playerPosition;
  double get playbackSpeed => _playbackSpeed;
  bool get isRecording => _state == RecordingState.recording;
  bool get isPaused => _state == RecordingState.paused;

  String get formattedTimer {
    final h = _currentDuration.inHours;
    final m = _currentDuration.inMinutes.remainder(60);
    final s = _currentDuration.inSeconds.remainder(60);
    final ms = (_currentDuration.inMilliseconds.remainder(1000) ~/ 10);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
  }

  double get currentDb {
    return -60 + (_currentLevel * 60);
  }

  RecordingProvider() {
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('recordings') ?? [];
    _recordings = data.map((e) => Recording.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
    if (_recordings.isEmpty) {
      _generateDemoRecordings();
    }
    notifyListeners();
  }

  void _generateDemoRecordings() {
    final random = Random();
    final titles = [
      'اجتماع فريق العمل',
      'محاضرة الذكاء الاصطناعي',
      'مقابلة عمل - أحمد',
      'تسجيل ملاحظات المشروع',
      'اجتماع العميل - شركة النور',
      'محاضرة البرمجة المتقدمة',
      'مذكرة صوتية شخصية',
      'اجتماع التخطيط الشهري',
      'تسجيل بودكاست الحلقة ٣',
      'ملاحظات سفر - دبي',
      'مقابلة صحفية',
      'تسجيل موسيقي - عود',
    ];
    final categories = [
      RecordingCategory.meeting,
      RecordingCategory.lecture,
      RecordingCategory.interview,
      RecordingCategory.memo,
      RecordingCategory.meeting,
      RecordingCategory.lecture,
      RecordingCategory.personal,
      RecordingCategory.meeting,
      RecordingCategory.personal,
      RecordingCategory.memo,
      RecordingCategory.interview,
      RecordingCategory.music,
    ];

    for (int i = 0; i < titles.length; i++) {
      _recordings.add(Recording(
        title: titles[i],
        filePath: '/recordings/${titles[i].replaceAll(' ', '_')}.mp3',
        createdAt: DateTime.now().subtract(Duration(
          days: random.nextInt(30),
          hours: random.nextInt(24),
          minutes: random.nextInt(60),
        )),
        duration: Duration(
          minutes: random.nextInt(45) + 1,
          seconds: random.nextInt(60),
        ),
        fileSizeBytes: (random.nextDouble() * 50 + 1).toInt() * 1024 * 1024,
        format: AudioFormat.values[random.nextInt(AudioFormat.values.length)],
        quality: AudioQuality.values[random.nextInt(AudioQuality.values.length)],
        category: categories[i],
        isBookmarked: random.nextBool(),
      ));
    }
    _saveRecordings();
  }

  Future<void> _saveRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _recordings.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('recordings', data);
  }

  List<Recording> _getFilteredRecordings() {
    var list = List<Recording>.from(_recordings);

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Filter by category
    if (_filterCategory != null) {
      list = list.where((r) => r.category == _filterCategory).toList();
    }

    // Filter bookmarks
    if (_showBookmarksOnly) {
      list = list.where((r) => r.isBookmarked).toList();
    }

    // Sort
    switch (_sortOption) {
      case SortOption.dateDesc:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dateAsc:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.nameAsc:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameDesc:
        list.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.durationDesc:
        list.sort((a, b) => b.duration.compareTo(a.duration));
        break;
      case SortOption.sizeDesc:
        list.sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));
        break;
    }

    return list;
  }

  // Recording controls
  void startRecording() {
    _state = RecordingState.recording;
    _currentDuration = Duration.zero;
    _waveformData.clear();
    _currentLevel = 0.0;
    _startTimers();
    notifyListeners();
  }

  void pauseRecording() {
    _state = RecordingState.paused;
    _timer?.cancel();
    _waveformTimer?.cancel();
    notifyListeners();
  }

  void resumeRecording() {
    _state = RecordingState.recording;
    _startTimers();
    notifyListeners();
  }

  void stopRecording(String title, AudioFormat format, AudioQuality quality, RecordingCategory category) {
    _state = RecordingState.idle;
    _timer?.cancel();
    _waveformTimer?.cancel();

    if (_currentDuration.inSeconds > 0) {
      final recording = Recording(
        title: title,
        filePath: '/recordings/${title.replaceAll(' ', '_')}.${format.label.toLowerCase()}',
        createdAt: DateTime.now(),
        duration: _currentDuration,
        fileSizeBytes: _estimateFileSize(_currentDuration, quality),
        format: format,
        quality: quality,
        category: category,
      );
      _recordings.insert(0, recording);
      _saveRecordings();
    }

    _currentDuration = Duration.zero;
    _currentLevel = 0.0;
    _waveformData.clear();
    notifyListeners();
  }

  void cancelRecording() {
    _state = RecordingState.idle;
    _timer?.cancel();
    _waveformTimer?.cancel();
    _currentDuration = Duration.zero;
    _currentLevel = 0.0;
    _waveformData.clear();
    notifyListeners();
  }

  void _startTimers() {
    final random = Random();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _currentDuration += const Duration(milliseconds: 50);
      notifyListeners();
    });

    _waveformTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _currentLevel = 0.3 + random.nextDouble() * 0.7;
      _waveformData.add(_currentLevel);
      if (_waveformData.length > 300) {
        _waveformData.removeAt(0);
      }
      notifyListeners();
    });
  }

  int _estimateFileSize(Duration duration, AudioQuality quality) {
    final seconds = duration.inSeconds;
    switch (quality) {
      case AudioQuality.low:
        return seconds * 8000;
      case AudioQuality.standard:
        return seconds * 16000;
      case AudioQuality.high:
        return seconds * 32000;
      case AudioQuality.ultra:
        return seconds * 40000;
    }
  }

  // Search & Filter
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setSortOption(SortOption o) {
    _sortOption = o;
    notifyListeners();
  }

  void setFilterCategory(RecordingCategory? c) {
    _filterCategory = c;
    notifyListeners();
  }

  void toggleBookmarksOnly() {
    _showBookmarksOnly = !_showBookmarksOnly;
    notifyListeners();
  }

  // Recording management
  void toggleBookmark(String id) {
    final idx = _recordings.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _recordings[idx] = _recordings[idx].copyWith(isBookmarked: !_recordings[idx].isBookmarked);
      _saveRecordings();
      notifyListeners();
    }
  }

  void renameRecording(String id, String newTitle) {
    final idx = _recordings.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _recordings[idx] = _recordings[idx].copyWith(title: newTitle);
      _saveRecordings();
      notifyListeners();
    }
  }

  void deleteRecording(String id) {
    _recordings.removeWhere((r) => r.id == id);
    _saveRecordings();
    notifyListeners();
  }

  void updateCategory(String id, RecordingCategory category) {
    final idx = _recordings.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _recordings[idx] = _recordings[idx].copyWith(category: category);
      _saveRecordings();
      notifyListeners();
    }
  }

  // Player controls
  void playRecording(Recording recording) {
    _currentlyPlaying = recording;
    _isPlaying = true;
    _playerPosition = Duration.zero;
    _startPlaybackTimer();
    notifyListeners();
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startPlaybackTimer();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void seekTo(Duration position) {
    _playerPosition = position;
    notifyListeners();
  }

  void seekForward() {
    if (_currentlyPlaying != null) {
      final newPos = _playerPosition + const Duration(seconds: 10);
      _playerPosition = newPos > _currentlyPlaying!.duration ? _currentlyPlaying!.duration : newPos;
      notifyListeners();
    }
  }

  void seekBackward() {
    final newPos = _playerPosition - const Duration(seconds: 10);
    _playerPosition = newPos < Duration.zero ? Duration.zero : newPos;
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  void stopPlayback() {
    _isPlaying = false;
    _currentlyPlaying = null;
    _playerPosition = Duration.zero;
    _timer?.cancel();
    notifyListeners();
  }

  void _startPlaybackTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_currentlyPlaying != null && _isPlaying) {
        _playerPosition += Duration(milliseconds: (100 * _playbackSpeed).toInt());
        if (_playerPosition >= _currentlyPlaying!.duration) {
          _playerPosition = _currentlyPlaying!.duration;
          _isPlaying = false;
          _timer?.cancel();
        }
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveformTimer?.cancel();
    super.dispose();
  }
}
