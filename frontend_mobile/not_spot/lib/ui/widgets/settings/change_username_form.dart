import 'package:flutter/material.dart';
import 'package:not_spot/core/router/app_router.dart';
import '../../../features/settings/state/settings_controller.dart';
import 'package:provider/provider.dart';

class ChangeUsernameForm extends StatefulWidget {
  const ChangeUsernameForm({super.key});

  @override
  State<ChangeUsernameForm> createState() => _ChangeUsernameFormState();
}

class _ChangeUsernameFormState extends State<ChangeUsernameForm> {
  final _formkey = GlobalKey<FormState>();
  final _userController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<SettingsController>();

    return Form(
        key: _formkey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'New username'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _handleNameChange,
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Change username"),
              ),
            ),
          ],
        ));
  }

  void _handleNameChange() async {
    if (_formkey.currentState!.validate()) {
      final success = await context
          .read<SettingsController>()
          .changeUsername(_userController.text);
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }
}
