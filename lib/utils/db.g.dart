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
            'CREATE TABLE IF NOT EXISTS `RecognizedTextItem` (`id` INTEGER, `image` BLOB NOT NULL, `text` TEXT NOT NULL, `timeCreated` INTEGER NOT NULL, `timeLastUpdated` INTEGER NOT NULL, PRIMARY KEY (`id`))');

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
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _recognizedTextItemInsertionAdapter = InsertionAdapter(
            database,
            'RecognizedTextItem',
            (RecognizedTextItem item) => <String, Object?>{
                  'id': item.id,
                  'image': item.image,
                  'text': item.text,
                  'timeCreated': item.timeCreated,
                  'timeLastUpdated': item.timeLastUpdated
                },
            changeListener),
        _recognizedTextItemUpdateAdapter = UpdateAdapter(
            database,
            'RecognizedTextItem',
            ['id'],
            (RecognizedTextItem item) => <String, Object?>{
                  'id': item.id,
                  'image': item.image,
                  'text': item.text,
                  'timeCreated': item.timeCreated,
                  'timeLastUpdated': item.timeLastUpdated
                },
            changeListener),
        _recognizedTextItemDeletionAdapter = DeletionAdapter(
            database,
            'RecognizedTextItem',
            ['id'],
            (RecognizedTextItem item) => <String, Object?>{
                  'id': item.id,
                  'image': item.image,
                  'text': item.text,
                  'timeCreated': item.timeCreated,
                  'timeLastUpdated': item.timeLastUpdated
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<RecognizedTextItem>
      _recognizedTextItemInsertionAdapter;

  final UpdateAdapter<RecognizedTextItem> _recognizedTextItemUpdateAdapter;

  final DeletionAdapter<RecognizedTextItem> _recognizedTextItemDeletionAdapter;

  @override
  Future<List<RecognizedTextItem>> getList() async {
    return _queryAdapter.queryList('SELECT * FROM RecognizedTextItem',
        mapper: (Map<String, Object?> row) => RecognizedTextItem(
            id: row['id'] as int?,
            image: row['image'] as Uint8List,
            text: row['text'] as String));
  }

  @override
  Stream<List<RecognizedTextItem>> getStreamList() {
    return _queryAdapter.queryListStream('SELECT * FROM RecognizedTextItem',
        mapper: (Map<String, Object?> row) => RecognizedTextItem(
            id: row['id'] as int?,
            image: row['image'] as Uint8List,
            text: row['text'] as String),
        queryableName: 'RecognizedTextItem',
        isView: false);
  }

  @override
  Future<RecognizedTextItem?> getById(int itemId) async {
    return _queryAdapter.query('SELECT * FROM RecognizedTextItem where id =?1',
        mapper: (Map<String, Object?> row) => RecognizedTextItem(
            id: row['id'] as int?,
            image: row['image'] as Uint8List,
            text: row['text'] as String),
        arguments: [itemId]);
  }

  @override
  Future<void> clear() async {
    await _queryAdapter.queryNoReturn('DELETE FROM RecognizedTextItem');
  }

  @override
  Future<void> add(RecognizedTextItem val) async {
    await _recognizedTextItemInsertionAdapter.insert(
        val, OnConflictStrategy.abort);
  }

  @override
  Future<void> update(RecognizedTextItem val) async {
    await _recognizedTextItemUpdateAdapter.update(val, OnConflictStrategy.fail);
  }

  @override
  Future<void> remove(RecognizedTextItem val) async {
    await _recognizedTextItemDeletionAdapter.delete(val);
  }
}
