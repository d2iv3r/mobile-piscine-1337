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
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color.fromRGBO(84, 85, 0, 1),
            ),
            child: Text(
              _isButtonPressed ? 'Hello world' : 'A simple text',
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
              setState(() {
                _isButtonPressed = !_isButtonPressed;
              });
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
