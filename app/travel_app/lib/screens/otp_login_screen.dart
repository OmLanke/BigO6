import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../utils/validation_utils.dart';
import 'registration_screen.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final success = await _authService.sendEmailOTP(_emailController.text);

        setState(() {
          _isLoading = false;
          _otpSent = success;
          if (!success) {
            _errorMessage = 'Failed to send OTP. Please try again.';
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: $e';
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final userData = await _authService.verifyEmailOTP(
          _emailController.text,
          _otpController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (userData != null) {
          // Successfully verified OTP
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RegistrationScreen(
                  userId: userData['userId'],
                  email: userData['email'],
                ),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = 'Invalid OTP. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // App logo or icon
              Icon(
                Icons.travel_explore,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                !_otpSent ? 'Login with Email' : 'Enter OTP',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              const SizedBox(height: 20),
              
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                enabled: !_otpSent,
                validator: ValidationUtils.validateEmail,
              ),
              
              const SizedBox(height: 20),
              
              // OTP field (visible only after OTP is sent)
              if (_otpSent)
                Column(
                  children: [
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'OTP',
                        hintText: 'Enter the OTP sent to your email',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the OTP';
                        }
                        if (value.length < 4) {
                          return 'Please enter a valid OTP';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 10),
                    
                    TextButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 20),
              
              // Action button (Send OTP or Verify OTP)
              CustomButton(
                onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                text: _isLoading
                    ? 'Please wait...'
                    : (_otpSent ? 'Verify OTP' : 'Send OTP'),
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 20),
              
              // Alternative login options
              if (!_otpSent)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        // Navigate to traditional login screen if available
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
