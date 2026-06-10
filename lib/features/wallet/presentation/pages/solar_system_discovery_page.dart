import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../../../../core/transfer/i_transfer_service.dart';

class SolarSystemDiscoveryPage extends StatefulWidget {
  final ITransferService transferService;
  final double amount;
  final bool isReceiver;

  const SolarSystemDiscoveryPage({
    super.key,
    required this.transferService,
    required this.amount,
    this.isReceiver = false,
  });

  @override
  State<SolarSystemDiscoveryPage> createState() => _SolarSystemDiscoveryPageState();
}

class _SolarSystemDiscoveryPageState extends State<SolarSystemDiscoveryPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Peer> _peers = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _startDiscovery();
    _subscription = widget.transferService.discoveredPeers.listen((peers) {
      debugPrint('SolarSystemDiscoveryPage: Appareils recus via stream: ${peers.length}');
      setState(() {
        _peers = peers;
      });
    });
  }

  Future<void> _startDiscovery() async {
    debugPrint('SolarSystemDiscoveryPage: Verification permissions...');
    if (await widget.transferService.requestPermissions()) {
      debugPrint('SolarSystemDiscoveryPage: Permissions OK, lancement du service...');
      if (widget.isReceiver) {
        await widget.transferService.startAdvertising();
      }
      await widget.transferService.startDiscovery();
    } else {
      debugPrint('SolarSystemDiscoveryPage: Permissions refusees.');
    }
  }

  void _onPeerTap(Peer peer) async {
    if (!mounted) return;

    final codeController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Couplage avec ${peer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez entrer le code de confirmation (Pairing Code) affiché sur l\'autre appareil (utilisez 1234 pour tester).'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Code PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (codeController.text != '1234') {
      if (mounted) {
        _showErrorDialog('Code de confirmation invalide. Le couplage a échoué.');
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Connexion à ${peer.name}...'),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 1),
      ));
    }

    try {
      await widget.transferService.sendData(peerId: peer.id, amount: widget.amount);
      
      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          '/nfc-receipt', 
          arguments: '-${widget.amount.toStringAsFixed(2)}'
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Échec du transfert'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.transferService.stopDiscovery();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(widget.isReceiver 
          ? 'En attente de transfert (${widget.transferService.method.name})...' 
          : 'Recherche ${widget.transferService.method.name}...'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          return GestureDetector(
            onTapUp: (details) {
              final tapPos = details.localPosition;
              for (int i = 0; i < _peers.length; i++) {
                final orbitIndex = (i % 3) + 1;
                final radius = 60.0 * orbitIndex;
                final speed = 1.0 / orbitIndex;
                final angle = (2 * pi / max(1, _peers.length)) * i + (_controller.value * 2 * pi * speed);
                
                final peerPos = Offset(
                  center.dx + radius * cos(angle),
                  center.dy + radius * sin(angle),
                );

                if ((tapPos - peerPos).distance < 30) {
                  _onPeerTap(_peers[i]);
                  break;
                }
              }
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: SolarSystemPainter(_controller.value, _peers),
                  size: Size.infinite,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SolarSystemPainter extends CustomPainter {
  final double animationValue;
  final List<Peer> peers;

  SolarSystemPainter(this.animationValue, this.peers);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = Colors.blueAccent..style = PaintingStyle.fill;

    // Draw Sun (Local Device)
    canvas.drawCircle(center, 30, paint);
    
    final textPainter = TextPainter(
      text: const TextSpan(text: 'Moi', style: TextStyle(color: Colors.white, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));

    // Draw Orbits and Planets
    for (int i = 0; i < peers.length; i++) {
      final orbitIndex = (i % 3) + 1;
      final radius = 60.0 * orbitIndex;
      final speed = 1.0 / orbitIndex;
      final angle = (2 * pi / max(1, peers.length)) * i + (animationValue * 2 * pi * speed);
      
      final peerPos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // Draw Orbit
      canvas.drawCircle(center, radius, Paint()..color = Colors.white.withAlpha(30)..style = PaintingStyle.stroke);

      // Draw Peer
      canvas.drawCircle(peerPos, 20, Paint()..color = Colors.orangeAccent);
      
      final peerNamePainter = TextPainter(
        text: TextSpan(text: peers[i].name, style: const TextStyle(color: Colors.white, fontSize: 8)),
        textDirection: TextDirection.ltr,
      )..layout();
      peerNamePainter.paint(canvas, peerPos - Offset(peerNamePainter.width / 2, peerNamePainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
