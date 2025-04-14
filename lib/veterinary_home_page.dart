import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VeterinaryHomePage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String birthday;

  VeterinaryHomePage({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.birthday,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinary Home'),
      ),
      body: Center(
        child: Container(
          color: const Color(0xFFfaecd8),
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'images/veterinary.png',
                  height: 200,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(name, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Email', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(email, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Phone', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(phone, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Address', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(address, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(context, '/signin');
                          },
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
