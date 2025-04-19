import 'dart:convert'; // For base64Decode
import 'dart:io';
import 'dart:convert'; // For base64Decode
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_page.dart';
import 'medicine_page.dart';
import 'prediction_page.dart';
import 'goal_page.dart';
import 'veterinary_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _petName = 'My Dog'; // Default pet name
  String _petType = 'Cat'; // Default pet type
  String? _petImageBase64; // Uploaded image (nullable)
  String _defaultImagePath = 'images/dog.jpeg';

  final _database = FirebaseDatabase.instance.ref();
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _fetchPetData();
    loadProfilePicture();
  }

  Future<void> loadProfilePicture() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DatabaseReference profilePictureRef =
          _database.child('users').child(userId).child('profile_picture');

      profilePictureRef.onValue.listen((event) {
        setState(() {
          _profilePictureUrl = event.snapshot.value as String?;
        });
      });
    }
  }

  Future<void> _fetchPetData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await _database.child('users').child(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          _petName = snapshot.child('petName').value as String? ?? 'My Dog';
          _petType = snapshot.child('petType').value as String? ?? 'Cat';
        });
      } else {
        print('No data available.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff2d9),
      body: Column(
        children: [
          // Top image section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(130),
              bottomRight: Radius.circular(130),
            ),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.20,
              color: const Color(0xFFffbc0b),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Image.asset(
                    'images/pet-care-home.png',
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.20 * 0.75,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          // Pet card section
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 150,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(petName: _petName, petType: _petType)),
                );
              },
              child: Card(
                color: const Color(0xFFffbc0b),
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _petName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _petType,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      ClipOval(
                        child: _profilePictureUrl != null
                            ? FutureBuilder<String?>(
                                future: Future.value(_profilePictureUrl),
                                builder: (context, snapshot) {
                                  ImageProvider<Object>? image;
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    image = MemoryImage(
                                        base64Decode(snapshot.data!));
                                  } else {
                                    image = AssetImage('images/dog.jpeg');
                                  }
                                  return CircleAvatar(
                                    radius: 50,
                                    backgroundImage: image,
                                  );
                                },
                              )
                            : const CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage('images/dog.jpeg'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Four rounded square widgets
          Expanded(
            child: GridView.count(
              crossAxisCount: 1,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height * 0.12),
              padding: const EdgeInsets.all(8.0),
              children: List.generate(4, (index) {
                String image;
                String text;
                VoidCallback onTap;

                switch (index) {
                  case 0:
                    image = 'images/pet-care-home-medicine.png';
                    text = 'Set Medicine';
                    onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MedicinePage()),
                      );
                    };
                    break;
                  case 1:
                    image = 'images/pet-care-home-prediction.png';
                    text = 'Prediction';
                    onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PredictionPage()),
                      );
                    };
                    break;
                  case 2:
                    image = 'images/pet-care-home-goal.png';
                    text = 'Set Goal';
                    onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GoalPage()),
                      );
                    };
                    break;
                  case 3:
                    image = 'images/petcare-home-veterinary.png';
                    text = 'Veterinary';
                    onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VeterinaryPage()),
                      );
                    };
                    break;
                  default:
                    image = '';
                    text = '';
                    onTap = () {};
                }

                return RoundedSquareWidget(
                  image: image,
                  text: text,
                  onTap: onTap,
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFffbc0b),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await Future.delayed(const Duration(milliseconds: 500));
              Navigator.pushReplacementNamed(context, '/signin');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedSquareWidget extends StatelessWidget {
  final String image;
  final String text;
  final VoidCallback onTap;

  const RoundedSquareWidget({
    Key? key,
    required this.image,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                image,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFFffbc0b),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
