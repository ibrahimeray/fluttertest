import 'dart:convert';
import 'package:bautagebuch/db/dbCreate.dart';
import 'package:bautagebuch/db/dbHelper.dart';
import 'package:bautagebuch/models/bttable.dart';
import 'package:bautagebuch/models/einstellungen/einst_abweichungen.dart';
import 'package:bautagebuch/models/einstellungen/einst_gerate.dart';
import 'package:bautagebuch/models/einstellungen/einst_qualifikation.dart';
import 'package:bautagebuch/models/image_container.dart';
import 'package:bautagebuch/models/modul/abweichungen.dart';
import 'package:bautagebuch/models/modul/anwesende.dart';
import 'package:bautagebuch/models/modul/baubesprechung.dart';
import 'package:bautagebuch/models/modul/baubestand.dart';
import 'package:bautagebuch/models/modul/fahrbuch.dart';
import 'package:bautagebuch/models/modul/gerate.dart';
import 'package:bautagebuch/models/modul/sonstiges.dart';
import 'package:bautagebuch/models/modul/weisungen.dart';
import 'package:bautagebuch/models/modul/wetter.dart';
import 'package:bautagebuch/models/ticket.dart';
import 'package:bautagebuch/models/users.dart';
import 'package:sqflite/sqflite.dart';

class RequestController {
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  /// SENKRONIZASYON DATA ERSTELLEN
  /// ///////////////////////////////////////////////////////////////////////////////////////////////////

  Future<String> senkronizasyonRequestDataVorbereitung() async {
    DbHelper mDbHelper = DbHelper();
    mDbHelper.initializeDb();

    Database db = await mDbHelper.db;
    List tableList = List();

    List<dynamic> tableModel;
    var dbResult;
    List<String> tableuuid = List();
    var requestString = "";
    var tableNames = [
      "abweichungen",
      "anwesende",
      "baubestand",
      "gerateundmaschinen",
      "sonstige",
      // "tageleistung",
      "weisungen",
      "wetter",
      "bt_table",
      "users",
      "sync_protokoll",
      "einst_abweichung",
      "einst_gerate",
      "einst_qualifikation",
      "image_container",
      "fahrbuch",
      "ticket_kategorie",
      "ticket",
      "baubesprechung"
    ];

    for (var tableName in tableNames) {
      dbResult = await db.rawQuery(
          "SELECT * FROM sync_protokoll WHERE sync_table='$tableName' ");
      for (var i = 0; i < dbResult.length; i++) {
        tableuuid.add(dbResult[i]['sync_uuid'].toString());
      }

      if (tableName == "bt_table") {
        tableList = await db.rawQuery(
            "SELECT * FROM bt_table WHERE bt_nummer IN (" +
                getWhereString(tableuuid) +
                ")");

        tableModel = tableList.isNotEmpty
            ? tableList.map((c) => BtTableModel.formObject(c)).toList()
            : [];

        requestString += '"$tableName" :' + jsonEncode(tableModel) + ",";
      }
      if (tableName == "abweichungen" ||
          tableName == "anwesende" ||
          tableName == "baubestand" ||
          tableName == "gerateundmaschinen" ||
          tableName == "sonstige" ||
          // tableName == "tageleistung" ||
          tableName == "weisungen" ||
          tableName == "wetter" ||
          tableName == "einst_abweichung" ||
          tableName == "einst_gerate" ||
          tableName == "einst_qualifikation" ||
          tableName == "ticket_kategorie" ||
          tableName == "fahrbuch" ||
          tableName == "baubesprechung" ||
          tableName == "image_container") {
        tableList = await db.rawQuery(
            "SELECT * FROM $tableName WHERE uuid IN (" +
                getWhereString(tableuuid) +
                ")");
        if (tableName == "abweichungen") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => AbweichungenModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "anwesende") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => AnwesendeModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "baubestand") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => BaubestandModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "gerateundmaschinen") {
          tableModel = tableList.isNotEmpty
              ? tableList
                  .map((c) => GerateundMaschinenModel.formObject(c))
                  .toList()
              : [];
        }
        if (tableName == "sonstige") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => SonstigesModel.formObject(c)).toList()
              : [];
        }
        /*  if (tableName == "tageleistung") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => TageleistungModel.formObject(c)).toList()
              : [];
        }
        */
        if (tableName == "weisungen") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => WeisungenModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "wetter") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => WetterModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "einst_abweichung") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => AbweichungEinModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "einst_gerate") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => GerateModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "einst_qualifikation") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => BrancheModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "image_container") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => ImageContainerModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "fahrbuch") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => FahrbuchModel.formObject(c)).toList()
              : [];
        }
        if (tableName == "baubesprechung") {
          tableModel = tableList.isNotEmpty
              ? tableList.map((c) => BaubesprechungModel.formObject(c)).toList()
              : [];
        }
        requestString += '"$tableName" :' + jsonEncode(tableModel) + ",";
      }

      if (tableName == "users") {
        tableList = await db.rawQuery("SELECT * FROM " +
            DbCreateTable.TABLE_USER +
            "  WHERE kundennummer IN (" +
            getWhereString(tableuuid) +
            ")");

        tableModel = tableList.isNotEmpty
            ? tableList.map((c) => UsersModel.formObject(c)).toList()
            : [];
        print("tableModel" + tableModel.toString());
        requestString += '"$tableName" :' + jsonEncode(tableModel) + ",";
      }
      if (tableName == "ticket") {
        tableList = await db.rawQuery(
            "SELECT * FROM ticket WHERE ticket_nummer IN (" +
                getWhereString(tableuuid) +
                ")");

        tableModel = tableList.isNotEmpty
            ? tableList.map((c) => TicketModel.formObject(c)).toList()
            : [];

        requestString += '"$tableName" :' + jsonEncode(tableModel) + ",";
      }
    }
    // Senkron Prokotoll senden
    dbResult = await db.rawQuery(
        "SELECT * FROM sync_protokoll WHERE sync_table !='image_container'");
    requestString += '"sync_protokoll" :' + jsonEncode(dbResult);
    return requestString;
  }

  static getWhereString(List<String> tableuuid) {
    var whereInString = "";
    for (int i = 0; i < tableuuid.length; i++) {
      if (i == tableuuid.length - 1) {
        whereInString += "'" + tableuuid[i] + "'";
      } else {
        whereInString += "'" + tableuuid[i] + "',";
      }
    }
    return whereInString;
  }
}
