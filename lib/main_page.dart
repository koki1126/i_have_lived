import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime displayDate = DateTime.now();
  dynamic livedDays = 0;
  DateTime now = DateTime.now();

  //日付を取得する
  getselectedDate(BuildContext context) async {
    Intl.defaultLocale = 'ja_JP';
    await initializeDateFormatting('ja_JP');
    final selectedDate = await showDatePicker(
      initialDatePickerMode: DatePickerMode.year,
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(
        () {
          displayDate = selectedDate;
          dynamic lived = now.difference(selectedDate).inDays + 1;
          livedDays = lived;
        },
      );
    }
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
