import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openAppDatabase({required OnDatabaseCreateFn onCreate}) async {
  final directory = await getDatabasesPath();
  return openDatabase(
    join(directory, 'trify.db'),
    version: 1,
    onCreate: onCreate,
  );
}
