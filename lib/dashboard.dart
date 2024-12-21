import 'package:flutter/material.dart';
import 'package:desktop_search_a_holic/sidebar.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, const Color.fromARGB(255, 73, 206, 195)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Dashboard'),
      ),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlueAccent,
                    const Color.fromARGB(141, 178, 255, 89)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.white, // Background color
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Welcome to the Dashboard',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Here you can manage your products, view reports, and more.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white, // Background color
                    child: ListTile(
                      title: const Text('Dummy Data 1'),
                      subtitle: const Text('This is some dummy data.'),
                    ),
                  ),
                  Card(
                    color: Colors.white, // Background color
                    child: ListTile(
                      title: const Text('Dummy Data 2'),
                      subtitle: const Text('This is some more dummy data.'),
                    ),
                  ),
                  Card(
                    color: Colors.white, // Background color
                    child: ListTile(
                      title: const Text('Dummy Data 3'),
                      subtitle: const Text('This is some more dummy data.'),
                    ),
                  ),
                  Card(
                    color: Colors.white, // Background color
                    child: ListTile(
                      title: const Text('Dummy Data 4'),
                      subtitle: const Text('This is some more dummy data.'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
