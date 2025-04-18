import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  List<String> symptoms = [];
  List<String?> selectedSymptoms = [null];
  int symptomCount = 1;
  final int maxSymptoms = 5;
  String? petType;

  late Interpreter interpreter;
  List<String> xColumns = [];
  bool modelLoaded = false;
  String predictionResult = '';

  @override
  void initState() {
    super.initState();
    loadModelAndFeatures();
    loadSymptoms();
    _fetchPetType();
  }

  Future<void> loadModelAndFeatures() async {
    interpreter =
        await Interpreter.fromAsset('model/cat_and_dog_nn_model.tflite');

    String raw = await rootBundle.loadString('model/x_columns.txt');
    xColumns = raw.split('\n').map((e) => e.trim()).toList();

    setState(() {
      modelLoaded = true;
    });
  }

  Future<void> _fetchPetType() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users').child(user.uid);
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          petType = userData['petType'];
        });
        print('Pet Type: $petType');
      }
    }
  }

  Future<void> loadSymptoms() async {
    String jsonString =
        await rootBundle.loadString('model/all_symptoms_cat_and_dog.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    List<String?> allSymptoms = [];
    jsonData.forEach((key, value) {
      if (value is List) {
        for (var item in value) {
          allSymptoms.add(item?.toString());
        }
      }
    });
    symptoms = allSymptoms.whereType<String>().toList();
    setState(() {});
  }

  void addSymptomField() {
    if (symptomCount < maxSymptoms) {
      setState(() {
        symptomCount++;
        selectedSymptoms.add(null);
      });
    }
  }

  List<double> createInputRow(String animalName, List<String> symptoms) {
    List<double> inputRow = List.filled(xColumns.length, 0.0);

    for (int i = 0; i < xColumns.length; i++) {
      if (xColumns[i] == animalName || symptoms.contains(xColumns[i])) {
        inputRow[i] = 1.0;
      }
    }
    return inputRow;
  }

  Future<void> predict() async {
    if (petType == null || selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please wait, or fill all inputs')),
      );
      return;
    }

    List<String> validSymptoms = selectedSymptoms.whereType<String>().toList();
    List<double> inputRow = createInputRow(petType!, validSymptoms);

    var inputTensor = [inputRow];
    var outputTensor = List.filled(1 * 1, 0.0).reshape([1, 1]);

    interpreter.run(inputTensor, outputTensor);

    double probability = outputTensor[0][0];
    int prediction = probability > 0.5 ? 1 : 0;

    setState(() {
      predictionResult = prediction == 1 ? "Dangerous" : "Not Dangerous";
    });

    // Show popup dialog with result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Prediction Result'),
        content: Text(
          predictionResult,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: prediction == 1 ? Colors.red : Colors.green,
          ),
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff2d9),
      appBar: AppBar(
        title: const Text('Prediction'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addSymptomField,
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
        tooltip: 'Add Symptom',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: Image.asset('images/Prediction.png'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Symptoms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < symptomCount; i++)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownSearch<String>(
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: "Search symptom",
                      ),
                    ),
                  ),
                  items: symptoms,
                  selectedItem: selectedSymptoms[i],
                  onChanged: (newValue) {
                    setState(() {
                      selectedSymptoms[i] = newValue;
                    });
                  },
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Symptom ${i + 1}',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: modelLoaded ? predict : null,
              child: const Text('Predict'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
