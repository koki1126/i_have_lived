import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    print('初回起動確認 : $seen');
    if (!seen) {
      getselectedDate(context);
      saveFirstLaunch(seen);
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
      locale: const Locale('ja'),
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
    } else {
      stMonth = month.toString();
    }

    if (day < 10) {
      stDay = day.toString();
      stDay = '0' + stDay;
    } else {
      stDay = day.toString();
    }

    return displayDate = DateTime.parse(
      "${year.toString()}-$stMonth-$stDay",
    );
  }

  final BannerAd myBanner = BannerAd(
    size: AdSize.banner,
    adUnitId: 'ca-app-pub-9425623246062001/8288374356', //本番
    // adUnitId: 'ca-app-pub-3940256099942544/6300978111', //テスト用
    listener: const BannerAdListener(),
    request: const AdRequest(),
  );

  loadingAd() async {
    await myBanner.load();
  }

  //ローカル通知(Android)
  Future<void> notify() {
    final flnp = FlutterLocalNotificationsPlugin();
    return flnp
        .initialize(
          InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        )
        .then((_) => flnp.show(
            0,
            'これはテスト広告です',
            'あなたの○○日目の人生が始まりました！',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'channel_id',
                'channel_name',
              ),
            )));
  }

  @override
  void initState() {
    super.initState();
    loadingAd();
    notify();
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
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                DateFormat.y('ja').format(displayDate),
                                style: kNumberDecoration,
                              ),
                              Text(
                                DateFormat.MMMd('ja').format(displayDate),
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
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: AdWidget(ad: myBanner),
                  width: myBanner.size.width.toDouble(),
                  height: myBanner.size.height.toDouble(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
