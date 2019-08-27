import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:super_apps/api/api.dart' as api;
import 'package:super_apps/style//theme.dart' as theme;
import 'package:super_apps/style/string.dart' as string;
import 'package:super_tooltip/super_tooltip.dart';

int lengthReportAbsen = 0;
List<String> tanggalAbsen = [];
List<String> jamMasukAbsen = [];
List<String> jamPulangAbsen = [];
List<String> ketAbsen = [];
String message;
String status;

String date1 = '';
String date2 = '';
String nik = '';

class ReportPage extends StatefulWidget {
  _ReportPageState createState() => new _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  SuperTooltip tooltip;

  GlobalKey _containerKey = GlobalKey();

  List _keterangan = [
    string.text.lbl_mobile,
    string.text.lbl_fingerprint,
    string.text.lbl_web,
    string.text.lbl_izin,
    string.text.lbl_sppd,
    string.text.lbl_sakit,
    string.text.lbl_cuti,
    string.text.lbl_pengganti_hari_libur,
    string.text.lbl_penugasan_di_luar
  ];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _selectedKeterangan;

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _selectedKeterangan = _dropDownMenuItems[0].value;
    super.initState();
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    date1 = formattedDateTime;
    date2 = formattedDateTime;
    makeGetRequest();
    getNik();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String keterangan in _keterangan) {
      items.add(
          new DropdownMenuItem(value: keterangan, child: new Text(keterangan)));
    }
    return items;
  }

  ketWidgetAbsen(String ket) {
    Widget ketIcon;
    switch (ket) {
      case 'p':
        {
          return ketIcon = Container(
            color: Colors.greenAccent,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('F', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      case 'm':
        {
          return ketIcon = Container(
            color: Colors.grey,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('M', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      case 'f':
        {
          return ketIcon = Container(
            color: Colors.greenAccent,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('F', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      case 'w':
        {
          return ketIcon = Container(
            color: Colors.lightBlueAccent,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('W', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      case 'd':
        {
          return ketIcon = Container(
            color: Colors.green,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('D', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      case 's':
        {
          return ketIcon = Container(
            color: Colors.deepPurple,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('S', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      case 'c':
        {
          return ketIcon = Container(
            color: Colors.deepOrangeAccent,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('C', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      case 'i':
        {
          return ketIcon = Container(
            color: Colors.purpleAccent,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('I', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      case 't':
        {
          return ketIcon = Container(
            color: Colors.indigo,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('T', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      case 'g':
        {
          return ketIcon = Container(
            color: Colors.pinkAccent,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('G', style: TextStyle(color: Colors.white))),
          );
        }
        break;
      default:
        {
          return ketIcon = Container(
            color: Colors.grey,
            height: 25.0,
            // height of the button
            width: 25.0,
            // width of the button
            child:
                Center(child: Text('M', style: TextStyle(color: Colors.white))),
          );
        }
    }
  }

  void onTap() {
    if (tooltip != null && tooltip.isOpen) {
      tooltip.close();
      return;
    }

    // We create the tooltip on the first use
    tooltip = SuperTooltip(
        popupDirection: TooltipDirection.down,
        arrowTipDistance: 30.0,
        maxHeight: 300,
        borderColor: Colors.white,
        content: new Material(
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(string.text.lbl_keterangan_absen + " :\n"),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        child: ClipOval(
                          child: Container(
                            color: Colors.grey,
                            height: 25.0, // height of the button
                            width: 25.0, // width of the button
                            child: Center(
                                child: Text('M',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      Container(child: Text(" : " + string.text.lbl_mobile)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: ClipOval(
                          child: Container(
                            color: Colors.greenAccent,
                            height: 25.0, // height of the button
                            width: 25.0, // width of the button
                            child: Center(
                                child: Text('F',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(" : "+string.text.lbl_fingerprint)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: ClipOval(
                          child: Container(
                            color: Colors.lightBlueAccent,
                            height: 25.0, // height of the button
                            width: 25.0, // width of the button
                            child: Center(
                                child: Text('W',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(" : "+string.text.lbl_web)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: ClipOval(
                          child: Container(
                            color: Colors.green,
                            height: 25.0, // height of the button
                            width: 25.0, // width of the button
                            child: Center(
                                child: Text('D',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(" : "+string.text.lbl_sppd)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: ClipOval(
                          child: Container(
                            color: Colors.deepPurple,
                            height: 25.0, // height of the button
                            width: 25.0, // width of the button
                            child: Center(
                                child: Text('S',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(" : "+string.text.lbl_sakit)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("\n"),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: ClipOval(
                          child: Container(
                            color: Colors.deepOrangeAccent,
                            height: 25.0, // height of the button
                            width: 25.0, // width of the button
                            child: Center(
                                child: Text('C',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(" : " + string.text.lbl_cuti)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: ClipOval(
                          child: Container(
                            color: Colors.purpleAccent,
                            height: 25.0, // height of the button
                            width: 25.0, // width of the button
                            child: Center(
                                child: Text('I',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(" : " + string.text.lbl_izin)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: ClipOval(
                          child: Container(
                            color: Colors.indigo,
                            height: 25.0, // height of the button
                            width: 25.0, // width of the button
                            child: Center(
                                child: Text('T',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                              " : " + string.text.lbl_pengganti_hari_libur)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: ClipOval(
                          child: Container(
                            color: Colors.pinkAccent,
                            height: 25.0, // height of the button
                            width: 25.0, // width of the button
                            child: Center(
                                child: Text('G',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child:
                              Text(" : " + string.text.lbl_penugasan_di_luar)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));

    tooltip.show(_containerKey.currentContext);
  }

  final text = new Text(
    string.text.lbl_tulis_disini,
    style: new TextStyle(fontSize: 50.0),
  );

  getNik() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nik = (prefs.getString('username') ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: theme.Colors.backgroundHumanCapital,
        title: Text(string.text.page_report_absen,
          style: TextStyle(
              color: Colors.white
          )),
      ),
      body: new SafeArea(
        child: new Column(children: [
          Container(
            padding: EdgeInsets.only(right: 10.0, left: 10.0),
            color: theme.Colors.backgroundHumanCapital,
            child: new Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 15),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    string.text.lbl_tanggal,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: width / 2.3,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true, onConfirm: (date) {
                            var day = (date.day).toString();
                            var month = (date.month).toString();
                            var year = (date.year).toString();
                            date1 = year +
                                string.text.lbl_strip +
                                month +
                                string.text.lbl_strip +
                                day;
                            setState(() {
                              date1;
                            });
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType.en);
                        },
                        child: Row(
                          children: <Widget>[
                            Text(
                              date1,
                              textAlign: TextAlign.center,
                            ),
                            Flexible(fit: FlexFit.tight, child: SizedBox()),
                            Icon(Icons.date_range),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      string.text.lbl_strip,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: width / 2.3,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true, onConfirm: (date) {
                            var day = (date.day).toString();
                            var month = (date.month).toString();
                            var year = (date.year).toString();
                            date2 = year +
                                string.text.lbl_strip +
                                month +
                                string.text.lbl_strip +
                                day;
                            setState(() {
                              date2;
                            });
                          },
                              currentTime: DateTime.now(),
                              locale: LocaleType.en);
                        },
                        child: Row(
                          children: <Widget>[
                            Text(
                              date2,
                              textAlign: TextAlign.center,
                            ),
                            Flexible(fit: FlexFit.tight, child: SizedBox()),
                            Icon(Icons.date_range),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: width,
                  padding: EdgeInsets.only(top: 10, bottom: 15),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    string.text.lbl_keterangan,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 15, right: 30),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(width: 0, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                  ),
                  child: DropdownButton(
                    value: _selectedKeterangan,
                    items: _dropDownMenuItems,
                    onChanged: changedDropDownItem,
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 25),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () async {
                      makeGetRequest();
                    },
                    child: Text(string.text.lbl_filter),
                    color: theme.Colors.bacgroundButton,
                    textColor: theme.Colors.colorTextWhite,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: width,
              // this will give you flexible width not fixed widt
              color: Colors.white,
              //variable
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  child: StickyHeader(
                      header: new Container(
                        height: 50.0,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        margin: EdgeInsets.only(bottom: 16.0),
                        color: Colors.lightBlueAccent,
                        alignment: Alignment.centerLeft,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                  child: Container(
                                      child: new Text(string.text.lbl_nomor,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15)))),
                              Expanded(
                                  child: new Text(string.text.lbl_tanggal,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15))),
                              Expanded(
                                  child: new Text(string.text.lbl_jam_masuk,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15))),
                              Expanded(
                                child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: new Text(string.text.lbl_jam_pulang,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15))),
                              ),
                              Expanded(
                                child: Container(
                                    child: GestureDetector(
                                  onTap: onTap,
                                  child: Container(
                                    key: _containerKey,
                                    padding: EdgeInsets.only(left: 30),
                                    child: new Text(string.text.lbl_ket,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15)),
                                  ),
                                )),
                              ),
                            ]),
                      ),
                      content: Table(
                        children: List<int>.generate(
                                lengthReportAbsen, (index) => index)
                            .map((item) => TableRow(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text((item + 1).toString()),
                                    ),
                                    Text(tanggalAbsen[item]),
                                    Container(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(jamMasukAbsen[item]),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 18),
                                      child: Text(jamPulangAbsen[item]),
                                    ),
                                    Center(
                                      child: Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: GestureDetector(
                                            child: ClipOval(
                                              child: ketWidgetAbsen(
                                                  ketAbsen[item]),
                                            ),
                                          )),
                                    )
                                  ],
                                ))
                            .toList(),
                      )),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
    //);
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _selectedKeterangan = selectedCity;
    });
  }

  makeGetRequest() async {
    final uri =
        api.Api.report_absen + "$nik/$date1/$date2/${_selectedKeterangan}";
    print(uri);
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    Response response = await get(uri, headers: headers);

    var data = jsonDecode(response.body);
    var data_absensi = (data["data"] as List)
        .map((data) => new dataReport.fromJson(data))
        .toList();

    foreachHasil(data_absensi);
  }

  void foreachHasil(List<dataReport> data_absensi) {
    setState(() {
      lengthReportAbsen = data_absensi.length;
    });
    for (var ini = 0; ini < data_absensi.length; ini++) {
      //TODO setstate
      setState(() {
        tanggalAbsen.add(data_absensi[ini].tanggal);
        jamMasukAbsen.add(data_absensi[ini].jam_masuk);
        jamPulangAbsen.add(data_absensi[ini].jam_pulang);
        ketAbsen.add(data_absensi[ini].keterangan);
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('y-M-d').format(dateTime);
  }
}

class dataReport {
  String tanggal;
  String jam_masuk;
  String jam_pulang;
  String keterangan;
  String message;
  String status;

  dataReport({this.tanggal, this.jam_masuk, this.jam_pulang, this.keterangan});

  factory dataReport.fromJson(Map<String, dynamic> parsedJson) {
    return dataReport(
        tanggal: parsedJson['present_date'].toString(),
        jam_masuk: parsedJson['in_dtm'].toString(),
        jam_pulang: parsedJson['out_dtm'].toString(),
        keterangan: parsedJson['keterangan'].toString());
  }
}
