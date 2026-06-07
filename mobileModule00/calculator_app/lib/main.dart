import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:math_expressions/math_expressions.dart';

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

String calculateResult(String input) {
  try {
    GrammarParser p = GrammarParser();
    Expression exp = p.parse(input);
    ContextModel cm = ContextModel();

    double result = exp.evaluate(EvaluationType.REAL, cm);
    return result.toString();
  } catch (e) {
    return 'Error: $e';
  }
}

class _InitialCalculatorWidgetState extends State<InitialCalculatorWidget> {

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();



  void handleButtonPress(CalculatorButtonData buttonData) {
    switch (buttonData.label) {
      case 'C':
        debugPrint('Clear last input');
        _inputController.text = _inputController.text.isNotEmpty
            ? _inputController.text.substring(0, _inputController.text.length - 1)
            : '';
        break;
      case 'AC':
        debugPrint('Clear all inputs');
        _inputController.clear();
        _resultController.clear();
        break;
      case '=':
        String res = calculateResult(_inputController.text);
        _resultController.text = res;
        break;
      default:
        _inputController.text += buttonData.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _inputController,
          readOnly: true,
            decoration: InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _resultController,
            decoration: InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
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
                onPressed: () => handleButtonPress(buttonData),
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
