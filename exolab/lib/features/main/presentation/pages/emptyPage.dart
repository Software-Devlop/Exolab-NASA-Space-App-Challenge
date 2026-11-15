import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(30),
        constraints: BoxConstraints(maxWidth: 600),
        child: Text(
          "This section is intentionally left undeveloped due to time constraints. However, its core functionality and intended purpose are demonstrated through other sections of this project.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
