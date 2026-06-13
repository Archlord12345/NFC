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
              debugPrint('NfcProvider: Tag non compatible NDEF');
              _errorMessage = 'Tag non compatible NDEF';
              _status = NfcSessionStatus.error;
            } else {
              final message = await ndef.read();
              if (message == null || message.records.isEmpty) {
                debugPrint('NfcProvider: Tag NFC vide');
                _errorMessage = 'Tag NFC vide';
                _status = NfcSessionStatus.error;
              } else {
                final record = message.records.first;
                final payload = record.payload;
                String decoded;

                // Handling standard NDEF Text record prefix (language code length)
                if (record.typeNameFormat == TypeNameFormat.wellKnown &&
                    listEquals(record.type, Uint8List.fromList([0x54]))) {
                  int languageCodeLength = payload[0] & 0x3F;
                  decoded = utf8.decode(payload.sublist(1 + languageCodeLength));
                } else {
                  decoded = utf8.decode(payload);
                }

                debugPrint('NfcProvider: Données décodées: $decoded');
                final jsonStart = decoded.indexOf('{');
                final jsonEnd = decoded.lastIndexOf('}');
                
                if (jsonStart != -1 && jsonEnd != -1) {
                  _lastReadData = jsonDecode(decoded.substring(jsonStart, jsonEnd + 1));
                  debugPrint('NfcProvider: Succès lecture JSON: $_lastReadData');
                  _status = NfcSessionStatus.success;
                } else {
                  debugPrint('NfcProvider: Format JSON invalide dans le payload');
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
              debugPrint('NfcProvider: Tag non compatible ou non inscriptible');
              _errorMessage = 'Tag non inscriptible';
              _status = NfcSessionStatus.error;
            } else {
              final jsonString = jsonEncode(token.toJson());
              debugPrint('NfcProvider: Tentative d\'écriture: $jsonString');

              // Standard NDEF Text record: [Status Byte] [Language Code] [Text]
              // Status byte: 0x02 (UTF-8, language code length 2)
              // Language code: 'en' (0x65, 0x6E)
              final payload = Uint8List.fromList([
                0x02, 0x65, 0x6E,
                ...utf8.encode(jsonString)
              ]);

              final message = NdefMessage(records: [
                NdefRecord(
                  typeNameFormat: TypeNameFormat.wellKnown,
                  type: Uint8List.fromList([0x54]), // 'T'
                  identifier: Uint8List.fromList([]),
                  payload: payload,
                ),
              ]);
              await ndef.write(message: message);
              debugPrint('NfcProvider: Écriture réussie');
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
