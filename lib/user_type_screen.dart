import 'package:flutter/material.dart';
import 'veterinary_sign_up_screen.dart';
import 'pet_sign_up_screen.dart';

class UserTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select your user type"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VeterinarySignUpScreen()),
                );
              },
              child: Text("Veterinary"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetSignUpScreen()),
                );
              },
              child: Text("Client"),
            ),
          ],
        ),
      ),
    );
  }
}
