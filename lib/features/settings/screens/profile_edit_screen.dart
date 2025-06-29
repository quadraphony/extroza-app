import 'dart:io';
import 'package:extroza/features/settings/screens/badges_screen.dart';
import 'package:extroza/features/settings/screens/username_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  // We'll use state variables to hold the user's data.
  // Later, this will come from your user model.
  String _name = 'Leeroy Sr';
  String _about = 'Available';
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  // Function to show the image picker options (Gallery or Camera)
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to handle image picking
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Generic function to show an editing dialog
  Future<void> _showEditDialog(String title, String initialValue, Function(String) onSave) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter your $title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: initialValue),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      onSave(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            // --- Avatar Section ---
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null
                  ? Text(
                      _name.isNotEmpty ? _name.substring(0, 2).toUpperCase() : 'LS',
                      style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _showImagePickerOptions,
              child: const Text('Edit photo'),
            ),
            const SizedBox(height: 24),

            // --- User Info Section ---
            _InfoTile(
              icon: Icons.person_outline,
              text: _name,
              onTap: () => _showEditDialog('name', _name, (newValue) {
                setState(() => _name = newValue);
              }),
            ),
            _InfoTile(
              icon: Icons.edit_outlined,
              text: _about,
              onTap: () => _showEditDialog('about info', _about, (newValue) {
                setState(() => _about = newValue);
              }),
            ),
            _InfoTile(
              icon: Icons.shield_outlined, // Placeholder for badge icon
              text: 'Badges',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BadgesScreen())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                'Your profile and changes to it will be visible to people you message, contacts, and groups.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),

            const Divider(height: 30),

            // --- Username Section ---
            _InfoTile(
              icon: Icons.alternate_email_rounded,
              text: 'Username',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UsernameScreen())),
            ),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                "People can now message you using your optional username so you don't have to give out your phone number.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for the list tiles to avoid code repetition
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _InfoTile({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(text),
      onTap: onTap,
    );
  }
}
