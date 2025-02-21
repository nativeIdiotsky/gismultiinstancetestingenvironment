import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gismultiinstancetestingenvironment/pages/loginpage.dart';
import 'package:gismultiinstancetestingenvironment/pages/signuppage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: 'Log In',
                ),
                Tab(
                  text: 'Sign Up',
                ),
              ],
            ),
            title: const Center(
              child: Text('GIS MULTIINSTANCE TESTING ENVIRONMENT'),
            ),
          ),
          body: const TabBarView(
            children: [
              LoginPage(),
              SignUpPage(),
            ],
          ),
        ),
      ),
    );
  }
}
