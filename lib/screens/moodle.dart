import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitask/constants.dart';
import 'package:vitask/api.dart';
import 'package:vitask/database/Moodle_DAO.dart';
import 'package:vitask/database/MoodleModel.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

class Moodle extends StatefulWidget {
  Moodle(this.reg, this.appNo, this.moodle);
  Map<String, dynamic> moodle;
  final String reg, appNo;
  @override
  _MoodleState createState() => _MoodleState();
}

class _MoodleState extends State<Moodle> {
  List<dynamic> assignments;
  bool refresh = false;
  var r, p, a;
  String updatedText = "";

  @override
  void initState() {
    getData();
    updateAssignments();
    super.initState();
  }

  void getData() {
    assignments = [];
    if (widget.moodle != null) {
      for (var i = 0; i < widget.moodle["Assignments"].length; i++) {
        assignments.add(widget.moodle["Assignments"][i]);
      }
    }
  }

  void updateAssignments() async {
    updatedText = " ";
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MMMM-dd-HH-mm');
    String update = formatter.format(now);
    List<String> updated = update.split('-');
    updatedText = updated[2] +
        " " +
        updated[1].substring(0, 3) +
        " " +
        updated[3] +
        ":" +
        updated[4];
    r = widget.reg;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    p = prefs.getString("moodle-password");
    a = widget.appNo;
    String url = "https://vitask.me/api/moodle/sync";
    API api = API();
    Map<String, String> data = {"token": a};
    Map<String, dynamic> moodleData = await api.getAPIData(url, data);
    if (moodleData != null) {
      widget.moodle = moodleData;
      MoodleData m = MoodleData(r + "-moodle", moodleData);
      MoodleDAO().deleteStudent(m);
      MoodleDAO().insertMoodleData(m);
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Color.fromRGBO(13, 50, 77, 100),
              Color.fromRGBO(0, 0, 10, 10)
            ])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Moodle'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                    children: assignments.map((e) {
                  int i = assignments.indexOf(e) + 1;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.indigo,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(9),
                    child: Column(
                      children: <Widget>[
                        MaterialButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: Card(
                            color: Colors.transparent,
                            elevation: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
//                                    Row(
//                                      children: <Widget>[
//                                        Icon(FontAwesomeIcons.graduationCap,
//                                            size: 20, color: Colors.indigo),
                                      AutoSizeText(
                                        i.toString() + ". " + e["course"],
                                        maxFontSize: 18,
                                        minFontSize: 16,
                                        maxLines: 10,
                                        //textAlign: TextAlign.center,
                                      ),
//                                      ],
//                                    ),
                                      SizedBox(height: 8),
                                      AutoSizeText(
                                        e["name"] + ".",
                                        maxLines: 10,
                                        maxFontSize: 17,
                                        minFontSize: 15,
                                        //textAlign: TextAlign.start,
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: <Widget>[
//                                        Icon(FontAwesomeIcons.clock,
//                                            size: 20, color: Colors.indigo),
//                                        SizedBox(width: 8),
                                          Texts(
                                              "Date: " +
                                                  e["time"]
                                                      .split(' ')[0]
                                                      .toString(),
                                              14),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Texts(
                                          "Time: " +
                                              e["time"]
                                                  .split(' ')[1]
                                                  .toString(),
                                          14),
                                      SizedBox(height: 4),
                                    ],
                                  ),
                                ),
//                              SizedBox(width: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Texts("Last Updated On: " + updatedText, 14))
            ],
          ),
        ),
      ),
    );
  }
}
