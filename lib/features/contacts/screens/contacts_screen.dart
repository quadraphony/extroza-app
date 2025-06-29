    import 'package:extroza/features/chats/models/chat_model.dart';
    import 'package:extroza/features/chats/screens/individual_chat_screen.dart';
    import 'package:flutter/material.dart';
    import 'package:flutter_contacts/flutter_contacts.dart'; // Import the new package

    class ContactsScreen extends StatefulWidget {
    const ContactsScreen({super.key});

    @override
    State<ContactsScreen> createState() => _ContactsScreenState();
    }

    class _ContactsScreenState extends State<ContactsScreen> {
    List<Contact> _contacts = [];
    bool _isLoading = true;
    String? _error;

    @override
    void initState() {
        super.initState();
        _loadContacts();
    }

    Future<void> _loadContacts() async {
        // The new package handles permissions internally, which is much cleaner.
        try {
        if (await FlutterContacts.requestPermission()) {
            // Fetch contacts and their properties (like phone numbers)
            final contacts = await FlutterContacts.getContacts(withProperties: true);
            if (mounted) {
            setState(() {
                _contacts = contacts;
                _isLoading = false;
            });
            }
        } else {
            if (mounted) {
            setState(() {
                _error = 'Permission denied. Please enable contact access in settings.';
                _isLoading = false;
            });
            }
        }
        } catch (e) {
        if (mounted) {
            setState(() {
            _error = 'Failed to load contacts.';
            _isLoading = false;
            });
        }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            title: const Text('New Chat'),
        ),
        body: _buildBody(),
        );
    }

    Widget _buildBody() {
        if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
        }
        if (_error != null) {
        return Center(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_error!, textAlign: TextAlign.center),
            ),
        );
        }
        if (_contacts.isEmpty) {
        return const Center(child: Text('No contacts found.'));
        }

        return ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
            final contact = _contacts[index];
            final displayName = contact.displayName;
            
            // Create a dummy Chat object to pass to the chat screen
            final dummyChat = Chat(
            otherUserId: contact.id, // Use the contact's unique ID
            name: displayName,
            avatarUrl: 'https://placehold.co/100x100/E6E6E6/000000?text=${displayName.isNotEmpty ? displayName[0].toUpperCase() : ''}',
            lastMessage: '',
            timestamp: '',
            );

            return ListTile(
            leading: CircleAvatar(
                child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : ''),
            ),
            title: Text(displayName),
            subtitle: contact.phones.isNotEmpty ? Text(contact.phones.first.number) : null,
            onTap: () {
                // When a contact is tapped, we go to the chat screen with them
                Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => IndividualChatScreen(chat: dummyChat),
                ),
                );
            },
            );
        },
        );
    }
    }
