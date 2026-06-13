import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../../../../core/transfer/i_transfer_service.dart';

class QuickShareTransferService implements ITransferService {
  final Strategy strategy = Strategy.P2P_STAR;
  final String userName = 'NFC_User_${DateTime.now().millisecondsSinceEpoch}';
  final _peersController = StreamController<List<Peer>>.broadcast();
  final _dataController = StreamController<Map<String, dynamic>>.broadcast();
  final Map<String, Peer> _discoveredPeersMap = {};

  @override
  TransferMethod get method => TransferMethod.quickShare;

  @override
  Stream<List<Peer>> get discoveredPeers => _peersController.stream;

  @override
  Stream<Map<String, dynamic>> get onDataReceived => _dataController.stream;

  @override
  Future<bool> requestPermissions() async {
    // Nearby Connections gère souvent ses propres permissions ou nécessite un check manuel via permission_handler
    // Si checkBluetoothPermission n'existe pas, on retourne true pour laisser le plugin gérer l'erreur ou on utilise permission_handler
    return true; 
  }

  // Activer la réception (Advertiser)
  @override
  Future<void> startAdvertising() async {
    await Nearby().startAdvertising(
      userName,
      strategy,
      onConnectionInitiated: (id, info) {
        Nearby().acceptConnection(id, onPayLoadRecieved: (id, payload) {
          if (payload.type == PayloadType.BYTES && payload.bytes != null) {
            final dataStr = String.fromCharCodes(payload.bytes!);
            final amount = double.tryParse(dataStr) ?? 0.0;
            _dataController.add({
              'amount': amount,
              'senderId': id,
            });
          }
        });
      },
      onConnectionResult: (id, status) {},
      onDisconnected: (id) {},
    );
  }

  @override
  Future<void> startDiscovery() async {
    debugPrint('QuickShareTransferService: Demarrage de la decouverte...');
    _discoveredPeersMap.clear();
    _peersController.add([]);
    
    bool discoveryStarted = await Nearby().startDiscovery(
      userName,
      strategy,
      onEndpointFound: (id, name, serviceId) {
        debugPrint('QuickShareTransferService: Appareil trouve - $name ($id)');
        _discoveredPeersMap[id] = Peer(id: id, name: name);
        _peersController.add(_discoveredPeersMap.values.toList());
      },
      onEndpointLost: (id) {
        debugPrint('QuickShareTransferService: Appareil perdu - $id');
        _discoveredPeersMap.remove(id);
        _peersController.add(_discoveredPeersMap.values.toList());
      },
    );
    debugPrint('QuickShareTransferService: Decouverte lancee: $discoveryStarted');
  }

  @override
  Future<void> stopDiscovery() async {
    await Nearby().stopDiscovery();
    await Nearby().stopAdvertising();
  }

  @override
  Future<void> sendData({
    required String peerId,
    required double amount,
  }) async {
    // Établir la connexion
    await Nearby().requestConnection(
      userName,
      peerId,
      onConnectionInitiated: (id, info) {
        Nearby().acceptConnection(id, onPayLoadRecieved: (id, payload) {});
      },
      onConnectionResult: (id, status) {
        if (status == Status.CONNECTED) {
          // Envoyer les données
          Nearby().sendBytesPayload(id, Uint8List.fromList(amount.toString().codeUnits));
        }
      },
      onDisconnected: (id) {},
    );
  }
}
