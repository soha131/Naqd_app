import 'package:flutter/material.dart';

class NaqdBackground extends StatelessWidget {
  final Widget? child;

  const NaqdBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: GridView.builder(
            padding: const EdgeInsets.all(5),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 40,
            ),
            itemCount: 10,
            physics: const NeverScrollableScrollPhysics(), // disable scroll
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  'NAQD',
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.04 * 255).round()),
                    fontSize: 65,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),

        // Foreground content
        if (child != null) child!,
      ],
    );
  }
}
