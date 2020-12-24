import 'dart:core';
import 'package:bautagebuch/db/dbCreate.dart';

class BtTableModel {
  int _id;
  String _process;
  String _admin_kundennummer;
  String _bt_nummer;
  String _pr_name;
  String _pr_nummer;
  String _pr_adresse;
  String _pr_beschreibung;
  String _pr_ausstattung;
  String _pr_etagenanzahl;
  String _pr_sanierung_datum;
  String _pr_baujahr;
  String _pr_arch;
  String _pr_bauherr;
  String _pr_bauleiter;
  String _pr_status;

  String _latitude;
  String _longitude;
  String _created_at;
  String _updated_at;
  // Bu konstructur genelde insert icin kullanilir o yuzden id yazilmak
  BtTableModel(
      this._process,
      this._admin_kundennummer,
      this._bt_nummer,
      this._pr_name,
      this._pr_nummer,
      this._pr_adresse,
      this._pr_beschreibung,
      this._pr_ausstattung,
      this._pr_etagenanzahl,
      this._pr_sanierung_datum,
      this._pr_baujahr,
      this._pr_arch,
      this._pr_bauherr,
      this._pr_bauleiter,
      this._pr_status,
      this._latitude,
      this._longitude,
      this._created_at,
      this._updated_at);

  /////// GETTER SETTER////////////////
  int get id => _id;

  String get admin_kundennummer => _admin_kundennummer;
  String get bt_nummer => _bt_nummer;
  String get pr_name => _pr_name;
  String get pr_nummer => _pr_nummer;
  String get pr_adresse => _pr_adresse;
  String get pr_beschreibung => _pr_beschreibung;
  String get pr_ausstattung => _pr_ausstattung;
  String get pr_etagenanzahl => _pr_etagenanzahl;
  String get pr_sanierung_datum => _pr_sanierung_datum;
  String get pr_baujahr => _pr_baujahr;
  String get pr_arch => _pr_arch;
  String get pr_bauherr => _pr_bauherr;
  String get pr_bauleiter => _pr_bauleiter;

  String get pr_status => _pr_status;
  String get process => _process;
  String get latitude => _latitude;
  String get longitude => _longitude;
  String get created_at => _created_at;
  String get updated_at => _updated_at;

  set process(String value) {
    _process = value;
  }

  set latitude(String value) {
    _latitude = value;
  }

  set longitude(String value) {
    _longitude = value;
  }

  set admin_kundennummer(String value) {
    _admin_kundennummer = value;
  }

  set bt_nummer(String value) {
    _bt_nummer = value;
  }

  set pr_name(String value) {
    _pr_name = value;
  }

  set pr_adresse(String value) {
    _pr_adresse = value;
  }

  set pr_beschreibung(String value) {
    _pr_beschreibung = value;
  }

  set pr_ausstattung(String value) {
    _pr_ausstattung = value;
  }

  set pr_etagenanzahl(String value) {
    _pr_etagenanzahl = value;
  }

  set pr_sanierung_datum(String value) {
    _pr_sanierung_datum = value;
  }

  set pr_baujahr(String value) {
    _pr_baujahr = value;
  }

  set pr_arch(String value) {
    _pr_arch = value;
  }

  set pr_bauherr(String value) {
    _pr_bauherr = value;
  }

  set pr_bauleiter(String value) {
    _pr_bauleiter = value;
  }

  set pr_status(String value) {
    _pr_status = value;
  }

  set created_at(String value) {
    _created_at = value;
  }

  set updated_at(String value) {
    _updated_at = value;
  }

///////////////////////////////////////

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map[DbCreateTable.MODUL_PROCESS] = _process;
    map[DbCreateTable.BT_ADMIN_KUNDENNUMMER] = _admin_kundennummer;
    map[DbCreateTable.BT_BT_NUMBER] = _bt_nummer;
    map[DbCreateTable.BT_PR_NAME] = _pr_name;
    map[DbCreateTable.BT_PR_NUMBER] = _pr_nummer;
    map[DbCreateTable.BT_PR_ADRESSE] = _pr_adresse;
    map[DbCreateTable.BT_PR_BESCHREIBUNG] = _pr_beschreibung;
    map[DbCreateTable.BT_PR_AUSTATTUNG] = _pr_ausstattung;
    map[DbCreateTable.BT_PR_ETAGENANZAHL] = _pr_etagenanzahl;
    map[DbCreateTable.BT_PR_SANIERUNG] = _pr_sanierung_datum;
    map[DbCreateTable.BT_PR_BAUJAHR] = _pr_baujahr;
    map[DbCreateTable.BT_PR_ARCH] = _pr_arch;
    map[DbCreateTable.BT_PR_BAUHERR] = _pr_bauherr;
    map[DbCreateTable.BT_PR_BAULEITER] = _pr_bauleiter;
    map[DbCreateTable.BT_PR_STATUS] = _pr_status;

    map[DbCreateTable.BT_PR_LAT] = _latitude;
    map[DbCreateTable.BT_PR_LON] = _longitude;
    map[DbCreateTable.MODUL_CERATEDATE] = _created_at;
    map[DbCreateTable.MODUL_UPDATEDATE] = _updated_at;

    if (_id != null) {
      map["id"] = _id;
    }

    return map;
  }

  // Bu yapi ise Json datasini ceviriyor
  BtTableModel.formObject(dynamic o) {
    // this._id = o['id'];
    this._process = o[DbCreateTable.MODUL_PROCESS] == null
        ? ""
        : o[DbCreateTable.MODUL_PROCESS].toString();
    this._admin_kundennummer = o[DbCreateTable.BT_ADMIN_KUNDENNUMMER] == null
        ? ""
        : o[DbCreateTable.BT_ADMIN_KUNDENNUMMER].toString();
    this._bt_nummer = o[DbCreateTable.BT_BT_NUMBER] == null
        ? ""
        : o[DbCreateTable.BT_BT_NUMBER].toString();
    this._pr_name = o[DbCreateTable.BT_PR_NAME] == null
        ? ""
        : o[DbCreateTable.BT_PR_NAME].toString();
    this._pr_nummer = o[DbCreateTable.BT_PR_NUMBER] == null
        ? ""
        : o[DbCreateTable.BT_PR_NUMBER].toString();
    this._pr_adresse = o[DbCreateTable.BT_PR_ADRESSE] == null
        ? ""
        : o[DbCreateTable.BT_PR_ADRESSE].toString();
    this._pr_beschreibung = o[DbCreateTable.BT_PR_BESCHREIBUNG] == null
        ? ""
        : o[DbCreateTable.BT_PR_BESCHREIBUNG].toString();
    this._pr_ausstattung = o[DbCreateTable.BT_PR_AUSTATTUNG] == null
        ? ""
        : o[DbCreateTable.BT_PR_AUSTATTUNG].toString();
    this._pr_etagenanzahl = o[DbCreateTable.BT_PR_ETAGENANZAHL] == null
        ? ""
        : o[DbCreateTable.BT_PR_ETAGENANZAHL].toString();
    this._pr_sanierung_datum = o[DbCreateTable.BT_PR_SANIERUNG] == null
        ? ""
        : o[DbCreateTable.BT_PR_SANIERUNG].toString();
    this._pr_baujahr = o[DbCreateTable.BT_PR_BAUJAHR] == null
        ? ""
        : o[DbCreateTable.BT_PR_BAUJAHR].toString();
    this._pr_arch = o[DbCreateTable.BT_PR_ARCH] == null
        ? ""
        : o[DbCreateTable.BT_PR_ARCH].toString();
    this._pr_bauherr = o[DbCreateTable.BT_PR_BAUHERR] == null
        ? ""
        : o[DbCreateTable.BT_PR_BAUHERR].toString();
    this._pr_bauleiter = o[DbCreateTable.BT_PR_BAULEITER] == null
        ? ""
        : o[DbCreateTable.BT_PR_BAULEITER].toString();
    this._pr_status = o[DbCreateTable.BT_PR_STATUS] == null
        ? ""
        : o[DbCreateTable.BT_PR_STATUS].toString();
    this._latitude = o[DbCreateTable.BT_PR_LAT] == null
        ? ""
        : o[DbCreateTable.BT_PR_LAT].toString();
    this._longitude = o[DbCreateTable.BT_PR_LON] == null
        ? ""
        : o[DbCreateTable.BT_PR_LON].toString();
    this._created_at = o[DbCreateTable.MODUL_CERATEDATE] == null
        ? ""
        : o[DbCreateTable.MODUL_CERATEDATE].toString();
    this._updated_at = o[DbCreateTable.MODUL_UPDATEDATE] == null
        ? ""
        : o[DbCreateTable.MODUL_UPDATEDATE].toString();
  }

  Map<String, dynamic> toJson() => {
        "process": _process,
        "admin_kundennummer": _admin_kundennummer,
        "pr_status": _pr_status,
        "bt_nummer": _bt_nummer,
        "pr_name": _pr_name,
        "pr_nummer": _pr_nummer,
        "pr_adresse": _pr_adresse,
        "pr_beschreibung": _pr_beschreibung,
        "pr_ausstattung": _pr_ausstattung,
        "pr_etagenanzahl": _pr_etagenanzahl,
        "pr_sanierung_datum": _pr_sanierung_datum,
        "pr_baujahr": _pr_baujahr,
        "pr_arch": _pr_arch,
        "pr_bauherr": _pr_bauherr,
        "pr_bauleiter": _pr_bauleiter,
        "latitude": _latitude,
        "longitude": _longitude,
        "created_at": _created_at,
        "updated_at": _updated_at,
      };
}
