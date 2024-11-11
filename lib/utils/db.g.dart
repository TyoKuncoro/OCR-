// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $DbManagerBuilderContract {
  /// Adds migrations to the builder.
  $DbManagerBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $DbManagerBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<DbManager> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorDbManager {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $DbManagerBuilderContract databaseBuilder(String name) =>
      _$DbManagerBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $DbManagerBuilderContract inMemoryDatabaseBuilder() =>
      _$DbManagerBuilder(null);
}

class _$DbManagerBuilder implements $DbManagerBuilderContract {
  _$DbManagerBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $DbManagerBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $DbManagerBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<DbManager> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$DbManager();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$DbManager extends DbManager {
  _$DbManager([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RecognizedTextDao? _recognizedTextDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RecognizedText` (`id` INTEGER, `image` BLOB NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RecognizedTextDao get recognizedTextDao {
    return _recognizedTextDaoInstance ??=
        _$RecognizedTextDao(database, changeListener);
  }
}

class _$RecognizedTextDao extends RecognizedTextDao {
  _$RecognizedTextDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recognizedTextInsertionAdapter = InsertionAdapter(
            database,
            'RecognizedText',
            (RecognizedText item) =>
                <String, Object?>{'id': item.id, 'image': item.image});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<RecognizedText> _recognizedTextInsertionAdapter;

  @override
  Future<List<RecognizedText>> findAll() async {
    return _queryAdapter.queryList('SELECT * FROM RecognizedText',
        mapper: (Map<String, Object?> row) =>
            RecognizedText(row['image'] as Uint8List));
  }

  @override
  Future<void> insertItem(RecognizedText val) async {
    await _recognizedTextInsertionAdapter.insert(val, OnConflictStrategy.abort);
  }
}
