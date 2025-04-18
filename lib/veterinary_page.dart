import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

class VeterinaryPage extends StatefulWidget {
  @override
  _VeterinaryPageState createState() => _VeterinaryPageState();
}

class _VeterinaryPageState extends State<VeterinaryPage> {
  TextEditingController searchController = TextEditingController();
  List<Veterinary> searchResults = [];
  List<Veterinary> allVeterinaries = [];
  final databaseReference = FirebaseDatabase.instance.ref().child('users');

  @override
  void initState() {
    super.initState();
    fetchVeterinaryData();
  }

  Future<void> fetchVeterinaryData() async {
    DatabaseEvent event = await databaseReference
        .orderByChild('type')
        .equalTo('veterinary')
        .once();
    DataSnapshot dataSnapshot = event.snapshot;

    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> data = dataSnapshot.value as Map;
      List<Veterinary> vets = [];
      data.forEach((key, value) {
        vets.add(Veterinary(
          id: key,
          name: value['name'],
          address: value['address'],
          phone: value['phone'],
        ));
      });
      setState(() {
        searchResults = vets;
        allVeterinaries = vets;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFfff2d9),
        title: Text(
          'Veterinary',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFfff2d9),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or address',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  // Perform search here
                  setState(() {
                    searchResults = allVeterinaries
                        .where((vet) =>
                            vet.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            vet.address
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final veterinary = searchResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                veterinary.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(veterinary.address),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFffbc0b),
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              final Uri phoneUri = Uri(
                                scheme: 'tel',
                                path: veterinary.phone,
                              );
                              if (await launchUrl(phoneUri)) {
                                launchUrl(phoneUri);
                              } else {
                                throw 'Could not launch ${phoneUri.path}';
                              }
                            },
                            child: const Text(
                              'Call',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Veterinary {
  final String id;
  final String name;
  final String address;
  final String phone;

  Veterinary({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
  });
}
