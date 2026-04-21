import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: const Text("Placement Prep Tracker  "),
      ), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Progress",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text("DSA: 20/100"),
            const Text("Aptitude: 10/50"),
            const Text("Core CS: 5/30"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Add Task"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.check_box_outline_blank),
                    title: Text("Solve 2 DSA problems"),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_box_outline_blank),
                    title: Text("Revise DBMS"),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_box_outline_blank),
                    title: Text("Practice aptitude"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}//test
