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
  int livedDays = 0;

  //日付を取得する FABを押したら出る
  getselectedDate(BuildContext context) async {
    // Intl.defaultLocale = 'ja_JP';
    // await initializeDateFormatting();
    final pickedDate = await showDatePicker(
      initialDatePickerMode: DatePickerMode.year,
      context: context,
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

          // int lived = calculateLivedDays(pickedDate);
          // livedDays = lived;
        },
      );
    }
  }

  //生まれてからの日付を計算する
  calcLivedDays(DateTime n) {
    print('取得したlivedDays = $n');
    livedDays = DateTime.now().difference(n).inDays + 1;
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
  loadDisplayDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int year = prefs.getInt('BIRTH_YEAR') ?? 1996;
    int month = prefs.getInt('BIRTH_MONTH') ?? 1;
    int day = prefs.getInt('BIRTH_DAY') ?? 23;
    print('$year in loadDisplayDate');
    print('$month in loadDisplayDate');
    print('$day in loadDisplayDate');
    setState(() {}); //画面に表示するため。暫定。
    return displayDate = DateTime.parse(
      "${year.toString()}-${month.toString()}-${day.toString()}",
    );
  }

  @override
  void initState() {
    super.initState();
    loadDisplayDate();
    setState(() {
      calcLivedDays(displayDate);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      '$livedDays日目です',
                      style: kNumberDecoration,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey,
                        onPrimary: Colors.white,
                      ),
                      onPressed: () {
                        // setState(() {});
                        setState(
                          () {
                            calcLivedDays(displayDate);
                          },
                        );
                      },
                      child: const Text('計算する'),
                    ),
                  ],
                ),
              ),
            ),

            // Text()
          ],
        ),
      ),
    );
  }
}
