import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'medico_app.db');
    // version: 2 porque cambiamos el esquema de tomas y tratamientos.
    // onUpgrade elimina y recrea las tablas afectadas para que los
    // nombres de columna queden correctos.
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  /// Se ejecuta cuando la versión de la DB aumenta.
  /// Elimina y recrea todas las tablas para aplicar el esquema correcto.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS tomas');
    await db.execute('DROP TABLE IF EXISTS tratamientos');
    await db.execute('DROP TABLE IF EXISTS doctores');
    await db.execute('DROP TABLE IF EXISTS consultas');
    await db.execute('DROP TABLE IF EXISTS inventario');
    await db.execute('DROP TABLE IF EXISTS catalogo');
    await db.execute('DROP TABLE IF EXISTS sync_queue');
    await _createTables(db);
  }

  /// Crea todas las tablas de la base de datos local.
  /// Los nombres de columna deben coincidir exactamente con los campos
  /// de los modelos Dart para que los helpers _toLocalMap/_fromLocalMap
  /// funcionen correctamente.
  Future<void> _createTables(Database db) async {
    // Doctores — directorio de médicos del usuario
    await db.execute('''
      CREATE TABLE doctores (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        especialidad TEXT,
        consultorio TEXT,
        isActive INTEGER DEFAULT 1,
        pendingAction TEXT,
        updatedAt TEXT
      )
    ''');

    // Consultas — historial clínico del usuario
    await db.execute('''
      CREATE TABLE consultas (
        id INTEGER PRIMARY KEY,
        doctorId INTEGER,
        doctorNombre TEXT,
        fechaConsulta TEXT,
        sintomas TEXT,
        diagnostico TEXT,
        observaciones TEXT,
        pendingAction TEXT,
        updatedAt TEXT
      )
    ''');

    // Inventario — medicamentos disponibles en casa
    await db.execute('''
      CREATE TABLE inventario (
        id INTEGER PRIMARY KEY,
        medicamentoId INTEGER,
        medicamentoNombre TEXT,
        medicamentoPresentacion TEXT,
        medicamentoConcentracion TEXT,
        cantidadActual INTEGER,
        cantidadMinima INTEGER,
        unidad TEXT,
        fechaCaducidad TEXT,
        lugarCompra TEXT,
        precio REAL,
        status TEXT,
        stockBajo INTEGER,
        pendingAction TEXT,
        updatedAt TEXT
      )
    ''');

    // Catálogo — base de datos global de medicamentos disponibles
    await db.execute('''
      CREATE TABLE catalogo (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        nombreGenerico TEXT,
        presentacion TEXT,
        concentracion TEXT
      )
    ''');

    // Tratamientos — planes de medicación activos e históricos.
    // Columnas alineadas con TratamientoModel:
    // notas (no instrucciones), totalTomas, tomasTomadas, tomasPendientes, createdAt
    await db.execute('''
      CREATE TABLE tratamientos (
        id INTEGER PRIMARY KEY,
        medicamentoId INTEGER,
        medicamentoNombre TEXT,
        dosis TEXT,
        frecuenciaHoras INTEGER,
        fechaInicio TEXT,
        fechaFin TEXT,
        duracionDias INTEGER,
        notas TEXT,
        status TEXT,
        totalTomas INTEGER DEFAULT 0,
        tomasTomadas INTEGER DEFAULT 0,
        tomasPendientes INTEGER DEFAULT 0,
        pendingAction TEXT,
        updatedAt TEXT
      )
    ''');

    // Tomas — registro individual de cada toma programada.
    // Columnas alineadas con TomaModel:
    // horaProgramada (no fechaProgramada), horaTomada (no fechaConfirmada),
    // descontadoInventario como INTEGER (0/1) porque SQLite no tiene booleano
    await db.execute('''
      CREATE TABLE tomas (
        id INTEGER PRIMARY KEY,
        tratamientoId INTEGER,
        medicamentoNombre TEXT,
        dosis TEXT,
        horaProgramada TEXT,
        horaTomada TEXT,
        status TEXT,
        descontadoInventario INTEGER DEFAULT 0,
        pendingAction TEXT
      )
    ''');

    // Cola de sincronización — operaciones pendientes cuando no hay internet.
    // Se procesa en orden FIFO (createdAt ASC) cuando regresa la conexión.
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity TEXT NOT NULL,
        action TEXT NOT NULL,
        entityId INTEGER,
        payload TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // ─── HELPERS GENÉRICOS ───────────────────────────────────────────

  /// Inserta o reemplaza múltiples filas en una tabla en un solo batch.
  /// Más eficiente que insertar una por una cuando vienen datos de la API.
  Future<void> upsertAll(String table, List<Map<String, dynamic>> rows) async {
    final database = await db;
    final batch = database.batch();
    for (final row in rows) {
      batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Retorna todas las filas de una tabla.
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final database = await db;
    return await database.query(table);
  }

  /// Retorna una fila por su ID, o null si no existe.
  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final database = await db;
    final results = await database.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Inserta o reemplaza una fila. Si ya existe el ID, la sobreescribe.
  Future<void> upsert(String table, Map<String, dynamic> row) async {
    final database = await db;
    await database.insert(
      table,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualiza campos específicos de una fila por su ID.
  Future<void> update(String table, Map<String, dynamic> row, int id) async {
    final database = await db;
    await database.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  /// Elimina una fila por su ID.
  Future<void> delete(String table, int id) async {
    final database = await db;
    await database.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // ─── SYNC QUEUE ──────────────────────────────────────────────────

  /// Agrega una operación pendiente a la cola de sincronización.
  /// Se llama cada vez que el usuario hace una acción sin internet.
  Future<void> addToSyncQueue({
    required String entity,
    required String action,
    int? entityId,
    String? payload,
  }) async {
    final database = await db;
    await database.insert('sync_queue', {
      'entity': entity,
      'action': action,
      'entityId': entityId,
      'payload': payload,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Retorna todos los items pendientes ordenados por fecha (FIFO).
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final database = await db;
    return await database.query('sync_queue', orderBy: 'createdAt ASC');
  }

  /// Elimina un item de la queue después de sincronizarlo exitosamente.
  Future<void> removeSyncItem(int id) async {
    final database = await db;
    await database.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  /// Limpia toda la queue. Útil para resetear en caso de errores graves.
  Future<void> clearSyncQueue() async {
    final database = await db;
    await database.delete('sync_queue');
  }
}
