import 'dart:convert'; // <-- Important for base64Decode
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  String _petType = ''; // Default pet type
  String? _petImageBase64; // Uploaded image (nullable)

  final _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _fetchPetData();
  }

  Future<void> _fetchPetData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await _database.child('users').child(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          _petName = snapshot.child('petName').value as String? ?? 'My Dog';
          _petType = snapshot.child('petType').value as String? ?? 'Cat';
          _petImageBase64 = snapshot.child('petImage').value as String?;
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
                alignment: Alignment.center,
                child: Image.asset(
                  'images/pet-care-home.png',
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.20 * 0.75,
                  fit: BoxFit.contain,
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
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Card(
                color: const Color(0xFFffbc0b),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _petName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _petType,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      ClipOval(
                        child: _petImageBase64 != null
                            ? Image.memory(
                                base64Decode(_petImageBase64!),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'images/my_dog.jpeg',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
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
