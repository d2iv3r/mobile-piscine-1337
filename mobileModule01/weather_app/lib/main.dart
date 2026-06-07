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

  int currentIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _cityController = TextEditingController();
  String searchValue = '';


  void _handleOnTab(int value) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        value,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
    setState(() {
      currentIndex = value;
    });
  }

  void _handleOnChanged(String value) {
    setState(() {
      searchValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 48, 62, 73),
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  onChanged: _handleOnChanged,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    hintText: 'Search location...',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 28,
                child: VerticalDivider(
                  color: Colors.white,
                  thickness: 1,
                  width: 20,
                ),
              ),
              IconButton(
                icon: Icon(Icons.near_me, color: Colors.white),
                onPressed: () {
                  setState(() {
                    searchValue = "Geolocation";
                    _cityController.clear();
                  });
                },
              ),
            ],
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _handleOnTab,
          children: [
            Center(child: Text('Currently\n$searchValue', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            Center(child: Text('Today\n$searchValue', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            Center(child: Text('Weekly\n$searchValue', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: _handleOnTab,
          items: const [
            BottomNavigationBarItem(label: 'Currently', icon: Icon(Icons.now_widgets)),
            BottomNavigationBarItem(label: 'Today', icon: Icon(Icons.today)),
            BottomNavigationBarItem(label: 'Weekly', icon: Icon(Icons.calendar_view_week)),
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
