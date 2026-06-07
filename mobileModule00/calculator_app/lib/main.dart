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
];

class DisplayArea extends StatelessWidget {
  const DisplayArea({
    super.key,
    required this.inputController,
    required this.resultController,
  });

  final TextEditingController inputController;
  final TextEditingController resultController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 30, 43, 59),
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            controller: inputController,
            readOnly: true,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 28,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "0",
              hintStyle: TextStyle(
                color: Colors.blueGrey,
                fontSize: 28,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          TextField(
            controller: resultController,
            readOnly: true,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 28,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "0",
              hintStyle: TextStyle(
                color: Colors.blueGrey,
                fontSize: 28,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
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

class ButtonsWidget extends StatelessWidget {
  const ButtonsWidget({super.key, required this.handleButtonPress});

  final void Function(CalculatorButtonData) handleButtonPress;

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 5;
    const gridSpacing = 10.0;
    const holderPadding = 6.0;

    return Container(
      color: Colors.blueGrey,
      padding: EdgeInsets.all(holderPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rows = (calculatorButtons.length / crossAxisCount).ceil();
          final usableWidth = constraints.maxWidth - (crossAxisCount - 1) * gridSpacing;
          final usableHeight = constraints.maxHeight - (rows - 1) * gridSpacing;
          final itemWidth = usableWidth / crossAxisCount;
          final itemHeight = usableHeight / rows;
          final ratio = itemHeight > 0 ? itemWidth / itemHeight : 1.0;

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: calculatorButtons.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: gridSpacing,
              mainAxisSpacing: gridSpacing,
              childAspectRatio: ratio,
            ),
            itemBuilder: (context, index) {
              final buttonData = calculatorButtons[index];
              return ElevatedButton(
                onPressed: () => handleButtonPress(buttonData),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                child: Text(
                  buttonData.label,
                  style: TextStyle(
                    color: buttonData.textColor,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  void handleButtonPress(CalculatorButtonData buttonData) {
    switch (buttonData.label) {
      case 'C':
        _inputController.text = _inputController.text.isNotEmpty
            ? _inputController.text.substring(0, _inputController.text.length - 1)
            : '';
        break;
      case 'AC':
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.topCenter,
              child: DisplayArea(
                inputController: _inputController,
                resultController: _resultController,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ButtonsWidget(handleButtonPress: handleButtonPress),
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
      home: CalculatorApp(),
    );
  }
}
