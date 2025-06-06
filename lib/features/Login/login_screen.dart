import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/images/Logo.png",
                        fit: BoxFit.contain,
                        height: 300,
                        width: 400,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Nhập Usename/Email...',
                              labelText: 'Thông tin',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập thông tin.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
