import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(30),
        constraints: BoxConstraints(maxWidth: 600),
        child: Text(
          "This section allows users to specify their gender, enabling the app to apply the corresponding health reference ranges and display a gender-specific 3D human model, similar to the one featured on the Home page.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
