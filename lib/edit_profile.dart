
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();

  String selectedCategory = ""; // Holds the selected category
  List<String> categories = []; // To dynamically fetch categories from Firestore

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories from Firestore
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
      setState(() {
        categories = snapshot.docs.map((doc) => doc['name'].toString()).toList();
        selectedCategory = categories.isNotEmpty ? categories.first : ""; // Default to the first category
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    String name = nameController.text.trim();
    String dob = dobController.text.trim();
    String location = locationController.text.trim();
    String specialty = specialtyController.text.trim();


    if (name.isEmpty || dob.isEmpty || location.isEmpty || specialty.isEmpty || selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    try {
      // Save service provider data
      //change it  to update
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      DocumentReference providerRef = FirebaseFirestore.instance.collection('service-providers').doc(userId);
      await providerRef.set({
        'name': name,
        'dob': dob,
        'location': location,
        'specialty': specialty,
        'category': selectedCategory,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      // Update the Category collection with the service provider's reference
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('name', isEqualTo: selectedCategory)
          .get();

      if (categorySnapshot.docs.isNotEmpty) {
        DocumentReference categoryRef = categorySnapshot.docs.first.reference;

        // Add the service provider's ID to the `ProviderList` in the category
        await categoryRef.update({
          'ProviderList': FieldValue.arrayUnion([providerRef.id]),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile saved successfully.")),
      );
      Navigator.pushNamed(context, '/home'); // Redirect to HomePage
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save profile. Please try again.")),
      );
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text("Edit Profile"),
  //       automaticallyImplyLeading: false, // Removes the back button
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         children: [
  //           TextField(
  //             controller: nameController,
  //             decoration: const InputDecoration(
  //               labelText: "Name",
  //               border: OutlineInputBorder(),
  //             ),
  //             inputFormatters: [
  //               FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Only allow letters and spaces
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           TextField(
  //             controller: dobController,
  //             readOnly: true,
  //             decoration: const InputDecoration(
  //               labelText: "Date of Birth",
  //               border: OutlineInputBorder(),
  //               suffixIcon: Icon(Icons.calendar_today),
  //             ),
  //             onTap: () => _selectDate(context),
  //           ),
  //           const SizedBox(height: 16),
  //           TextField(
  //             controller: locationController,
  //             decoration: const InputDecoration(
  //               labelText: "Location",
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           DropdownButtonFormField<String>(
  //             value: selectedCategory,
  //             items: categories
  //                 .map((category) => DropdownMenuItem<String>(
  //               value: category,
  //               child: Text(category),
  //             ))
  //                 .toList(),
  //             onChanged: (value) {
  //               setState(() {
  //                 selectedCategory = value ?? "";
  //               });
  //             },
  //             decoration: const InputDecoration(
  //               labelText: "Category",
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           TextField(
  //             controller: specialtyController,
  //             decoration: const InputDecoration(
  //               labelText: "Specialty",
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //           ElevatedButton(
  //             onPressed: _saveProfile,
  //             child: const Text("Save"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Only allow letters and spaces
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dobController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Date of Birth",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value ?? "";
                });
              },
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: specialtyController,
              decoration: const InputDecoration(
                labelText: "Specialty",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

}
