abstract class NfcTransferEvent {}

class StartNfcTransferEvent extends NfcTransferEvent {
  final double amount;
  final String senderId;
  final String receiverId;
  
  StartNfcTransferEvent({
    required this.amount, 
    required this.senderId, 
    required this.receiverId
  });
}

class CancelNfcTransferEvent extends NfcTransferEvent {}