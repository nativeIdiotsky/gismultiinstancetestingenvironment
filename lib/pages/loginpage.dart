import 'package:flutter/material.dart';
import 'package:gismultiinstancetestingenvironment/pages/anonymouscaptcha.dart';
import 'package:gismultiinstancetestingenvironment/pages/createpost.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  Future<void> _logIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _showSnackBar('Sign in successful', Colors.green);
        _navigateToCreatePost();
      }
    } catch (e) {
      _showSnackBar('Sign In error: ${e.toString()}', Colors.red);
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _anonymousLogin() async {
    setState(() => _isLoading = true);

    try {
      //Navigator.push(context,MaterialPageRoute(builder: (context) => const AnonymousCaptchaPage()),);
      final response = await supabase.auth.signInAnonymously();
      if (response.user != null) {
        _showSnackBar('Anonymous sign in successful', Colors.green);
        _navigateToCreatePost();
      }
    } catch (e) {
      _showSnackBar('Sign In error: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToCreatePost() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CreatePost()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 242, 255),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: screenSize.width * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenSize.width * 0.2,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  border: Border.all(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: const LinearGradient(
                    colors: [Colors.indigo, Colors.blueAccent],
                  ),
                ),
                child: const Icon(Icons.account_box,
                    size: 80, color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _logIn,
                          child: const Text('Sign In'),
                        ),
                  const SizedBox(width: 10),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _anonymousLogin,
                          child: const Text('Anonymous Login'),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
