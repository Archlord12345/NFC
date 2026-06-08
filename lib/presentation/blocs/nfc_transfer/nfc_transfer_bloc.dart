import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/nfc_simulation_service.dart';
import 'nfc_transfer_event.dart';
import 'nfc_transfer_state.dart';

class NfcTransferBloc extends Bloc<NfcTransferEvent, NfcTransferState> {
  final NfcSimulationService _nfcService;

  NfcTransferBloc(this._nfcService) : super(NfcTransferInitial()) {
    on<StartNfcTransferEvent>((event, emit) async {
      emit(NfcTransferScanning()); // On passe à l'état "recherche/animation"
      
      try {
        final result = await _nfcService.executeMockNfcTransfer(
          amount: event.amount,
          senderId: event.senderId,
          receiverId: event.receiverId,
        );
        emit(NfcTransferSuccess(transaction: result)); // Succès !
      } catch (e) {
        emit(NfcTransferFailure(errorMessage: e.toString())); // Échec
      }
    });

    on<CancelNfcTransferEvent>((event, emit) {
      emit(NfcTransferInitial());
    });
  }
}