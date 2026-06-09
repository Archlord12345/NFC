import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

// Platform-specific NDEF handling imports


enum NfcSessionStatus { idle, scanning, processing, success, error }

/**
 * Represents a transfer token containing payment information.
 *
 * Fields:
 * - amount: The monetary amount to transfer.
 * - currency: Currency code (e.g., 'USD', 'EUR').
 * - senderWalletId: Identifier of the sender's wallet.
 * - timestamp: ISO‑8601 timestamp generated when the token is created.
 */
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

  Ndef? _getNdef(NfcTag tag) => Ndef.from(tag);

  Future<void> startReading() async {
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
            final ndef = _getNdef(tag);
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
                final payload = message.records.first.payload;
                String decoded = utf8.decode(payload);
                
                final jsonStart = decoded.indexOf('{');
                final jsonEnd = decoded.lastIndexOf('}');
                if (jsonStart != -1 && jsonEnd != -1) {
                  _lastReadData = jsonDecode(decoded.substring(jsonStart, jsonEnd + 1));
                  _status = NfcSessionStatus.success;
                } else {
                  _errorMessage = 'Invalid data';
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

  /// Starts a write session to send a [TransferToken] to an NFC tag.
  /// The token is encoded as a JSON payload inside an NDEF record.
  /// The method ensures the tag is writable and handles errors gracefully.
  Future<void> startWriting(TransferToken token) async {
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
            final ndef = _getNdef(tag);
            if (ndef == null || !ndef.isWritable) {
              _errorMessage = 'Tag not writable';
              _status = NfcSessionStatus.error;
              await NfcManager.instance.stopSession();
            } else {
              final record = NdefRecord(
                typeNameFormat: NdefTypeNameFormat.wellKnown,
                type: Uint8List.fromList([0x54]),
                identifier: Uint8List(0),
                payload: Uint8List.fromList(utf8.encode(jsonEncode(token.toJson()))),
              );
              final message = NdefMessage([record]);
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
