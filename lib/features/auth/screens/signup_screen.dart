import 'dart:math';
import 'package:extroza/core/services/auth_service.dart';
import 'package:extroza/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controllers for text fields
  final _fullNameController = TextEditingController();
  late final TextEditingController _usernameController;
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _captchaController = TextEditingController();

  // State for dropdowns and captcha
  String? _selectedAgeRange;
  String? _selectedGender;
  int _captchaNum1 = 0;
  int _captchaNum2 = 0;

  final List<String> _adjectives = ['Clever', 'Swift', 'Silent', 'Happy', 'Brave', 'Witty', 'Cosmic'];
  final List<String> _nouns = ['Puma', 'Fox', 'Shadow', 'Gecko', 'Eagle', 'Lion', 'Star'];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: _generateUsername());
    _generateCaptcha();
  }

  String _generateUsername() {
    final random = Random();
    return '@extro${(10000 + random.nextInt(90000))}';
  }

  void _generateNickname() {
    final random = Random();
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    final noun = _nouns[random.nextInt(_nouns.length)];
    _nicknameController.text = '$adjective$noun${random.nextInt(100)}';
  }

  void _generateCaptcha() {
    final random = Random();
    setState(() {
      _captchaNum1 = random.nextInt(10) + 1;
      _captchaNum2 = random.nextInt(10) + 1;
    });
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      final correctAnswer = _captchaNum1 + _captchaNum2;
      if (int.tryParse(_captchaController.text) != correctAnswer) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect captcha answer. Please try again.')),
        );
        _generateCaptcha();
        _captchaController.clear();
        return;
      }
      
      setState(() => _isLoading = true);

      // Call the auth service to sign up the user and create their profile
      _authService.signUpWithUsernameAndPassword(
        context: context,
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        nickname: _nicknameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        ageRange: _selectedAgeRange,
        gender: _selectedGender,
      ).whenComplete(() {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _bioController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ageRanges = List.generate(18, (index) => '${10 + index * 5}-${14 + index * 5}');
    final genders = ['Male', 'Female', 'Rather not say'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildSectionHeader('Account Information'),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Nickname',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _generateNickname,
                      tooltip: 'Generate Nickname',
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter a nickname' : null,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('Optional Information'),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Bio or Mood'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedAgeRange,
                  decoration: const InputDecoration(labelText: 'Age Range'),
                  items: ageRanges.map((range) => DropdownMenuItem(value: range, child: Text(range))).toList(),
                  onChanged: (value) => setState(() => _selectedAgeRange = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: genders.map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('Security Check'),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'What is $_captchaNum1 + $_captchaNum2 ?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _captchaController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(hintText: 'Answer'),
                         validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: const Text('Sign Up & Continue'),
                ),
                 const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}
