import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/firebase_bootstrap.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/data/user_repository.dart';
import 'features/auth/domain/app_user.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/planner/data/wikimedia_places_repository.dart';
import 'features/planner/data/cloud_planner_store.dart';
import 'features/planner/data/planner_repository.dart';
import 'features/planner/domain/places_repository.dart';
import 'features/planner/presentation/planner_shell.dart';
import 'features/planner/presentation/places_controller.dart';
import 'features/planner/presentation/planner_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  final users = await UserRepository.open();
  final auth = AuthController(users);
  await auth.restoreGoogleSession();
  final planner = await _openPlannerFor(auth.user);
  runApp(TrifyApp(authController: auth, plannerState: planner));
}

Future<PlannerState> _openPlannerFor(AppUser? user) {
  final ownerId = user?.plannerOwnerId ?? 'guest';
  final localStore = PlannerRepository(ownerId: ownerId);
  final firebaseUser = Firebase.apps.isEmpty
      ? null
      : FirebaseAuth.instance.currentUser;
  if (user?.firebaseUid == null || user!.firebaseUid != firebaseUser?.uid) {
    return PlannerState.open(store: localStore);
  }
  return PlannerState.open(
    store: CloudPlannerStore(
      ownerId: user.firebaseUid!,
      localStore: localStore,
    ),
  );
}

class TrifyApp extends StatefulWidget {
  const TrifyApp({
    super.key,
    this.initialThemeMode = ThemeMode.dark,
    this.placesRepository,
    this.authController,
    this.plannerState,
  });
  final ThemeMode initialThemeMode;
  final PlacesRepository? placesRepository;
  final AuthController? authController;
  final PlannerState? plannerState;
  @override
  State<TrifyApp> createState() => _TrifyAppState();
}

class _TrifyAppState extends State<TrifyApp> {
  late PlannerState planner = widget.plannerState ?? PlannerState();
  late String _plannerOwnerId;
  late final places = PlacesController(
    widget.placesRepository ?? WikimediaPlacesRepository(),
  );
  late final appearance = ThemeController(widget.initialThemeMode);
  AuthController? get auth => widget.authController;

  @override
  void initState() {
    super.initState();
    _plannerOwnerId = auth?.user?.plannerOwnerId ?? 'guest';
    auth?.addListener(_switchPlannerForActiveUser);
  }

  @override
  void didUpdateWidget(covariant TrifyApp oldWidget) {
    if (oldWidget.authController != widget.authController) {
      oldWidget.authController?.removeListener(_switchPlannerForActiveUser);
      auth?.addListener(_switchPlannerForActiveUser);
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _switchPlannerForActiveUser() async {
    final ownerId = auth?.user?.plannerOwnerId ?? 'guest';
    if (_plannerOwnerId == ownerId) return;
    _plannerOwnerId = ownerId;
    final next = await _openPlannerFor(auth?.user);
    if (!mounted || _plannerOwnerId != ownerId) {
      next.dispose();
      return;
    }
    final previous = planner;
    setState(() => planner = next);
    await previous.flush();
    previous.dispose();
  }

  @override
  void dispose() {
    auth?.removeListener(_switchPlannerForActiveUser);
    planner.dispose();
    places.dispose();
    appearance.dispose();
    auth?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PlacesScope(
    controller: places,
    child: PlannerScope(
      state: planner,
      child: ThemeScope(
        controller: appearance,
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: appearance,
          builder: (context, mode, _) => MaterialApp(
            title: 'Trify',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            // Switch all surfaces together; no mixed-theme transition frames.
            themeAnimationDuration: Duration.zero,
            locale: const Locale('ru'),
            supportedLocales: const [Locale('ru')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: auth == null
                ? const PlannerShell()
                : AuthScope(
                    controller: auth!,
                    child: AnimatedBuilder(
                      animation: auth!,
                      builder: (context, _) => auth!.user == null
                          ? const AuthScreen()
                          : const PlannerShell(),
                    ),
                  ),
          ),
        ),
      ),
    ),
  );
}
