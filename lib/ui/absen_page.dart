import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:super_apps/style//theme.dart' as Theme;
import 'package:intl/intl.dart';
import 'package:imei_plugin/imei_plugin.dart';

DateTime now = DateTime.now();
String formattedDate = DateFormat('kk:mm').format(now);

var absen = 'false';
bool onLocation = false;

class FingerPrintAbsen extends StatefulWidget {
  FingerPrintAbsen({Key key}) : super(key: key);

  _FingerPrintAbsen createState() => new _FingerPrintAbsen();
}

class _FingerPrintAbsen extends State<FingerPrintAbsen> {
  String _timeString;

   getImei() async{
    
    var imei = await ImeiPlugin.getImei;

    return imei;
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  void _changeStatusAbsen() {
    if (onLocation == true) {
      if (absen == 'false') {
        setState(() {
          absen = 'masuk';
        });
      } else if (absen == 'masuk') {
        setState(() {
          absen = 'pulang';
        });
      } else {
        setState(() {
          absen = 'false';
        });
      }
    }
  }

  Widget _textStatusAbsen() {
    if (absen == 'false') {
      return Text('Absen Masuk',
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold));
    } else if (absen == 'masuk') {
      return Text('Absen Pulang',
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold));
    } else if (absen == 'pulang') {
      return Text('Absen Complete',
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold));
    }
  }

  Widget _statusOnLocation() {
    if (onLocation == false) {
      return Container(
        width: 24.0,
        height: 24.0,
        decoration: new BoxDecoration(
          color: Theme.Colors.colorNotOnLocation,
          shape: BoxShape.circle,
        ),
      );
    } else {
      return Container(
        width: 24.0,
        height: 24.0,
        decoration: new BoxDecoration(
          color: Theme.Colors.colorOnLocation,
          shape: BoxShape.circle,
        ),
      );
    }
  }

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(minutes: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthDevice = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: Theme.Colors.backgroundAbsen,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: EdgeInsets.only(top: 50, left: 16, right: 16),
                  margin: EdgeInsets.only(bottom: 32),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: prefix0.MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _statusOnLocation(),
                      Container(
                        child: Text(_timeString,
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: prefix0.FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () {
                            _changeStatusAbsen();
                            if (onLocation == true) {
                              if (absen == 'masuk') {
                                Future.delayed(Duration(seconds: 1)).then((_) {
                                  final snackBar = SnackBar(
                                      content:
                                          Text('Semangat pagi pagi pagi!!!'),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        onPressed: () {
                                          // Some code to undo the change.
                                        },
                                      ));
                                  Scaffold.of(context).showSnackBar(snackBar);
                                });
                              } else if (absen == 'pulang') {
                                Future.delayed(Duration(milliseconds: 200))
                                    .then((_) {
                                  final snackBar = SnackBar(
                                      content: Text('Pulang lu sana!!!'),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        onPressed: () {
                                          // Some code to undo the change.
                                        },
                                      ));
                                  Scaffold.of(context).showSnackBar(snackBar);
                                });
                              } else if (absen == 'false') {
                                Future.delayed(Duration(seconds: 1)).then((_) {
                                  final snackBar = SnackBar(
                                      content: Text('loop back'),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        onPressed: () {
                                          // Some code to undo the change.
                                        },
                                      ));
                                  Scaffold.of(context).showSnackBar(snackBar);
                                });
                              }
                            } else {
                              Future.delayed(Duration(seconds: 1)).then((_) {
                                final snackBar = SnackBar(
                                    content: Text(
                                        'Mohon datang ke kantor untuk melakukan absen!!'),
                                    action: SnackBarAction(
                                      label: 'OK',
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ));
                                Scaffold.of(context).showSnackBar(snackBar);
                              });
                            }
                          },
                          child: Container(
                            width: widthDevice,
                            child: Image.asset(
                                'assets/images/absen_masuk_fingerprint.gif'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 32),
                        child: _textStatusAbsen(),
                      )
                    ],
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
