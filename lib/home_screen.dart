import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medicine_page.dart';
import 'prediction_page.dart';
import 'goal_page.dart';
import 'veterinary_page.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff2d9),
      body: Column(
        children: [
          // Top image section
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.25,
            color: const Color(0xFFffbc0b),
            child: Image.asset(
              'images/pet-care-home.png',
              fit: BoxFit.cover,
            ),
          ),
          // Pet card section
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'images/my_dog.jpeg',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'My Dog',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Four rounded square widgets
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8.0),
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
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

                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.22, // 22% width
                  child: RoundedSquareWidget(
                    image: image,
                    text: text,
                    onTap: onTap,
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/signin');
            },
            child: const Text('Logout'),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                image,
                width: 40,
                height: 40,
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
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
