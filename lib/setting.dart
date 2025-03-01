import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft background
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Profile Section


          const SizedBox(height: 24),

          // Settings Options
          _buildSettingTile("Notifications", Icons.notifications, trailing: Switch(
            value: notifications,
            activeColor: Colors.black,
            onChanged: (value) {
              setState(() {
                notifications = value;
              });
            },
          )),
          _buildSettingTile("Dark Mode", Icons.dark_mode, trailing: Switch(
            value: darkMode,
            activeColor: Colors.black,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
          )),
          _buildSettingTile("Privacy", Icons.lock),
          _buildSettingTile("Language", Icons.language),
          _buildSettingTile("Help & Support", Icons.help_outline),

          const SizedBox(height: 40),

          // Logout Button

        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 5, spreadRadius: 1)],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        onTap: () {},
      ),
    );
  }
}
