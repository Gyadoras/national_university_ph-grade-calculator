import 'package:flutter/material.dart';

void main() {
  runApp(const NuGradeCalculatorApp());
}

class NuGradeCalculatorApp extends StatelessWidget {
  const NuGradeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NU Grade Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xff1d3276), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1d3276),
          primary: const Color(0xff1d3276),
          secondary: const Color(0xffd9b638), 
          surface: const Color(0xfff4f6f9),
        ),
        scaffoldBackgroundColor: const Color(0xfff4f6f9),
        useMaterial3: true,
      ),
      home: const GradeCalculatorHome(),
    );
  }
}

class AssessmentItem {
  TextEditingController scoreController = TextEditingController();
  TextEditingController hpsController = TextEditingController();
}

class GradeCategory {
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  List<AssessmentItem> items = [];

  GradeCategory() {
    items.add(AssessmentItem());
  }
}

class PeriodData {
  double classStandingWeight = 60.0;
  double examWeight = 40.0;
  TextEditingController classStandingController = TextEditingController(text: "60");
  TextEditingController examController = TextEditingController(text: "40");
  TextEditingController examScoreController = TextEditingController();
  TextEditingController examHpsController = TextEditingController();
  List<GradeCategory> categories = [];
}

class GradeCalculatorHome extends StatefulWidget {
  const GradeCalculatorHome({super.key});

  @override
  State<GradeCalculatorHome> createState() => _GradeCalculatorHomeState();
}

class _GradeCalculatorHomeState extends State<GradeCalculatorHome> {
  final PeriodData _midtermData = PeriodData();
  final PeriodData _finalData = PeriodData();

  String _midtermResult = "N/A";
  String _finalResult = "N/A";
  String _semestralResult = "N/A";

  String? _midtermError;
  String? _finalError;

  @override
  void initState() {
    super.initState();
    _midtermData.categories.add(GradeCategory()..nameController.text = "Quizzes"..weightController.text = "100");
    _finalData.categories.add(GradeCategory()..nameController.text = "Quizzes"..weightController.text = "100");
  }

  String _convertToFourPointSystem(double percentage) {
    if (percentage >= 96) return "4.0";
    if (percentage >= 90) return "3.5";
    if (percentage >= 84) return "3.0";
    if (percentage >= 78) return "2.5";
    if (percentage >= 72) return "2.0";
    if (percentage >= 66) return "1.5";
    if (percentage >= 60) return "1.0";
    return "R";
  }

  void _calculateGrades() {
    setState(() {
      _midtermError = null;
      _finalError = null;

      double? midtermPercentage = _calculatePeriod(_midtermData, (err) => _midtermError = err);
      double? finalPercentage = _calculatePeriod(_finalData, (err) => _finalError = err);

      if (_midtermError == null && midtermPercentage != null) {
        _midtermResult = "${midtermPercentage.toStringAsFixed(2)}% (${_convertToFourPointSystem(midtermPercentage)})";
      } else {
        _midtermResult = "Error";
      }

      if (_finalError == null && finalPercentage != null) {
        _finalResult = "${finalPercentage.toStringAsFixed(2)}% (${_convertToFourPointSystem(finalPercentage)})";
      } else {
        _finalResult = "Error";
      }

      if (_midtermError == null && _finalError == null && midtermPercentage != null && finalPercentage != null) {
        double semestral = (midtermPercentage + finalPercentage) / 2;
        _semestralResult = "${semestral.toStringAsFixed(2)}% (${_convertToFourPointSystem(semestral)})";
      } else {
        _semestralResult = "N/A (Fix errors)";
      }
    });
  }

  double? _calculatePeriod(PeriodData data, Function(String) onError) {
    if (data.categories.isNotEmpty) {
      double totalWeight = 0;
      for (var cat in data.categories) {
        totalWeight += double.tryParse(cat.weightController.text) ?? 0;
      }
      if (totalWeight != 100.0) {
        onError("Category weights must equal 100%. Total: ${totalWeight.toStringAsFixed(0)}%");
        return null;
      }
    }

    double totalClassStandingScore = 0;

    for (var cat in data.categories) {
      double catWeight = (double.tryParse(cat.weightController.text) ?? 0) / 100;
      double catTotalScore = 0;
      double catTotalHps = 0;

      for (var item in cat.items) {
        double score = double.tryParse(item.scoreController.text) ?? 0;
        double hps = double.tryParse(item.hpsController.text) ?? 0;
        catTotalScore += score;
        catTotalHps += hps;
      }

      double catPercentage = catTotalHps > 0 ? (catTotalScore / catTotalHps) : 0;
      totalClassStandingScore += (catPercentage * catWeight);
    }

    double examScore = double.tryParse(data.examScoreController.text) ?? 0;
    double examHps = double.tryParse(data.examHpsController.text) ?? 0;
    double examPercentage = examHps > 0 ? (examScore / examHps) : 0;

    double classStandingContribution = totalClassStandingScore * data.classStandingWeight;
    double examContribution = examPercentage * data.examWeight;

    return classStandingContribution + examContribution;
  }

  void _updateWeights(PeriodData data, double classStandingVal) {
    setState(() {
      data.classStandingWeight = classStandingVal.clamp(0, 100);
      data.examWeight = 100 - data.classStandingWeight;
      data.classStandingController.text = data.classStandingWeight.toStringAsFixed(0);
      data.examController.text = data.examWeight.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff1d3276), 
          centerTitle: true,
          title: const Text(
            'NU GRADE CALCULATOR',
            style: TextStyle(
              color: Color(0xffd9b638), 
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xffd9b638), 
            unselectedLabelColor: Colors.white70,
            indicatorColor: Color(0xffd9b638),
            tabs: [
              Tab(icon: Icon(Icons.looks_one), text: "Midterm Period"),
              Tab(icon: Icon(Icons.looks_two), text: "Final Period"),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildPeriodForm(_midtermData, _midtermError),
                  _buildPeriodForm(_finalData, _finalError),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xff1d3276),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
              ),
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultSummary("Midterm Result", _midtermResult),
                        _buildResultSummary("Final Term Result", _finalResult),
                      ],
                    ),
                    const Divider(color: Color(0xffd9b638), height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tentative Semestral Grade:",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _semestralResult,
                          style: const TextStyle(color: Color(0xffd9b638), fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffd9b638),
                          foregroundColor: const Color(0xff1d3276),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _calculateGrades,
                        child: const Text("Calculate Total Grades", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSummary(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPeriodForm(PeriodData data, String? errorText) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (errorText != null)
          Card(
            color: Colors.red.shade50,
            shape: RoundedRectangleBorder(side: BorderSide(color: Colors.red.shade300), borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(child: Text(errorText, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),

        Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Weight Split Configuration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xff1d3276))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: data.classStandingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Class Standing %", border: OutlineInputBorder()),
                        onChanged: (val) {
                          double parsed = double.tryParse(val) ?? 60;
                          _updateWeights(data, parsed);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: data.examController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Exam %", border: OutlineInputBorder()),
                        onChanged: (val) {
                          double parsed = double.tryParse(val) ?? 40;
                          _updateWeights(data, 100 - parsed);
                        },
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: data.classStandingWeight,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: const Color(0xff1d3276),
                  inactiveColor: const Color(0xffd9b638).withValues(alpha: 0.3),
                  thumbColor: const Color(0xffd9b638),
                  onChanged: (val) => _updateWeights(data, val),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Class Standing Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff1d3276))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1d3276),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  data.categories.add(GradeCategory());
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Category"),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...data.categories.asMap().entries.map((catEntry) {
          int catIdx = catEntry.key;
          GradeCategory cat = catEntry.value;

          return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xffd9b638), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: cat.nameController,
                            decoration: const InputDecoration(hintText: "e.g., Quizzes, Activities", labelText: "Category Name", isDense: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: cat.weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: "%", labelText: "Weight %", isDense: true),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              data.categories.removeAt(catIdx);
                            });
                          },
                        )
                      ],
                    ),
                    const Divider(height: 24),
                    ...cat.items.asMap().entries.map((itemEntry) {
                      int itemIdx = itemEntry.key;
                      AssessmentItem item = itemEntry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text("#${itemIdx + 1}", style: const TextStyle(color: Colors.grey)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: item.scoreController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(hintText: "Score", isDense: true, border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text("/"),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: item.hpsController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(hintText: "HPS", isDense: true, border: OutlineInputBorder()),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  if (cat.items.length > 1) {
                                    cat.items.removeAt(itemIdx);
                                  }
                                });
                              },
                            )
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          cat.items.add(AssessmentItem());
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xff1d3276)),
                      label: const Text("Add Score Entry", style: TextStyle(color: Color(0xff1d3276))),
                    ),
                  ],
                ),
              ));
        }),

        const SizedBox(height: 16),
        const Text("Examination", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff1d3276))),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: data.examScoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Your Exam Score", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                const Text("/", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: data.examHpsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Exam HPS", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
