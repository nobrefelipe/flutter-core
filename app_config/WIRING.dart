// HOW TO WIRE IT — not a runnable file, reference only

// ─── 1. auth_builder.dart ─────────────────────────────────────────────────────
//
// After Authenticated:
//
//   case Authenticated():
//     await appConfigController.load();
//
//     // Register custom handlers for non-standard routes
//     AppNavigator.registerCustomHandler(
//       'intercom',
//       (context, item) async => IntercomHandler().openMessenger(),
//     );
//     AppNavigator.registerCustomHandler(
//       'kiosk',
//       (context, item) async => context.push('/kiosk', extra: item.config),
//     );
//
// After Unauthenticated:
//
//   case Unauthenticated():
//     appConfigController.onLogout(); // clears nav handlers
//     resetAllAtoms();                // resets appConfig + all other atoms

// ─── 2. router.dart — redirect based on appConfig ────────────────────────────
//
//   redirect: (context, state) {
//     final auth   = authState.value;
//     final config = appConfig.value;
//
//     if (auth is Unauthenticated) return '/login';
//     if (auth is Authenticated) {
//       if (config is Loading || config is Idle) return '/loader';
//       if (config is Failure)                   return '/config-error';
//       if (config is Success) {
//         // Let the user through — their navigation is ready
//         return null;
//       }
//     }
//     return null;
//   }

// ─── 3. Bottom nav bar — renders from config ─────────────────────────────────
//
//   appConfig(
//     loading: () => const AppLoaderScreen(),
//     failure: (msg) => ConfigErrorScreen(onRetry: appConfigController.reload),
//     success: (config) => AppShell(navItems: config.navigation),
//   )

// ─── 4. AppShell — renders tabs from config ───────────────────────────────────
//
//   class AppShell extends StatelessWidget {
//     final List<NavItem> navItems;
//
//     @override
//     Widget build(BuildContext context) {
//       return Scaffold(
//         body: router.currentRoute,
//         bottomNavigationBar: BottomNavigationBar(
//           items: navItems.map((item) => BottomNavigationBarItem(
//             icon: AppIcons.resolve(item.icon),
//             label: item.label,
//           )).toList(),
//           onTap: (index) => navItems[index].navigate(context, forRoot: false),
//         ),
//       );
//     }
//   }

// ─── 5. Menu screen — renders links from a NavItem ───────────────────────────
//
//   final menuItem = appConfigController.current?.findByRoute('app-menu');
//
//   ListView(
//     children: menuItem?.links.map((link) => ListTile(
//       title: UIKText.body(link.label),
//       onTap: () => link.navigate(context),
//     )).toList() ?? [],
//   )
