import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import '../../../core/transfer/i_transfer_service.dart';

class QuickShareTransferService implements ITransferService {
  final Strategy strategy = Strategy.P2P_STAR;
  final String userName = 'NFC_User_${DateTime.now().millisecondsSinceEpoch}';

  @override
  TransferMethod get method => TransferMethod.quickShare;

  @override
  Future<bool> requestPermissions() async {
    return await Nearby().askBluetoothPermission() && await Nearby().askLocationPermission();
  }

  // Activer la réception (Advertiser)
  Future<void> startAdvertising() async {
    await Nearby().startAdvertising(
      userName,
      strategy,
      onConnectionInitiated: (id, info) {
        Nearby().acceptConnection(id, onPayLoadRecieved: (id, payload) {
          // Gérer la réception du montant ici (ex: notifier le WalletProvider)
        });
      },
      onConnectionResult: (id, status) {},
      onDisconnected: (id) {},
    );
  }

  @override
  Future<void> startDiscovery() async {
    await Nearby().startDiscovery(
      userName,
      strategy,
      onEndpointFound: (id, name, serviceId) {
        // Enregistrer l'appareil trouvé pour l'UI Système Solaire
      },
      onEndpointLost: (id) {},
    );
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
        Nearby().acceptConnection(id);
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
