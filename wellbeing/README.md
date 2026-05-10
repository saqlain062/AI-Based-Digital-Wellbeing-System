# Wellbeing App

This folder contains the Flutter mobile application for **AI Wellbeing**, an MSc Artificial Intelligence project focused on digital wellbeing risk prediction and privacy-preserving on-device inference.

The mobile app consumes the exported model assets produced by the Python research workflow in the project root and presents the prediction results through a user-facing digital wellbeing experience.

## App Scope

The application supports two main usage modes:

- **Smart Tracking**: uses device activity signals such as screen time, app activity, notifications, and app opens when the required Android permissions are available
- **Manual Assessment**: allows the user to provide the required feature values without enabling device usage tracking

The app is designed to keep inference local to the device and to avoid mandatory account creation.

## Main Features

- onboarding and personal setup flow
- AI-based digital wellbeing risk prediction
- manual and smart-tracking input paths
- detailed analysis and explanation-oriented recommendation display
- app activity and category-level usage views
- weekly dashboard insights
- editable profile inputs with recalculation
- local data history and reset flow
- in-app privacy, support, and feedback access

## Model Assets Used by the App

The Flutter app loads these assets from `assets/`:

- `assets/wellbeing_model.onnx`
- `assets/feature_map.json`
- `assets/shap_recommendation_map.json`
- `assets/app_categories.json`

These assets are declared in [pubspec.yaml](/d:/Ms%20AI/Project/archive/wellbeing/pubspec.yaml).

## Key Packages

The app uses Flutter together with:

- `onnxruntime_v2` for local model inference
- `get` for state management and navigation
- `hive_flutter` for local persistence
- `usage_stats` and `flutter_device_apps` for Android usage-based features
- `workmanager` for background smart-tracking refresh
- `flutter_easyloading` for loading state presentation
- `url_launcher` for privacy policy and feedback links

## App Flow

The entry point is [lib/main.dart](/d:/Ms%20AI/Project/archive/wellbeing/lib/main.dart).

High-level launch flow:

1. initialize local storage and smart-tracking services
2. decide whether to show:
   - welcome screen
   - onboarding
   - fresh start flow
   - main navigation
3. load the main application experience

Primary user flow:

1. welcome and onboarding
2. manual input or smart tracking
3. prediction result
4. dashboard and detailed analysis
5. profile, settings, privacy, feedback, and local data management

## Project Structure

Important areas in this Flutter module:

- `lib/controller/`
  - app logic and prediction orchestration
- `lib/services/`
  - model loading, storage, category mapping, smart tracking, and recommendation support
- `lib/view/`
  - screens for onboarding, result views, dashboard, settings, privacy, and support
- `lib/navigation_menu.dart`
  - main in-app navigation
- `assets/`
  - model files, mappings, icons, and static resources

## Running the App

From this folder:

```bash
flutter pub get
flutter run
```

For release build generation:

```bash
flutter build appbundle --release
```

## Android Notes

Some functionality depends on Android-specific usage permissions. When Smart Tracking is enabled, the app may request usage-related access in order to gather device-level behavioural signals.

Manual Assessment remains available when such permissions are not enabled.

## Privacy and Data Handling

The app is intended to follow a privacy-preserving architecture:

- model inference is performed locally on-device
- no mandatory login is required
- app-side insights are stored locally
- smart tracking is optional
- the hosted privacy policy is available at:
  - `https://ai-wellbeing.web.app`

The privacy policy site is maintained separately in the project root under `privacy_policy_site/`.

## Relationship to the Research Workflow

This Flutter module is the deployment-facing companion to the Python research workflow in the project root.

The research-side materials are documented in:

- [../README.md](</d:/Ms AI/Project/archive/README.md>)
- `../digital_wellbeing_ai_model.ipynb`

The root-level documentation explains:

- dataset preparation
- comparative model evaluation
- SHAP explainability
- model export workflow
- project-level research framing

## Current Position

At this stage, the app acts as the mobile delivery layer for the AI Wellbeing project:

- model outputs are integrated into the Flutter experience
- recommendations are linked to explanation-oriented model logic
- dashboard and activity views support the broader digital wellbeing narrative
- exported ONNX assets allow the prediction pipeline to run locally on the device
