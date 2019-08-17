import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(MyApp());

Future<Database> database() async {
  return openDatabase(join(await getDatabasesPath(), "doggie_database.db"),
      onCreate: (db, version) {
    return db.execute(
        "CREATE TABLE dogs(id INTEGER PRIMARY KEY,name TEXT,age INTEGER)");
  }, version: 1);
}

Future<void> insertDog(Dog dog) async {
  final Database db = await database();
  await db.insert('dogs', dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<Dog>> dogs() async {
  final Database db = await database();
  final List<Map<String, dynamic>> maps = await db.query('dogs');
  return List.generate(maps.length, (i) {
    return Dog(
      id: maps[i]['id'],
      name: maps[i]['name'],
      age: maps[i]['age'],
    );
  });
}

Future<void> updateDog(Dog dog) async {
  final db = await database();
  await db.update(
    'dogs',
    dog.toMap(),
    where: 'id = ?',
    whereArgs: [dog.id],
  );
}

Future<void> deleteDog(int id) async {
  final db = await database();
  await db.delete(
    'dogs',
    where: 'id = ?',
    whereArgs: [id],
  );
}

class MyApp extends StatelessWidget {
  final String title = 'Sqflite demo';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int id = 0;
  int age = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: dogs(),
          builder: (context, snapshot) {
            final List<Dog> dogList = snapshot.data;
            id = dogList.length - 1;
            if (dogList.isNotEmpty) {
              return Text(
                  '$id: ${dogList[id].name} ${dogList[id].age}');
            } else {
              return Text("Database is empty");
            }
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _insertDog,
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _deleteDog,
            child: Icon(Icons.delete),
          ),
          FloatingActionButton(
            onPressed: _updateDog,
            child: Icon(Icons.update),
          )
        ],
      ),
    );
  }

  void _insertDog() async {
    id++;
    age++;
    var fido = Dog(
      id: id,
      name: 'Fido',
      age: age,
    );
    await insertDog(fido);
    setState(() {});
  }

  void _deleteDog() async {
    await deleteDog(id);
    setState(() {});
  }

  void _updateDog() async {
    var sally = Dog(id: id, name: "Sally", age: 10);
    await updateDog(sally);
    setState(() {});
  }
}

class Dog {
  final int id;
  final int age;
  final String name;

  Dog({this.id, this.age, this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'age': age, 'name': name};
  }
}
