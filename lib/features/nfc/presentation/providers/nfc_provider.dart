import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

enum NfcSessionStatus { idle, scanning, processing, success, error }

class NfcProvider extends ChangeNotifier {
  NfcSessionStatus _status = NfcSessionStatus.idle;
  String? _errorMessage;
  Map<String, dynamic>? _lastReadData;

  NfcSessionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastReadData => _lastReadData;

  bool get isScanning => _status == NfcSessionStatus.scanning;

  /// Démarre une session de lecture NFC.
  Future<void> startReading() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      _errorMessage = 'NFC is not available on this device';
      _status = NfcSessionStatus.error;
      notifyListeners();
      return;
    }

    _status = NfcSessionStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          _status = NfcSessionStatus.processing;
          notifyListeners();

          try {
            final ndef = Ndef.from(tag);
            if (ndef == null) {
              _errorMessage = 'Tag is not NDEF compatible';
              _status = NfcSessionStatus.error;
              await NfcManager.instance.stopSession();
            } else {
              final message = await ndef.read();
              if (message.records.isEmpty) {
                _errorMessage = 'Empty NFC tag';
                _status = NfcSessionStatus.error;
              } else {
                // Lecture du premier record
                final payload = message.records.first.payload;
                
                // Pour un TextRecord NDEF, le premier byte est la longueur du code langue
                // On utilise une approche plus robuste pour extraire le texte
                String decoded;
                if (message.records.first.typeNameFormat == NdefTypeNameFormat.nfcWellKnown &&
                    listEquals(message.records.first.type, [0x54])) { // 'T' for Text
                  int languageCodeLength = payload[0] & 0x3F;
                  decoded = utf8.decode(payload.sublist(1 + languageCodeLength));
                } else {
                  decoded = utf8.decode(payload);
                }
                
                final jsonStart = decoded.indexOf('{');
                final jsonEnd = decoded.lastIndexOf('}');
                if (jsonStart != -1 && jsonEnd != -1) {
                  final jsonStr = decoded.substring(jsonStart, jsonEnd + 1);
                  try {
                    _lastReadData = jsonDecode(jsonStr);
                    _status = NfcSessionStatus.success;
                  } catch (e) {
                    _errorMessage = 'Invalid data format';
                    _status = NfcSessionStatus.error;
                  }
                } else {
                  _errorMessage = 'No valid transaction data found';
                  _status = NfcSessionStatus.error;
                }
              }
              await NfcManager.instance.stopSession();
            }
          } catch (e) {
            _errorMessage = 'Read error: $e';
            _status = NfcSessionStatus.error;
            await NfcManager.instance.stopSession();
          }
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Session error: $e';
      _status = NfcSessionStatus.error;
      notifyListeners();
    }
  }

  /// Démarre une session d'écriture NFC pour envoyer des fonds.
  Future<void> startWriting(Map<String, dynamic> data) async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      _errorMessage = 'NFC is not available';
      _status = NfcSessionStatus.error;
      notifyListeners();
      return;
    }

    _status = NfcSessionStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          _status = NfcSessionStatus.processing;
          notifyListeners();

          try {
            final ndef = Ndef.from(tag);
            if (ndef == null || !ndef.isWritable) {
              _errorMessage = 'Tag is not writable or NDEF compatible';
              _status = NfcSessionStatus.error;
              await NfcManager.instance.stopSession();
            } else {
              final jsonStr = jsonEncode(data);
              final message = NdefMessage([
                NdefRecord.createText(jsonStr),
              ]);
              await ndef.write(message);
              _status = NfcSessionStatus.success;
              await NfcManager.instance.stopSession();
            }
          } catch (e) {
            _errorMessage = 'Write error: $e';
            _status = NfcSessionStatus.error;
            await NfcManager.instance.stopSession();
          }
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Session error: $e';
      _status = NfcSessionStatus.error;
      notifyListeners();
    }
  }

  Future<void> stopSession() async {
    await NfcManager.instance.stopSession();
    _status = NfcSessionStatus.idle;
    notifyListeners();
  }

  void reset() {
    _status = NfcSessionStatus.idle;
    _errorMessage = null;
    _lastReadData = null;
    notifyListeners();
  }
}
