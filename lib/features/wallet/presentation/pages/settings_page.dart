import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          const ListTile(title: Text('Méthodes de transfert', style: TextStyle(fontWeight: FontWeight.bold))),
          SwitchListTile(title: const Text('Bluetooth'), value: true, onChanged: (v) {}),
          SwitchListTile(title: const Text('Quick Share'), value: true, onChanged: (v) {}),
          SwitchListTile(title: const Text('NFC'), value: true, onChanged: (v) {}),
          const Divider(),
          const ListTile(title: Text('Profil', style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(leading: const Icon(Icons.person), title: const Text('Nom d\'utilisateur')),
          ListTile(leading: const Icon(Icons.security), title: const Text('Sécurité')),
        ],
      ),
    );
  }
}
