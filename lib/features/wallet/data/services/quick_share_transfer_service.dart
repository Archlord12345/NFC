import 'package:nearby_connections/nearby_connections.dart';
import '../../../core/transfer/i_transfer_service.dart';

class QuickShareTransferService implements ITransferService {
  final Strategy strategy = Strategy.P2P_STAR; // Appropriate for one-to-one transfer

  @override
  TransferMethod get method => TransferMethod.quickShare;

  @override
  Future<bool> requestPermissions() async {
    return await Nearby().askBluetoothPermission() && await Nearby().askLocationPermission();
  }

  @override
  Future<void> startDiscovery() async {
    await Nearby().startDiscovery(
      'username',
      strategy,
      onEndpointFound: (id, name, serviceId) {
        // Handle discovery callback
      },
      onEndpointLost: (id) {},
    );
  }

  @override
  Future<void> stopDiscovery() async {
    await Nearby().stopDiscovery();
  }

  @override
  Future<void> sendData({
    required String peerId,
    required double amount,
  }) async {
    // Send data to the discovered peer
    await Nearby().sendBytesPayload(peerId, Uint8List.fromList(amount.toString().codeUnits));
  }
}
