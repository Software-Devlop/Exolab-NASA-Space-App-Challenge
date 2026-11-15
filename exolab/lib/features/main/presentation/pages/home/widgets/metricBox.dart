import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';

class MetricBox extends StatelessWidget {
  final String label;
  const MetricBox({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 300),
      width: double.infinity,
      height: 200,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor,
            offset: Offset(0, 0),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 6,
            children: [
              Icon(
                Icons.ac_unit_rounded,
                color: context.colors.primary,
                size: 21,
              ),
              Text(label, style: context.text.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}
