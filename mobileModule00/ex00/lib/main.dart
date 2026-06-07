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
          Text(
            'A simple text',
            textAlign: TextAlign.center,
            style: TextStyle(
              backgroundColor: Colors.lightGreen,
              fontSize: 24,
              fontWeight: FontWeight.bold,),
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              debugPrint('Button pressed');
            },
            child: Text('Click Me'),
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
