import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileComponent extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String avatarUrl;
  final ValueChanged<Map<String, String>> onProfileUpdated;
  const EditProfileComponent({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatarUrl,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<EditProfileComponent> createState() => _EditProfileComponentState();
}

class _EditProfileComponentState extends State<EditProfileComponent> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  String? _avatarUrl;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _emailController = TextEditingController(text: widget.email);
    _avatarUrl = widget.avatarUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
        _avatarUrl = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _avatarFile != null
                  ? FileImage(_avatarFile!)
                  : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                            ? NetworkImage(_avatarUrl!)
                            : null)
                        as ImageProvider?,
              child:
                  (_avatarFile == null &&
                      (_avatarUrl == null || _avatarUrl!.isEmpty))
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              widget.onProfileUpdated({
                'firstName': _firstNameController.text,
                'lastName': _lastNameController.text,
                'email': _emailController.text,
                'avatarUrl': _avatarFile != null
                    ? _avatarFile!.path
                    : (_avatarUrl ?? ''),
              });
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Profil mis à jour'),
                  content: const Text(
                    'Vos informations ont été enregistrées avec succès.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
