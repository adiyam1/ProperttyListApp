import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database_helper.dart';
import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/property_provider.dart'; // ✅ make sure this exists

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserModel? _user;
  bool _isEditing = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _avatarCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _avatarCtrl = TextEditingController();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await DatabaseHelper.instance.getUser();
    if (user != null) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      _avatarCtrl.text = user.avatar ?? '';
      setState(() => _user = user);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  // ================= SAVE PROFILE =================

  Future<void> _saveProfile() async {
    if (_user == null) return;

    final updated = _user!.copyWith(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      avatar: _avatarCtrl.text.trim().isEmpty
          ? null
          : _avatarCtrl.text.trim(),
    );

    await DatabaseHelper.instance.saveUser(updated);
    ref.invalidate(userProvider);

    setState(() {
      _user = updated;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  // ================= CLEAR CACHE =================

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Offline Data'),
        content: const Text(
          'This will remove all locally cached properties. '
              'Your favorites and sent inquiries will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
            onPressed: () async {
              await DatabaseHelper.instance.clearOfflineCache();

              ref.invalidate(userProvider);
              ref.invalidate(propertyListProvider);

              if (context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Offline cache cleared'),
                  ),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          if (_user != null)
            TextButton(
              onPressed: () =>
              _isEditing ? _saveProfile() : setState(() => _isEditing = true),
              child: Text(
                _isEditing ? 'Save' : 'Edit',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ================= PROFILE HEADER =================
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatarCtrl.text.isNotEmpty
                      ? NetworkImage(_avatarCtrl.text)
                      : null,
                  child: _avatarCtrl.text.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),

                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _avatarCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Avatar URL',
                      prefixIcon: Icon(Icons.image),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                _isEditing
                    ? TextField(
                  controller: _nameCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Name'),
                )
                    : Text(
                  _user?.name ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                _isEditing
                    ? TextField(
                  controller: _emailCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Email'),
                )
                    : Text(
                  _user?.email ?? '',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ================= SYNC SETTINGS =================
          const Text("Sync Settings",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),

          SwitchListTile(
            title: const Text('Offline Mode'),
            subtitle: const Text('Wi-Fi only sync'),
            secondary: const Icon(Icons.wifi_off),
            value: _user?.isOfflineModeOnly ?? false,
            onChanged: (val) async {
              if (_user == null) return;
              final updated = _user!.copyWith(isOfflineModeOnly: val);
              await DatabaseHelper.instance.saveUser(updated);
              ref.invalidate(userProvider);
              setState(() => _user = updated);
            },
          ),

          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: isDarkMode,
            onChanged: (_) =>
                ref.read(themeProvider.notifier).toggleTheme(),
          ),

          const SizedBox(height: 24),

          // ================= ACTIONS =================
          const Text("Actions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Offline Cache'),
            subtitle: const Text('Remove cached properties'),
            onTap: () => _clearCache(context),
          ),
        ],
      ),
    );
  }
}
