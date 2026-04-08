import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recording.dart';

class SettingsProvider extends ChangeNotifier {
  AudioFormat _format = AudioFormat.mp3;
  AudioQuality _quality = AudioQuality.standard;
  bool _noiseSuppression = true;
  bool _autoGainControl = true;
  bool _echoCancellation = false;
  bool _showWaveform = true;
  bool _autoSave = true;
  RecordingCategory _defaultCategory = RecordingCategory.other;
  String _filePrefix = 'تسجيل';

  AudioFormat get format => _format;
  AudioQuality get quality => _quality;
  bool get noiseSuppression => _noiseSuppression;
  bool get autoGainControl => _autoGainControl;
  bool get echoCancellation => _echoCancellation;
  bool get showWaveform => _showWaveform;
  bool get autoSave => _autoSave;
  RecordingCategory get defaultCategory => _defaultCategory;
  String get filePrefix => _filePrefix;

  String get formatLabel => _format.label;
  String get qualityLabel => _quality.label;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _format = AudioFormat.values[prefs.getInt('format') ?? 1];
    _quality = AudioQuality.values[prefs.getInt('quality') ?? 1];
    _noiseSuppression = prefs.getBool('noiseSuppression') ?? true;
    _autoGainControl = prefs.getBool('autoGainControl') ?? true;
    _echoCancellation = prefs.getBool('echoCancellation') ?? false;
    _showWaveform = prefs.getBool('showWaveform') ?? true;
    _autoSave = prefs.getBool('autoSave') ?? true;
    _defaultCategory = RecordingCategory.values[prefs.getInt('defaultCategory') ?? 6];
    _filePrefix = prefs.getString('filePrefix') ?? 'تسجيل';
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('format', _format.index);
    await prefs.setInt('quality', _quality.index);
    await prefs.setBool('noiseSuppression', _noiseSuppression);
    await prefs.setBool('autoGainControl', _autoGainControl);
    await prefs.setBool('echoCancellation', _echoCancellation);
    await prefs.setBool('showWaveform', _showWaveform);
    await prefs.setBool('autoSave', _autoSave);
    await prefs.setInt('defaultCategory', _defaultCategory.index);
    await prefs.setString('filePrefix', _filePrefix);
  }

  void setFormat(AudioFormat f) {
    _format = f;
    notifyListeners();
    _saveSettings();
  }

  void setQuality(AudioQuality q) {
    _quality = q;
    notifyListeners();
    _saveSettings();
  }

  void toggleNoiseSuppression() {
    _noiseSuppression = !_noiseSuppression;
    notifyListeners();
    _saveSettings();
  }

  void toggleAutoGainControl() {
    _autoGainControl = !_autoGainControl;
    notifyListeners();
    _saveSettings();
  }

  void toggleEchoCancellation() {
    _echoCancellation = !_echoCancellation;
    notifyListeners();
    _saveSettings();
  }

  void toggleShowWaveform() {
    _showWaveform = !_showWaveform;
    notifyListeners();
    _saveSettings();
  }

  void toggleAutoSave() {
    _autoSave = !_autoSave;
    notifyListeners();
    _saveSettings();
  }

  void setDefaultCategory(RecordingCategory c) {
    _defaultCategory = c;
    notifyListeners();
    _saveSettings();
  }

  void setFilePrefix(String p) {
    _filePrefix = p;
    notifyListeners();
    _saveSettings();
  }
}
