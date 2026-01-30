import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/property_provider.dart';
import '../db/database_helper.dart';
import 'inquiries_screen.dart';
import 'my_inquiries_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _avatarCtrl;
  //XFile? _pickedAvatar;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _avatarCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _avatarCtrl.dispose();
 //   _pickedAvatar = null;
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
     // _pickedAvatar = picked;
      _avatarCtrl.text = picked.path;
    });
  }

  void _syncFromUser(UserModel user, bool isEditing) {
    if (isEditing) return;
    if (_nameCtrl.text != user.name) _nameCtrl.text = user.name;
    if (_emailCtrl.text != user.email) _emailCtrl.text = user.email;
    final av = user.avatar ?? '';
    if (_avatarCtrl.text != av) _avatarCtrl.text = av;
  }

  Future<void> _saveProfile(UserModel user) async {
    final updated = user.copyWith(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
      avatar: _avatarCtrl.text.trim().isEmpty ? null : _avatarCtrl.text.trim(),
    );
    await ref.read(userProvider.notifier).updateUser(updated);
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Offline Data'),
        content: const Text(
          'This will remove all locally cached properties. '
          'Your favorites and sent inquiries will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Offline cache cleared')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await ref.read(authNotifierProvider).signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final userAsync = ref.watch(userProvider);
    final user = userAsync.maybeWhen(data: (d) => d, orElse: () => null);

    if (user != null) _syncFromUser(user, _isEditing);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          TextButton(
            onPressed: () => _isEditing
                ? _saveProfile(user)
                : setState(() => _isEditing = true),
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
          Center(
            child: Column(
              children: [
                Builder(
                  builder: (ctx) {
                    final av = _avatarCtrl.text.trim();
                    ImageProvider? avatarImage;
                    if (av.isNotEmpty) {
                      if (av.startsWith('http')) {
                        avatarImage = NetworkImage(av);
                      } else if (av.startsWith('assets/')) {
                        avatarImage = AssetImage(av);
                      } else {
                        avatarImage = FileImage(File(av));
                      }
                    }

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: avatarImage,
                          child: avatarImage == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _avatarCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Avatar URL or local path',
                              prefixIcon: Icon(Icons.image),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickAvatar,
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Upload'),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () {
                                  _avatarCtrl.clear();
                                  //setState(() => _pickedAvatar = null);
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                _isEditing
                    ? TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name'),
                      )
                    : Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const SizedBox(height: 6),
                _isEditing
                    ? TextField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                      )
                    : Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    user.role.displayName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: user.isAdmin
                      ? Colors.blue.shade100
                      : Colors.grey.shade300,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Sync Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Offline Mode'),
            subtitle: const Text('Wi-Fi only sync'),
            secondary: const Icon(Icons.wifi_off),
            value: user.isOfflineModeOnly,
            onChanged: (val) async {
              final u = user.copyWith(isOfflineModeOnly: val);
              await ref.read(userProvider.notifier).updateUser(u);
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: isDarkMode,
            onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Actions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
          if (user.isAdmin)
            ListTile(
              leading: const Icon(Icons.inbox_outlined, color: Colors.blue),
              title: const Text('View Inquiries'),
              subtitle: const Text('All inquiries (admin)'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InquiriesScreen()),
              ),
            )
          else
            ListTile(
              leading: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.blue,
              ),
              title: const Text('My Inquiries'),
              subtitle: const Text('Your sent messages'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyInquiriesScreen()),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Offline Cache'),
            subtitle: const Text('Remove cached properties'),
            onTap: () => _clearCache(context),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.orange.shade700),
            title: const Text('Sign out'),
            subtitle: const Text('Sign out of your account'),
            onTap: () => _signOut(),
          ),
        ],
      ),
    );
  }
}
