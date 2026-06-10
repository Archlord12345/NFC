import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              const ListTile(title: Text('Méthodes de transfert', style: TextStyle(fontWeight: FontWeight.bold))),
              SwitchListTile(
                title: const Text('Bluetooth'),
                value: settings.bluetoothEnabled,
                onChanged: settings.toggleBluetooth,
              ),
              SwitchListTile(
                title: const Text('Quick Share'),
                value: settings.quickShareEnabled,
                onChanged: settings.toggleQuickShare,
              ),
              SwitchListTile(
                title: const Text('NFC'),
                value: settings.nfcEnabled,
                onChanged: settings.toggleNfc,
              ),
              const Divider(),
              const ListTile(title: Text('Profil', style: TextStyle(fontWeight: FontWeight.bold))),
              ListTile(leading: const Icon(Icons.person), title: const Text('Nom d\'utilisateur')),
              ListTile(leading: const Icon(Icons.security), title: const Text('Sécurité')),
            ],
          );
        },
      ),
    );
  }
}
