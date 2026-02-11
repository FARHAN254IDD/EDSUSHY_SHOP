import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  XFile? _selectedImageFile; // For web compatibility

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _fullNameController = TextEditingController(
      text: userProvider.currentUser?.fullName ?? '',
    );
    _phoneController = TextEditingController(
      text: userProvider.currentUser?.phoneNumber ?? '',
    );
    _addressController = TextEditingController(
      text: userProvider.currentUser?.address ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = pickedFile;
          if (!kIsWeb) {
            _selectedImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    print('=== SAVE PROFILE CLICKED ===');
    
    if (_fullNameController.text.isEmpty) {
      print('❌ Full name is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final uid = userProvider.currentUser?.uid;

    if (uid == null) {
      print('❌ User ID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      return;
    }

    print('User ID: $uid');
    print('Full Name: ${_fullNameController.text}');
    print('Phone: ${_phoneController.text}');
    print('Address: ${_addressController.text}');
    print('Selected image: ${_selectedImageFile != null}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving profile...')),
    );

    String? photoUrl = userProvider.currentUser?.profilePhotoUrl;

    // Upload photo if selected
    if (_selectedImageFile != null) {
      print('📸 Uploading photo...');
      if (kIsWeb) {
        print('Using web upload');
        photoUrl = await userProvider.uploadProfilePhotoWeb(_selectedImageFile!, uid);
      } else {
        print('Using mobile upload');
        photoUrl = await userProvider.uploadProfilePhoto(_selectedImage!, uid);
      }
      
      if (photoUrl == null) {
        print('❌ Photo upload failed');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userProvider.profileUpdateError ?? 'Error uploading photo')),
        );
        return;
      }
      print('✅ Photo uploaded: $photoUrl');
    }

    // Update profile
    print('💾 Updating profile data...');
    final success = await userProvider.updateUserProfile(
      uid: uid,
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      profilePhotoUrl: photoUrl,
    );

    if (!mounted) return;
    
    if (success) {
      print('✅ Profile updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.profileUpdateError ?? 'Error updating profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.currentUser == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Photo Section
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Profile Photo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                        color: Colors.grey[200],
                      ),
                      child: _selectedImageFile != null
                          ? ClipOval(
                              child: kIsWeb
                                  ? FutureBuilder<Uint8List>(
                                      future: _selectedImageFile!.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        return const CircularProgressIndicator();
                                      },
                                    )
                                  : Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : (userProvider.currentUser?.profilePhotoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    userProvider.currentUser!.profilePhotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person);
                                    },
                                  ),
                                )
                              : const Icon(Icons.person, size: 50)),
                    ),
                    // Upload Photo Button
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Fields
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your address',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Email (Read-only)
                TextField(
                  controller: TextEditingController(
                    text: userProvider.currentUser?.email ?? '',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: userProvider.isUpdatingProfile ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: userProvider.isUpdatingProfile
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
