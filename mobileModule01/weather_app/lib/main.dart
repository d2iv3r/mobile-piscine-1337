import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int index = 0;
  final TextEditingController _cityController = TextEditingController();

  final List<Widget> pages = [
    Center(child: Text('Currently')),
    Center(child: Text('Today')),
    Center(child: Text('Weekly')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Enter city name',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    pages[0] = Center(child: Text('Currently\n${_cityController.text}'));
                    pages[1] = Center(child: Text('Today\n${_cityController.text}'));
                    pages[2] = Center(child: Text('Weekly\n${_cityController.text}'));
                  });
                },
              )
            ],
          ),
        ),
        body: pages[index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (int index) {
            setState(() {
              this.index = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              label: 'Currently',
              icon: Icon(Icons.now_widgets),
              
            ),
            BottomNavigationBarItem(
              label: 'Today',
              icon: Icon(Icons.today),
            ),
            BottomNavigationBarItem(
              label: 'Weekly',
              icon: Icon(Icons.calendar_view_week),
            )
          ],
        ),
      );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
