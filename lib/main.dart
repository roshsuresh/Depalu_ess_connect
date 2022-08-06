import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:depaul_angamaly/utils/constants.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/LoginPageWeb.dart';
import 'Provider/LoginProvider.dart';
import 'models/activation_model.dart';






 Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
 if (Platform.isAndroid) {
   await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
 }
 SystemChrome.setPreferredOrientations([
   DeviceOrientation.portraitUp,
   DeviceOrientation.portraitDown,
 ]).then((value) => runApp(GjInfoTech()));

 await FlutterDownloader.initialize(
     debug: true
 );
 await Permission.storage.request();
 await Permission.accessMediaLocation.request();

    runApp(GjInfoTech());
 }

class GjInfoTech extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<GjInfoTech> createState() => _GjInfoTechState();
}

class _GjInfoTechState extends State<GjInfoTech> {
  SharedPreferences? prefs;
  _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('activated') != null) {
      activated = true;
    }
  }

  bool? activated;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('activated') != null) {
        activated = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
       // ChangeNotifierProvider(create: (context) => StudentNotification()),
        // ChangeNotifierProvider(create: (context)=>StudentNotificationProvider()),
       // ChangeNotifierProvider(create: (context) => HomeProvider()),
        //ChangeNotifierProvider(create: (context) => StaffNotification()),
      ],
      child: MaterialApp(
        title: 'Ess Connect',
        theme: ThemeData(
          primaryColor:UIGuide.PRIMARY,
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black))),
          // primarySwatch: Colors.deepOrange,
        ),
        // home: MyHomePage(title: 'Flutter Demo Home Page'),
        //routes: routes,
        home: SplashFuturePage(),
        debugShowCheckedModeBanner: false,
        //home : MyHomepage(),
        //home:LoginSecondPage(),
      ),
    );
  }
}


class SplashFuturePage extends StatefulWidget {
  @override
  _SplashFuturePageState createState() => _SplashFuturePageState();
}
class _SplashFuturePageState extends State<SplashFuturePage> {
  void getActivationCode() async{
    String res;
    var headers = {
      'Content-Type': 'application/json'
    };
    var params = {
      "code":"WIOpe",
    };
    var response = await http.post(Uri.parse("${UIGuide.baseURL}/mobileapp/common/get-schooldomain"),
        body: json.encode(params),headers: headers);
    if (response.statusCode==200) {
      var jsonData=json.decode(response.body);
      ActivationModel ac=ActivationModel.fromJson(jsonData);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('baseUrl', ac.subDomain!);
      await prefs.setBool('activated', true);
      print(response.body);
    }else{
      print(response.body);
    }
    //return response.statusCode;
  }


  @override
  void initState() {
    super.initState();
    getActivationCode();
    Timer(Duration(seconds: 3),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) =>
                LoginPageWeb()
            )
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/school.jpg',
                width: 250.0,
                height: 250.0,
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: const [
                  Text("DePaul E.M.H.S. School",style: TextStyle(
                      fontSize: 20
                  ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CircularProgressIndicator(),
                  Text("Loading",style: TextStyle(fontSize:15,color: Colors.blue),)
                ],
              )
            ],
          ),
        ),
      ) ,
    );
  }
}