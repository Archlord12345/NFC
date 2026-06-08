import '../../../data/models/transaction_model.dart';

abstract class NfcTransferState {}

class NfcTransferInitial extends NfcTransferState {}

// État de recherche active (déclenchera l'animation Ripple/Pulse de l'UI)
class NfcTransferScanning extends NfcTransferState {}

// Transfert réussi avec les détails du reçu
class NfcTransferSuccess extends NfcTransferState {
  final TransactionModel transaction;
  NfcTransferSuccess({required this.transaction});
}

// Échec du transfert (ex: appareils éloignés trop vite)
class NfcTransferFailure extends NfcTransferState {
  final String errorMessage;
  NfcTransferFailure({required this.errorMessage});
}