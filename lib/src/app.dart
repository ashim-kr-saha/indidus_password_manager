import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/dummy_data_progress_page.dart';
import 'screens/home/home_screen.dart';
import 'screens/login_page.dart';
import 'screens/registration_page.dart';

class MyPasswordManagerApp extends ConsumerWidget {
  final int? savedThemeColor;
  final String initialRoute;

  const MyPasswordManagerApp({
    super.key,
    required this.savedThemeColor,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var color = ref.watch(themeNotifierProvider);
    color ??= savedThemeColor;
    color ??= defaultThemeColor;

    if (kDebugMode) {
      print("Theme color code: $color");
    }

    return MaterialApp.router(
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(color),
        ),
      ),
      routerConfig: _router(ref),
      title: 'Indidus Password Manager',
    );
  }

  GoRouter _router(WidgetRef ref) => GoRouter(
        initialLocation: initialRoute,
        routes: [
          GoRoute(
            path: LoginPage.path,
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: RegistrationPage.path,
            builder: (context, state) => const RegistrationPage(),
          ),
          GoRoute(
            path: HomeScreen.path,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: DummyDataProgressPage.path,
            builder: (context, state) => const DummyDataProgressPage(),
          ),
        ],
        redirect: (BuildContext context, GoRouterState state) {
          final authState = ref.read(authProvider);
          final isRegistrationRoute =
              state.uri.toString() == RegistrationPage.path;
          final bool isAuthenticated = authState.isAuthenticated;
          final bool isAuthRoute = state.uri.toString() == LoginPage.path;

          if (!isAuthenticated && isRegistrationRoute) {
            return RegistrationPage.path;
          } else if (!isAuthenticated && !isAuthRoute) {
            return LoginPage.path;
          } else if (isAuthenticated && isAuthRoute) {
            return HomeScreen.path;
          } else {
            return null;
          }
        },
        refreshListenable: _authStream(ref),
      );

  // This is a workaround to refresh the router when the auth state changes
  // This is needed because the auth state is not a stream
  Listenable _authStream(WidgetRef ref) {
    final isAuth = ValueNotifier<AsyncValue<bool>>(const AsyncLoading());
    ref.listen(
      authProvider.select((value) => value.isAuthenticated),
      (_, next) {
        isAuth.value = AsyncValue.data(next);
      },
    );
    return isAuth;
  }
}
