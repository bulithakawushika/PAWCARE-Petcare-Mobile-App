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

  @override
  void initState() {
    super.initState();
    loadProfilePicture();
    createClientProfileTable();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff2d9),
      body: SafeArea(
        child: Stack(
          children: [
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 3 / 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFfff8eb),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 14,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 7,
              left: 0,
              right: 0,
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
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 7 + 60,
              left: 0,
              right: 0,
              child: const Center(
                child: Icon(Icons.photo_camera, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    var firstStart = Offset(size.width / 4, size.height);
    var firstEnd = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);
    var secondStart = Offset(size.width / 1.5, size.height - 60);
    var secondEnd = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
        secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
