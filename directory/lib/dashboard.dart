import 'package:flutter/material.dart';
import 'package:ordering/contact.dart';
import 'package:ordering/settings.dart';
import 'main.dart';
import 'contact.dart';
import 'settings.dart';
import 'user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        // automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 cards per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            buildDashboardCard(Icons.phone, 'Contacts', Colors.blue, context),
            buildDashboardCard(Icons.person, 'Users', Colors.green, context),
            // buildDashboardCard(
            //     Icons.games_rounded, 'Orders', Colors.orange, context),
            buildDashboardCard(
                Icons.settings, 'Settings', Colors.purple, context),
          ],
        ),
      ),
    );
  }

  Future<void> onBoxClick(String Title, context) async {
    Widget screenWindow = Contact();
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Title)));

    switch (Title) {
      case 'Contacts':
        screenWindow = Contact();
        break;
      case 'Settings':
        screenWindow = Settings();
        break;
      case 'Users':
        screenWindow = User();
        break;
      case 'Orders':
        screenWindow = SizedBox.shrink();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('This option is not yet available')));
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screenWindow),
    );
  }

  // Function to build a single dashboard card
  Widget buildDashboardCard(
      IconData icon, String title, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await onBoxClick(title, context);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
