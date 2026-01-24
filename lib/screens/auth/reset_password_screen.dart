import 'package:flutter/material.dart';

/// ResetPasswordScreen
/// - Two fields: New Password & Confirm Password
/// - Toggle show/hide for both fields
/// - Validates: min length (8), match
/// - Submit button disabled until valid
/// - Optional: accepts `token` via `ModalRoute` arguments or Get.arguments
///
/// Usage:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => ResetPasswordScreen(token: '...'),
/// ));

class ResetPasswordScreen extends StatefulWidget {
  final String? token;

  const ResetPasswordScreen({Key? key, this.token}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  String? _validatePassword(String? v) {
    if (v == null || v.trim().isEmpty) return 'Password required';
    if (v.trim().length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please confirm password';
    if (v != _newPassCtrl.text) return 'Passwords do not match';
    return null;
  }

  bool get _isFormValid {
    return (_newPassCtrl.text.trim().length >= 8) &&
        (_confirmPassCtrl.text == _newPassCtrl.text);
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSubmitting = true);

    // TODO: Replace this block with your API call (http / dio / GetConnect)
    // Use widget.token when calling the reset-password endpoint.
    await Future.delayed(Duration(seconds: 1)); // simulate network

    setState(() => _isSubmitting = false);

    // On success: show a snackbar and pop or navigate to login
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset successful. Please login.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Try to obtain token from route arguments if user passed it that way
    final args = ModalRoute.of(context)?.settings.arguments;
    final tokenFromArgs = (args is Map && args['token'] != null) ? args['token'] : null;
    final token = widget.token ?? tokenFromArgs;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8),
              Text(
                'Choose a new password for your account',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),

              if (token != null) ...[
                SizedBox(height: 16),
                Text('Token detected (hidden):', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                SizedBox(height: 6),
                Text(token.toString(), style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],

              SizedBox(height: 24),

              Form(
                key: _formKey,
                onChanged: () => setState(() {}), // re-evaluate enabled state
                child: Column(
                  children: [
                    // New Password
                    TextFormField(
                      controller: _newPassCtrl,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        hintText: 'Enter new password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: _validatePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        hintText: 'Re-enter password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: _validateConfirm,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    SizedBox(height: 20),

                    // Password strength / hint
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Password must be at least 8 characters.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ),

                    SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting || !_isFormValid ? null : _submit,
                        child: _isSubmitting
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Reset Password'),
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),

                    SizedBox(height: 12),

                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Back to login'),
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
