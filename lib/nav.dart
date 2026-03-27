import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'data/thot_provider.dart';
import 'presentation/scaffold_with_navbar.dart';
import 'package:thot/presentation/home_screen.dart' as home;
import 'presentation/session_list_screen.dart';
import 'presentation/new_session_screen.dart';
import 'presentation/session_exercises_screen.dart';
import 'presentation/inventory_screen.dart';
import 'package:thot/presentation/add_item_screen.dart' as add_item;
import 'package:thot/presentation/item_detail_screen.dart' as item_detail;
import 'presentation/settings_screen.dart';
import 'presentation/lock_screen.dart';
import 'presentation/set_pin_screen.dart';
import 'package:thot/presentation/onboarding_screen.dart' as onboarding;
import 'presentation/splash_screen.dart';
import 'presentation/pro_screen.dart';
import 'presentation/statistics_screen.dart';
import 'presentation/achievements_screen.dart';
import 'presentation/legal_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final provider = Provider.of<ThotProvider>(context, listen: false);
      final isLockScreen = state.matchedLocation == '/lock';
      final isSetPinScreen = state.matchedLocation == '/set-pin';
      final isOnboardingScreen = state.matchedLocation == '/onboarding';
      final isSplashScreen = state.matchedLocation == '/splash';

      if (!provider.isInitialized && !isSplashScreen) {
        return '/splash';
      }
      
      if (isSplashScreen) {
        return null;
      }
      // If user has not seen onboarding, force them there
      if (!provider.hasSeenOnboarding &&
          !provider.onboardingDismissedForSession &&
          !isOnboardingScreen) {
        return '/onboarding';
      }
      
      // If PIN is enabled and user is not authenticated, redirect to lock screen
      if (provider.hasSeenOnboarding && provider.pinEnabled && !provider.isAuthenticated && !isLockScreen && !isSetPinScreen) {
        return '/lock';
      }
      
      // If user is on lock screen but PIN is disabled or already authenticated, go home
      if (isLockScreen && (!provider.pinEnabled || provider.isAuthenticated)) {
        return '/';
      }
      
      return null;
    },
    routes: [
      // Splash Screen (outside main shell)
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/legal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final chapter = state.uri.queryParameters['chapter'];
          return LegalScreen(initialChapterId: chapter);
        },
      ),
      GoRoute(
        path: '/pro',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black.withValues(alpha: 0.6),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: child,
            );
          },
          child: const ProScreen(),
        ),
      ),
      // Onboarding Screen (outside main shell)
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const onboarding.OnboardingScreen(),
      ),
      // Lock Screen (outside main shell)
      GoRoute(
        path: '/lock',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LockScreen(),
      ),
      // Set PIN Screen (outside main shell)
      GoRoute(
        path: '/set-pin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SetPinScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const home.HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'statistics',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const StatisticsScreen(),
                  ),
                  GoRoute(
                    path: 'achievements',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const AchievementsScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Sessions Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sessions',
                builder: (context, state) => const SessionListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey, // Fullscreen
                    builder: (context, state) {
                      final sessionId = state.uri.queryParameters['sessionId'];
                      return NewSessionScreen(sessionId: sessionId);
                    },
                  ),
                  GoRoute(
                    path: 'exercises',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final sessionId = state.uri.queryParameters['sessionId'];
                      return SessionExercisesScreen(sessionId: sessionId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Inventory Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                builder: (context, state) {
                  final tab = state.uri.queryParameters['tab'];
                  int initialIndex = 0;
                  if (tab == '1') initialIndex = 1;
                  if (tab == '2') initialIndex = 2;
                  return InventoryScreen(initialIndex: initialIndex);
                },
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final itemId = state.uri.queryParameters['itemId'];
                      final itemType = state.uri.queryParameters['itemType'];
                      return add_item.AddItemScreen(
                        itemId: itemId,
                        itemType: itemType,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'detail/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return item_detail.ItemDetailScreen(itemId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Settings Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
