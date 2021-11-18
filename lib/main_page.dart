import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime displayDate = DateTime.now();
  dynamic livedDays = 0;

  //初回起動化を確認する
  Future checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = (prefs.getBool('SEEN') ?? false);
    print('$seen after define seen');
    if (seen == false) {
      print('$seen in checkfirstlaunch');
      getselectedDate(context);
      saveFirstLaunch(seen);
    } else {
      print('$seen in checkfirstlaunch');
    }
  }

  //起動情報を保存する
  saveFirstLaunch(bool seen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('SEEN', true);
  }

  //日付を設定する。カレンダーが出てくる
  getselectedDate(BuildContext context) async {
    // Intl.defaultLocale = 'ja_JP';
    // await initializeDateFormatting();
    final pickedDate = await showDatePicker(
      initialDatePickerMode: DatePickerMode.year,
      context: context,
      helpText: '誕生日を教えて下さい',
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(
        () {
          displayDate = pickedDate;
          int year = displayDate.year;
          int month = displayDate.month;
          int day = displayDate.day;
          saveData(year, month, day);
          calcLivedDays(pickedDate);
        },
      );
    }
  }

  //生まれてからの日付を計算する
  Future<String> calcLivedDays(DateTime n) async {
    print('取得したlivedDays = $n');
    livedDays = DateTime.now().difference(n).inDays + 1;
    print('livedDays = $livedDays');
    return livedDays.toString();
  }

  //日付を保存する
  saveData(int year, int month, int day) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('BIRTH_YEAR', year);
    prefs.setInt('BIRTH_MONTH', month);
    prefs.setInt('BIRTH_DAY', day);
    print('$year in saveData');
    print('$month in saveData');
    print('$day in saveData');
  }

  //日付を読み込む
  Future<DateTime> loadDisplayDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int year = prefs.getInt('BIRTH_YEAR') ?? DateTime.now().year;
    int month = prefs.getInt('BIRTH_MONTH') ?? DateTime.now().month;
    int day = prefs.getInt('BIRTH_DAY') ?? DateTime.now().day;
    print('$year in loadDisplayDate');
    print('$month in loadDisplayDate');
    print('$day in loadDisplayDate');
    setState(() {}); //画面に表示するため。暫定。

    String stMonth = '';
    String stDay = '';

    if (month < 10) {
      stMonth = month.toString();
      stMonth = '0' + stMonth;
      print('$stMonth in month digit check');
    }

    if (day < 10) {
      stDay = day.toString();
      stDay = '0' + stDay;
      print('$stDay in month digit check');
    }

    return displayDate = DateTime.parse(
      "${year.toString()}-$stMonth-$stDay",
    );
  }

  @override
  void initState() {
    super.initState();
    checkFirstLaunch();
    loadDisplayDate();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: calcLivedDays(displayDate),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Scaffold(
          backgroundColor: Colors.blueGrey,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueGrey,
            child: const Icon(Icons.calendar_today),
            onPressed: () {
              getselectedDate(context);
            },
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 240,
                    width: 300,
                    color: Colors.white70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'あなたの生まれた日は',
                          style: kTextDecoration,
                        ),
                        Text(
                          DateFormat.yMMMd().format(displayDate),
                          style: kNumberDecoration,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 240,
                    width: 300,
                    color: Colors.white70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'あなたの人生は',
                          style: kTextDecoration,
                        ),
                        Text(
                          '${livedDays.toString()}日目です',
                          style: kNumberDecoration,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
