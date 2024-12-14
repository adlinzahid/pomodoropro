import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_pro/models/user_model.dart';
import 'package:pomodoro_pro/screens/Homepage/homepage.dart';
import 'package:pomodoro_pro/screens/Homepage/splashscreen.dart';
import 'package:pomodoro_pro/screens/authentication/login_page.dart';
import 'package:pomodoro_pro/services/database.dart';
import 'package:provider/provider.dart';

enum AuthStatus {
  notLoggedIn,
  loggedIn,
  unknown,
}

class OurRoot extends StatefulWidget {
  const OurRoot({super.key});

  @override
  State<OurRoot> createState() => _OurRootState();
}

class _OurRootState extends State<OurRoot> {
  AuthStatus _authStatus = AuthStatus.unknown;
  late String currentUid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    //get the state, check current User, set AuthStatus based on state
    UserModel userStream = Provider.of<UserModel>(context);
    setState(() {
      _authStatus = AuthStatus.loggedIn;
      currentUid = userStream.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget retVal;

    switch (_authStatus) {
      case AuthStatus.notLoggedIn:
        retVal = LoginPage();
        break;
      case AuthStatus.loggedIn:
        retVal = StreamProvider<UserModel>.value(
          value: OurDatabase().streamUser(currentUid),
          initialData: UserModel(
            uid: '',
            email: '',
            fullName: '',
            accountCreated: Timestamp.now(),
          ),
          child: const MyHomePage(),
        );
        break;
      case AuthStatus.unknown:
        retVal = SplashScreen();
        break;
    }
    return retVal;
  }
}
