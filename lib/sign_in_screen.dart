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
              password: _passwordController.text.trim());

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
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                    child: Text('Sign In'),
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserTypeScreen()),
                    );
                  },
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
