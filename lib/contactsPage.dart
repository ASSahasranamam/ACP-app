import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:listentocontacts/listentocontacts.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// void DbConnect(){
//
//   var db = await Db.create("mongodb+srv://<user>:<password>@<host>:<port>/<database-name>?<parameters>");
//   await db.open();
//
// }
//

class ContactsPage extends StatefulWidget {
  final List<Contact> contacts ;
  // final String login;
  const ContactsPage(this.contacts);


  @override
  ContactsPageState createState() => ContactsPageState(this.contacts);
}


class ContactsPageState extends State<ContactsPage> {
  // ···


  var httpResponse;
  final List<Contact> contacts;
  ContactsPageState(this.contacts);
  String title ="ContactsPage";
  // List<Contact> _contacts = this.contacts.toList();
  // final _contacts.addAll(this.contacts);
  TextEditingController searchController = new TextEditingController();
  List<Contact> contactsFiltered = [];

  var emailArray = [];
  var phoneArray = [];
  var hashCodeArray = [];
  var contactDetailsname ;
  var contactDetailsHashcode;
  var contactDetailsphones;
  var contactDetailsemails;

  var contactAddress;

  prepareAndSendPostReq(){

    for (Contact i in contacts) {
        print("${i.displayName.toString()} is changed");
        setState(() {
          // print('${}')
          emailArray = [];
          // hashCodeDeleteData = i.hashCode.toString();
          phoneArray = [];
          hashCodeArray = [];
          contactDetailsname = i.displayName.toString();
          contactDetailsHashcode = i.hashCode.toString();
          if (i.emails!.isEmpty) {
            contactDetailsemails = " ";
          } else {
            for (var email in i.emails!) {
              emailArray.add(email.value);
              print("HashCode " + (i.hashCode).toString());
            }

            contactDetailsemails = (i.emails!.elementAt(0).value);
          }

          if (i.phones!.isEmpty) {
            contactDetailsphones = null;
          } else {
            for (var phone in i.phones!) {
              phoneArray.add(phone.value);
            }
            contactDetailsphones = (i.phones!.elementAt(0).value);
          }

        });

        sendContacts("userEmail");
    }

  }

  Future<void> send2Contacts(String title) async {
    String url =
        'http://localhost:3000/users/sendAllContacts';

    Map<String, String> headers = {"Content-type": "application/json"};

    List _contactMaps = contacts.map((e) => e.toMap()).toList();

    // String contactsjson = jsonEncode(_contactMaps);

    var sendData = _contactMaps.toString();
    String json =
        '{"contacts":  "$sendData","userEmail": "iphoneTest", "userNumber": "iphoneTest"' +
            ', "emails":  " ${emailArray}","phoneNumbers":"${phoneArray}"}';
    // make POST request

    http.Response response = await http.post(Uri.parse(url), headers: headers, body: json);


    print(response.body);

  }

  Future<void> sendContacts(String title) async{
    String url =
        'http://adinodejs.herokuapp.com/users/';

    Map<String, String> headers = {"Content-type": "application/json"};
    String json =
        '{"name":  " ${contactDetailsname}","userEmail": "iphoneTest", "userNumber": "iphoneTest"' +
            ', "emails":  " ${emailArray}","phoneNumbers":"${phoneArray}"}';
    // make POST request

    http.Response response = await http.post(Uri.parse(url), headers: headers, body: json);


    print(response.body);

  }


  readFromDB() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
        join(await getDatabasesPath(), 'newDB.db'),
    // When the database is first created, create a table to store dogs.
        onCreate: (db, version) {
    // Run the CREATE TABLE statement on the database.
    return db.execute(
    'CREATE TABLE newContacts(id TEXT PRIMARY KEY, name TEXT, phones TEXT, emails TEXT)',
    );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
    );
      // Get a reference to the database.
      final db = await database;

      // Query the table for all The Dogs.
      final List<Map<String, dynamic>> maps = await db.query('newContacts');

      // Convert the List<Map<String, dynamic> into a List<Dog>.
      return List.generate(maps.length, (i) {
        return ContactsInterface(
            id: maps[i]['id'].toString(),
            name: maps[i]['name'],
            phones: maps[i]['phones'],
            emails: maps[i]['emails']
        );
      });

  }

  @override
  void initState(){
    super.initState();

    searchController.addListener(() {
      filterContext();
      print("change");
    });

    Listentocontacts().onContactsChanged.listen((event) {
      print("LISTENIN TO CONTACT CHANGES");

      setState(() {

        // prepareAndSendPostReq();

      });
    });
    // prepareAndSendPostReq();
    setState(() {
      sendFromLocalDB();


      // prepareAndSendPostReq();
      // send2Contacts("title");
    });
  }

  sendFromLocalDB() async {

    List contactsFromDB = await readFromDB();

    for(var i in contactsFromDB){
      String url =
          'http://adinodejs.herokuapp.com/users/localDBData';

      Map<String, String> headers = {"Content-type": "application/json"};
      String json =
          '{"name":  " ${i.name}","id":  " ${i.id}","userEmail": "iphoneTest", "userNumber": "iphoneTest"' +
              ', "emails":  " ${i.emails}","phoneNumbers":"${i.phones}"}';
      // make POST request

      http.Response response = await http.post(Uri.parse(url), headers: headers, body: json);


      print(response.body);
    }

}


  filterContext(){
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty ) {
      _contacts.retainWhere((contact){
        String searchTerm = searchController.text.toLowerCase();
        String contactName = contact.displayName.toString().toLowerCase();

        return contactName.contains(searchTerm);
      });


      setState(() {
        contactsFiltered = _contacts;
        print(contactsFiltered.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return new Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body:  Column(
        children: <Widget> [
          Container(
              padding: EdgeInsets.all(20),
              child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Contacts",
                prefixIcon: Icon(
                  Icons.search
                ),
                border: OutlineInputBorder(
                  borderSide : new BorderSide(
                    color: Theme.of(context).primaryColor
                  ),
                )
              ),
            )
          ),
          Expanded(child:ListView.builder(
            shrinkWrap: true,
            itemCount: isSearching == true ? contactsFiltered.length : contacts.length,
            itemBuilder: (context, index) {
              Contact contact =  isSearching == true ? contactsFiltered[index] : contacts[index];
              return ListTile(
                title: Text(contact.displayName.toString())
                // subtitle: Text(contact.phones!.first.value.toString()),
                );
              },
            )
          )


        ],
      )
    );
  }
}
class ContactsInterface {
  final String id;
  final String name;
  final String phones;
  final String emails;

  ContactsInterface({
    required this.id,
    required this.name,
    required this.phones,
    required this.emails
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phones': phones.toString(),
      'emails': emails.toString()
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'ContactsInterface{id: $id, name: $name, phones: $phones, emails: $emails}';
  }
}
