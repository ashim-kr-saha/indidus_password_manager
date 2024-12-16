import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'src/app.dart';
import 'src/providers/share_pref_provider.dart';
import 'src/rust/frb_generated.dart';
import 'src/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  await RustLib.init();

  int? savedThemeColor = sharedPreferences.getInt(themeColorKey);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      ],
      child: MyPasswordManagerApp(
        savedThemeColor: savedThemeColor,
        initialRoute: LoginPage.path,
      ),
    ),
  );
}

// import 'package:flutter/material.dart';

// import 'src/rust/api/simple.dart';
// import 'src/rust/frb_generated.dart';

// Future<void> main() async {
//   await RustLib.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
//         body: Center(
//           child: Text(
//               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
//         ),
//       ),
//     );
//   }
// }
