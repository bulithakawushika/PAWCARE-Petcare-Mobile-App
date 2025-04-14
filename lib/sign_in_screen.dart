import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_screen.dart';
import 'user_type_screen.dart';
import 'veterinary_home_page.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${userCredential.user?.email}')),
      );

      final ref = FirebaseDatabase.instance.ref();
      final snapshot =
          await ref.child('users/${userCredential.user!.uid}').get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> userData = snapshot.value as Map;
        if (userData['type'] == 'veterinary') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(

              builder: (context) => VeterinaryHomePage(
                name: userData['name'] ?? '',
                email: userData['email'] ?? '',
                phone: userData['phone'] ?? '',
                address: userData['address'] ?? '',
                birthday: userData['birthday'] ?? '',
              ),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(
              context, '/home'); // Navigate to home screen
        }
      } else {
        Navigator.pushReplacementNamed(
            context, '/home'); // Navigate to home screen
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Sign in failed.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-email') {
        message = 'Invalid email or password';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      } else {
        message = "Invalid email or password";
      }
      print('Firebase Auth Exception Code: ${e.code}'); // Log the error code
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFfff2d9),
              Color(0xFFfff2d9),
              Color(0xFFfcd262),
            ],
            stops: [0.0, 0.33, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 48.0, left: 16.0, right: 16.0, bottom: 16.0),
          child: Column(
            children: [
              Image.asset(
                'images/signin.png',
                height: 250,
              ),
              SizedBox(height: 20),
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFffbc0b),
                        textStyle: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserTypeScreen()),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
