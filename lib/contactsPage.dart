import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';


class ContactsPage extends StatefulWidget {
  final Iterable<Contact> contacts ;
  const ContactsPage(this.contacts);


  @override
  ContactsPageState createState() => ContactsPageState(this.contacts);
}


class ContactsPageState extends State<ContactsPage> {
  // ···
  final Iterable<Contact> contacts;
  ContactsPageState(this.contacts);



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[ ],
      ),
    );
  }
}
