import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'app/theme_provider.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/providers/locale_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFF8FAFC),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final container = ProviderContainer();
  await container.read(authProvider.notifier).init();
  await container.read(localeProvider.notifier).init();
  await container.read(themeProvider.notifier).init();

  // Initialize notifications after auth is loaded
  final authNotifier = container.read(authProvider.notifier);
  final authToken = container.read(authProvider).token;
  if (authToken != null) {
    await NotificationService().initialize(authNotifier);
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const EduNovaApp(),
  ));
}

class EduNovaApp extends ConsumerStatefulWidget {
  const EduNovaApp({super.key});

  @override
  ConsumerState<EduNovaApp> createState() => _EduNovaAppState();
}

class _EduNovaAppState extends ConsumerState<EduNovaApp> {
  final _navKey = GlobalKey<NavigatorState>();
  GoRouter? _observedRouter;

  @override
  void initState() {
    super.initState();
    NotificationService().setNavigatorKey(_navKey);
  }

  @override
  void dispose() {
    _observedRouter?.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    if (!identical(_observedRouter, router)) {
      _observedRouter?.routerDelegate.removeListener(_onRouteChanged);
      router.routerDelegate.addListener(_onRouteChanged);
      _observedRouter = router;
    }

    return MaterialApp.router(
      title: 'EduNova',
      onGenerateTitle: (context) =>
          titleForPath(router.routeInformationProvider.value.uri.path),
      debugShowCheckedModeBanner: false,
      key: _navKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
