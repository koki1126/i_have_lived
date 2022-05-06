import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

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

  //Admobの設定
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

  //毎日通知
  Future<tz.TZDateTime> scheduleDaily(Time time) async {
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.getLocation('Asia/Tokyo'));
    //UTC→JST は UTC + 9
    //デイリー通知
    final scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );
    return scheduleDate.isBefore(now)
        ? scheduleDate.add(const Duration(days: 1))
        : scheduleDate;
  }

  //ローカル通知(Android)
  Future<void> notify() async {
    // await loadDisplayDate();
    final flnp = FlutterLocalNotificationsPlugin();

    return flnp
        .initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        )
        .then(
          (_) => flnp.zonedSchedule(
            0,
            '☀おはようございます☀',
            '$livedDays日目の人生が始まりました！',
            tz.TZDateTime.now(tz.UTC).add(
              Duration(seconds: 1),
            ),
            // scheduleDaily(const Time(21, 14, 00)),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'channnel_id',
                'channel_name',
              ),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          ),
        );
  }

  @override
  void initState() {
    super.initState();
    loadingAd();
    notify();
    checkFirstLaunch();
    loadDisplayDate();
    // notify();
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
                    mainAxisAlignment: MainAxisAlignment.center,
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
              // Expanded(
              //   child: Container(
              //     alignment: Alignment.bottomLeft,
              //     child: AdWidget(ad: myBanner),
              //     width: myBanner.size.width.toDouble(),
              //     height: myBanner.size.height.toDouble(),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
