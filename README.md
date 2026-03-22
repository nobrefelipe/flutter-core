# core/

> Zero app-specific knowledge. Pure infrastructure. Copy it unchanged to any Flutter project and it works.



## About this architecture

This is not a framework. It's not a package. It's not an opinionated wrapper around someone else's solution.

`core/` is something I built myself — gradually, over several years of shipping Flutter apps and living with the consequences of the decisions I made in them. It grew out of frustration with the state management ecosystem: the churn, the boilerplate, the way third-party solutions solve the demo case perfectly and fall apart at scale. I tried Provider, Riverpod, Bloc, GetX, and combinations of all of them. Each time I found myself fighting the library as much as I was fighting the problem.

So I stopped reaching for packages and started thinking about what I actually needed. The answer was simpler than any of them: a reactive value that rebuilds widgets, a typed result that covers every async state, and a strict separation between data and UI. Everything in `core/` is an expression of those three ideas.

The primitives are small enough to read in an afternoon and opinionated enough to keep a codebase consistent across a team and across years. They have no dependencies outside of Flutter itself. If something doesn't work the way you expect, you can read the source and fix it — there's no black box.


---

This is the single rule that governs everything in this folder. If a file needs to import a feature route, a business model, or any screen — it doesn't belong here. `core/` is the foundation the app is built on, not a part of the app itself.

---

## The problem it solves

Flutter apps tend to rot in a predictable way. State starts as `setState`, then becomes a `ChangeNotifier`, then a `Provider`, then a `Bloc`, and somewhere along the way every widget starts knowing too much. Views call APIs. Controllers hold `BuildContext`. `try/catch` blocks appear in random places. Every feature reinvents the loading/error/success cycle differently.

`core/` solves this by making the right pattern the only easy option. The primitives are designed so that following the architecture takes less code than fighting it.

---

## What's inside

```
core/
  atomic_state/
    atom.dart              # Atom<T> — reactive value with a widget interface
    async_atom.dart        # AsyncAtom<T> — async state with auto-reset on logout
    result.dart            # Result<T> — sealed class for every async outcome
    auth_state.dart        # AuthState sealed hierarchy
  helpers.dart             # Safe JSON parsing + debug utilities
  global_atoms.dart        # authState + keyboardOpened
  env.dart                 # Build-time environment config
  cache/                   # AppCache — SharedPreferences singleton
  http/                    # APIRequest + ResponseInterceptor
  localization/            # LocalizationService + localeAtom
  local_auth/              # AppLifecycleService + BiometricAuthService
  notifications/           # OneSignal infrastructure + NotificationRouter
  form_builder/            # Data-driven form system
  ui/                      # DesignTokens, UIKText, UIKButton, UIKitBottomSheet
  auth_builder.dart        # Auth side effects — never routing
```

---

## The data flow

Every feature in the app follows one pattern — no exceptions.

```
View  →  Controller  →  Service  →  API
              ↓
         atom.emit(result)
              ↓
         View rebuilds
```

- **Views** render atoms and call controller methods. Nothing else.
- **Controllers** orchestrate service calls and manage atom state. No `BuildContext`. No `try/catch`.
- **Services** extend `APIRequest` and return `Result<T>`. No logic — just HTTP calls.
- **Atoms** are the single source of truth for all state.

The beauty of this is that each layer has exactly one job and cannot do another layer's job without actively fighting the types.

---

## Atomic State

The most important part of `core/`. Three files that replace every state management package.

### `Result<T>`

Every async operation in the app returns one of five states:

```dart
Idle()            // nothing has happened yet
Loading()         // request in flight
Success(value)    // data returned — value is typed T
Failure(message)  // something went wrong — message is a human-readable string
Empty()           // request succeeded but there's nothing to show
```

This is a sealed class. The compiler enforces exhaustive handling. You can't forget the error case. You can't forget the empty case. And crucially, there's no way to have "data + error" or "loading + data" — states that are technically impossible are made unrepresentable in the type system.

```dart
// Extract the error without casting
result.errorMessage // returns String? — works regardless of which Failure subtype
```

### `Atom<T>`

For local UI state that doesn't need async lifecycle. A thin wrapper over `ValueNotifier` with two additions: `emit()` for updates, and `call()` so the atom itself is a valid widget builder.

```dart
final activeTab = Atom(0);
final isExpanded = Atom(false);
final searchQuery = Atom('');

// Update from anywhere
activeTab.emit(1);

// Use directly in the widget tree — no ValueListenableBuilder boilerplate
activeTab((tab) => TabIndicator(tab))
isExpanded((_) => const ExpandedIcon(), fallback: const CollapsedIcon())
searchQuery(Text.new)  // constructor reference when widget takes a single positional arg
```

The `call()` syntax is the key insight. The atom is both the data store and the widget boundary. The rebuild scope is exactly the size of the closure — not the whole screen, not a subtree you had to manually wrap in a `Consumer`.

### `AsyncAtom<T>`

For all remote/async data. Wraps `Result<T>` internally, starts as `Idle()`, and is callable as a widget just like `Atom<T>` — but with named parameters for each result state.

```dart
final rewards = AsyncAtom<List<RewardModel>>();

// In the widget tree — only success is required
rewards(
  success: RewardsList.new,       // constructor reference
  loading: RewardsShimmer.new,
  failure: (message) => ErrorText(message, onRetry: controller.load),
)
```

The widget convention matters here. Widgets used as constructor references must accept their value as a single positional argument:

```dart
// This works as a constructor reference — rewards(success: RewardsList.new)
class RewardsList extends StatelessWidget {
  const RewardsList(this.rewards, {super.key});
  final List<RewardModel> rewards;
}
```

**The most important property of `AsyncAtom`:** it self-registers in a global registry the moment it's created. When the user logs out, one call to `resetAllAtoms()` resets every single atom in the app back to `Idle()`. No manual registration. No risk of stale data from a previous session persisting into a new one.

This is why `AsyncAtom` must always be a global variable — never created inside a method or widget. If it were local, it couldn't self-register, and the reset wouldn't reach it.

```dart
// controllers/rewards_controller.dart

final rewards = AsyncAtom<List<RewardModel>>();  // ← global, self-registers

class RewardsController {
  final _service = RewardsService();

  Future<void> load() async {
    rewards.emit(Loading());
    rewards.emit(await _service.getRewards());
  }
}
```

---

## HTTP Layer

### `APIRequest`

The base class for all services. Never instantiated directly — always extended.

It provides five shorthand methods that each handle the full request lifecycle: building the URL, attaching the auth token, running the request, parsing the response, and converting the result into a `Result<T>`.

```dart
class RewardsService extends APIRequest {
  Future<Result<List<RewardModel>>> getRewards() =>
      authGet('/api/rewards', RewardModel.fromJsonToList);

  Future<Result<RewardModel>> getRewardById({required String id}) =>
      authGet('/api/rewards/$id', RewardModel.fromJson);

  Future<Result<String>> createPreOrder({required String id}) =>
      authPost('/api/rewards/$id/pre-order', (data) => Helper.getString(data['message']));
}
```

Arrow syntax only. No `async/await`. No `return`. No braces. A service file is a list of declarations — not imperative code.

### `ResponseInterceptor`

Sits between the raw HTTP response and the `Result<T>` the service returns. Handles every standard API error shape automatically:

| Response shape | Outcome |
|---|---|
| `{ "message": "Unauthenticated." }` | `Failure` + emits `Unauthenticated()` globally |
| `{ "error": "..." }` | `Failure(message)` |
| `{ "message": "..." }` | `Failure(message)` |
| `{ "data": {...} }` | `Success(adapter(data))` |
| `{ "result": {...} }` | `Success(adapter(result))` |
| Empty / malformed | `Failure` |

This logic exists in exactly one place. Services never duplicate it. Controllers never handle raw HTTP errors. When a 401 comes in, `authState` emits `Unauthenticated()` automatically — the router handles the redirect. No controller even sees it.

---

## Auth Lifecycle

### `AuthState`

Four states covering the full auth lifecycle:

```dart
Initial()          // status unknown — triggers checkAuth()
Authenticated()    // session valid
Unauthenticated()  // no session or explicitly signed out
AuthErrorState()   // something went wrong during the check
```

The `Initial` state is the key design decision. When the app starts — or returns from background — `authState` is set to `Initial()`. This triggers a single `checkAuth()` call. Everything else reacts to the outcome. There's no polling, no timers, no manual refresh logic scattered through screens.

### `AuthBuilder`

Wraps the entire app. Listens to `authState` and coordinates side effects — notifications setup, atom reset, token storage. It never routes. GoRouter owns all routing decisions and reacts to `authState` through its `redirect` callback.

The separation is deliberate: `AuthBuilder` handles *what happens when auth changes*, `router.dart` handles *where the user goes*. Mixing these two concerns is one of the most common sources of navigation bugs in Flutter apps.

```
App starts
  → authState emits Initial()
  → AuthBuilder calls checkAuth()
  → Authenticated → store token, set up notifications, run migration
  → Unauthenticated → resetAllAtoms(), tear down notifications
  → GoRouter redirect fires → sends user to correct screen
```

---

## UI Kit

Project specific UI components are defined in `core/ui/`.

### `UIKButton`

Self-manages its loading state. `onTap` always takes `Future<void> Function()` — the button disables and shows a spinner automatically while the future is running. Pass `null` to disable.

```dart
UIKButton.primary(label: 'Save', onTap: () async => controller.save())
UIKButton.secondary(label: 'Cancel', onTap: () async => context.pop())
UIKButton.destructive(label: 'Delete', onTap: () async => controller.delete())
UIKButton.ghost(label: 'Skip', onTap: () async => controller.skip())

// Sizes
UIKButton.primary.large(label: 'Get started', onTap: () async => controller.start())
UIKButton.primary.small(label: 'View', onTap: () async => controller.view())

// Full width, with icon
UIKButton.primary(label: 'Pay', onTap: () async => controller.pay(),
  leftIcon: const Icon(Icons.payment), fullWidth: true)
```

### `UIKText`

A typed text scale. No magic numbers anywhere in the codebase.

```dart
UIKText.pageTitle('My Rewards')
UIKText.pageSubtitle('Redeem your points')
UIKText.h1('Section') // through UIKText.h6('Label')
UIKText.body('Regular copy')
UIKText.small('Fine print')

// Optional params on all variants
UIKText.body('Truncated', maxLines: 2, overflow: TextOverflow.ellipsis)
UIKText.h4('Highlighted', color: DesignTokens.primary)
```

### `UIKitBottomSheet`

Handles the chrome — drag handle, padding, border radius, safe area — so call sites only provide content and actions.

```dart
// Simple info sheet
UIKitBottomSheet.show(context, title: 'Details', content: DetailWidget())

// With actions
UIKitBottomSheet.show(context,
  title: 'Confirm deletion',
  content: DeleteWarning(),
  primaryAction: BottomSheetAction(label: 'Delete', onTap: () async => controller.delete()),
  secondaryAction: BottomSheetAction(label: 'Cancel', onTap: () async => context.pop()),
)

// Multi-step flow
UIKitBottomSheet.showPaged(context, pages: [
  BottomSheetPage(title: 'Step 1', content: Step1()),
  BottomSheetPage(title: 'Step 2', content: Step2()),
])
```

### `DesignTokens`

All colours, spacing, border radii, and font sizes as named constants. No magic numbers anywhere in the codebase. Theme-aware colours are available via a `ThemeData` extension: `Theme.of(context).primaryColor`, `.surfaceColor`, `.onSurfaceColor` etc.

---

## Helper

Safe JSON parsing utilities. The rule is simple: never cast raw JSON. Always use `Helper`.

```dart
Helper.getString(json['name'])           // '' on null/wrong type
Helper.getStringOrNull(json['bio'])      // null on null/wrong type
Helper.getInt(json['count'])             // 0 on failure
Helper.getDouble(json['amount'])         // 0.0 on failure
Helper.getBool(json['is_active'])        // handles true, "true", 1, "1"
Helper.getList(json['items'])            // [] on failure
Helper.getMap(json['metadata'])          // {} on failure
```

A model that uses raw casts will crash on any unexpected API response. A model that uses `Helper` degrades gracefully — empty string instead of crash, zero instead of crash, empty list instead of crash. The failure is visible and handleable rather than a fatal exception.

---

## Form Builder

An API-driven form system. Field definitions are Dart maps. The UI renders itself from the data — no `TextFormField` in views, no form logic scattered across screens.

```dart
// Defined once in the controller file
final loginFields = FormFieldAdapter().fromJsonToList([
  {"attribute": "email",    "label": "Email",    "type": "email",    "required": true},
  {"attribute": "password", "label": "Password", "type": "password", "required": true},
]);

// Rendered in the view — zero form logic here
FormFieldsBuilderPage(
  formFields: loginFields,
  ctaLabel: 'Sign in',
  onSubmit: (dto) async => controller.login(dto),
)
```

Supports conditional fields (show field B only when field A has a specific value), pre-filling from an existing model, and a full standalone page template with an AppBar.

Supported types: `text`, `email`, `number`, `password`, `select`, `radio`, `address_lookup`, `picture`. Unknown types fall back to `text` — fields never silently disappear.

---

## Notifications

Push notification infrastructure via OneSignal. The key design: `NotificationRouter` lives in `core/` but has zero hardcoded routes. Routes are injected from outside via `configure()` — `core/` stays decoupled from the app's route constants.

```dart
// Wired once in AuthBuilder after Authenticated
NotificationRouter.configure({
  NotificationType.newMessage: '/messages',
  NotificationType.paymentReceived: '/home',
});
```

Notification type metadata — icon, colour — lives on the enum as getters. No utility class needed. `notification.type.icon` and `notification.type.color` work everywhere.