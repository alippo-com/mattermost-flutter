
import 'package:sqflite/sqflite.dart' as sql;

class MyTeam {
  static const String tableName = 'my_team';
  static const String columnRoles = 'roles';

  static Future<void> createTable(sql.Database database) async {
    await database.execute('''
      CREATE TABLE \$tableName (
        \$columnRoles TEXT NOT NULL
      )
    ''');
  }

  static Future<void> insertTeam(sql.Database database, String roles) async {
    await database.transaction((txn) async {
      await txn.rawInsert('''
        INSERT INTO \$tableName (\$columnRoles)
        VALUES (?)
      ''', [roles]);
    });
  }
}
