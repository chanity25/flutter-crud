import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  late Future<List<Map<String, dynamic>>> _contacts;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contacts = fetchContacts();
  }

  // Function to fetch contacts from the API
  Future<List<Map<String, dynamic>>> fetchContacts() async {
    final url = Uri.parse(
        "https://spweb2key.online/emp/userLists"); // Replace with your API URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server returns an OK response, parse the JSON
      final data = json.decode(response.body);
      List<dynamic> userList = data['userList'];
      return userList
          .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
          .toList();
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load contacts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Management'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contacts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts available'));
          } else {
            // Data is available, display it in a ListView
            var contacts = snapshot.data!;
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                var contact = contacts[index];

                var accountId = contact['account_id'] ?? 'No contact';

                return ListTile(
                  title: Text(contact['email'] ?? 'No email'),
                  subtitle: Text('Contact No. : ${contact['contact']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editContact(contacts, contact, index, accountId);
                        },
                      ),
                      // Delete Button
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteContact(contacts, index, accountId);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _editContact(List<Map<String, dynamic>> contacts,
      Map<String, dynamic> contact, int index, accountId) {
    // Open a dialog or navigate to another screen to edit the contact.
    // After editing, update the contact in the data source and refresh the list.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  // onChanged: (value) => updatedName = value,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: _nameController.text,
                  ),
                  controller: _nameController),
              TextField(
                  // onChanged: (value) => updatedEmail = value,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: _emailController.text,
                  ),
                  controller: _emailController),
              TextField(
                  // onChanged: (value) => updatedContactNo = value,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    hintText: _contactController.text,
                  ),
                  controller: _contactController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the contact in the list and close the dialog
                _confirmUpdate(accountId);

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmUpdate(id) async {
    var url = Uri.parse("https://spweb2key.online/emp/updateUser");
    var response = await http.post(url, body: {
      // "name": _nameController.text,
      "email": _emailController.text,
      "contact": _contactController.text,
      // "password": "test",
      "account_id": id
    });

    var data = json.decode(response.body);

    if (data['status'] == 'success') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Contact()),
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update Successful')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Registration Failed, Please enter your valid information to proceed.')));
    }
  }

  void _deleteContact(
      List<Map<String, dynamic>> contacts, int index, accountId) {
    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Contact'),
        content: Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                contacts.removeAt(index);

                _confirmDelete(accountId);
              });
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(accountId) async {
    var url = Uri.parse("https://spweb2key.online/emp/deleteUser");
    var response = await http.post(url, body: {
      "account_id": accountId,
    });
  }

  // Future<void> _confirmUpdate() async {}
}
