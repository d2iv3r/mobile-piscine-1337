import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class CentredTextButtonWidget extends StatelessWidget {
  const CentredTextButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color.fromRGBO(84, 85, 0, 1),
            ),
            child: Text(
              'A simple text',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              debugPrint('Button pressed');
            },
            child: Text(
              'Click Me',
              style: TextStyle(
                color: Color.fromRGBO(84, 85, 0, 1),
              ),
            ),
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
    return const MaterialApp(
      home: Scaffold(
        body: CentredTextButtonWidget()
      ),
    );
  }
}
