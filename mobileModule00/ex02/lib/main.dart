import 'dart:developer';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

enum ButtonType { number, operator, action, equal, none }

class CalculatorButtonData {
  final String label;
  final ButtonType type;
  final Color textColor;

  const CalculatorButtonData({required this.label, required this.type, this.textColor = Colors.black});
}

const List<CalculatorButtonData> calculatorButtons = [
  CalculatorButtonData(label: '7', type: ButtonType.number),
  CalculatorButtonData(label: '8', type: ButtonType.number),
  CalculatorButtonData(label: '9', type: ButtonType.number),
  CalculatorButtonData(label: 'C', type: ButtonType.action, textColor: Colors.red),
  CalculatorButtonData(label: 'AC', type: ButtonType.action, textColor: Colors.red),
  CalculatorButtonData(label: '4', type: ButtonType.number),
  CalculatorButtonData(label: '5', type: ButtonType.number),
  CalculatorButtonData(label: '6', type: ButtonType.number),
  CalculatorButtonData(label: '+', type: ButtonType.operator),
  CalculatorButtonData(label: '-', type: ButtonType.operator),
  CalculatorButtonData(label: '1', type: ButtonType.number),
  CalculatorButtonData(label: '2', type: ButtonType.number),
  CalculatorButtonData(label: '3', type: ButtonType.number),
  CalculatorButtonData(label: '*', type: ButtonType.operator),
  CalculatorButtonData(label: '/', type: ButtonType.operator),
  CalculatorButtonData(label: '0', type: ButtonType.number),
  CalculatorButtonData(label: '.', type: ButtonType.action),
  CalculatorButtonData(label: '00', type: ButtonType.number),
  CalculatorButtonData(label: '=', type: ButtonType.equal),
  CalculatorButtonData(label: '', type: ButtonType.none),
];

class DisplayArea extends StatelessWidget {
  const DisplayArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class InitialCalculatorWidget extends StatefulWidget {
  const InitialCalculatorWidget({super.key});

  @override
  State<InitialCalculatorWidget> createState() =>
      _InitialCalculatorWidgetState();
}

class _InitialCalculatorWidgetState extends State<InitialCalculatorWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DisplayArea(),
        Expanded(
          child: GridView.builder(
            itemCount: calculatorButtons.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              // mainAxisSpacing: 8,
              // crossAxisSpacing: 8,
              // childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final buttonData = calculatorButtons[index];
              return ElevatedButton(
                onPressed: () {
                  debugPrint('Button pressed: ${buttonData.label}');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1)
                  ),
                  backgroundColor: Colors.blueGrey
                ),
                child: Text(
                  buttonData.label,
                  style: TextStyle(
                    color: buttonData.textColor,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Calculator'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(child: InitialCalculatorWidget()),
      ),
    );
  }
}
