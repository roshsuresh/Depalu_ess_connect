// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UIGuide {
  static const String ourlogo = "assets/plogo.png";
  static const String essplogo = "assets/essplogo.png";
  static const String notification = "assets/notification.png";
  static const String student = "assets/stud.png";
  static const String pay = "assets/pay.png";
  static const String board = "assets/blackboard.png";
  static const String school = "assets/school1.png";
  static const String homeback = "assets/activation_page.png";
  static const String logout = "assets/logout.png";
  static const String notcheck = "assets/square.svg";
  static const String check = "assets/check-square.svg";
  static const String profile = "assets/Profile.png";


  static const String reportcard = "assets/Reportcard.png";
  static const String baseURL = "https://api.eschoolweb.org/";


  static const Color WHITE = Colors.white;
  static const Color BLACK = Colors.black;
  static const Color THEME_PRIMARY = Color(0XFF575C79);
  static const Color THEME_LIGHT = Color(0XFF8489A8);
  static const Color THEME_DARK = Color(0XFF2D334D);
  static const Color BACKGROUND_COLOR = Color(0XFFAEB2D1);
  static const Color PRIMARY = Color(0XFF36235a);
  static const Color PRIMARY2 = Color(0XFF59081b);
  static const Color PRIMARY3 = Color(0XFFff6699);
  static const Color light_black = Color(0xff292C31);

  static const Color primary4 = Color(0xff17a2b8);
  Widget sizer20 = const SizedBox(
    height: 20,
  );

  // ignore: use_full_hex_values_for_flutter_colors
  static const Color FACEBOOK_COLOR = Color(0xfff3b5998);
}

Future<Map<String, dynamic>> parseJWT() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String? token = pref.getString("accesstoken");
  print(token);
  if (token == null) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginUI()));
    return {};
  } else {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken;
  }
}

// alertAppLogin({required BuildContext context}){
//   return showDialog(
//       context: context,
//       builder: (context)=>Dialog(
//     child: Column(
//       children: [
//         Row(
//           children: [
//             Text('Notification Access'),
//             Text('For notification access you need ')
//           ],
//         )
//       ],
//     ),
//   );
//       }
//   )
// }

enum LoginType { student, guardian, staff }
