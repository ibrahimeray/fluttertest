import 'dart:async';
import 'package:bautagebuch/helper/const.dart';
import 'package:bautagebuch/helper/dialog/modaldialog.dart';
import 'package:bautagebuch/helper/location/localization.dart';
import 'package:bautagebuch/helper/root_.dart';
import 'package:bautagebuch/services/auhtentication.dart';
import 'package:bautagebuch/services/httpController.dart';
import 'package:bautagebuch/services/requestController.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdi/mdi.dart';
import 'package:progress_indicator_button/progress_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
 
  LoginPage({this.callback, this.auth, this.onSignedIn});
  final Function callback;
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  double screenHeight;
  final Connectivity _connectivity = Connectivity();
  AppHelper appHelper = AppHelper();
  RequestController mRequestVorbereitungController = new RequestController();
  HttpController mRequestController = HttpController();
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  GlobalKey<ScaffoldState> _loginKeyScaffold = new GlobalKey<ScaffoldState>();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Animation<double> animation;
  String _connectionStatus = 'nointernet';
  bool hidePassword = true;
  bool selected = false;
  Dio dio = new Dio();
  String _email;
  String _password;
  final _loginformKey = new GlobalKey<FormState>();
  bool _isButtonEnabled;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    setState(() {
      _isButtonEnabled = true;
    });
    initConnectivity();
    initPlatformState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _loginKeyScaffold,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            upperHalf(context),
            loginCard(context),
            pageTitle(),
            Positioned(
                child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                _isButtonEnabled
                    ? Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(null);
                          },
                          child: Icon(
                            Mdi.close,
                            size: 25,
                          ),
                        ))
                    : Container(),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget pageTitle() {
    return Container(
      margin: EdgeInsets.only(top: screenHeight / 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/logoweiss.png',
            fit: BoxFit.cover,
            scale: 4,
          ),
        ],
      ),
    );
  }

  Widget upperHalf(BuildContext context) {
    return Container(
      height: screenHeight / 2.5,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          fit: BoxFit.cover,
          colorFilter: new ColorFilter.mode(
              Color(0xFF000000).withOpacity(0.8), BlendMode.hardLight),
          image: new ExactAssetImage(
            'assets/images/loginbackground.png',
          ),
        ),
      ),
    );
  }

  Widget loginCard(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: screenHeight / 4),
          padding: EdgeInsets.only(left: 0, right: 0),
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: new Form(
              key: _loginformKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 0,
                  ),
                  Center(
                      child: Text(
                    'Willkommen Zurück!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Roboto-500'),
                  )),
                  SizedBox(
                    height: screenHeight / 6,
                  ),
                  TextFormField(
                    cursorColor: Colors.black54,
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    autofocus: false,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'E-Mail',
                      fillColor: Colors.black54,
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                    validator: validateEmail,
                    onSaved: (value) => _email = value,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) => value.isEmpty
                        ? AppTranslations.of(context)
                            .text("feld_darf_nicht_leer_sein")
                        : null,
                    onSaved: (value) => _password = value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Passwort',
                      fillColor: Colors.black54,
                      labelStyle: TextStyle(color: Colors.black54),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        child: Icon(
                          hidePassword == true ? Mdi.eyeOff : Mdi.eye,
                          size: 25,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    obscureText: hidePassword,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ButtonTheme(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5),
                      ),
                      minWidth: MediaQuery.of(context).size.width,
                      height: 45.0,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Container(
                            height: 45,
                            child: ProgressButton(
                              color: Color(0xFFffa400),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              child: Text(
                                "ANMELDEN",
                                style: TextStyle(
                                    color: Color(0xFFF1b273a),
                                    fontSize: 15,
                                    fontFamily: 'Roboto-500'),
                              ),
                              onPressed: _isButtonEnabled
                                  ? (AnimationController controller) {
                                      controller.forward();
                                      _validateAndSubmit(controller);
                                    }
                                  : (AnimationController controller) {},
                            )),
                      )),
                  SizedBox(
                    height: 30,
                  ),
                  _isButtonEnabled
                      ? new GestureDetector(
                          onTap: () {
                            _passswordvergessenWebseiteURL();
                          },
                          child: new Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                                AppTranslations.of(context)
                                    .text("password_vergessen"),
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.grey[700])),
                          ))
                      : new Container(
                          child: Text(
                            AppTranslations.of(context)
                                .text("app_nicht_beenden"),
                            style: TextStyle(color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

 
  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'devicename': 'android',
      'systemVersion': build.version.release,
      'version.baseOS': build.version.baseOS,
      'name': build.manufacturer + " " + build.model,
      'board': build.board,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'host': build.host,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'devicename': 'ios',
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
    };
  }

  _passswordvergessenWebseiteURL() async {
    var url = Constants.BACKEND + Configurtions.PASSWORD_VERGESSEN;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return AppTranslations.of(context).text("falsche_email");
    else
      return null;
  }

  bool _validateAndSave() {
    final form = _loginformKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future _validateAndSubmit(AnimationController controller) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_connectionStatus == "ConnectivityResult.mobile" ||
        _connectionStatus == "ConnectivityResult.wifi") {
      if (_validateAndSave()) {
        setState(() {
          selected = !selected;
        });

        await widget.auth
            .login(_email, _password, _deviceData)
            .then((_isLogin) {
          if (_isLogin == 'success') {
            //Login button disable
            setState(() {
              _isButtonEnabled = false;
            });

 
            mRequestVorbereitungController
                .senkronizasyonRequestDataVorbereitung()
                .then((requestdata) {
              mRequestController.getVersionundVertrag().whenComplete(() {
                  return mRequestController
                    .sessionDataVorbereitung(requestdata)
                    .then((requestdata) {
                  try {
                    mRequestController
                        .getSenkronData(
                            requestdata, widget.onSignedIn, navigationClose)
                        .then((response) {
                      if (response == "429") {
                        controller.reverse();
                        setState(() {
                          _isButtonEnabled = true;
                        });
                        appHelper.alertDialog(
                            "Too many requests", "Too many requests", context);
                      } else if (response == "408") {
                        controller.reverse();
                        setState(() {
                          _isButtonEnabled = true;
                        });
                        appHelper.alertDialog(
                            AppTranslations.of(context)
                                .text("zeit_uberschreitung"),
                            AppTranslations.of(context)
                                .text("spater_versuchen"),
                            context);
                      } else if (response == "500" || response == "401") {
                        controller.reverse();
                        setState(() {
                          _isButtonEnabled = true;
                        });
                        appHelper.alertDialog(
                            AppTranslations.of(context).text("server_fehler"),
                            AppTranslations.of(context)
                                .text("server_fehler_versuchen"),
                            context);
                      } else if (response == "503") {
                        controller.reverse();
                        setState(() {
                          _isButtonEnabled = true;
                        });
                        appHelper.alertDialog(
                            AppTranslations.of(context)
                                .text("service_unaviable"),
                            AppTranslations.of(context)
                                .text("server_nichterreichabr"),
                            context);
                      } else if (response == "200") {
                        setState(() {
                          _isButtonEnabled = false;
                        });
                        
                      } else {
                        controller.reverse();
                        setState(() {
                          _isButtonEnabled = true;
                        });
                        appHelper.alertDialog(
                            "Unbekannte Fehler",
                            "Es ist ein Unbekannte Fehler aufgetreten. Bitte kontaktieren Sie mit unseren Support. app@zentoplan.de",
                            context);
                      }
                    });
                  } catch (error) {
                    controller.reverse();
                    setState(() {
                      _isButtonEnabled = true;
                    });
                    appHelper.alertDialog(
                        "Unbekannte Fehler",
                        "Es ist ein Unbekannte Fehler aufgetreten. Bitte kontaktieren Sie mit unseren Support. app@zentoplan.de",
                        context);
                  }
                });
              });
            });
          } else if (_isLogin == 'timeout') {
            controller.reverse();
            setState(() {
              _isButtonEnabled = true;
            });
            appHelper.alertDialog(
                AppTranslations.of(context).text("zeit_uberschreitung"),
                AppTranslations.of(context).text("spater_versuchen"),
                context);
          } else if (_isLogin == 'servererror') {
            controller.reverse();
            setState(() {
              _isButtonEnabled = true;
            });
            appHelper.alertDialog(
                AppTranslations.of(context).text("server_fehler"),
                AppTranslations.of(context).text("server_fehler_versuchen"),
                context);
          } else if (_isLogin == 'error') {
            controller.reverse();
            setState(() {
              _isButtonEnabled = true;
            });
            appHelper.alertDialog(
                AppTranslations.of(context).text("login_fehler"),
                AppTranslations.of(context).text("falsche_password"),
                context);
          }
          //Login button disable
          setState(() {
            selected = !selected;
          });
        });
      } else {
        controller.reverse();
        setState(() {
          selected = !selected;
          _isButtonEnabled = true;
        });
      }
    } else {
      controller.reverse();

      return Flushbar(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 20),
        borderRadius: 8,
        message: AppTranslations.of(context).text("kein_internet"),
        icon: Icon(
          Mdi.wifiOff,
          size: 22.0,
          color: Colors.white,
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.black87,
      )..show(context);
    }
  }

  void navigationClose() {
    Navigator.of(context).pop();
  }

  Future<void> isNetwork() async {
    try {
      _connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on Exception catch (e) {
      print(e.toString());
      _connectionStatus = 'Failed to get connectivity.';
    }
  }

  Future<void> initConnectivity() async {
    String connectionStatus;
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on Exception catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    setState(() {
      _connectionStatus = connectionStatus;
      _connectivitySubscription = _connectivity.onConnectivityChanged
          .listen((ConnectivityResult result) {
        setState(() => _connectionStatus = result.toString());
      });
    });
  }
}
