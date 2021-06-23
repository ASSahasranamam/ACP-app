// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'contactsPage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

void main() async {
  runApp(MyApp());

  // Avoid errors caused by flutter upgrade.
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

  // Define a function that inserts dogs into the database
  Future<void> insertDog(ContactsInterface cint) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'newContacts',
      cint.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<ContactsInterface>> getCints() async {
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

  Future<void> updateDog(ContactsInterface cint) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'newContacts',
      cint.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [cint.id],
    );
  }

  Future<void> deleteDog(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'newContacts',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  // Create a Dog and add it to the dogs table
  // var fido = ContactsInterface(
  //   id: 0,
  //   name: 'Fido',
  //   phones: ["123", "325"].toString(),
  // );

  // await insertDog(fido);
  Iterable<Contact> contacts = await ContactsService.getContacts();
  List<Contact> _contacts = contacts.toList();

  for( var i in _contacts){
    var contactDetailsphones = [];
    var phoneArray = [] ;
    var emailArray = [] ;

    if (i.phones!.isEmpty) {
      phoneArray = ["null"];
    } else {
      for (var phone in i.phones!) {
        phoneArray.add(phone.value);
      }
      // contactDetailsphones = (i.phones!.elementAt(0).value.toString()) as List;
    }

    if (i.emails!.isEmpty) {
      emailArray = ["null"];
    } else {
      for (var email in i.emails!) {
        emailArray.add(email.value);
      }
      // contactDetailsphones = (i.phones!.elementAt(0).value.toString()) as List;
    }


    var fido = ContactsInterface(
      id: i.hashCode.toString(),
      name: i.displayName.toString(),
      phones: phoneArray.toString(),
      emails: emailArray.toString(),

    );
    print(fido.id);
    insertDog(fido);

  }
  // Now, use the method above to retrieve all the dogs.
  print(await getCints()); // Prints a list that include Fido.

  // // Update Fido's age and save it to the database.
  // fido = ContactsInterface(
  //   id: fido.id,
  //   name: fido.name,
  //   phones: fido.phones,
  // );
  // await updateDog(fido);

  // Print the updated results.
  // print(await getCints()); // Prints Fido with age 42.

  // Delete Fido from the database.
  // await deleteDog(fido.id);
  //
  // // Print the list of dogs (empty).
  // print(await getCints());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Named Routes Demo',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      // initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/login': (context) => MyHomePage(title: "Login"),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => RegisterPage(title: "Register"),
/*
        '/contactsList' : (context) => ContactPage
*/
      },

      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void permissionsStatus() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      Permission.contacts.request();
    });
  }

  //Contacts Threading

  var myEmail = "myEmail";
  // Iterable<Contact> = new Iterable<Contact>;

  // List<Contact> contacts = [];
  // List<Contact> filteredContacts = [];
  // String myEmail; // Refers to myNumber
  // String myNumber;
  // List<String> options = Options.getOptions();
  // List<DropdownMenuItem<Options>> dropDownOptions;
  //
  // // Get Contact Thread
  // bool isLogging = false;
  // bool runningGetContact = false;
  // String getContactsnotification = "";
  // ReceivePort receivePortgetContacts;
  //
  // void startGetContacts() async {
  //   runningGetContact = true;
  //   _receivePort = ReceivePort();
  //   setState(() {
  //     isLogging = true;
  //   });
  //
  //   IsolateDataClass contactData =
  //   new IsolateDataClass(widget.myEmail, _receivePort.sendPort);
  //
  //   isolateTimer = await Isolate.spawn(getContactsThread, contactData);
  //   _receivePort.listen(handleGetContacts, onDone: () {
  //     print("done!");
  //   });
  // }
  //
  // static void getContactsThread(IsolateDataClass object) async {
  //   String msg = 'Get ContactsDataThread: ' + object.email;
  //   print("SEND: " + msg);
  //   object.sendPort.send(msg);
  // }
  //
  // void handleGetContacts(dynamic data) {
  //   print('RECEIVED: ' + data);
  //   getContacts(widget.myEmail);
  //   setState(() {
  //     notification = data;
  //     print("get Contacts stopped");
  //     stopGetContacts();
  //   });
  // }
  //
  // void stopGetContacts() {
  //   if (isolateGetContacts != null) {
  //     setState(() {
  //       _running = false;
  //       notification = '';
  //     });
  //     _receivePort.close();
  //     isolateTimer.kill(priority: Isolate.immediate);
  //     isolateTimer = null;
  //   }
  // }
  //
  // Future<void> getContacts(String userEmail) async {
  //   //We already have permissions for contact when we get to this page, so we
  //   // are now just retrieving it
  //   final List<Contact> _contacts =
  //   (await ContactsService.getContacts(withThumbnails: false)).toList();
  //   var userEmailInp = userEmail;
  //   setState(() {
  //     contacts = _contacts;
  //     mainContact = _contacts;
  //     for (Contact i in contacts) {
  //       emailArray = [];
  //       phoneArray = [];
  //       contactDetailsname = i.displayName.toString();
  //       contactDetailsHashcode = i.hashCode.toString();
  //       if (i.emails.isEmpty) {
  //         contactDetailsemails = " ";
  //       } else {
  //         for (var email in i.emails) {
  //           emailArray.add(email.value);
  //           print("HashCode " + (i.hashCode).toString());
  //         }
  //
  //         contactDetailsemails = (i.emails.elementAt(0).value);
  //       }
  //
  //       if (i.phones.isEmpty) {
  //         contactDetailsphones = null;
  //       } else {
  //         for (var phone in i.phones) {
  //           phoneArray.add(phone.value);
  //         }
  //         contactDetailsphones = (i.phones.elementAt(0).value);
  //       }
  //
  //       print(i.displayName);
  //       // print(i.emails.elementAt(0).value);
  //       _makePostRequest(userEmailInp);
  //     }
  //   });
  //   _getMutualContacts(userEmail);
  // }
  //
  List<Contact> _contacts = [];

  Future<void> deleteDog() async {

    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'contacts_database.db'),
    );

    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
        'contacts'
      // Use a `where` clause to delete a specific dog.
      // Pass the Dog's id as a whereArg to prevent SQL injection.
    );

  }
  //
  // final PermissionHandler _permissionHandler = PermissionHandler();
  //
  // Future<bool> _requestPermission(PermissionGroup permission) async {
  //   var result = await _permissionHandler.requestPermissions([permission]);
  //   if (result[permission] == PermissionStatus.granted) {
  //     return true;
  //   }
  //   return false;
  // }
  @override
  void initState() {
    // deleteDog();
    permissionsStatus();
    getContacts();

    super.initState();
  }



  Future<void> getContacts() async {
    //Make sure we already have permissions for contacts when we get to this
    //page, so we can just retrieve it

    // await _getPermission();


    var emailArray = [];
    var phoneArray = [];
    var hashCodeArray = [];
    var contactDetailsname ;
    var contactDetailsHashcode;
    var contactDetailsphones;
    var contactDetailsemails;

    var contactAddress;

    final Iterable<Contact> contacts = await ContactsService.getContacts();



    setState(() {
      _contacts = contacts.toList();
      print(_contacts);
      for (var i in _contacts) {
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

        print(phoneArray.toString());

      print("fook this");

    }
    }
    );
    // print(await getContactInterfaces());


  }

  // A method that retrieves all the dogs from the dogs table.
  // Future<List<ContactsInterface>> getContactInterfaces() async {
  //   final database = openDatabase(
  //     // Set the path to the database. Note: Using the `join` function from the
  //     // `path` package is best practice to ensure the path is correctly
  //     // constructed for each platform.
  //     join(await getDatabasesPath(), 'contacts_database.db'),
  //   );
  //
  //   // Get a reference to the database.
  //   final db = await database;
  //
  //   // Query the table for all The Dogs.
  //   final List<Map<String, dynamic>> maps = await db.query('contacts');
  //
  //   // Convert the List<Map<String, dynamic> into a List<Dog>.
  //   return List.generate(maps.length, (i) {
  //     return ContactsInterface(
  //         id: maps[i]['id'].toString(),
  //         name: maps[i]['name'],
  //         phones: maps[i]['[phones]'],
  //         emails: maps[i]['[emails]']
  //
  //     );
  //   });
  // }

  Future<void> updateDog(ContactsInterface cInt) async {
    // Get a reference to the database.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'contacts_database.db'),
    );


    final db = await database;


    // Update the given Dog.
    await db.update(
      'contacts',
      cInt.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [cInt.id],
    );
  }


  Future<void> insertDog(ContactsInterface cInt) async {
    // Get a reference to the database.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'contacts_database.db'),
    );

    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'contacts',
      cInt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  //Check contacts permission
  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();

      return permission;
    } else {
      return permission;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Future
    // = await ContactsService.getContacts();
    //
    // print(contacts);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/pink-bubbles.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Center(
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * (0.95),
                    child: Card(
                      color: Colors.white,

                      clipBehavior: Clip.antiAlias,
                      child: Column(children: [
                        ListTile(
                          // leading: Icon(Icons.arrow_drop_down_circle),
                          title: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 20.0,
                              // color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          // subtitle: Text(
                          //   'Secondary Text',
                          //   style: TextStyle(color: Colors.black.withOpacity(0.6)),
                          // ),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * (0.8),
                                  child: TextFormField(
                                    cursorColor: Theme.of(context).focusColor,
                                    // initialValue: 'Input text',
                                    // maxLength: 20,
                                    decoration: InputDecoration(
                                      // icon: Icon(Icons.favorite),
                                      labelText: 'Username',
                                      labelStyle: TextStyle(
                                        color: Colors.black12,
                                      ),
                                      focusColor: Colors.black12,
                                      // helperText: 'Helper text',
                                      // suffixIcon: Icon(
                                      //   Icons.check_circle,
                                      // ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: (Colors.pink)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: (Colors.pink)),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 42.0,
                                  width: 42.0,
                                  // color: Colors.white,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * (0.8),
                                  child: TextFormField(
                                    obscureText: true,
                                    cursorColor: Theme.of(context).focusColor,

                                    // initialValue: 'Input text',
                                    // maxLength: 20,
                                    decoration: InputDecoration(
                                      // icon: Icon(Icons.favorite),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                        color: Colors.pink,
                                      ),
                                      // helperText: 'Helper text',
                                      // suffixIcon: Icon(
                                      //   Icons.check_circle,
                                      // ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: (Colors.pink)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: (Colors.pink)),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 42.0,
                                  width: 42.0,
                                  // color: Colors.white,
                                ),
                                ButtonBar(
                                  alignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    RaisedButton(
                                      textColor: Colors.white,
                                      color: Colors.deepPurpleAccent,
                                      onPressed: () {



                                        // final PermissionStatus permissionStatus = await _getPermission();
                                        // if (permissionStatus == PermissionStatus.granted) {
                                          Navigator.push(
                                              context, MaterialPageRoute(builder: (context) => ContactsPage( _contacts)));
                                        // } else {
                                        //If permissions have been denied show standard cupertino alert dialog
                                        // showDialog(
                                        //     context: context,
                                        //     builder: (BuildContext context) =>
                                        //         CupertinoAlertDialog(
                                        //           title:
                                        //               Text('Permissions error'),
                                        //           content: Text(
                                        //               'Please enable contacts access '
                                        //               'permission in system settings'),
                                        //           actions: <Widget>[
                                        //             CupertinoDialogAction(
                                        //               child: Text('OK'),
                                        //               onPressed: () =>
                                        //                   Navigator.of(context)
                                        //                       .pop(),
                                        //             )
                                        //           ],
                                        //         ));
                                      },
                                      child: const Text('Login'),
                                      autofocus: true,
                                    ),
                                    RaisedButton(
                                      color: Colors.amberAccent,
                                      textColor: Colors.black,
                                      onPressed: () {
                                        // Perform some action
                                      },
                                      child: const Text('Forgot Password'),
                                    ),
                                    RaisedButton(
                                      color: Colors.redAccent,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/second');
                                      },
                                      child: const Text('Register'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ]),

                      // Container(
                      //   width: MediaQuery.of(context).size.width*(0.89),
                      //   child: TextFormField(
                      //     cursorColor: Theme.of(context).cursorColor,
                      //     // initialValue: 'Input text',
                      //     // maxLength: 20,
                      //     decoration: InputDecoration(
                      //       icon: Icon(Icons.favorite),
                      //       labelText: 'Label text',
                      //       labelStyle: TextStyle(
                      //         color: Color(0xFF6200EE),
                      //       ),
                      //       // helperText: 'Helper text',
                      //       // suffixIcon: Icon(
                      //       //   Icons.check_circle,
                      //       // ),
                      //       enabledBorder: UnderlineInputBorder(
                      //         borderSide: BorderSide(color: Color(0xFF6200EE)),
                      //       ),
                      //     ),
                      //
                      //   ),
                      //
                      //
                      // ),
                    ))
              ],
            ),
          )),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _counter = 0;

  var _image;
  final picker = ImagePicker();



  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/pink-bubbles.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Center(
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: SingleChildScrollView(
                    child: Column(
                      // Column is also a layout widget. It takes a list of children and
                      // arranges them vertically. By default, it sizes itself to fit its
                      // children horizontally, and tries to be as tall as its parent.
                      //
                      // Invoke "debug painting" (press "p" in the console, choose the
                      // "Toggle Debug Paint" action from the Flutter Inspector in Android
                      // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                      // to see the wireframe for each widget.
                      //
                      // Column has various properties to control how it sizes itself and
                      // how it positions its children. Here we use mainAxisAlignment to
                      // center the children vertically; the main axis here is the vertical
                      // axis because Columns are vertical (the cross axis would be
                      // horizontal).
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width * (0.95),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(children: [
                                ListTile(
                                  // leading: Icon(Icons.arrow_drop_down_circle),
                                  title: const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      // color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  // subtitle: Text(
                                  //   'Secondary Text',
                                  //   style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                  // ),
                                ),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 25),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (0.8),
                                          child: TextFormField(
                                            cursorColor:
                                                Theme.of(context).focusColor,
                                            // initialValue: 'Input text',
                                            // maxLength: 20,
                                            decoration: InputDecoration(
                                              // icon: Icon(Icons.favorite),
                                              labelText: 'First Name',
                                              labelStyle: TextStyle(
                                                color: Colors.pink,
                                              ),
                                              // helperText: 'Helper text',
                                              // suffixIcon: Icon(
                                              //   Icons.check_circle,
                                              // ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 42.0,
                                          width: 42.0,
                                          // color: Colors.white,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (0.8),
                                          child: TextFormField(
                                            // obscureText: true,
                                            cursorColor:
                                                Theme.of(context).focusColor,

                                            // initialValue: 'Input text',
                                            // maxLength: 20,
                                            decoration: InputDecoration(
                                              // icon: Icon(Icons.favorite),
                                              labelText: 'Last Name',
                                              labelStyle: TextStyle(
                                                color: Colors.pink,
                                              ),
                                              // helperText: 'Helper text',
                                              // suffixIcon: Icon(
                                              //   Icons.check_circle,
                                              // ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 42.0,
                                          width: 42.0,
                                          // color: Colors.white,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (0.8),
                                          child: TextFormField(
                                            obscureText: true,
                                            cursorColor:
                                                Theme.of(context).focusColor,

                                            // initialValue: 'Input text',
                                            // maxLength: 20,
                                            decoration: InputDecoration(
                                              // icon: Icon(Icons.favorite),
                                              labelText: 'Password',
                                              labelStyle: TextStyle(
                                                color: Colors.pink,
                                              ),
                                              // helperText: 'Helper text',
                                              // suffixIcon: Icon(
                                              //   Icons.check_circle,
                                              // ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 42.0,
                                          width: 42.0,
                                          // color: Colors.white,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (0.8),
                                          child: TextFormField(
                                            obscureText: true,
                                            cursorColor:
                                                Theme.of(context).focusColor,

                                            // initialValue: 'Input text',
                                            // maxLength: 20,
                                            decoration: InputDecoration(
                                              // icon: Icon(Icons.favorite),
                                              labelText: ' Confirm Password',
                                              labelStyle: TextStyle(
                                                color: Colors.pink,
                                              ),
                                              // helperText: 'Helper text',
                                              // suffixIcon: Icon(
                                              //   Icons.check_circle,
                                              // ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 42.0,
                                          width: 42.0,
                                          // color: Colors.white,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (0.8),
                                          child: TextFormField(
                                            // obscureText: true,
                                            cursorColor:
                                                Theme.of(context).focusColor,

                                            // initialValue: 'Input text',
                                            // maxLength: 20,
                                            decoration: InputDecoration(
                                              // icon: Icon(Icons.favorite),
                                              labelText: 'NickName',
                                              labelStyle: TextStyle(
                                                color: Colors.pink,
                                              ),
                                              // helperText: 'Helper text',
                                              // suffixIcon: Icon(
                                              //   Icons.check_circle,
                                              // ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 42.0,
                                          width: 42.0,
                                          // color: Colors.white,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (0.8),
                                          child: TextFormField(
                                            // obscureText: true,
                                            cursorColor:
                                                Theme.of(context).focusColor,

                                            // initialValue: 'Input text',
                                            // maxLength: 20,
                                            decoration: InputDecoration(
                                              // icon: Icon(Icons.favorite),
                                              labelText: 'Email',
                                              labelStyle: TextStyle(
                                                color: Colors.pink,
                                              ),
                                              // helperText: 'Helper text',
                                              // suffixIcon: Icon(
                                              //   Icons.check_circle,
                                              // ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: (Colors.pink)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 10.0,
                                          width: 42.0,
                                          // color: Colors.white,
                                        ),

                                        // Container(
                                        //   height: 02.0,
                                        //   width: 42.0,
                                        //   // color: Colors.white,
                                        // ),
                                        ButtonBar(
                                            alignment: MainAxisAlignment.center,
                                            children: [
                                              RaisedButton(
                                                textColor: Colors.pink,
                                                color: Colors.white,
                                                onPressed: getImage,
                                                child: const Text(
                                                    'Upload Profile Picture'),
                                                autofocus: true,
                                              ),
                                            ]),
                                        _image == null
                                            ? Image.file(File(
                                                "assets/pink-bubbles.jpeg"))
                                            : Image.file(
                                                _image,
                                                height: 200,
                                                width: 200,
                                              ),

                                        ButtonBar(
                                          alignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            RaisedButton(
                                              textColor: Colors.pink,
                                              color: Colors.white,
                                              onPressed: () {
                                                // Perform some action
                                              },
                                              child: const Text('Register'),
                                              autofocus: true,
                                            ),
                                            RaisedButton(
                                              color: Colors.white,
                                              textColor: Colors.pink,
                                              onPressed: () {
                                                // Perform some action
                                              },
                                              child:
                                                  const Text('Forgot Password'),
                                            ),
                                            RaisedButton(
                                              color: Colors.white,
                                              textColor: Colors.pink,
                                              onPressed: () {
                                                // Navigate to the second screen using a named route.
                                                //   Navigator.pushNamed(context, '/login');
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Login'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]),

                              // Container(
                              //   width: MediaQuery.of(context).size.width*(0.89),
                              //   child: TextFormField(
                              //     cursorColor: Theme.of(context).cursorColor,
                              //     // initialValue: 'Input text',
                              //     // maxLength: 20,
                              //     decoration: InputDecoration(
                              //       icon: Icon(Icons.favorite),
                              //       labelText: 'Label text',
                              //       labelStyle: TextStyle(
                              //         color: Color(0xFF6200EE),
                              //       ),
                              //       // helperText: 'Helper text',
                              //       // suffixIcon: Icon(
                              //       //   Icons.check_circle,
                              //       // ),
                              //       enabledBorder: UnderlineInputBorder(
                              //         borderSide: BorderSide(color: Color(0xFF6200EE)),
                              //       ),
                              //     ),
                              //
                              //   ),
                              //
                              //
                              // ),
                            ))
                      ],
                    ),
                  )))),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: getImage,
      //   tooltip: 'Pick Image',
      //   child: Icon(Icons.add_a_photo),
      // ),
    );
  }
}
