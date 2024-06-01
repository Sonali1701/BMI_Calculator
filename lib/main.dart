import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      home: const MyHomePage(title: 'BMI Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var wtController = TextEditingController();
  var ftController = TextEditingController();
  var inController = TextEditingController();
  String res = "";
  Color resColor = Colors.lightBlueAccent;
  List<String> bmiHistory = [];
  List<BMIData> bmiData = [];

  void _clearFields() {
    wtController.clear();
    ftController.clear();
    inController.clear();
    setState(() {
      res = "";
      resColor = Colors.lightBlueAccent;
    });
  }

  void _calculateBMI() {
    var wt = wtController.text.trim();
    var ft = ftController.text.trim();
    var inch = inController.text.trim();

    if (wt.isNotEmpty && ft.isNotEmpty && inch.isNotEmpty) {
      try {
        var iWt = int.parse(wt);
        var iFt = int.parse(ft);
        var iInch = int.parse(inch);

        var tinch = (iFt * 12) + iInch;
        var iCm = tinch * 2.54;
        var tM = iCm / 100;
        var bmi = iWt / (tM * tM);

        var msg = "";
        if (bmi > 25) {
          msg = "Ooops! You're Overweight!";
          resColor = Colors.redAccent;
          bmiData.add(BMIData('Overweight', bmi, Colors.redAccent));
        } else if (bmi < 18) {
          msg = "Ooops! You're Underweight!";
          resColor = Colors.orangeAccent;
          bmiData.add(BMIData('Underweight', bmi, Colors.orangeAccent));
        } else {
          msg = "Congrats! You're Healthy!";
          resColor = Colors.lightGreenAccent;
          bmiData.add(BMIData('Healthy', bmi, Colors.lightGreenAccent));
        }

        setState(() {
          res = "Your BMI is: ${bmi.toStringAsFixed(2)} \n$msg";
          bmiHistory.add(res);
        });
      } catch (e) {
        setState(() {
          res = "Invalid input! Please enter numbers only.";
          resColor = Colors.redAccent;
        });
      }
    } else {
      setState(() {
        res = "Please fill all the required information!";
        resColor = Colors.redAccent;
      });
    }
  }

  Widget _buildTips() {
    if (res.contains("Overweight")) {
      return Text(
        "Tip: Consider a balanced diet and regular exercise to lose weight.",
        style: TextStyle(color: Colors.redAccent),
      );
    } else if (res.contains("Underweight")) {
      return Text(
        "Tip: Increase your calorie intake with healthy foods to gain weight.",
        style: TextStyle(color: Colors.orangeAccent),
      );
    } else if (res.contains("Healthy")) {
      return Text(
        "Tip: Maintain your current lifestyle to stay healthy.",
        style: TextStyle(color: Colors.lightGreenAccent),
      );
    } else {
      return Container();
    }
  }

  List<charts.Series<BMIData, String>> _createBarChartData() {
    return [
      charts.Series<BMIData, String>(
        id: 'BMI',
        colorFn: (BMIData data, _) => charts.ColorUtil.fromDartColor(data.color),
        domainFn: (BMIData data, _) => data.category,
        measureFn: (BMIData data, _) => data.value,
        data: bmiData,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: resColor,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BMI Calculator',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: wtController,
                    decoration: InputDecoration(
                      labelText: 'Enter Your Weight (kg)',
                      prefixIcon: Icon(Icons.line_weight_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: ftController,
                    decoration: InputDecoration(
                      labelText: 'Enter Your Height (ft)',
                      prefixIcon: Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: inController,
                    decoration: InputDecoration(
                      labelText: 'Enter Your Height (in)',
                      prefixIcon: Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _calculateBMI,
                        child: Text("Calculate"),
                      ),
                      OutlinedButton(
                        onPressed: _clearFields,
                        child: Text("Clear"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    res,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  _buildTips(),
                  SizedBox(height: 20),
                  Container(
                    height: 200,
                    child: charts.BarChart(
                      _createBarChartData(),
                      animate: true,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'History',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 100,
                    child: ListView.builder(
                      itemCount: bmiHistory.length,
                      itemBuilder: (context, index) {
                        return Text(
                          bmiHistory[index],
                          style: TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BMIData {
  final String category;
  final double value;
  final Color color;

  BMIData(this.category, this.value, this.color);
}
