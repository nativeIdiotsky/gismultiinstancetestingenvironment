import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAccountInfo extends StatefulWidget {
  @override
  _EditAccountInfoState createState() => _EditAccountInfoState();
}

class _EditAccountInfoState extends State<EditAccountInfo> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isObscuredNew = true;
  bool _isObscuredConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase.from('profiles').select().eq('id', user.id).single();
      setState(() {
        usernameController.text = response['username'] ?? '';
        firstNameController.text = response['first_name'] ?? '';
        lastNameController.text = response['last_name'] ?? '';
        emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _updateUserInfo() async {
    if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        await supabase.from('profiles').update({
          'username': usernameController.text,
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
        }).eq('id', user.id);

        if (newPasswordController.text.isNotEmpty) {
          await supabase.auth.updateUser(
            UserAttributes(password: newPasswordController.text),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Account Info',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTextField('Username', usernameController, Icons.person),
            SizedBox(height: 16),
            buildTextField('First Name', firstNameController, Icons.badge),
            SizedBox(height: 16),
            buildTextField(
                'Last Name', lastNameController, Icons.badge_outlined),
            SizedBox(height: 16),
            buildTextField('Email Address', emailController, Icons.email,
                enabled: false),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Password must include:\n- At least 8 characters\n- One uppercase letter\n- One lowercase letter',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF49454F),
                    height: 1.33),
              ),
            ),
            buildPasswordField('New Password', newPasswordController,
                Icons.lock_outline, _isObscuredNew, () {
              setState(() {
                _isObscuredNew = !_isObscuredNew;
              });
            }),
            SizedBox(height: 16),
            buildPasswordField(
                'Confirm New Password',
                confirmPasswordController,
                Icons.lock_reset,
                _isObscuredConfirm, () {
              setState(() {
                _isObscuredConfirm = !_isObscuredConfirm;
              });
            }),
            SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(color: Color(0xFF79747E)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: _isLoading ? null : _updateUserInfo,
              child: _isLoading
                  ? CircularProgressIndicator(color: Color(0xFF65558F))
                  : Text(
                      'Save Changes',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF65558F)),
                    ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
          prefixIcon: Icon(icon, color: Colors.grey),
        ),
      ),
    );
  }

  Widget buildPasswordField(String label, TextEditingController controller,
      IconData icon, bool isObscured, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
}
