import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

enum NfcSessionStatus { idle, scanning, processing, success, error }

class TransferToken {
  final String amount;
  final String currency;
  final String senderWalletId;
  final String timestamp;

  TransferToken({
    required this.amount,
    required this.currency,
    required this.senderWalletId,
  }) : timestamp = DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'sender': senderWalletId,
        'time': timestamp,
      };
}

class NfcProvider extends ChangeNotifier {
  NfcSessionStatus _status = NfcSessionStatus.idle;
  String? _errorMessage;
  Map<String, dynamic>? _lastReadData;

  NfcSessionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastReadData => _lastReadData;

  bool get isScanning => _status == NfcSessionStatus.scanning;

  Future<void> startReading() async {
    NfcAvailability availability = await NfcManager.instance.checkAvailability();
    if (availability != NfcAvailability.enabled) {
      _errorMessage = 'NFC non disponible';
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
              _errorMessage = 'Tag non compatible NDEF';
              _status = NfcSessionStatus.error;
            } else {
              final message = await ndef.read();
              if (message == null || message.records.isEmpty) {
                _errorMessage = 'Tag NFC vide';
                _status = NfcSessionStatus.error;
              } else {
                final payload = message.records.first.payload;
                String decoded = utf8.decode(payload);
                final jsonStart = decoded.indexOf('{');
                final jsonEnd = decoded.lastIndexOf('}');
                
                if (jsonStart != -1 && jsonEnd != -1) {
                  _lastReadData = jsonDecode(decoded.substring(jsonStart, jsonEnd + 1));
                  _status = NfcSessionStatus.success;
                } else {
                  _errorMessage = 'Format de données invalide';
                  _status = NfcSessionStatus.error;
                }
              }
            }
          } catch (e) {
            _errorMessage = 'Erreur de lecture: $e';
            _status = NfcSessionStatus.error;
          }
          await NfcManager.instance.stopSession();
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Erreur de session: $e';
      _status = NfcSessionStatus.error;
      notifyListeners();
    }
  }

  Future<void> startWriting(TransferToken token) async {
    NfcAvailability availability = await NfcManager.instance.checkAvailability();
    if (availability != NfcAvailability.enabled) {
      _errorMessage = 'NFC non disponible';
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
              _errorMessage = 'Tag non inscriptible';
              _status = NfcSessionStatus.error;
            } else {
              final jsonString = jsonEncode(token.toJson());
              final message = NdefMessage(records: [
                NdefRecord(
                  typeNameFormat: TypeNameFormat.wellKnown,
                  type: Uint8List.fromList([0x54]), // 'T' for Text
                  identifier: Uint8List.fromList([]),
                  payload: Uint8List.fromList(utf8.encode(jsonString)),
                ),
              ]);
              await ndef.write(message: message);
              _status = NfcSessionStatus.success;
            }
          } catch (e) {
            _errorMessage = 'Erreur d\'écriture: $e';
            _status = NfcSessionStatus.error;
          }
          await NfcManager.instance.stopSession();
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Erreur de session: $e';
      _status = NfcSessionStatus.error;
      notifyListeners();
    }
  }

  Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
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
