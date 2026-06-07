import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class CentredTextButtonWidget extends StatefulWidget {
  const CentredTextButtonWidget({super.key});

  @override
  State<CentredTextButtonWidget> createState() => _CentredTextButtonWidgetState();
}

class _CentredTextButtonWidgetState extends State<CentredTextButtonWidget> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isButtonPressed ? 'Hello world' : 'A simple text',
            textAlign: TextAlign.center,
            style: TextStyle(
              backgroundColor: Colors.lightGreen,
              fontSize: 24,
              fontWeight: FontWeight.bold,),
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isButtonPressed = !_isButtonPressed;
              });
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
