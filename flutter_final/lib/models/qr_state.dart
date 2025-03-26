import 'package:flutter/material.dart';

class QRState with ChangeNotifier {
  String? _qrData;
  DateTime? _qrGeneratedTime;
  static const int _qrValidityMinutes = 1;

  String? get qrData => _qrData;
  DateTime? get qrGeneratedTime => _qrGeneratedTime;

  bool get isButtonEnabled {
    if (_qrGeneratedTime == null) return true;
    final elapsed = DateTime.now().difference(_qrGeneratedTime!).inMinutes;
    return elapsed >= _qrValidityMinutes;
  }

  void generateQR(String userId) {
    if (!isButtonEnabled) return;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    _qrData = '${userId}';
    _qrGeneratedTime = DateTime.now();
    notifyListeners();
  }

  void clearQR() {
    _qrData = null;
    _qrGeneratedTime = null;
    notifyListeners();
  }

  String getRemainingTime() {
    if (_qrGeneratedTime == null || _qrData == null) return 'Not generated';
    final elapsedSeconds =
        DateTime.now().difference(_qrGeneratedTime!).inSeconds;
    final remainingSeconds = (_qrValidityMinutes * 60) - elapsedSeconds;
    if (remainingSeconds <= 0) {
      clearQR(); // Auto-clear when expired
      return 'Expired';
    }
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
