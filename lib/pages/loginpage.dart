import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gismultiinstancetestingenvironment/pages/newsfeed.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gismultiinstancetestingenvironment/pages/inbox/inbox_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  /// Displays a snackbar message
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  /// Stores the FCM token in Supabase after login
  Future<void> _storeFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print('🔑 FCM Token: $token');

    final user = supabase.auth.currentUser;
    if (token != null && user != null) {
      try {
        final response = await supabase
            .from('profiles')
            .update({'fcm_token': token}).eq('id', user.id);

        print('✅ FCM Token stored successfully for user: ${user.id}');
      } catch (e) {
        print('❌ Supabase Error: $e');
      }
    } else {
      print('⚠️ No authenticated user found or FCM token is null.');
    }
  }

  /// Handles user login
  Future<void> _logIn() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        _showSnackBar('Sign in successful', Colors.green);
        await _storeFCMToken();
        _navigateToNewsFeed();
      }
    } catch (e) {
      _showSnackBar('Sign In error: ${e.toString()}', Colors.red);
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handles anonymous login
  Future<void> _anonymousLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.auth.signInAnonymously();
      if (response.user != null) {
        _showSnackBar('Anonymous sign in successful', Colors.green);
        await _storeFCMToken();
        _navigateToNewsFeed();
      }
    } catch (e) {
      _showSnackBar('Sign In error: ${e.toString()}', Colors.red);
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Navigates to the Inbox Page after login
  void _navigateToNewsFeed() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => NewsFeed()));
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
              _buildProfileIcon(screenSize.width * 0.2),
              const SizedBox(height: 20),
              _buildLoginForm(),
              const SizedBox(height: 20),
              _buildLoginButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the profile icon at the top of the login screen
  Widget _buildProfileIcon(double size) {
    return Container(
      width: size,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
        gradient:
            const LinearGradient(colors: [Colors.indigo, Colors.blueAccent]),
      ),
      child: const Icon(Icons.account_box, size: 80, color: Colors.white),
    );
  }

  /// Builds the login form fields
  Widget _buildLoginForm() {
    return Column(
      children: [
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
      ],
    );
  }

  /// Builds the login buttons
  Widget _buildLoginButtons() {
    return Row(
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
