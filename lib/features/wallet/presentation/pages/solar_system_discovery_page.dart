import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/transfer/i_transfer_service.dart';

class SolarSystemDiscoveryPage extends StatefulWidget {
  final ITransferService transferService;
  final double amount;

  const SolarSystemDiscoveryPage({
    super.key,
    required this.transferService,
    required this.amount,
  });

  @override
  State<SolarSystemDiscoveryPage> createState() => _SolarSystemDiscoveryPageState();
}

class _SolarSystemDiscoveryPageState extends State<SolarSystemDiscoveryPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _peers = ['Device A', 'Device B', 'Device C'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _startDiscovery();
  }

  Future<void> _startDiscovery() async {
    if (await widget.transferService.requestPermissions()) {
      await widget.transferService.startDiscovery();
    }
  }

  void _onPeerTap(String peerId) {
    widget.transferService.sendData(peerId: peerId, amount: widget.amount);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Envoi à $peerId...')));
  }

  @override
  void dispose() {
    widget.transferService.stopDiscovery();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return GestureDetector(
              onTapUp: (details) {
                // Simplified tap detection logic to simulate selecting an orbiting peer
                _onPeerTap(_peers.first);
              },
              child: CustomPaint(
                painter: SolarSystemPainter(_controller.value, _peers),
                size: const Size(300, 300),
              ),
            );
          },
        ),
      ),
    );
  }
}
// ... (SolarSystemPainter remains unchanged)

class SolarSystemPainter extends CustomPainter {
  final double animationValue;
  final List<String> peers;

  SolarSystemPainter(this.animationValue, this.peers);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = Colors.blueAccent..style = PaintingStyle.fill;

    // Draw Sun (Local Device)
    canvas.drawCircle(center, 30, paint);

    // Draw Orbits and Planets
    for (int i = 0; i < peers.length; i++) {
      final angle = (2 * pi / peers.length) * i + (animationValue * 2 * pi);
      final radius = 100.0;
      final peerPos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // Draw Orbit
      canvas.drawCircle(center, radius, Paint()..color = Colors.white.withAlpha(50)..style = PaintingStyle.stroke);

      // Draw Peer
      canvas.drawCircle(peerPos, 15, Paint()..color = Colors.orangeAccent);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
