import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'registrationpage.dart';
import 'dashboardpage.dart';
import 'guestpage.dart';
import 'admindashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(role: 'User'),
    );
  }
}

class LoginPage extends StatefulWidget {
  final String role;
  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isObscured = true; // Added this to fix your error

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      // 1. Get the email and password from controllers
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // 2. Check the database for this user
      Map<String, dynamic>? userData = await _dbHelper.getUserData(email, password);

      if (!mounted) return;

      if (userData != null) {
        String name = userData['name'] ?? "User";

        if (email == "admin@forkyeah.com" && password == "admin123") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        }

        else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage(userName: name)),
          );
        }
      } else {
      //SHOW ERROR
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Invalid Email or Password"),
              backgroundColor: Colors.black
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/image/login.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.85), BlendMode.lighten),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // 1. Add vertical padding here to push content toward the middle
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                  const SizedBox(height: 50),

              const Text(
                'WELCOME TO\nFORK YEAH RESTAURANT',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black87.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                          validator: (val) => val!.isEmpty ? "Enter email" : null,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscured,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _isObscured = !_isObscured),
                            ),
                          ),
                          validator: (val) => val!.length < 6 ? "Min 6 chars" : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                            onPressed: _signIn,
                            child: const Text("Sign In", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage(role: widget.role))),
                          child: const Text('No Account? Register Now'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GuestPage())),
                    child: const Text('Continue as Guest', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}