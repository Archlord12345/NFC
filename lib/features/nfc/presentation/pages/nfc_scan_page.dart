import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/transfer/i_transfer_service.dart';
import '../../../wallet/data/services/bluetooth_transfer_service.dart';
import '../../../wallet/data/services/quick_share_transfer_service.dart';
import '../../../wallet/presentation/pages/solar_system_discovery_page.dart';
import '../providers/nfc_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

enum NfcMode { send, receive }

class NfcScanPage extends StatefulWidget {
  final NfcMode mode;
  const NfcScanPage({super.key, this.mode = NfcMode.receive});

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final _amountController = TextEditingController();
  final _auth = LocalAuthentication();
  bool _isWritingMode = false;
  bool _isNfcAvailable = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    try {
      final available = await NfcManager.instance.isAvailable();
      setState(() => _isNfcAvailable = available);

      if (available) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<NfcProvider>().reset();
          if (widget.mode == NfcMode.receive) {
            context.read<NfcProvider>().startReading();
          }
        });
      }
    } catch (e) {
      debugPrint('NFC check error: $e');
      setState(() => _isNfcAvailable = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _onSharePressed() async {
    final amount = _amountController.text;
    final wallet = context.read<WalletProvider>().wallet;
    
    final message = 'Transférez-moi $amount ${wallet?.devise ?? 'XAF'} sur mon portefeuille ${wallet?.id}';
    
    await Share.share(message, subject: 'Transfert d\'argent');
  }

  Future<void> _onSendPressed() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    final wallet = context.read<WalletProvider>().wallet;
    if (wallet == null) return;

    if (amount > wallet.solde) {
      _showSnackBar('Insufficient balance');
      return;
    }

    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (canAuthenticate) {
        final authenticated = await _auth.authenticate(
          localizedReason: 'Please authenticate to confirm the transfer of ${amount.toStringAsFixed(2)} ${wallet.devise}',
        );

        if (!authenticated) return;
      }
    } catch (e) {
      debugPrint('Biometric auth error: $e');
    }

    setState(() => _isWritingMode = true);
    
    // Création du token
    final token = TransferToken(
      amount: amount.toString(),
      currency: wallet.devise,
      senderWalletId: wallet.id,
    );
    
    context.read<NfcProvider>().startWriting(token);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleFallback(BuildContext context, TransferMethod method) {
    ITransferService? service;
    if (method == TransferMethod.bluetooth) service = BluetoothTransferService();
    if (method == TransferMethod.quickShare) service = QuickShareTransferService();

    if (service != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SolarSystemDiscoveryPage(
            transferService: service!,
            amount: double.tryParse(_amountController.text) ?? 500.0,
            isReceiver: widget.mode == NfcMode.receive,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nfcProvider = context.watch<NfcProvider>();
    final walletProvider = context.watch<WalletProvider>();

    if (!_isNfcAvailable) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
          title: Text(widget.mode == NfcMode.send ? 'Envoi d\'argent' : 'Réception d\'argent'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nfc_outlined, size: 64, color: AppColors.error),
                const SizedBox(height: 20),
                Text(
                  'Le NFC n\'est pas disponible sur cet appareil.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Utilisez une autre méthode de transfert interne :',
                  style: TextStyle(color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FallbackButton(
                      icon: Icons.bluetooth,
                      label: 'Bluetooth',
                      onTap: () => _handleFallback(context, TransferMethod.bluetooth),
                    ),
                    _FallbackButton(
                      icon: Icons.share_rounded,
                      label: 'Quick Share',
                      onTap: () => _handleFallback(context, TransferMethod.quickShare),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Gestion automatique de la réussite du transfert
    if (nfcProvider.status == NfcSessionStatus.success) {
      if (widget.mode == NfcMode.receive && nfcProvider.lastReadData != null) {
        final data = nfcProvider.lastReadData!;
        final amount = double.parse(data['amount'].toString());
        final senderId = data['sender'] as String;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final success = await walletProvider.transfertNfc(
            montant: amount,
            isEnvoi: false,
            peerWalletId: senderId,
          );
          if (mounted && success) {
            Navigator.of(context).pushReplacementNamed('/nfc-receipt', arguments: amount.toStringAsFixed(2));
          }
        });
      } else if (widget.mode == NfcMode.send && _isWritingMode) {
        final amount = double.parse(_amountController.text);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final success = await walletProvider.transfertNfc(
            montant: amount,
            isEnvoi: true,
            peerWalletId: 'NFC_PEER',
          );
          if (mounted && success) {
            Navigator.of(context).pushReplacementNamed('/nfc-receipt', arguments: '-$amount');
          }
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        title: Text(widget.mode == NfcMode.send ? 'Send Money' : 'Receive Money', style: const TextStyle(color: AppColors.textPrimaryLight)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<NfcProvider>().stopSession();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.mode == NfcMode.send && !_isWritingMode) ...[
                Text(
                  'Enter amount to send',
                  style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(color: AppColors.textSecondaryLight),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSendPressed,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                    child: const Text('Start NFC Beam'),
                  ),
                ),
              ] else ...[
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: nfcProvider.isScanning ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          nfcProvider.status == NfcSessionStatus.success
                              ? Icons.check_rounded
                              : Icons.nfc_rounded,
                          size: 56, color: AppColors.accent,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  nfcProvider.status == NfcSessionStatus.error
                      ? 'Error!'
                      : (nfcProvider.status == NfcSessionStatus.success ? 'Success!' : 'Ready to Scan'),
                  style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 12),
                Text(
                  nfcProvider.errorMessage ??
                      (widget.mode == NfcMode.send
                          ? 'Approach the devices to transfer ${_amountController.text} ${walletProvider.wallet?.devise}'
                          : 'Hold your device near the sender\'s phone'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FallbackButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.accent.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
