import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
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
          profilePictureRef.set('images/my_dog.jpeg');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: ClipOval(
                    child: FutureBuilder<String?>(
                      future: Future.value(_profilePictureUrl),
                      builder: (context, snapshot) {
                        ImageProvider image;
                        if (snapshot.hasData && snapshot.data != null) {
                          image = NetworkImage(snapshot.data!);
                        } else {
                          image = const AssetImage('images/my_dog.jpeg');
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
              const SizedBox(height: 20),
              const Text('Pet details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildInputField('Description:', _description, (val) {
                _description = val;
              }),
              _buildInputField('Name:', _petName, (val) {
                _petName = val;
              }),
              _buildInputField('Breed:', _breed, (val) {
                _breed = val;
              }),
              _buildInputField('Type:', _type, (val) {
                _type = val;
              }),
              _buildInputField('Gender:', _gender, (val) {
                _gender = val;
              }),
              _buildInputField('Size:', _size, (val) {
                _size = val;
              }),
              _buildInputField('Weight:', _weight, (val) {
                _weight = val;
              }),
              const SizedBox(height: 20),
              const Text('Owner details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildInputField('Name:', _ownerName, (val) {
                _ownerName = val;
              }),
              _buildInputField('Address:', _address, (val) {
                _address = val;
              }),
              _buildInputField('Password:', _password, (val) {
                _password = val;
              }),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
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

  Widget _buildInputField(
      String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: initialValue),
              decoration: const InputDecoration(
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
