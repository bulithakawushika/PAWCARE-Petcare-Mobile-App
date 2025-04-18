import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // For encoding images to base64
import 'dart:io'; // For handling file images

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _PasswordTextField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _PasswordTextField({Key? key, required this.onChanged})
      : super(key: key);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: 'Password',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  String? _profilePictureUrl;
  File? _imageFile;

  String _description = '';
  String _petName = '';
  String _breed = '';
  String _type = '';
  String _gender = '';
  String _size = '';
  String _weight = '';
  String _ownerName = '';
  String _address = '';
  String _password = '';

  final _picker = ImagePicker();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    loadProfilePicture();
    createClientProfileTable();
    _loadData();
  }

  Future<void> createClientProfileTable() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      DatabaseReference clientProfileRef =
          _database.child('client_profiles').child(userId);

      await clientProfileRef.set({
        'name': 'Your Name',
        'email': 'your.email@example.com',
        'phone': '123-456-7890',
        'address': 'Your Address',
      });
    }
  }

  Future<void> loadProfilePicture() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      DatabaseReference profilePictureRef =
          _database.child('users').child(userId).child('profile_picture');

      profilePictureRef.once().then((DatabaseEvent event) {
        if (event.snapshot.value == null) {
          profilePictureRef.set(null);
        }
      });

      profilePictureRef.onValue.listen((event) {
        setState(() {
          _profilePictureUrl = event.snapshot.value as String?;
        });
      });
    }
  }

  Future<void> _loadData() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      DatabaseReference profileRef =
          _database.child('users').child(userId).child('profile');
      profileRef.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _description = data['description'] ?? '';
            _petName = data['petName'] ?? '';
            _breed = data['breed'] ?? '';
            _type = data['type'] ?? '';
            _gender = data['gender'] ?? '';
            _size = data['size'] ?? '';
            _weight = data['weight'] ?? '';
            _ownerName = data['ownerName'] ?? '';
            _address = data['address'] ?? '';
            _password = data['password'] ?? '';
          });
        }
      });
    }
  }

  Future<void> _saveData() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      DatabaseReference profileRef =
          _database.child('users').child(userId).child('profile');
      await profileRef.set({
        'description': _description,
        'petName': _petName,
        'breed': _breed,
        'type': _type,
        'gender': _gender,
        'size': _size,
        'weight': _weight,
        'ownerName': _ownerName,
        'address': _address,
        'password': _password,
      }).catchError((error) {
        print("Error saving data: $error");
      });
    }
  }

  Future<void> _updatePassword() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null && _password.isNotEmpty) {
      try {
        User? user = _auth.currentUser;
        await user?.updatePassword(_password);
        print('Password updated successfully!');
      } catch (error) {
        print('Error updating password: $error');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_imageFile != null) {
      String base64Image = base64Encode(_imageFile!.readAsBytesSync());
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DatabaseReference profilePictureRef =
            _database.child('users').child(userId).child('profile_picture');
        await profilePictureRef.set(base64Image);
      }
    }
  }

  Widget _buildInputField(String label, String initialValue,
      Function(String) onChanged, String hintText,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextField(
        obscureText: isPassword ? !_isPasswordVisible : false,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFFFFF2D9), // Light cream background color
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Profile',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: ClipOval(
                          child: FutureBuilder<String?>(
                            future: Future.value(_profilePictureUrl),
                            builder: (context, snapshot) {
                              ImageProvider<Object>? image;
                              if (snapshot.hasData && snapshot.data != null) {
                                image = MemoryImage(base64Decode(snapshot.data!));
                              } else {
                                image = null;
                              }
                              return CircleAvatar(
                                radius: 75,
                                backgroundImage: image,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.camera_alt, size: 30, color: Colors.grey),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Pet details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: TextEditingController(text: _description),
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        decoration: const InputDecoration(
                          hintText: 'Describe the furball of joy!',
                          hintStyle: TextStyle(fontStyle: FontStyle.italic),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                _buildInputField('Name', _petName, (val) {
                  _petName = val;
                }, 'Pet Name'),
                _buildInputField('Breed', _breed, (val) {
                  _breed = val;
                }, 'Breed'),
                _buildInputField('Type', _type, (val) {
                  _type = val;
                }, 'Type'),
                _buildInputField('Gender', _gender, (val) {
                  _gender = val;
                }, 'Gender'),
                _buildInputField('Size', _size, (val) {
                  _size = val;
                }, 'Size'),
                _buildInputField('Weight', _weight, (val) {
                  _weight = val;
                }, 'Weight'),
                const SizedBox(height: 10),
                const Text('Owner details',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildInputField('Name', _ownerName, (val) {
                  _ownerName = val;
                }, 'Owner Name'),
                _buildInputField('Address', _address, (val) {
                  _address = val;
                }, 'Address'),
                _buildInputField('Password', _password, (val) {
                  _password = val;
                }, 'Password', isPassword: true),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveData();
                        _updatePassword();
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFBC0B),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
