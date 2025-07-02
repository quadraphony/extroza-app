import 'dart:io';
import 'package:extroza/core/services/database_service.dart';
import 'package:extroza/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserModel user;
  const ProfileEditScreen({super.key, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final DatabaseService _db = DatabaseService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isSaving = false;

  late String _fullName;
  late String _nickname;
  late String _bio;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fullName = widget.user.fullName;
    _nickname = widget.user.nickname;
    _bio = widget.user.bio ?? '';
  }

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // TODO: Implement Firebase Storage upload for _profileImage
    }
  }

  Future<void> _showEditBottomSheet(
      String title, String initialValue, String fieldKey) async {
    final controller = TextEditingController(text: initialValue);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your $title',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'New $title',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () async {
                  if (controller.text.isNotEmpty && _uid != null) {
                    setState(() => _isSaving = true);
                    await _db
                        .updateUserProfile(_uid!, {fieldKey: controller.text});
                    
                    setState(() {
                      if (fieldKey == 'fullName') _fullName = controller.text;
                      if (fieldKey == 'nickname') _nickname = controller.text;
                      if (fieldKey == 'bio') _bio = controller.text;
                      _isSaving = false;
                    });
                    Navigator.of(context).pop(); 
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String getInitials(String name) {
    if (name.isEmpty) return 'EX';
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLocalImage = _profileImage != null;
    final bool hasRemoteImage = widget.user.profilePictureUrl != null &&
        widget.user.profilePictureUrl!.isNotEmpty;

    // --- FIX: Determine the ImageProvider outside the widget ---
    ImageProvider? backgroundImage;
    if (hasLocalImage) {
      backgroundImage = FileImage(_profileImage!);
    } else if (hasRemoteImage) {
      backgroundImage = NetworkImage(widget.user.profilePictureUrl!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  // Use the pre-determined ImageProvider
                  backgroundImage: backgroundImage,
                  child: (backgroundImage == null)
                      ? Text(
                          getInitials(_fullName),
                          style: TextStyle(
                              fontSize: 40,
                              color: Theme.of(context).primaryColor),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _showImagePickerOptions,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoTile(
            context: context,
            icon: Icons.person_outline,
            label: 'Name',
            value: _fullName,
            onTap: () => _showEditBottomSheet('Full Name', _fullName, 'fullName'),
          ),
          _buildInfoTile(
            context: context,
            icon: Icons.badge_outlined,
            label: 'Nickname',
            value: _nickname,
            onTap: () => _showEditBottomSheet('Nickname', _nickname, 'nickname'),
          ),
          _buildInfoTile(
            context: context,
            icon: Icons.info_outline,
            label: 'About / Mood',
            value: _bio.isEmpty ? 'Not set' : _bio,
            onTap: () => _showEditBottomSheet('About / Mood', _bio, 'bio'),
          ),
          const Divider(height: 48),
          ListTile(
            leading:
                Icon(Icons.alternate_email_rounded, color: Colors.grey[700]),
            title: const Text('Username', style: TextStyle(color: Colors.grey)),
            subtitle: Text(widget.user.username),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Username cannot be changed.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Icon(Icons.edit, color: Theme.of(context).primaryColor),
      onTap: onTap,
    );
  }
}
