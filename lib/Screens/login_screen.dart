import 'package:databaseapp/Screens/sign_up.dart';
import 'package:databaseapp/Screens/sqlhomepage.dart';
import 'package:databaseapp/Services/firebase_authservice.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.apikey, this.flushbarMessage});
  final String apikey;
  final String? flushbarMessage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final AuthService auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    if (widget.flushbarMessage != null) {
      Future.delayed(Duration.zero, () {
        Flushbar(
          title: "Verify Email",
          message: widget.flushbarMessage!,
          icon: const Icon(Icons.email_outlined, size: 28.0, color: Colors.greenAccent),
          leftBarIndicatorColor: Colors.greenAccent,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          margin: const EdgeInsets.all(16),
          flushbarPosition: FlushbarPosition.BOTTOM,
          animationDuration: const Duration(milliseconds: 500),
        ).show(context);
      });
    }
  }

  Future<void> signin() async {
    setState(() => isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    User? user = await auth.signIn(email, password);
    setState(() => isLoading = false);
    if (user != null) {
      if (user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SqlHomePage(apikey: widget.apikey)),
        );
      } else {
        // User exists but email not verified
        Flushbar(
          title: "Login Failed",
          message: "Please verify your email before logging in.",
          icon: const Icon(Icons.error_outline, size: 28.0, color: Colors.orangeAccent),
          leftBarIndicatorColor: Colors.orangeAccent,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.black45,
          borderRadius: BorderRadius.circular(8),
          margin: const EdgeInsets.all(16),
          animationDuration: const Duration(milliseconds: 500),
          flushbarPosition: FlushbarPosition.BOTTOM,
        ).show(context);
      }
    } else {
      // User null means credentials invalid
      Flushbar(
        title: "Login Failed",
        message: "Invalid email or password.",
        icon: const Icon(Icons.error_outline, size: 28.0, color: Colors.redAccent),
        leftBarIndicatorColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        margin: const EdgeInsets.all(16),
        animationDuration: const Duration(milliseconds: 500),
        flushbarPosition: FlushbarPosition.BOTTOM,
      ).show(context);
    }

  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeIn,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Hero(
                      tag: "loginTitle",
                      child: Text(
                        'Welcome Back!',
                        style: TextStyle(
                          height: 1,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.95),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                style: const TextStyle(color: Colors.white),
                                controller: _emailController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email, color: Colors.white54),
                                  hintText: 'Email',
                                  hintStyle: const TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                                  hintText: 'Password',
                                  hintStyle: const TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.white10,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) => value != null && value.length >= 6 ? null : 'Password must be at least 6 characters',
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purpleAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                    if (_formKey.currentState!.validate()) {
                                      signin();
                                    }
                                  },
                                  child: isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 900),
                                      pageBuilder: (context, animation, secondaryAnimation) => SignUp(apikey: widget.apikey),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Don't have an account? SIGN UP",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
