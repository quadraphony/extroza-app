import 'package:flutter/material.dart';
import 'dart:async';

// We need a StatefulWidget to manage the text field's state and the check results.
class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

// Enum to represent the state of the username check
enum UsernameStatus { idle, checking, available, taken, invalid }

class _UsernameScreenState extends State<UsernameScreen> {
  final _controller = TextEditingController();
  UsernameStatus _status = UsernameStatus.idle;
  Timer? _debounce;

  // This function simulates checking the username against a database.
  // In a real app, this would make a network call to your backend.
  Future<void> _checkUsername(String username) async {
    // Basic validation
    if (username.length < 4 || !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(() => _status = UsernameStatus.invalid);
      return;
    }

    // --- THIS IS THE FIX ---
    // It should be UsernameStatus, not Username.
    setState(() => _status = UsernameStatus.checking);

    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 750));

    // In a real app, you would query Firestore here.
    // For this example, we'll use a simple hardcoded check.
    if (mounted) {
      if (['leeroy', 'admin', 'test'].contains(username.toLowerCase())) {
        setState(() => _status = UsernameStatus.taken);
      } else {
        setState(() => _status = UsernameStatus.available);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // This is a debounce to prevent checking on every single keystroke.
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (_controller.text.isNotEmpty) {
          _checkUsername(_controller.text);
        } else {
          setState(() => _status = UsernameStatus.idle);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Helper to get the right feedback widget based on the status
  Widget _buildStatusIndicator() {
    switch (_status) {
      case UsernameStatus.checking:
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      case UsernameStatus.available:
        return const Icon(Icons.check_circle_rounded, color: Colors.green);
      case UsernameStatus.taken:
        return const Icon(Icons.cancel_rounded, color: Colors.red);
      case UsernameStatus.invalid:
        return const Icon(Icons.error_rounded, color: Colors.orange);
      case UsernameStatus.idle:
        return const SizedBox.shrink(); // Empty space
    }
  }
  
  String _getHelperText() {
     switch (_status) {
      case UsernameStatus.taken:
        return 'This username is already taken.';
      case UsernameStatus.invalid:
        return 'Usernames must be at least 4 characters long and can only contain letters, numbers, and underscores.';
      default:
        return "Your username is unique to you.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Username'),
        actions: [
          // The "Save" button is only enabled when the username is available
          TextButton(
            onPressed: _status == UsernameStatus.available
                ? () {
                    // TODO: Save username to Firebase
                    print('Username ${_controller.text} saved!');
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'e.g., leroy_sr',
                prefixText: '@',
                border: const OutlineInputBorder(),
                // Display the status indicator at the end of the field
                suffixIcon: _buildStatusIndicator(),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                _getHelperText(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _status == UsernameStatus.taken || _status == UsernameStatus.invalid ? Colors.red : Colors.grey[600]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
