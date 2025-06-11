import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:naqd_app/personal/personal_main.dart';

class SpendingTrendScreen extends StatefulWidget {
  @override
  _SpendingTrendScreenState createState() => _SpendingTrendScreenState();
}

class _SpendingTrendScreenState extends State<SpendingTrendScreen> {
  // Updated map to store total amount and icon by type
  Map<String, Map<String, dynamic>> categoryData = {};

  @override
  void initState() {
    super.initState();
    fetchSpendingData();
  }

  Future<void> fetchSpendingData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('spendings')
          .get();

      Map<String, Map<String, dynamic>> tempData = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
        final type = data['type'] ?? 'Unknown';
        final icon = data['icon'] ?? '❓';

        if (tempData.containsKey(type)) {
          tempData[type]!['total'] += amount;
        } else {
          tempData[type] = {
            'total': amount,
            'icon': icon,
          };
        }
      }

      setState(() {
        categoryData = tempData;
      });
    } catch (e) {
      print("Error fetching spending data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => PersonalMainScreen()),
                      );
                    },
                  ),
                  Text("WEEKLY", style: TextStyle(color: Colors.white70)),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Container(
                height: size.height * 0.3,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple, Colors.transparent]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    backgroundColor: Colors.transparent,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < categoryData.length) {
                              final key = categoryData.keys.elementAt(index);
                              return Text(
                                categoryData[key]!['icon'],
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(categoryData.length, (index) {
                      final key = categoryData.keys.elementAt(index);
                      final total = categoryData[key]!['total'] as double;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: total,
                            color: Colors.purpleAccent,
                            width: 14,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Wrap(
                spacing: 20,
                runSpacing: 30,
                children: categoryData.entries.map((entry) {
                  final label = entry.key;
                  final total = entry.value['total'] as double;
                  final icon = entry.value['icon'] as String;
                  return _categoryCard(label, '${total.toStringAsFixed(2)} SAR', icon);
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCard(String label, String amount, String icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: TextStyle(color: Colors.white70, fontSize: 16)),
                SizedBox(width: 6),
                Text(label, style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            SizedBox(height: 4),
            Text(amount, style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
