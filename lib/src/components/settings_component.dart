import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io';
import 'edit_profile_component.dart';
import '../../src/components/app_logger.dart';
import 'package:path_provider/path_provider.dart';

class SettingsComponent extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String avatarUrl;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Map<String, String>> onProfileUpdated;
  const SettingsComponent({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatarUrl,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<SettingsComponent> createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {
  Future<Directory> getCustomDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final customDir = Directory('${appDocDir.path}/src/data');
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }
    return customDir;
  }

  Future<void> _saveProfileToJson() async {
    try {
      final profile = {
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'avatarUrl': _avatarUrl,
        'role': _selectedRole,
        'paymentType': _paymentTypeController.text,
        'vehicleType': _selectedVehicle,
      };
      final jsonString = json.encode(profile);
      final directory = await getCustomDirectory();
      final file = File('${directory.path}/sessions.json');
      await file.writeAsString(jsonString);
      AppLogger().info('Profile saved to ${file.path}');
    } catch (e) {
      AppLogger().error('Erreur lors de la sauvegarde du profil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde du profil: $e')),
        );
      }
    }
  }

  Future<void> _loadProfileFromJson() async {
    try {
      final data = await rootBundle.loadString('assets/sessions.json');
      final profile = json.decode(data);
      setState(() {
        _firstName = profile['firstName'] ?? _firstName;
        _lastName = profile['lastName'] ?? _lastName;
        _email = profile['email'] ?? _email;
        _avatarUrl = profile['avatarUrl'] ?? _avatarUrl;
        _selectedRole = profile['role'] ?? _selectedRole;
        _paymentTypeController.text = profile['paymentType'] ?? '';
        _selectedVehicle = profile['vehicleType'] ?? _selectedVehicle;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du profil: $e')),
        );
      }
    }
  }

  String _selectedVehicle = 'voiture';
  final TextEditingController _paymentTypeController = TextEditingController();
  String _selectedRole = 'Acheteur';
  late bool _isDark;
  late String _firstName;
  late String _lastName;
  late String _email;
  late String _avatarUrl;

  @override
  void initState() {
    super.initState();
    _isDark = widget.themeMode == ThemeMode.dark;
    _firstName = widget.firstName;
    _lastName = widget.lastName;
    _email = widget.email;
    _avatarUrl = widget.avatarUrl;
    _loadProfileFromJson();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: _avatarUrl.isNotEmpty
              ? CircleAvatar(backgroundImage: NetworkImage(_avatarUrl))
              : const CircleAvatar(child: Icon(Icons.person)),
          title: Text('$_firstName $_lastName'),
          subtitle: Text(_email),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder: (context) => Dialog(
                  child: EditProfileComponent(
                    firstName: _firstName,
                    lastName: _lastName,
                    email: _email,
                    avatarUrl: _avatarUrl,
                    onProfileUpdated: (profile) {
                      Navigator.of(context).pop(profile);
                    },
                  ),
                ),
              );
              if (result != null) {
                setState(() {
                  _firstName = result['firstName'] ?? _firstName;
                  _lastName = result['lastName'] ?? _lastName;
                  _email = result['email'] ?? _email;
                  _avatarUrl = result['avatarUrl'] ?? _avatarUrl;
                });
                widget.onProfileUpdated({
                  'firstName': _firstName,
                  'lastName': _lastName,
                  'email': _email,
                  'avatarUrl': _avatarUrl,
                });
                await _saveProfileToJson();
              }
            },
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Theme'),
          trailing: Switch(
            value: _isDark,
            onChanged: (val) {
              setState(() {
                _isDark = val;
              });
              widget.onThemeChanged(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rôle utilisateur',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              RadioListTile<String>(
                title: const Text('Acheteur'),
                value: 'Acheteur',
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('filidides'),
                value: 'filidides',
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Vendeur'),
                value: 'Vendeur',
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _selectedRole == 'filidides'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type de véhicule',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedVehicle,
                      items: const [
                        DropdownMenuItem(
                          value: 'voiture',
                          child: Text('voiture'),
                        ),
                        DropdownMenuItem(
                          value: 'camionette',
                          child: Text('camionette'),
                        ),
                        DropdownMenuItem(value: 'velo', child: Text('velo')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicle = value!;
                        });
                      },
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type de paiement',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: _paymentTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Entrez le type de paiement',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
        ),
        // Add more help items here later
      ],
    );
  }
}
