import 'package:flutter/material.dart';
import 'database_helper.dart';

class RegistrationPage extends StatefulWidget {
  final String role;
  const RegistrationPage({super.key, required this.role});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      // 1. Check if email already exists
      bool alreadyExists = await _dbHelper.doesUserExist(email);

      if (!mounted) return;

      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email already in use!"), backgroundColor: Colors.orange),
        );
      } else {
        // 2. Prepare the user map including the 'role'
        Map<String, dynamic> user = {
          'name': _nameController.text.trim(),
          'email': email,
          'password': _passwordController.text.trim(),
          'role': 'customer', // Default role for all new sign-ups
        };

        // 3. Save to database using your helper method
        await _dbHelper.registerUser(user);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created!"), backgroundColor: Colors.green),
        );

        // 4. Return to Login Page
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/image/login.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.9), BlendMode.lighten),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                        ]
                    ),
                    child: Column(
                      children: [
                        _buildField(_nameController, 'Full Name', Icons.person_outline),
                        const SizedBox(height: 15),
                        _buildField(_emailController, 'Email Address', Icons.email_outlined),
                        const SizedBox(height: 15),
                        _buildField(_passwordController, 'Password', Icons.lock_outline, isPass: true),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ),
                            onPressed: _registerUser,
                            child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Required';
        if (label == 'Email Address' && !val.contains('@')) return 'Invalid Email';
        if (isPass && val.length < 6) return 'Min 6 characters';
        return null;
      },
    );
  }
}