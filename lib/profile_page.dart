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

      // Set default values for the client profile
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
      DatabaseReference profileRef = _database.child('users').child(userId).child('profile');
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
      DatabaseReference profileRef = _database
          .child('users')
          .child(userId)
          .child('profile');
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
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  // No action; gallery opening removed
                },
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
            const Center(
              child: Icon(Icons.photo_camera, size: 30),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pet details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Description:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _description),
                            decoration: const InputDecoration(
                              hintText: 'Description',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            maxLines: 1,
                            onChanged: (value) {
                              setState(() {
                                _description = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Name:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _petName),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _petName = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Breed:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _breed),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _breed = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Type:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _type),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _type = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Gender:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _gender),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Size:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _size),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _size = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Weight:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _weight),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _weight = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Owner details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Name:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _ownerName),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _ownerName = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Address:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _address),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _address = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 25,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: const Text('Password:'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _password),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveData,
        child: const Icon(Icons.save),
      ),
    );
  }
}
