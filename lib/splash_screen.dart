import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petapp2/sign_in_screen.dart';
import 'home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'veterinary_home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                final user = snapshot.data;
                if (user == null) {
                  return SignInScreen();
                } else {
                  return FutureBuilder(
                    future: FirebaseDatabase.instance.ref().child('users/${user.uid}').get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map<dynamic, dynamic> userData = snapshot.data!.value as Map;
                        if (userData['type'] == 'veterinary') {
                          return VeterinaryHomePage(
                            name: userData['name'] ?? '',
                            email: userData['email'] ?? '',
                            phone: userData['phone'] ?? '',
                            address: userData['address'] ?? '',
                            birthday: userData['birthday'] ?? '',
                          );
                        } else {
                          return HomeScreen();
                        }
                      } else {
                        return Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  );
                }
              } else {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/Splash.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
