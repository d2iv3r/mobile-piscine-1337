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
];

class DisplayArea extends StatelessWidget {
  const DisplayArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 30, 43, 59),
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            textAlign: TextAlign.right,
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
            textAlign: TextAlign.right,
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

class ButtonsWidget extends StatefulWidget {
  const ButtonsWidget({super.key});

  @override
  State<ButtonsWidget> createState() =>
      _ButtonsWidgetState();
}

class _ButtonsWidgetState extends State<ButtonsWidget> {
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
                onPressed: () {
                  debugPrint('Button pressed :${buttonData.label}');
                },
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Calculator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.topCenter,
                child: DisplayArea(),
              ),
            ),
            Expanded(
              flex: 2,
              child: ButtonsWidget(),
            )
          ],
        ),
      ),
    );
  }
}
