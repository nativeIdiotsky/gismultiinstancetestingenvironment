import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EmergencyHotlinesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EmergencyHotlinesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFFF7F2FA),
          title: Text(
            'Emergency hotline',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 22,
              color: Color(0xFF1D1B20),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF1D1B20)),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Emergency contact numbers\nDefault: 911',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF49454F),
                  letterSpacing: 0.25,
                  height: 1.4, // Equivalent to lineHeight: "20px"
                ),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213A57),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onPressed: () {
                // Handle call action
              },
              child: Text(
                'Call rescue response team',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
