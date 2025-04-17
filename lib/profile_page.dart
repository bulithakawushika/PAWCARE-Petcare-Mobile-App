import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
          profilePictureRef.set('images/dog.jpeg');
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
        // Optionally, show a success message to the user
      } catch (error) {
        print('Error updating password: $error');
        // Optionally, show an error message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Profile',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: ClipOval(
                    child: FutureBuilder<String?>(
                      future: Future.value(_profilePictureUrl),
                      builder: (context, snapshot) {
                        ImageProvider image;
                        if (snapshot.hasData && snapshot.data != null) {
                          image = const AssetImage('images/dog.jpeg');
                        } else {
                          image = const AssetImage('images/dog.jpeg');
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
              const Center(child: Icon(Icons.photo_camera, size: 30)),
              const Text('Pet details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5), //change
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: TextEditingController(text: _description),
                      style: const TextStyle(fontStyle: FontStyle.italic),
                      decoration: const InputDecoration(
                        hintText: 'Describe the furball of joy!',
                        hintStyle: const TextStyle(fontStyle: FontStyle.italic),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildInputField('Name', _ownerName, (val) {
                _ownerName = val;
              }, 'Owner Name'),
              _buildInputField('Address', _address, (val) {
                _address = val;
              }, 'Address'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Row(
                  children: [
                    SizedBox(width: 100, child: Text('Change Password')),
                    const SizedBox(width: 0),
                    Expanded(
                      child: _PasswordTextField(
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                      padding: const EdgeInsets.symmetric(vertical: 5), //change
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String initialValue,
      Function(String) onChanged, String? placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          const SizedBox(width: 0),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: initialValue),
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  onChanged(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
