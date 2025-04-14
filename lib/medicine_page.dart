import 'package:flutter/material.dart';

class MedicinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff2d9),
      appBar: AppBar(
        title: const Text('Set Medicine'),
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 150,
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
                        const Text(
                          'Pet Name',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Pet Type',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    ClipOval(
                      child: Image.asset(
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
          const Center(
            child: Text('Medicine Page Content'),
          ),
        ],
      ),
    );
  }
}
