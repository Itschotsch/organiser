import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:organiser/pages/entity_search.dart';
import 'package:sqflite/sqflite.dart';

class OrganisationDatabase {
  static Future<Database> open() async {
    // await deleteDatabase("organiser.db");
    return await openDatabase(
      "organiser.db",
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE entities ("
          "  entityID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "  name TEXT NOT NULL,"
          "  description TEXT NOT NULL,"
          "  image TEXT,"
          "  parent TEXT,"
          "  tags TEXT NOT NULL,"
          "  qrid TEXT,"
          "  bookmarked INTEGER,"
          "  created_on DATETIME DEFAULT CURRENT_TIMESTAMP,"
          "  modified_on DATETIME DEFAULT CURRENT_TIMESTAMP"
          ")",
        );

        await db.execute(
          "CREATE TABLE files ("
          "  hash TEXT PRIMARY KEY NOT NULL,"
          "  bytes BLOB NOT NULL,"
          "  created_on DATETIME DEFAULT CURRENT_TIMESTAMP"
          ")",
        );
      },
    );
  }

  static Future<int> getNumberOfEntities() async {
    Database db = await open();
    List<Map<String, dynamic>> results = await db.rawQuery(
      "SELECT COUNT(*) FROM entities",
    );
    // db.close();
    return results[0]["COUNT(*)"];
  }

  static Future<List<EntityProperties>> queryAllEntities() async {
    Database db = await open();
    List<Map<String, dynamic>> results = await db.query("entities");
    // db.close();
    return (await Future.wait(results.map((e) => EntityProperties.fromMap(e)).toList())
      ..sort(
        (a, b) {
          // Sort by:
          // 1. Bookmarked
          // 2. Last modified
          // 3. Name
          if (a.bookmarked && !b.bookmarked) {
            return -1;
          } else if (!a.bookmarked && b.bookmarked) {
            return 1;
          } else {
            return a.name.compareTo(b.name);
          }
        },
      ));
  }

  static Future<EntityProperties?> queryEntityByQRID(String qrid) async {
    Database db = await open();
    List<Map<String, dynamic>> results = await db.query(
      "entities",
      where: "qrid = ?",
      whereArgs: [qrid],
    );
    // db.close();
    if (results.isEmpty) {
      return null;
    } else {
      return EntityProperties.fromMap(results[0]);
    }
  }

  static queryEntitiesBySearch(String query) async {
    Database db = await open();
    List<Map<String, dynamic>> results = await db.query(
      "entities",
      where: "name LIKE ? OR description LIKE ? OR tags LIKE ?",
      whereArgs: ["%$query%", "%$query%", "%$query%"],
    );
    // db.close();

    return EntitySearch.sortByRelevance(
      await Future.wait(results.map((e) => EntityProperties.fromMap(e)).toList()),
      query,
    );
  }

  static Future<String> tryInsertBytes(Uint8List bytes) async {
    Database db = await open();
    String hash = sha256.convert(bytes).toString();
    List<Map<String, dynamic>> results = await db.query(
      "files",
      where: "hash = ?",
      whereArgs: [hash],
    );
    if (results.isEmpty) {
      await db.insert(
        "files",
        {
          "hash": hash,
          "bytes": bytes,
        },
      );
    }
    // db.close();
    return hash;
  }

  static Future<Uint8List?> queryBytes(String hash) async {
    Database db = await open();
    List<Map<String, dynamic>> results = await db.query(
      "files",
      where: "hash = ?",
      whereArgs: [hash],
    );
    // db.close();
    if (results.isEmpty) {
      return null;
    } else {
      return results[0]["bytes"];
    }
  }
}

class EntityProperties {
  int? entityID;
  String name;
  String description;
  Uint8List? image;
  String? parent;
  List<String> tags;
  String? qrid;
  bool bookmarked;
  DateTime? createdOn;
  DateTime? modifiedOn;

  EntityProperties({
    this.entityID,
    required this.name,
    required this.description,
    this.image,
    this.parent,
    required this.tags,
    this.qrid,
    required this.bookmarked,
    this.createdOn,
    this.modifiedOn,
  });

  Future<int> insertOrUpdate() async {
    if (entityID == null) {
      // New entity
      return insert(this);
    } else {
      // Existing entity
      return update(this);
    }
  }

  static Future<EntityProperties> fromMap(Map<String, dynamic> map) async {
    return EntityProperties(
      entityID: map["entityID"],
      name: map["name"],
      description: map["description"],
      image: map["image"] == null ? null : await OrganisationDatabase.queryBytes(map["image"]!),
      parent: map["parent"],
      tags: map["tags"].split(","),
      qrid: map["qrid"],
      bookmarked: map["bookmarked"] == 1,
      createdOn: DateTime.parse(map["created_on"]),
      modifiedOn: DateTime.parse(map["modified_on"]),
    );
  }

  static Future<int> insert(EntityProperties entityProperties) async {
    final String? imageHash = entityProperties.image == null ? null : await OrganisationDatabase.tryInsertBytes(entityProperties.image!);
    Database db = await OrganisationDatabase.open();
    await db.insert(
      "entities",
      {
        "name": entityProperties.name.trim(),
        "description": entityProperties.description.trim(),
        "image": imageHash,
        "parent": entityProperties.parent,
        "tags": entityProperties.tags.join(","),
        "qrid": entityProperties.qrid,
        "bookmarked": entityProperties.bookmarked ? 1 : 0,
        "created_on": DateTime.now().toUtc().toIso8601String(),
        "modified_on": DateTime.now().toUtc().toIso8601String(),
      },
    );
    List<Map<String, dynamic>> results = await db.rawQuery(
      "SELECT last_insert_rowid()",
    );
    // db.close();
    return results[0]["last_insert_rowid()"];
  }

  static Future<int> update(EntityProperties entityProperties) async {
    final String? imageHash = entityProperties.image == null ? null : await OrganisationDatabase.tryInsertBytes(entityProperties.image!);
    Database db = await OrganisationDatabase.open();
    await db.update(
      "entities",
      {
        "name": entityProperties.name.trim(),
        "description": entityProperties.description.trim(),
        "image": imageHash,
        "parent": entityProperties.parent,
        "tags": entityProperties.tags.join(","),
        "qrid": entityProperties.qrid,
        "bookmarked": entityProperties.bookmarked ? 1 : 0,
        "created_on": entityProperties.createdOn?.toIso8601String(),
        "modified_on": DateTime.now().toUtc().toIso8601String(),
      },
      where: "entityID = ?",
      whereArgs: [entityProperties.entityID],
    );
    // db.close();
    return entityProperties.entityID as int;
  }

  Future<bool> delete() async {
    Database db = await OrganisationDatabase.open();
    int rowsAffected = await db.delete(
      "entities",
      where: "entityID = ?",
      whereArgs: [entityID],
    );
    // db.close();
    return rowsAffected > 0;
  }
}
