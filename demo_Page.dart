import 'dart:async';
import 'package:bautagebuch/db/dbOperation.dart';
import 'package:bautagebuch/helper/location/localization.dart';
import 'package:bautagebuch/helper/root_.dart';
import 'package:bautagebuch/pages/allgemein/register_Page.dart';
import 'package:bautagebuch/services/auhtentication.dart';
import 'package:bautagebuch/services/httpController.dart';
import 'package:bautagebuch/services/requestController.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'login_Page.dart';

class SplashScreenPage extends StatefulWidget {
  final Function callback;
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  SplashScreenPage({this.callback, this.auth, this.onSignedIn});
  @override
  State<StatefulWidget> createState() => new _SplashScreenPagePageState();
}

class _SplashScreenPagePageState extends State<SplashScreenPage> {
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  DataBaseOperations dbHelper = new DataBaseOperations();
  RequestController mRequestVorbereitungController = new RequestController();
  HttpController mRequestController = HttpController();
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  List<Slide> slides = new List();
  PageController _controller;
  bool _locked;
  double _height;
  onPageChanged(int page) {
    print("Current Page: " + page.toString());
    int previousPage = page;
    if (page != 0)
      previousPage = 2;
    else
      previousPage = 2;
    print("Previous page: $previousPage");
  }

  void scrollListener() {
    print(_controller.offset);
    double _currentOffset = _controller.offset;
    double _width = MediaQuery.of(context).size.width;

    if (_currentOffset > _controller.page * _width) {
      setState(() {
        _locked = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller = PageController()..addListener(scrollListener);
    _locked = false;
    slides.add(
      new Slide(
          maxLineTextDescription: 6,
          title: 'Baumanagementsoftware\naus der Cloud',
          maxLineTitle: 4,
          styleTitle: TextStyle(
              fontSize: 25, color: Color(0xFFffa400), fontFamily: 'Roboto-600'),
          backgroundOpacity: 0.7,
          description:
              "ZentoPLAN ist ein Platform\naus der Cloud\nIhre Bautagesberichte anlegen, verwalten und versenden",
          marginDescription: EdgeInsets.only(top: 123, left: 20, right: 20),
          styleDescription: TextStyle(
              fontSize: 17, color: Colors.white, fontFamily: 'Roboto-400'),
          backgroundColor: Colors.transparent),
    );

    slides.add(
      new Slide(
          maxLineTextDescription: 6,
          title: 'Daten immer Aktuell',
          maxLineTitle: 4,
          styleTitle: TextStyle(
              fontSize: 25, color: Color(0xFFffa400), fontFamily: 'Roboto-600'),
          backgroundOpacity: 0.7,
          description:
              "Verwalten Sie Ihre Projekte über unseren Platform ins Büro und greifen Sie diese mit allen Geräten unabhängig von Ort und Zeit",
          marginDescription: EdgeInsets.only(top: 123, left: 20, right: 20),
          styleDescription: TextStyle(
              fontSize: 17, color: Colors.white, fontFamily: 'Roboto-400'),
          backgroundColor: Colors.transparent),
    );
    slides.add(
      new Slide(
          maxLineTextDescription: 6,
          title: 'Dokumentieren mit Bildern und\nDatei-Anhängen',
          maxLineTitle: 4,
          styleTitle: TextStyle(
              fontSize: 25, color: Color(0xFFffa400), fontFamily: 'Roboto-600'),
          backgroundOpacity: 0.7,
          description: "Erfassen Sie Ihre Bautagebuch per Bilder und Dokumente",
          marginDescription: EdgeInsets.only(top: 123, left: 20, right: 20),
          styleDescription: TextStyle(
              fontSize: 17, color: Colors.white, fontFamily: 'Roboto-400'),
          backgroundColor: Colors.transparent),
    );
    slides.add(
      new Slide(
          maxLineTextDescription: 6,
          title: 'Zusammerarbeiten',
          maxLineTitle: 4,
          styleTitle: TextStyle(
              fontSize: 25, color: Color(0xFFffa400), fontFamily: 'Roboto-600'),
          backgroundOpacity: 0.7,
          description:
              "Zusammenarbeit ist sehr einfach. Geben Sie gewünschten Berechtigungen an Ihrer Projektmitarbeiter und arbeiten Sie sich sicher mit allen",
          marginDescription: EdgeInsets.only(top: 123, left: 20, right: 20),
          styleDescription: TextStyle(
              fontSize: 17, color: Colors.white, fontFamily: 'Roboto-400'),
          backgroundColor: Colors.transparent),
    );
    slides.add(
      new Slide(
          widgetTitle: Container(
              child: Center(
                  child: Text(
            'Sicherheit',
            style: TextStyle(
                color: Color(0xFFffa400),
                fontFamily: 'Roboto-600',
                fontSize: 25),
          ))),
          maxLineTextDescription: 6,
          title: 'Sicherheit',
          maxLineTitle: 4,
          marginTitle:
              EdgeInsets.only(top: 60, bottom: 190, left: 20, right: 20),
          styleTitle: TextStyle(
              fontSize: 25, color: Color(0xFFffa400), fontFamily: 'Roboto-600'),
          backgroundOpacity: 0.7,
          pathImage: "assets/intro/security.png",
          widthImage: 80,
          heightImage: 80,
          description:
              "Ihre Daten werden bei ISO 27001 Zertifizierte Server in Deutschland sicher gespeichert",
          marginDescription: EdgeInsets.only(top: 10, left: 20, right: 20),
          styleDescription: TextStyle(
              fontSize: 17, color: Colors.white, fontFamily: 'Roboto-400'),
          backgroundColor: Colors.transparent),
    );

    slides.add(
      new Slide(
          maxLineTextDescription: 6,
          title: "Herzlich Willkommen!",
          maxLineTitle: 4,
          styleTitle: TextStyle(
              fontSize: 25, color: Color(0xFFffa400), fontFamily: 'Roboto-600'),
          backgroundOpacity: 0.7,
          description: "Willkommen\nbei Baumanagementsoftware\naus der Cloud",
          marginDescription: EdgeInsets.only(top: 123, left: 20, right: 20),
          styleDescription: TextStyle(
              fontSize: 20, color: Colors.white, fontFamily: 'Roboto-400'),
          backgroundColor: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xfffd8d8d8),
        //color: Color.fromRGBO(250, 253, 255, 1),
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 4,
                child: Center(
                    child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/tester.png"),
                      fit: BoxFit.fill,
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.7), BlendMode.luminosity),
                    ),
                  ),
                  child: IntroSlider(
                    isShowDoneBtn: false,
                    slides: this.slides,
                    isScrollable: true,
                    isShowPrevBtn: true,
                    isShowSkipBtn: false,
                    colorDot: Colors.white,
                    colorActiveDot: Color(0xFFffa400),
                  ),
                ))),
            Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: new RaisedButton(
                              elevation: 2.0,
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(6.0)),
                              child: Text(
                                AppTranslations.of(context).text("anmelden"),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Roboto-400'),
                              ),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      LoginPage(
                                          auth: widget.auth,
                                          onSignedIn: widget.onSignedIn),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var begin = Offset(0.0, 1.0);
                                    var end = Offset.zero;
                                    var curve = Curves.ease;
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                ));
                              },
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        new SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: RaisedButton(
                              elevation: 2.0,
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(6.0)),
                              color: Color(0xFFffa400),
                              onPressed: () {
                                Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      RegisterPage(
                                    auth: widget.auth,
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var begin = Offset(0.0, 1.0);
                                    var end = Offset.zero;
                                    var curve = Curves.ease;
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                ));
                              },
                              child: Text(
                                'KOSTENLOS REGISTRIEREN',
                                style: TextStyle(
                                    color: Color(0xFFF1b273a),
                                    fontFamily: 'Roboto-500'),
                              ),
                            )),
                      ],
                    ),
                  ),
                ))
          ],
        ));
  }
}
