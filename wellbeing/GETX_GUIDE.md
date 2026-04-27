## GetX Get.put() vs Get.find() - Explanation

### The Problem You Experienced

When you skipped onboarding, the app tried to use a controller that was never registered, causing `Get.find()` to fail.

### Why Get.find() Failed

```dart
// ❌ FAILS if controller not registered
final controller = Get.put(OnboardingController());
// Error: "Controller not found"
```

`Get.find()` **only works if the controller is already registered** somewhere in your app. If it's not, it throws an error.

### Why Get.put() Worked

```dart
// ✅ ALWAYS works
final controller = Get.put(OnboardingController());
// Registers AND returns the controller
```

`Get.put()` **registers the controller first, then returns it**. If called multiple times, it doesn't duplicate (reuses the existing instance by default).

---

## When to Use Each

| Pattern | Use Case | Risk |
|---------|----------|------|
| `Get.put()` | Register a new controller | Can create duplicates if called multiple times |
| `Get.find()` | Get an already-registered controller | Fails if controller doesn't exist |
| `Get.putIfAbsent()` | Register only if not exists | Safe but slightly slower |

---

## Best Practice for Your App

**For controllers used across multiple screens**, use dependency injection in `main()` or a separate service:

```dart
void setupControllers() {
  Get.put(AIController());
  Get.put(OnboardingController());
  Get.put(UserController());
  // All controllers are pre-registered
}
```

Then throughout the app, use `Get.find()` safely.

**For one-time controllers**, use `Get.put()` in that specific screen.

---

## Your Current Codebase Issue

Your `permission_screen.dart` tries to find `OnboardingController`:

```dart
final c = Get.put(OnboardingController());  // ❌ Fails if skipped onboarding
```

**Solution**: Always register it first.

In `onboarding_screen.dart`:
```dart
final controller = Get.put(OnboardingController());  // ✅ Correct
```

The issue is that `permission_screen` assumes `OnboardingController` is already registered, but it only exists if you didn't skip onboarding.

---

## Recommended Fix

Move to environment-based registration so all controllers exist from app start, or check before finding:

```dart
// Safe way
final c = Get.isRegistered<OnboardingController>()
    ? Get.put(OnboardingController())
    : null;
```

OR pre-register all in `main()`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.instance.init();

  // Pre-register all controllers
  Get.put(AIController());
  Get.put(OnboardingController());
  // Now Get.find() will always work

  runApp(const MyApp(initialScreen: initialScreen));
}
```
