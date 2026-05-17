import 'package:flutter/material.dart';
import '../../features/auth/state/auth_controller.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Form(
      key: _formKey,
      child: Column(
        //responsive equivalent on min width
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _userController,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => v!.contains('@') ? null : 'Invalid email',
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', hintText: 'Must be at least 8 characters'),
            validator: (v) {
              if(v == null || v.isEmpty) {
                return 'Password required';
              }
              if(v.length < 8){
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (auth.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(auth.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _handleRegister,
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Create Account"),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthController>().register(
            _userController.text,
            _emailController.text,
            _passwordController.text,
          );
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }
}
