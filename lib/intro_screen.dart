import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  DateTime setBirthDay = DateTime.now();

  //アプリが初回起動化を確認
  saveHaveOpenFlag(bool openFlag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('SEEN', openFlag);
    print(openFlag);
  }

  openHaveOpenFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    print('intro_screen');
    print('flag test');
    // setBirthDay(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              iconSize: 200,
              color: Colors.white,
              onPressed: () {
                // SharedPreferencesData().getselectedDate(context);
                // Navigator.named
              },
            ),
            const Text(
              '+を押して誕生日を追加する',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
