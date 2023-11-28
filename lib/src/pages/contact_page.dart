import 'dart:typed_data';

import 'package:contact_app/src/core/colors/colors.dart';
import 'package:contact_app/src/core/constants/strings.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      // TODO: Fetch contacts with additional information like thumbnails.
      final contacts = await ContactsService.getContacts(withThumbnails: true);
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } on FormOperationException catch (e) {
      _handleContactOperationError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.contactPageTitle),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContactList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openContactForm(context),
        tooltip: 'Add Contact',
        child: Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildContactList() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
          // TODO: Add a gesture recognizer to navigate to a detailed contact view.

          leading: _buildContactImage(contact),
          title: Text(contact.displayName ?? ''),
          subtitle: Text(contact.phones!.isNotEmpty
                ? contact.phones?.elementAt(0).value ?? "Default Value"
                : "")
        );
      },
    );
  }

  Widget _buildContactImage(Contact contact) {
    if (contact.avatar != null) {
      return CircleAvatar(
        backgroundImage: MemoryImage(Uint8List.fromList(contact.avatar!)),
      );
    } else {
      return CircleAvatar(
        child: Icon(Icons.person),
      );
    }
  }

  Future<void> _openContactForm(BuildContext context) async {
    try {
      // TODO: Open the contact form to add a new contact.
      final result = await ContactsService.openContactForm();

      if (result != null) {
        // TODO: Handle success, refresh contact list.
        _loadContacts();
      } else {
        // TODO: Handle failure or cancellation.
        print('Contact Adding Failed');
      }
    } on FormOperationException catch (e) {
      _handleContactOperationError(e);
    }
  }

  void _handleContactOperationError(FormOperationException e) {
    if (e.errorCode == FormOperationErrorCode.FORM_OPERATION_CANCELED) {
      // TODO: Handle the cancellation, show a message to the user.
      print('Contact operation canceled');
    } else if (e.errorCode == FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR) {
      // TODO: Handle the failure, show an error message to the user.
      print('Contact operation failed');
    } else {
      // TODO: Handle other errors as needed.
      print('Unknown error: $e');
    }
  } 
}
