import 'dart:async';
import 'dart:io';
import 'package:bautagebuch/db/dbOperation.dart';
import 'package:bautagebuch/db/dbSenkronOperation.dart';
import 'package:bautagebuch/helper/const.dart';
import 'package:bautagebuch/helper/session.dart';
import 'package:bautagebuch/models/bttable.dart';
import 'package:bautagebuch/models/einstellungen/einst_abweichungen.dart';
import 'package:bautagebuch/models/einstellungen/einst_gerate.dart';
import 'package:bautagebuch/models/einstellungen/einst_qualifikation.dart';
import 'package:bautagebuch/models/einstellungen/einst_wetter.dart';
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
import 'package:bautagebuch/models/ticket_kategorie.dart';
import 'package:bautagebuch/models/userberechtigung.dart';
import 'package:bautagebuch/models/users.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HttpController {
  String deviceImagePath = "";
  String _sessiontokenID;
  String _sessionKundennummer;
  String _sessionAdminKundennummer;

  bool _firstTimeSenkron;

  Future<dynamic> sessionDataVorbereitung(String listdata) async {
    _sessionAdminKundennummer = await AppSession.getAdminKundennummer();
    _sessionKundennummer = await AppSession.getKundennummer();
    _sessiontokenID = await AppSession.getToken();

    _firstTimeSenkron = await AppSession.getFirstTimeSenkron();

    var data = {
      "erste_sync": _firstTimeSenkron,
      "data": '{' + listdata + '}',
    };
    return data;
  }

  Future<String> setProjektLoschen(String password) async {
    String result;
    var responseVersionJson;
    String _sessiontokenID = await AppSession.getToken();
    var data = {"user_login_password": password};
    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_PROJEKT_LOSCHEN,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .timeout(const Duration(seconds: 30))
          .then((http.Response response) {
        final int statusCode = response.statusCode;

        responseVersionJson = json.decode(response.body);
        if (statusCode == 200) {
          result = responseVersionJson['data'];
        } else {
          result = 'servererror';
        }
      });
      return result;
    } catch (e) {
      if (e is TimeoutException) {
        return 'timeout';
      }
      if (e is SocketException) {
        return 'servererror';
      }
      return 'error';
    }
  }

  Future<String> getVersionundVertrag() async {
    var responseVersionJson;
    DBSenkronOperations dbSenkronHelper = new DBSenkronOperations();
    try {
      await http
          .post(Constants.SERVER + Configurtions.APP_STANDART_INFO,
              // body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .timeout(const Duration(seconds: 30))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseVersionJson = json.decode(response.body);
        // Vertragstatus
        AppSession.setVertragStatus(
            responseVersionJson['vertrag_status'].toString());
        print("Abonnement STATUS" +
            responseVersionJson['vertrag_status'].toString());
        print("BENUTZER UPDATE STAUS INFO-----" +
            responseVersionJson['users'].toString());

        List<dynamic> usersList = responseVersionJson['users'];
        if (usersList.length > 0) {
          for (dynamic users in usersList) {
            UsersModel mUsers = new UsersModel.formObject(users);
            dbSenkronHelper.insertUsers(mUsers);
            print("users_" + mUsers.user_type.toString());

            if (mUsers.kundennummer.toString() == _sessionKundennummer) {
              AppSession.setUserType(mUsers.user_type.toString());
            }
          }
        }
      });
      return responseVersionJson['vertrag_status'];
    } catch (e) {
      if (e is TimeoutException) {
        return 'timeout';
      }
      if (e is SocketException) {
        return 'servererror';
      }
      return 'error';
    }
  }

  Future<String> getSenkronData(var requestdata, VoidCallback onSignedIn,
      VoidCallback navigationClose) async {
    String result;

    print("GESENDETE DATEN----" + json.encode(requestdata).toString());
    try {
      await http
          .post(Constants.SERVER + Configurtions.URL_SENKRON,
              body: json.encode(requestdata),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .timeout(const Duration(seconds: 30))
          .then((http.Response response) {
        final int statusCode = response.statusCode;

        if (statusCode == 200) {
          return setResponseDataBaseInsert(
                  json.decode(response.body), onSignedIn, navigationClose)
              .whenComplete(() {
            result = statusCode.toString();
          });
        } else {
          result = statusCode.toString();
        }
      });
      return result;
    } catch (e) {
      if (e is TimeoutException) {
        return 'timeout';
      }
      if (e is SocketException) {
        return 'servererror';
      }
      return 'error';
    }
  }

/*
  Future<String> getDatensatzAktivForSplaschScreen() async {
    var responseJson;
    String result;
    DBSenkronOperations dbSenkronHelper = new DBSenkronOperations();
    _sessionAdminKundennummer =
        await AppSession.getAdminKundennummer();

    String _sessiontokenID = await AppSession.getToken();
    print("Bearer $_sessiontokenID");
    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_DATENSATZAKTIV,
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .timeout(const Duration(seconds: 15))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 ||
            statusCode > 400 ||
            json == null ||
            statusCode == 500) {
          result = "error";
        }
        responseJson = json.decode(response.body);
        return btDatenSatzAktivList(dbSenkronHelper, responseJson).then((_) {
          result = "success";
        });
      });
      print("SPLASCH SCREEN DEAKTIV DATEN I ARIYOR-----" + result);
      return result;
    } catch (e) {
      if (e is TimeoutException) {
        result = 'timeout';
      }
      if (e is SocketException) {
        result = 'servererror';
      }
      result = 'error';
    }
  }
*/
  Future<String> ticketPDFAusdruck(String ticketNummer, String btNummer) async {
    var responseImageJson;
    String _sessiontokenID = await AppSession.getToken();

    var data = {"ticket_nummer_mobile": ticketNummer, "bt_nummer": btNummer};

    print("_sessiontokenID" + _sessiontokenID);

    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_PDF_PRINT,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseImageJson = json.decode(response.body);
      });
      return responseImageJson.toString();
    } catch (e) {
      return "";
    }
  }

  Future<String> getPdfBaubericht(String btNummer, String vonDatum,
      String bisDatum, String kundennummer) async {
    var responseImageJson;
    String _sessiontokenID = await AppSession.getToken();
    var data = {
      "mobile": true,
      "bt_nummer": btNummer,
      "von_datum": vonDatum,
      "bis_datum": bisDatum,
      "firma": kundennummer //'alle' yada kundennummer olacak
    };

    print("_sessiontokenID" + _sessiontokenID);

    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_PDF_PRINT,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseImageJson = json.decode(response.body);
      });
      return responseImageJson.toString();
    } catch (e) {
      return "";
    }
  }

  Future getMitarbeiterList(String bt_nummer) async {
    var responseJson;
    _sessiontokenID = await AppSession.getToken();

    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_MITARBEITER_LIST,
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseJson = json.decode(response.body);
        // Plan a göre eklenebilen kullanici sayisi
      });
      return responseJson['data'];
    } catch (e) {
      return null;
    }
  }

  Future getMitarbeiterDetails(String kundennummer) async {
    var responseJson;
    _sessiontokenID = await AppSession.getToken();
    var data = {
      "kundennummer": kundennummer,
    };
    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_MITARBEITER_DETAILS,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseJson = json.decode(response.body);
        // Plan a göre eklenebilen kullanici sayisi
      });
      return responseJson['data'];
    } catch (e) {
      return null;
    }
  }

  Future getMitarbeiterProjektList() async {
    var responseJson;
    _sessiontokenID = await AppSession.getToken();

    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_MITARBEITER_PROJEKT_LIST,
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseJson = json.decode(response.body);
        // Plan a göre eklenebilen kullanici sayisi
      });
      return responseJson['data'];
    } catch (e) {
      return null;
    }
  }

  Future getMitarbeiterDatenSpeichern(Map mapData) async {
    var responseJson;
    _sessiontokenID = await AppSession.getToken();
    print("user-send-data--" + json.encode(mapData));
    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_MITARBEITER_SPEICHERN,
              body: json.encode(mapData),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseJson = json.decode(response.body);
      });
      return responseJson['data'];
    } catch (e) {
      return null;
    }
  }

  Future setMitarbeiterLoschen(String kundennummer) async {
    var responseJson;
    _sessiontokenID = await AppSession.getToken();
    var data = {'kundennummer': kundennummer};
    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_MITARBEITER_LOSCHEN,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseJson = json.decode(response.body);
      });
      return responseJson['data'];
    } catch (e) {
      return null;
    }
  }

  Future setMitarbeiterDeaktivieren(String kundennummer) async {
    var responseJson;
    _sessiontokenID = await AppSession.getToken();
    var data = {'kundennummer': kundennummer};
    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_MITARBEITER_DEAKTIVIEREN,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseJson = json.decode(response.body);
      });
      return responseJson['data'];
    } catch (e) {
      return null;
    }
  }

  Future setMitarbeiterAktivieren(String kundennummer) async {
    var responseJson;
    _sessiontokenID = await AppSession.getToken();
    var data = {'kundennummer': kundennummer};
    try {
      await http
          .post(Constants.SERVER + Configurtions.GET_MITARBEITER_AKTIVIEREN,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400 || json == null) {
          return false;
        }
        responseJson = json.decode(response.body);
      });
      return responseJson['data'];
    } catch (e) {
      return null;
    }
  }

  Future getFCMPushNotificationSave(String fcmToken) async {
    String _sessiontokenID = await AppSession.getToken();

    var data = {
      "fcm_token": fcmToken,
    };

    try {
      await http.post(Constants.SERVER + Configurtions.FCM_TOKEN_SAVE_DATABASE,
          body: json.encode(data),
          headers: {
            "Authorization": "Bearer $_sessiontokenID",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          encoding: Encoding.getByName("utf-8"));
    } catch (e) {
      return null;
    }
  }

  Future<bool> uploadImagetoServer(String imageUUID) async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    deviceImagePath = '${extDir.path}';

    DataBaseOperations dbHelper = new DataBaseOperations();
    DBSenkronOperations dbSenkronHelper = new DBSenkronOperations();
    var responseJson;
    var file_type;
    // Datenbank dan veri getirilecek

    return dbHelper.session().then((_) =>
        dbHelper.getImageForUpload(imageUUID).then((result) {
          result.forEach((listElement) {
            // File Type finder

            String url = ImageContainerModel.formObject(listElement).url;

            String extension = url.split('.').last;
            if (extension == "jpg" ||
                extension == "jpeg" ||
                extension == "png") {
              file_type = "images";
            } else {
              file_type = "dokument";
            }

            var data = {
              "file_type": file_type,
              "dokument_name": url,
              "uuid": ImageContainerModel.formObject(listElement).uuid,
              "modul_uuid":
                  ImageContainerModel.formObject(listElement).modulUuid,
              "admin_kundennummer":
                  ImageContainerModel.formObject(listElement).adinKundennummer,
              "kundennummer":
                  ImageContainerModel.formObject(listElement).kundennummer,
              "process": ImageContainerModel.formObject(listElement).process,
              "bt_nummer": ImageContainerModel.formObject(listElement).btNummer,
              "bt_datum": ImageContainerModel.formObject(listElement).btDatum,
              "url": ImageContainerModel.formObject(listElement).url,
              "thumbnail":
                  ImageContainerModel.formObject(listElement).thumbnail,
              "created_at":
                  ImageContainerModel.formObject(listElement).createdAt,
              "updated_at":
                  ImageContainerModel.formObject(listElement).updatedAt,
              "file": base64Encode(File(deviceImagePath +
                      "/" +
                      ImageContainerModel.formObject(listElement).url)
                  .readAsBytesSync()),
            };

            print("FILE NNAME FOR UPLOAD----:  " +
                ImageContainerModel.formObject(listElement).url);

            print(Constants.SERVER + Configurtions.MOBILE_IMAGE_UPLOAD);

            try {
              http
                  .post(Constants.SERVER + Configurtions.MOBILE_IMAGE_UPLOAD,
                      body: data,
                      headers: {
                        "Authorization": "Bearer $_sessiontokenID",
                        "Accept": "application/json",
                        HttpHeaders.acceptEncodingHeader: "*"
                      },
                      encoding: Encoding.getByName("utf-8"))
                  .timeout(const Duration(seconds: 30))
                  .then((http.Response response) {
                final int statusCode = response.statusCode;
                if (statusCode < 200 ||
                    statusCode > 400 ||
                    statusCode == 503 ||
                    json == null) {
                  print("HATA VAR" + response.body.toString());
                  print("HATA DURUM KODU" + statusCode.toString());
                  print(
                      "+++++++++++++++++++++++DOSYA YUKLENEMEDI +++++++++++++++++++++++++");
                  return false;
                }

                responseJson = json.decode(response.body);

                if (responseJson['message'].toString() == "true") {
                  dbSenkronHelper.syncImageTableDelete(
                      ImageContainerModel.formObject(listElement).uuid);
                  print(
                      "+++++++++++++++++++++++DOSYA SERVER E YUKLENDI+++++++++++++++++++++++++");
                  return true;
                } else {
                  print(
                      "+++++++++++++++++++++++DOSYA YUKLENEMEDI +++++++++++++++++++++++++");
                  return false;
                }
              });
            } catch (error) {
              print("NE HATASI LAN BU ++++" + error.toString());
              return false;
            }
          });
        }));
  }

  Future setResponseDataBaseInsert(var responseJson, VoidCallback onSignedIn,
      VoidCallback navigationClose) async {
    DBSenkronOperations dbSenkronHelper = new DBSenkronOperations();

    _firstTimeSenkron = await AppSession.getFirstTimeSenkron();

    await bttable(dbSenkronHelper, responseJson).whenComplete(() {
      //  return getKommentarVonServerDB(dbSenkronHelper, responseJson).then((_) {
      ticket(dbSenkronHelper, responseJson).whenComplete(() {
        ticketKategorie(dbSenkronHelper, responseJson).whenComplete(() {
          fahrbuchList(dbSenkronHelper, responseJson).whenComplete(() {
            baubesprechungsList(dbSenkronHelper, responseJson).whenComplete(() {
              wetter(dbSenkronHelper, responseJson).whenComplete(() {
                anwesendeList(dbSenkronHelper, responseJson).whenComplete(() {
                  baubestandList(dbSenkronHelper, responseJson)
                      .whenComplete(() {
                    //  tageleistungList(dbSenkronHelper, responseJson)
                    //      .whenComplete(() {
                    weisungenList(dbSenkronHelper, responseJson)
                        .whenComplete(() {
                      abweichungenList(dbSenkronHelper, responseJson)
                          .whenComplete(() {
                        gerateundmaschinenList(dbSenkronHelper, responseJson)
                            .whenComplete(() {
                          sonstigeList(dbSenkronHelper, responseJson)
                              .whenComplete(() {
                            einstAbweichungList(dbSenkronHelper, responseJson)
                                .whenComplete(() {
                              einstgerateList(dbSenkronHelper, responseJson)
                                  .whenComplete(() {
                                einstbrancheList(dbSenkronHelper, responseJson)
                                    .whenComplete(() {
                                  //  einsWetterVerhaltnisList(
                                  //          dbSenkronHelper, responseJson)
                                  //    .whenComplete(() {
                                  einstwindList(dbSenkronHelper, responseJson)
                                      .whenComplete(() {
                                    usersList(dbSenkronHelper, responseJson)
                                        .whenComplete(() {
                                      mitarbeiterList(
                                              dbSenkronHelper, responseJson)
                                          .whenComplete(() {
                                        usersBerechtigungList(
                                                dbSenkronHelper, responseJson)
                                            .whenComplete(() {
                                          // btDatenSatzAktivList(
                                          //         dbSenkronHelper, responseJson)
                                          //     .whenComplete(() {
                                          imageDownload(
                                                  dbSenkronHelper, responseJson)
                                              .whenComplete(() {
                                            imageDelete(dbSenkronHelper,
                                                    responseJson)
                                                .whenComplete(() {
                                              imageUpload(dbSenkronHelper,
                                                      responseJson)
                                                  .whenComplete(() {
                                                dbSenkronHelper
                                                    .syncTableDelete()
                                                    .whenComplete(() {
                                                  AppSession
                                                      .setFirstTimeSenkron(
                                                          false);
                                                  if (navigationClose != null) {
                                                    navigationClose();
                                                  }
                                                  if (onSignedIn != null) {
                                                    onSignedIn();
                                                  }
                                                  print(
                                                      "####################ENSON BURAYA GELIYOR##################");
                                                });
                                              });
                                            });
                                          });
                                        });
                                      });
                                    });
                                  });
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
    //   });
    //  });
    //   });
    //});
  }

  Future<Null> bttable(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> bttableContainerList = responseJson['bt_table'];

    if (bttableContainerList.length > 0) {
      for (dynamic bttable in bttableContainerList) {
        BtTableModel modelsbt = new BtTableModel.formObject(bttable);
        await dbSenkronHelper.senkronBTTable(modelsbt);
      }
      print("bt_table" + bttableContainerList.length.toString());
    }
  }

  Future<Null> ticket(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> ticketList = responseJson['ticket'];

    if (ticketList.length > 0) {
      for (dynamic ticket in ticketList) {
        TicketModel modelsbt = new TicketModel.formObject(ticket);
        await dbSenkronHelper.senkronTicketTable(modelsbt);
      }
      print("ticket" + ticketList.length.toString());
    }
  }

  Future<Null> ticketKategorie(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> ticketKategorieList = responseJson['ticket_kategorie'];

    if (ticketKategorieList.length > 0) {
      for (dynamic ticketkategorie in ticketKategorieList) {
        TicketKategorieModel modelsbt =
            new TicketKategorieModel.formObject(ticketkategorie);
        await dbSenkronHelper.senkronTicketKategorieTable(modelsbt);
      }
    }
  }

  Future<Null> wetter(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> wetterList = responseJson['wetter'];

    if (wetterList.length > 0) {
      for (dynamic bttablew in wetterList) {
        WetterModel modelsw = new WetterModel.formObject(bttablew);
        await dbSenkronHelper.updateORSaveModul(modelsw, "wetter");
      }
      print("wetter" + wetterList.length.toString());
    }
  }

  Future<Null> fahrbuchList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> fahrbuchList = responseJson['fahrbuch'];

    if (fahrbuchList.length > 0) {
      for (dynamic fahrbclist in fahrbuchList) {
        FahrbuchModel modelsa = new FahrbuchModel.formObject(fahrbclist);
        await dbSenkronHelper.updateORSaveModul(modelsa, "fahrbuch");
      }
      print("fahrbuch" + fahrbuchList.length.toString());
    }
  }

  Future<Null> baubesprechungsList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> baubesprechungsList = responseJson['baubesprechung'];

    if (baubesprechungsList.length > 0) {
      for (dynamic fbaubesprechlist in baubesprechungsList) {
        BaubesprechungModel modelsa =
            new BaubesprechungModel.formObject(fbaubesprechlist);
        await dbSenkronHelper.updateORSaveModul(modelsa, "baubesprechung");
      }
      print("baubesprechung" + baubesprechungsList.length.toString());
    }
  }

  Future<Null> anwesendeList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> anwesendeList = responseJson['anwesende'];

    if (anwesendeList.length > 0) {
      for (dynamic bttablea in anwesendeList) {
        AnwesendeModel modelsa = new AnwesendeModel.formObject(bttablea);
        await dbSenkronHelper.updateORSaveModul(modelsa, "anwesende");
      }
      print("anwesende" + anwesendeList.length.toString());
    }
  }

  Future<Null> baubestandList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> baubestandList = responseJson['baubestand'];

    if (baubestandList.length > 0) {
      for (dynamic bttableb in baubestandList) {
        BaubestandModel modelsb = new BaubestandModel.formObject(bttableb);
        await dbSenkronHelper.updateORSaveModul(modelsb, "baubestand");
      }
      print("baubestand");
    }
  }
/*
  Future<Null> tageleistungList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> tageleistungList = responseJson['tageleistung'];

    if (tageleistungList.length > 0) {
      for (dynamic bttablet in tageleistungList) {
        TageleistungModel modelst = new TageleistungModel.formObject(bttablet);
        await dbSenkronHelper.updateORSaveModul(modelst, "tageleistung");
      }
      print("tageleistung");
    }
  }
  */

  Future<Null> weisungenList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> weisungenList = responseJson['weisungen'];

    if (weisungenList.length > 0) {
      for (dynamic bttablewe in weisungenList) {
        WeisungenModel modelswe = new WeisungenModel.formObject(bttablewe);
        await dbSenkronHelper.updateORSaveModul(modelswe, "weisungen");
      }
      print("weisungen");
    }
  }

  Future<Null> abweichungenList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> abweichungenList = responseJson['abweichungen'];

    if (abweichungenList.length > 0) {
      for (dynamic bttableab in abweichungenList) {
        AbweichungenModel modelsab =
            new AbweichungenModel.formObject(bttableab);
        await dbSenkronHelper.updateORSaveModul(modelsab, "abweichungen");
      }
      print("abweichungen");
    }
  }

  Future<Null> gerateundmaschinenList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> gerateundmaschinenList = responseJson['gerateundmaschinen'];

    if (gerateundmaschinenList.length > 0) {
      for (dynamic bttablgee in gerateundmaschinenList) {
        GerateundMaschinenModel modelsge =
            new GerateundMaschinenModel.formObject(bttablgee);
        await dbSenkronHelper.updateORSaveModul(modelsge, "gerateundmaschinen");
      }
      print("gerateundmaschinen");
    }
  }

  Future<Null> sonstigeList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> sonstigeList = responseJson['sonstige'];

    if (sonstigeList.length > 0) {
      for (dynamic bttabsonstigelgee in sonstigeList) {
        SonstigesModel msonstige =
            new SonstigesModel.formObject(bttabsonstigelgee);
        await dbSenkronHelper.updateORSaveModul(msonstige, "sonstige");
      }
      print("sonstige");
    }
  }

  Future<Null> einstAbweichungList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> einstAbweichungList = responseJson['einst_abweichung'];

    if (einstAbweichungList.length > 0) {
      for (dynamic einabweichung in einstAbweichungList) {
        AbweichungEinModel abw =
            new AbweichungEinModel.formObject(einabweichung);
        await dbSenkronHelper.updateORSaveEinstellungen(
            abw, "einst_abweichung");
      }
      print("einst_abweichung");
    }
  }

/*
  Future<Null> einsWetterVerhaltnisList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> einsWetterVerhaltnisList = responseJson['einst_witterung'];

    if (einsWetterVerhaltnisList.length > 0) {
      for (dynamic wetterver in einsWetterVerhaltnisList) {
        WetterEinModel bwl = new WetterEinModel.formObject(wetterver);
        dbSenkronHelper.insertWetterEinstellungen(bwl, "einst_witterung");
      }
      print("einst_witterung" + einsWetterVerhaltnisList.length.toString());
    }
  }
*/
  Future<Null> einstwindList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> einstwindList = responseJson['einst_wind'];
    if (einstwindList.length > 0) {
      for (dynamic einwind in einstwindList) {
        WetterEinModel wind = new WetterEinModel.formObject(einwind);
        await dbSenkronHelper.insertWetterEinstellungen(wind, "einst_wind");
      }
      print("einst_wind");
    }
  }

  Future<Null> einstgerateList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> einstgerateList = responseJson['einst_gerate'];
    if (einstgerateList.length > 0) {
      for (dynamic eingerate in einstgerateList) {
        GerateModel grd = new GerateModel.formObject(eingerate);
        await dbSenkronHelper.updateORSaveEinstellungen(grd, "einst_gerate");
      }
      print("einst_gerate");
    }
  }

  Future<Null> einstbrancheList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> einstbrancheList = responseJson['einst_qualifikation'];
    if (einstbrancheList.length > 0) {
      for (dynamic einbranche in einstbrancheList) {
        BrancheModel brn = new BrancheModel.formObject(einbranche);
        await dbSenkronHelper.updateORSaveEinstellungen(
            brn, "einst_qualifikation");
      }
      print("einst_qualifikation");
    }
  }

  Future<Null> usersList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> usersList = responseJson['users'];
    if (usersList.length > 0) {
      for (dynamic users in usersList) {
        UsersModel mUsers = new UsersModel.formObject(users);
        await dbSenkronHelper.insertUsers(mUsers);
        print("users_");
      }
    }
  }

  Future<Null> mitarbeiterList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> usersList = responseJson['mitarbeiter'];
    if (usersList.length > 0) {
      for (dynamic users in usersList) {
        UsersModel mUsers = new UsersModel.formObject(users);
        await dbSenkronHelper.insertUsers(mUsers);
        print("mitarbeiterList_");
      }
    }
  }

  Future<Null> usersBerechtigungList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    //print("gelen" + responseJson.toString());
    List<dynamic> usersBerechtigungList = responseJson['users_berechtigung'];
    dbSenkronHelper.deleteUserBerechtigung().whenComplete(() {
      if (usersBerechtigungList.length > 0) {
        for (dynamic berechtigung in usersBerechtigungList) {
          BerechtigungModel mberechtigunguser =
              new BerechtigungModel.formObject(berechtigung);
          print("users_berechtigung");
          dbSenkronHelper.insertUserBerechtigung(mberechtigunguser);
        }
      }
    });
  }

/*
  Future<Null> btDatenSatzAktivList(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> btDatensatzAktivList = responseJson['bt_datensatz_aktiv'];
    dbSenkronHelper.deleteBTDatenSatzAktiv().whenComplete(() {
      if (btDatensatzAktivList.length > 0) {
        //  dbSenkronHelper.d.deleteUserBerechtigung();
        for (dynamic datensatzaktive in btDatensatzAktivList) {
          BTDatenSatzAktivModel mberechtigung =
              new BTDatenSatzAktivModel.formObject(datensatzaktive);
          dbSenkronHelper.insertBTDatenSatzAktiv(mberechtigung);
          print("bt_datensatz_aktiv");
        }
      }
    });
  }
*/
  Future<Null> imageDownload(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> imageContainerList = responseJson['image_container_download'];
    if (imageContainerList.length > 0) {
      for (dynamic imageconta in imageContainerList) {
        ImageContainerModel image =
            new ImageContainerModel.formObject(imageconta);

        await dbSenkronHelper.imageContainerDownload(image);
      }
    }
  }

  Future<Null> imageUpload(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> imageUploadList = responseJson['image_container_upload'];
    if (imageUploadList.length > 0) {
      for (dynamic imagecontainer in imageUploadList) {
        // Gelenler image_uuid dir
        print("IMAGE_CONTAINER UPLOAD uuid-----" + imagecontainer.toString());
        await uploadImagetoServer(imagecontainer.toString());
      }
    }
  }

  Future<Null> imageDelete(
      DBSenkronOperations dbSenkronHelper, var responseJson) async {
    List<dynamic> imageContainerList = responseJson['image_container_delete'];
    if (imageContainerList.length > 0) {
      for (dynamic imageconta in imageContainerList) {
        ImageContainerModel image =
            new ImageContainerModel.formObject(imageconta);
        await dbSenkronHelper.imageContainerDelete(image);
      }
    }
  }

  Future<List> getAllKommentarVonServer() async {
    var responseJson;

    String _sessiontokenID = await AppSession.getToken();

    try {
      await http
          .post(Constants.SERVER + Configurtions.KOMMENTAR_GETALL,
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .timeout(const Duration(seconds: 15))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 ||
            statusCode > 400 ||
            statusCode == 400 ||
            json == null ||
            statusCode == 500) {
          print("NILD------------------------" + statusCode.toString());
        } else {
          responseJson = json.decode(response.body);
        }
      });
      return responseJson['kommentarList'];
    } catch (e) {}
  }

  Future<List> getKommentarVonServer(String ticketNummer) async {
    var responseJson;
    var data = {"ticket_nummer": ticketNummer};

    String _sessiontokenID = await AppSession.getToken();

    print("KOMMENTAR GET SERVER URL----" +
        Constants.SERVER +
        Configurtions.KOMMENTAR_GET_VON_SERVER +
        "---dada---" +
        data.toString());
    try {
      await http
          .post(Constants.SERVER + Configurtions.KOMMENTAR_GET_VON_SERVER,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .timeout(const Duration(seconds: 15))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 ||
            statusCode > 400 ||
            statusCode == 400 ||
            json == null ||
            statusCode == 500) {
          print("NILD------------------------" + statusCode.toString());
        } else {
          responseJson = json.decode(response.body);
        }
      });
      return responseJson['kommentar'];
    } catch (e) {}
  }

  Future<String> kommentarSendToWeb(
      String ticketNummer, String btNummer, String mKommentar) async {
    var responseJson;
    String result;

    var data = {
      "ticket_nummer": ticketNummer,
      "bt_nummer": btNummer,
      "kommentar": mKommentar,
    };
    String _sessiontokenID = await AppSession.getToken();
    try {
      await http
          .post(Constants.SERVER + Configurtions.KOMMENTAR_SENDEN_TO_WEB,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .timeout(const Duration(seconds: 15))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 ||
            statusCode > 400 ||
            statusCode == 400 ||
            json == null ||
            statusCode == 500) {
          print("NILD------------------------" +
              result +
              "---" +
              statusCode.toString());
          result = "error";
        }
        responseJson = json.decode(response.body);
        if (responseJson['message'] == "success") {
          print("KOMMENTR GONDERILDI.......");
          result = "success";
        } else {
          result = "error";
        }
      });

      return result;
    } catch (e) {
      if (e is TimeoutException) {
        return 'timeout';
      } else if (e is SocketException) {
        return 'servererror';
      } else {
        return 'error';
      }
    }
  }

  Future<List> getkommentarBroadcast(String modul_uuid) async {
    String result;
    var responseJson;
    DBSenkronOperations dbSenkronHelper = new DBSenkronOperations();
    _sessiontokenID = await AppSession.getToken();
    var data = {
      "modul_uuid": modul_uuid,
    };
    print("GONDERILEN DATA:-------- " + data.toString());

    print(Constants.SERVER + Configurtions.KOMMENTAR_BROADCAST_UPDATE);
    try {
      await http
          .post(Constants.SERVER + Configurtions.KOMMENTAR_BROADCAST_UPDATE,
              body: json.encode(data),
              headers: {
                "Authorization": "Bearer $_sessiontokenID",
                "Accept": "application/json",
                "Content-Type": "application/json",
              },
              encoding: Encoding.getByName("utf-8"))
          .timeout(const Duration(seconds: 15))
          .then((http.Response response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 ||
            statusCode > 400 ||
            statusCode == 400 ||
            json == null ||
            statusCode == 500) {
          print("NILD------------------------");
          result = "error";
        }

        responseJson = json.decode(response.body);

        if (responseJson['message'] == "success") {
          print("KOMMENTAR GELEN DATA " + responseJson.toString());
          result = responseJson;
        } else {
          result = responseJson;
        }
      });

      return responseJson;
    } catch (e) {}
  }
}
