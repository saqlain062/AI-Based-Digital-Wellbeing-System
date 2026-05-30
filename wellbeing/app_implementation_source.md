# MSc AI Implementation Source Document

This document summarizes the current implementation using only material directly available in the project files inspected during analysis:

- Flutter application source code under `wellbeing/`
- Android native integration under `wellbeing/android/`
- Python experimentation notebook `digital_wellbeing_ai_model.ipynb`
- exported ONNX and feature-map files in the project root
- deployed app assets under `wellbeing/assets/`

Proposal/dissertation draft files were not found in the currently accessible project files. Additional screenshot files were not found beyond application assets and icons, so figure recommendations below are based on implemented screens and notebook outputs.

## 1. Project Overview

The project implements a digital wellbeing prototype that estimates smartphone overuse risk from behavioural and self-reported features, then presents a local explanation-oriented recommendation to support self-regulation. The implementation combines a Flutter mobile application, Android usage data collection, offline Python model experimentation, ONNX export, and on-device inference.

The current design emphasizes a privacy-preserving architecture:

- the model is executed locally in the app rather than through a remote prediction API
- onboarding/profile data and analysis history are stored locally with Hive
- the user can choose between permission-based smart tracking and manual input
- no login system was found in the current implementation
- Firebase, analytics SDKs, and cloud-backed inference were not found in the current implementation

The behavioural objective is not framed in the code as a medical diagnosis workflow. Instead, the prototype focuses on:

- digital habit monitoring
- smartphone overuse risk prediction
- behaviour-linked recommendations
- self-reflection and self-regulation support

Relevant files:

- `lib/main.dart` - `MyApp`, `_determineInitialScreen()` - application entry and startup flow
- `lib/controller/ai_controller.dart` - `AIController` - local inference, recommendation generation, and persistence
- `digital_wellbeing_ai_model.ipynb` - iterative experimentation, comparison, explainability, and export workflow

[INSERT FIGURE HERE - high-level system overview diagram]  
Suggested chapter location: Methodology chapter, after the project overview subsection.

## 2. Flutter Application Architecture

### Folder structure

The Flutter implementation is organized primarily as follows:

- `lib/controller/` - GetX controllers for inference, onboarding, and permissions
- `lib/services/` - usage collection, categories, storage, model support, permissions, scheduling, and recommendation services
- `lib/view/` - application screens and flows
- `lib/widget/` - reusable UI widgets and dialogs
- `lib/models/` - app model classes
- `assets/` - deployed ONNX model, feature map, recommendation map, category map, icons, and images
- `android/` - Android manifest, Gradle configuration, and native Kotlin method-channel logic

### Navigation architecture

The app uses `GetMaterialApp` rather than a named-route table.

File:

- `lib/main.dart` - `MyApp`

The startup screen is selected by `_determineInitialScreen()` using Hive flags:

- `needsFreshStart` -> `FreshStartScreen`
- `onboardingCompleted` -> `NavigationMenu`
- `hasSeenWelcome` -> `OnboardingScreen`
- otherwise -> `WelcomeScreen`

The main authenticated-style shell is not a login shell; it is a bottom-navigation container:

- `lib/navigation_menu.dart` - `NavigationMenu`

This shell uses an `IndexedStack` to preserve page state across tabs. The four tab roots are:

- `ResultScreen`
- `AnalyticsScreen`
- `ContactScreen`
- `UpgradedSettingScreen`

Back behaviour is customized:

- if the current tab is not the first tab, back returns to tab 0
- if already on tab 0, an exit dialog is shown

### Main screens

Core user-facing screens currently found:

- `lib/view/welcome_screen.dart` - `WelcomeScreen`
- `lib/view/onboarding_screen.dart` - `OnboardingScreen`
- `lib/view/permission_screen.dart` - `PermissionScreen`
- `lib/view/manual_estimation_screen.dart` - `ManualEstimationScreen`
- `lib/view/wellbeing_view.dart` - `ResultScreen`
- `lib/view/dashboard/analytics_screen.dart` - `AnalyticsScreen`
- `lib/view/dashboard/ai_analysis_screen.dart` - `AIAnalysisScreen`
- `lib/view/app_details_screen.dart` - `AppDetailsScreen`
- `lib/view/dashboard/usage_report_screen.dart` - `UsageReportScreen`
- `lib/view/setting/setting_upgrade_screen.dart` - `UpgradedSettingScreen`
- `lib/view/setting/profile_screen.dart` - `ProfileScreen`
- `lib/view/setting/data_management_screen.dart` - `DataManagementScreen`
- `lib/view/category_screen.dart` - `CategoryScreen`
- `lib/view/contact_screen.dart` - `ContactScreen`
- `lib/view/setting/privacy_policy_screen.dart` - `PrivacyPolicyScreen`
- `lib/view/setting/feedback_screen.dart` - `FeedbackScreen`
- `lib/view/setting/terms_of_service_screen.dart` - `TermsOfServiceScreen`
- `lib/view/fresh_start_screen.dart` - `FreshStartScreen`

`lib/view/dashboard/history_screen.dart` exists, but it is not part of the current main navigation flow and contains example-style static content rather than the main active analytics path.

### GetX state management and dependency injection

The app uses GetX for:

- dependency injection
- observable state
- reactive UI updates
- navigation
- transient messaging

Relevant implementation:

- `lib/main.dart` - `Get.put(AIController(), permanent: true)`
- `Obx`-driven UI in result, dashboard, and settings-related screens
- `Get.to`, `Get.offAll`, `Get.back`, `Get.snackbar`

### Controllers

#### `AIController`

File: `lib/controller/ai_controller.dart`  
Class: `AIController`

Responsibilities:

- load the ONNX model
- validate the deployed feature-order asset
- store the canonical 12-feature vector
- load saved profile and previous analysis
- trigger usage-based feature collection
- run local inference
- derive risk category and confidence proxy values
- generate recommendation output
- persist latest analysis and local history

Important functions:

- `_initModel()` - initializes ONNX runtime and loads `assets/wellbeing_model.onnx`
- `_validateFeatureMap()` - validates `assets/feature_map.json`
- `_loadSavedProfile()` - loads persisted onboarding/profile values
- `_loadSavedAnalysis()` - restores latest result state
- `setFeature()` - writes to the canonical feature vector
- `setUsageData()` - maps manual/smart usage signals to canonical model features
- `loadUsage()` - calls `UsageFeatureService.getUsageFeatures()`
- `runInference()` - performs local ONNX inference
- `_generateRecommendation()` - executes rule-based recommendation logic
- `_saveAnalysis()` - persists result snapshot and history
- `resetLocalState()` - clears controller-level state

#### `OnboardingController`

File: `lib/controller/onboarding_controller.dart`  
Class: `OnboardingController`

Responsibilities:

- holds onboarding form state
- stores age, gender, sleep, work/study, stress, academic impact, and manual estimates
- persists onboarding/profile values to Hive

#### `PermissionController`

File: `lib/controller/permission_controller.dart`  
Class: `PermissionController`

Responsibilities:

- delegates usage-access checks and requests through `PermissionService`

#### `UserInputController`

File: `lib/controller/user_controller.dart`  
Class: `UserInputController`

Not found in the current active navigation or inference flow.

### Services

Important service classes currently found:

- `lib/services/usage_feature_service.dart` - `UsageFeatureService`
- `lib/services/category_service.dart` - `CategoryService`
- `lib/services/recommendation_engine.dart` - `RecommendationEngine`
- `lib/services/hive_service.dart` - `HiveService`
- `lib/services/smart_tracking_service.dart` - `SmartTrackingService`
- `lib/services/permission_service.dart` - `PermissionService`
- `lib/services/permission_lifecycle_service.dart` - `PermissionLifecycleService`
- `lib/services/notification_service.dart` - `NotificationService`
- `lib/services/ai_service.dart` - `AIService`

`AIService` performs ONNX inference, but the main app flow currently uses `AIController` directly rather than routing predictions through `AIService`.

### Widgets

Reusable widget structures directly involved in onboarding and shell UI include:

- `lib/view/onboarding/basic_info_widget.dart`
- `lib/view/onboarding/lifestyle_widget.dart`
- `lib/view/onboarding/behavior_widget.dart`
- `lib/widget/dialogbox.dart`
- `lib/view/dashboard/ai_module_widgets.dart`

[INSERT FIGURE HERE - Flutter screen/navigation map]  
Suggested chapter location: Implementation chapter, after the Flutter architecture subsection.

## 3. Android Data Collection Pipeline

The smart-tracking path combines Flutter-side services, Android usage permission checks, installed-app inspection, and a native Kotlin method channel.

### Usage permission flow

The main Android permission is:

- `android.permission.PACKAGE_USAGE_STATS`

Declared in:

- `android/app/src/main/AndroidManifest.xml`

Permission handling is implemented in:

- `lib/services/permission_service.dart`
  - `hasUsagePermission()`
  - `requestUsagePermission()`
  - `ensureUsagePermission()`
- `lib/services/permission_lifecycle_service.dart`
  - monitors lifecycle resume after the user returns from settings
- `lib/view/permission_screen.dart`
  - presents Smart Tracking vs Manual Input

The permission flow is:

1. user selects Smart Tracking
2. app checks usage permission
3. if missing, it opens the Android usage-access settings
4. lifecycle service checks again when the app resumes
5. if granted, the app loads usage features and runs inference

### UsageStatsManager / UsageStats usage

Flutter-side usage queries are performed in:

- `lib/services/usage_feature_service.dart` - `UsageFeatureService.getUsageFeatures()`

The implementation uses:

- `usage_stats` package
- `FlutterDeviceApps.listApps(includeSystem: false, onlyLaunchable: true)`
- `UsageStats.checkUsagePermission()`
- `UsageStats.queryUsageStats(start, end)`

The current time window for the main aggregation is:

- approximately the previous 3 days

The service constructs a package-to-foreground-time map from `totalTimeInForeground`, handling both integer and string representations.

### Category detection logic

App category mapping is performed by:

- `lib/services/category_service.dart` - `CategoryService`

Workflow:

1. load category map from `assets/app_categories.json`
2. migrate any stored `"Unknown"` values to `"Other"`
3. resolve category in this order:
   - user override from Hive
   - exact package match in the asset map
   - partial-key match
   - fallback `"Other"`

The app includes a category override interface:

- `lib/view/category_screen.dart`

### Screen-time aggregation

`UsageFeatureService.getUsageFeatures()` aggregates:

- total foreground time across non-system launchable apps
- social-media foreground time when category is `Social`
- gaming foreground time when category is `Game`

System packages are filtered when the package name:

- starts with `com.android`
- starts with `com.google.android`
- contains `mediatek`

### Social-media and gaming usage calculation

The implementation does not identify "social" or "gaming" through Android's official semantic labels. Instead, those values depend on the local category classification described above. Foreground time is summed only for apps currently assigned to the relevant local category.

### Weekend usage calculation

Weekend usage is approximated in:

- `UsageFeatureService.getUsageFeatures()`

The implementation uses a simplified recent-period query:

- last 2 days from the current timestamp

This is stored as:

- `weekend_screen_hours` in the Flutter service result
- then mapped to canonical `weekend_screen_time` in `AIController.setUsageData()`

### App-open approximation logic

App-open count is not derived from exact open-event logs.

Native implementation:

- `android/app/src/main/kotlin/com/saqlain/wellbeing/MainActivity.kt`
  - `getDailyAppOpens()`

Current logic:

- query `UsageStatsManager.INTERVAL_DAILY`
- count apps with `totalTimeInForeground > 0`
- clamp the result into `10..200`
- return fallback `30` on failure

This is an approximation of device interaction breadth rather than an exact app-open counter.

### Notification approximation logic

Notification count is also approximate.

Native implementation:

- `MainActivity.kt` - `getDailyNotificationCount()`

Current logic:

- query daily usage stats
- estimate launches from `totalTimeInForeground / 60000`
- derive a rough notification estimate from that value
- clamp to `20..100`
- return fallback `50` on failure

The code comment explicitly states that real notification access would require `NotificationListenerService`, which is not implemented.

### MethodChannel integration

The native bridge is:

- channel name: `com.wellbeing.notifications`

Flutter caller:

- `lib/services/notification_service.dart`

Native receiver:

- `android/app/src/main/kotlin/com/saqlain/wellbeing/MainActivity.kt`

Exposed native methods:

- `getDailyNotificationCount`
- `getDailyAppOpens`

### Exact telemetry vs approximated metrics

Implemented as direct usage-derived signals:

- foreground-time-based total screen use
- category-derived social-media hours
- category-derived gaming hours
- recent-period weekend usage approximation

Implemented as approximations:

- notification count
- app-open count

Exact OS-level notification event logging was not found in the current implementation. Exact app-open event logging was not found in the current implementation.

### Android telemetry limitations

The current Android telemetry pipeline is shaped by:

- dependency on user-granted usage-access permission
- category accuracy being partly dependent on a local package-category map
- notification/app-open values being approximate rather than event-level
- WorkManager background execution depending on Android runtime conditions

[INSERT FIGURE HERE - Android data collection pipeline]  
Suggested chapter location: Methodology chapter, in the data collection subsection.

## 4. AI Model Training Pipeline

The model experimentation workflow is documented in:

- `../digital_wellbeing_ai_model.ipynb`

The notebook is structured as an iterative process rather than a single-step pipeline. It preserves:

- an initial Random Forest prototype
- early SHAP analysis
- recommendation experimentation
- prototype ONNX export
- later comparative evaluation
- XGBoost explainability
- XGBoost ONNX export and parity verification

### Dataset structure

The dataset file used in the notebook is:

- `../Smartphone_Usage_And_Addiction_Analysis_7500_Rows.csv`

Observed CSV header:

- `transaction_id`
- `user_id`
- `age`
- `gender`
- `daily_screen_time_hours`
- `social_media_hours`
- `gaming_hours`
- `work_study_hours`
- `sleep_hours`
- `notifications_per_day`
- `app_opens_per_day`
- `weekend_screen_time`
- `stress_level`
- `academic_work_impact`
- `addiction_level`
- `addicted_label`

Saved notebook output reports:

- full dataset shape: `(7500, 16)`
- feature matrix shape: `(7500, 12)`
- target vector shape: `(7500,)`

### Label logic

The notebook uses:

- `y = data['addicted_label']`

Custom label-generation logic was not found in the current notebook. The target label is treated as part of the source CSV.

### Preprocessing order

The notebook preprocessing sequence currently found is:

1. load CSV with `pd.read_csv(...)`
2. inspect dataset head, schema, statistics, and missing values
3. encode categorical values using pandas category codes:
   - `gender`
   - `stress_level`
   - `academic_work_impact`
4. select the 12 modelling features
5. split into train and test sets with `train_test_split(test_size=0.2, random_state=42)`

Important implementation details:

- the train/test split is not stratified in the current notebook code
- no global feature scaling is applied before all models
- feature scaling is used only inside the Logistic Regression pipeline

Relevant notebook cells:

- preprocessing: cell 22
- feature set definition: cell 25
- train/test split: cell 27

### Behavioural feature engineering

The selected 12-feature set is:

1. `age`
2. `gender`
3. `daily_screen_time_hours`
4. `social_media_hours`
5. `gaming_hours`
6. `work_study_hours`
7. `sleep_hours`
8. `notifications_per_day`
9. `app_opens_per_day`
10. `weekend_screen_time`
11. `stress_level`
12. `academic_work_impact`

This feature design combines:

- usage-based behavioural indicators
- routine and self-regulation indicators
- personal profile/context variables

### Initial Random Forest experimentation

The early prototype model is:

- `RandomForestClassifier()`

Relevant notebook cell:

- cell 31

Saved notebook output reports:

- prototype hold-out accuracy: `0.932`

Prototype evaluation output:

- class `0` precision `0.86`, recall `0.92`, F1 `0.89`
- class `1` precision `0.97`, recall `0.94`, F1 `0.95`

This early stage is followed immediately by confusion-matrix analysis, feature importance review, and SHAP exploration.

### Comparative evaluation workflow

The focused comparison stage is defined in notebook cells 69 to 100.

Compared models:

- `Logistic Regression`
  - implemented as `Pipeline([StandardScaler(), LogisticRegression(...)])`
- `Random Forest`
  - `RandomForestClassifier(n_estimators=300, random_state=42, n_jobs=-1)`
- `XGBoost`
  - `XGBClassifier(...)` with 300 estimators, max depth 5, learning rate 0.05, subsample 0.9, and `colsample_bytree=0.9`

Evaluation metrics used:

- accuracy
- precision
- recall
- F1-score
- ROC-AUC
- average single-sample inference latency

Saved hold-out comparison output:

| Model | Accuracy | Precision | Recall | F1 | ROC-AUC | Avg latency (ms) |
|---|---:|---:|---:|---:|---:|---:|
| XGBoost | 0.9260 | 0.9516 | 0.9416 | 0.9466 | 0.9876 | 2.2937 |
| Random Forest | 0.9247 | 0.9559 | 0.9349 | 0.9453 | 0.9875 | 46.1623 |
| Logistic Regression | 0.8927 | 0.9201 | 0.9262 | 0.9232 | 0.9565 | 1.1869 |

The experiments indicate that:

- Logistic Regression provided a clear interpretable baseline
- Random Forest remained a strong ensemble benchmark
- XGBoost achieved the strongest overall performance-latency balance in the saved notebook results

### Cross-validation and stability analysis

The notebook then applies five-fold stratified cross-validation using:

- `StratifiedKFold(n_splits=5, shuffle=True, random_state=42)`
- `cross_validate(...)`

Saved cross-validation output:

| Model | CV accuracy | CV precision | CV recall | CV F1 | CV ROC-AUC | ROC-AUC std |
|---|---:|---:|---:|---:|---:|---:|
| Random Forest | 0.9385 | 0.9651 | 0.9474 | 0.9562 | 0.9896 | 0.000787 |
| XGBoost | 0.9361 | 0.9596 | 0.9497 | 0.9546 | 0.9892 | 0.000696 |
| Logistic Regression | 0.8907 | 0.9131 | 0.9344 | 0.9236 | 0.9529 | 0.003014 |

The results suggest that Random Forest and XGBoost remain closely matched under repeated partitioning, while Logistic Regression remains clearly behind them on this dataset.

### Explainability workflow in Python

The notebook contains two explainability stages:

1. **Prototype Random Forest explainability**
   - `shap.TreeExplainer(model)`
   - global summary plot
   - global bar plot
   - local explanation examples

2. **Selected XGBoost explainability**
   - `shap.TreeExplainer(final_xgb_model)`
   - global summary plot
   - global bar plot
   - high-risk, low-risk, and borderline waterfall examples

Saved Random Forest global SHAP table:

- `social_media_hours` - `0.202100`
- `daily_screen_time_hours` - `0.171539`
- `weekend_screen_time` - `0.092273`

Saved XGBoost global SHAP table:

- `daily_screen_time_hours` - `4.087780`
- `social_media_hours` - `3.022773`
- `weekend_screen_time` - `0.408089`

Across both explainability stages, `social_media_hours` and `daily_screen_time_hours` repeatedly appear as the strongest behavioural contributors.

### Ablation and feature-stability workflow

The notebook aligns ablation with the selected deployment candidate:

- if XGBoost is available, ablation uses XGBoost
- otherwise it falls back to Random Forest

Relevant notebook cells:

- cell 87
- cell 88

Saved ablation baseline output:

- baseline XGBoost accuracy: `0.9260`
- baseline XGBoost F1: `0.9466`
- baseline XGBoost ROC-AUC: `0.9876`

Largest saved performance drop:

- removing `social_media_hours`
  - accuracy drop `0.147333`
  - F1 drop `0.108193`
  - ROC-AUC drop `0.129352`

Second meaningful drop:

- removing `daily_screen_time_hours`
  - ROC-AUC drop `0.011597`

The ablation results indicate that `social_media_hours` is the dominant predictive feature in the saved deployment-aligned experiment, while `daily_screen_time_hours` acts as the secondary signal and the remaining variables contribute smaller complementary information.

### Model selection rationale

The notebook's selected deployment candidate is determined from the sorted comparison table.

Relevant notebook cell:

- cell 99

Saved output:

- selected deployment candidate: `XGBoost`

The saved selection logic supports this interpretation:

- Logistic Regression remained useful as a baseline
- Random Forest performed strongly and was used earlier in deployment experiments
- XGBoost was retained as the selected model because it preserved very strong predictive performance while substantially reducing inference cost relative to Random Forest

### ONNX conversion workflow

Two export stages are currently documented:

#### Prototype export

- Random Forest prototype export with `skl2onnx.to_onnx(...)`
- outputs:
  - `wellbeing_model_random_forest_prototype.onnx`
  - `feature_map_random_forest_prototype.json`

#### Selected-model export

- XGBoost export with `onnxmltools.convert_xgboost(...)`
- converter-compatible export instance is retrained on the same ordered NumPy matrix before export
- outputs:
  - `wellbeing_model.onnx`
  - `feature_map.json`

Relevant notebook cells:

- prototype export: cells 61 to 65
- XGBoost export: cells 102 to 105

### Parity verification

The notebook performs parity checks between the exported ONNX model and the Python XGBoost model.

Saved outputs:

- sample parity difference: `0.00000006` -> `PASS`
- app-style input parity difference: `0.00000000` -> `PASS`

This supports the notebook's export pathway as a viable deployment candidate for local inference.

### Deployment synchronization note

The current project contains two distinct model locations:

- project-root export artifact: `../wellbeing_model.onnx` - size `262636`
- Flutter deployed asset: `assets/wellbeing_model.onnx` - size `1757039`

The current project also contains two different feature-map schemas:

- root export `../feature_map.json`
  - keys include `model_name`, `feature_order`, `input_size`
- Flutter asset `assets/feature_map.json`
  - key used by the app is `features`

The app's `AIController._validateFeatureMap()` currently expects `decoded['features']`. The notebook's root export writes `feature_order` instead. This indicates that automatic synchronization between notebook export artifacts and deployed Flutter assets was not found in the current implementation.

[INSERT FIGURE HERE - model comparison table/plot]  
Suggested chapter location: Results chapter, model comparison subsection.

[INSERT FIGURE HERE - ablation analysis plot]  
Suggested chapter location: Results chapter, feature stability subsection.

[INSERT FIGURE HERE - ONNX export and parity workflow]  
Suggested chapter location: Implementation or deployment subsection.

## 5. Canonical AI Inference Pipeline

The current implementation supports the following end-to-end inference flow:

Android Usage APIs  
->  
Feature Extraction  
->  
Canonical Feature Vector  
->  
ONNX Runtime  
->  
Probability Output  
->  
Risk Classification  
->  
Recommendation Engine  
->  
Hive Persistence  
->  
Dashboard Analytics

### Step 1: Android usage APIs

Usage-derived inputs originate from:

- `usage_stats`
- `flutter_device_apps`
- native method-channel calls for approximate notification/app-open values

Primary code:

- `lib/services/usage_feature_service.dart`
- `lib/services/notification_service.dart`
- `android/app/src/main/kotlin/com/saqlain/wellbeing/MainActivity.kt`

### Step 2: Feature extraction

`UsageFeatureService.getUsageFeatures()` returns a map containing:

- `daily_screen_time_hours`
- `social_media_hours`
- `gaming_hours`
- `weekend_screen_hours`
- `notifications_per_day`
- `app_opens_per_day`

### Step 3: Canonical feature vector

`AIController` maintains a 12-element observable feature list:

- `features = List<double>.filled(12, 0.0).obs`

The canonical order is hard-coded in `_featureOrder`:

1. `age`
2. `gender`
3. `daily_screen_time_hours`
4. `social_media_hours`
5. `gaming_hours`
6. `work_study_hours`
7. `sleep_hours`
8. `notifications_per_day`
9. `app_opens_per_day`
10. `weekend_screen_time`
11. `stress_level`
12. `academic_work_impact`

Aliases are used so older/manual keys can still be mapped:

- `daily_screen_time` -> `daily_screen_time_hours`
- `notifications` -> `notifications_per_day`
- `app_opens` -> `app_opens_per_day`
- `weekend_screen` -> `weekend_screen_time`
- `academic_impact` -> `academic_work_impact`

### Step 4: Tensor creation

`AIController.runInference()` creates:

- `Float32List.fromList(features)`
- `OrtValueTensor.createTensorWithDataList(inputData, [1, 12])`

This is the tensor sent into the ONNX runtime session.

### Step 5: ONNX Runtime execution

The app uses:

- package: `onnxruntime_v2`
- session created from `assets/wellbeing_model.onnx`

Relevant code:

- `AIController._initModel()`
- `AIController.runInference()`

The model input name used in the notebook export is `float_input`. The Flutter controller currently calls:

- `_session?.runAsync(OrtRunOptions(), {'float_input': inputTensor})`

### Step 6: Probability output and risk classification

The controller expects the probability output in the second returned tensor and stores:

- `riskScore.value = row[1]`

Current thresholds:

- `High` if `riskScore >= 0.7`
- `Moderate` if `riskScore >= 0.3`
- `Low` otherwise

### Step 7: Recommendation engine

After inference:

- `_generateRecommendation()` calls `RecommendationEngine.build(...)`
- the engine returns a label and message
- `recommendationContext` and `recommendation` are updated

### Step 8: Hive persistence

`_saveAnalysis()` stores:

- timestamp
- date key
- score
- recommendation
- recommendation context
- source
- usage summary fields

The latest snapshot is stored in `userBox['lastAnalysis']`, and history is added through `HiveService.saveAnalysisSnapshot(...)`.

### Step 9: Dashboard analytics

`AnalyticsScreen` reads the latest analysis and local history to produce:

- status summary
- recommendation card
- weekly chart
- navigation to app details and deeper analysis

### Latency and local execution benefits

The saved notebook comparison reports approximate single-sample inference latencies of:

- Logistic Regression: `1.1869 ms`
- XGBoost: `2.2937 ms`
- Random Forest: `46.1623 ms`

Within the experimentation workflow, the selected XGBoost model offered a stronger balance between predictive quality and inference cost than the earlier Random Forest deployment candidate.

Local execution benefits visible in the current architecture:

- no remote round trip for prediction
- no account dependency for inference
- persistence and analytics remain device-local
- prediction remains available even without a backend service

[INSERT FIGURE HERE - canonical AI inference pipeline]  
Suggested chapter location: Methodology chapter, AI inference subsection.

## 6. Explainability Strategy

The explainability strategy is split between offline experimentation and lightweight mobile deployment.

### Important implementation distinction

The app does **not** execute full SHAP computations on-device in real time.

Instead, the implementation separates explainability into two stages:

1. **Offline experimentation in Python**
   - SHAP summary plots
   - SHAP bar plots
   - local example explanations
   - feature-importance interpretation
   - ablation analysis

2. **Operationalized mobile logic**
   - lightweight feature/risk rules stored in `assets/shap_recommendation_map.json`
   - runtime recommendation selection through `RecommendationEngine`

This distinction is directly supported by the code:

- notebook SHAP analysis exists in `digital_wellbeing_ai_model.ipynb`
- Flutter app consumes a static JSON recommendation map
- Flutter app code does not import SHAP or calculate SHAP values on device

### Global interpretability

The notebook supports global interpretability through:

- Random Forest SHAP summary plot and bar plot
- XGBoost SHAP summary plot and bar plot
- ablation analysis
- permutation importance

The saved notebook outputs show recurring dominance of:

- `social_media_hours`
- `daily_screen_time_hours`
- `weekend_screen_time` as a secondary signal in both SHAP stages

### Local interpretability

The notebook supports local interpretability through:

- Random Forest local SHAP examples for high-risk, low-risk, and borderline cases
- XGBoost waterfall examples for high-risk, low-risk, and borderline cases

These local explanations are accompanied by human-readable interpretation strings printed in the notebook.

### Recommendation mapping

The current mobile explanation strategy is not a live SHAP replay. Instead, it is a lightweight operational mapping:

- offline experimentation identifies dominant behavioural patterns
- selected feature-risk patterns are encoded as app rules
- the app matches the current feature vector and risk score to the rule map

This creates a deployable explanation layer without requiring on-device SHAP computation.

### Explainability trade-offs for mobile deployment

Benefits of the current approach:

- low runtime overhead
- simple local execution
- deterministic recommendation triggers
- no need to ship SHAP libraries into the mobile runtime

Trade-offs:

- recommendations are only as expressive as the exported rule map
- the app does not show full per-user SHAP contribution values on device
- explanation fidelity is reduced compared with the offline notebook analysis

[INSERT FIGURE HERE - SHAP summary plot]  
Suggested chapter location: Results chapter, explainability subsection.

[INSERT FIGURE HERE - local SHAP explanation example]  
Suggested chapter location: Results chapter, case-study subsection.

## 7. Recommendation / Nudge Engine

The recommendation engine is implemented in:

- `lib/services/recommendation_engine.dart`

Asset source:

- `assets/shap_recommendation_map.json`

### Exact rule thresholds

Current explicit rules:

1. `social_media_hours_high`
   - feature: `social_media_hours`
   - condition: `gte`
   - threshold: `3.5`
   - min risk score: `0.7`
   - label: `Social media pattern`

2. `daily_screen_time_high`
   - feature: `daily_screen_time_hours`
   - condition: `gte`
   - threshold: `6.0`
   - min risk score: `0.7`
   - label: `Daily screen time`

3. `sleep_hours_low`
   - feature: `sleep_hours`
   - condition: `lte`
   - threshold: `6.0`
   - min risk score: `0.7`
   - label: `Sleep routine`

4. `app_opens_high`
   - feature: `app_opens_per_day`
   - condition: `gte`
   - threshold: `80.0`
   - min risk score: `0.7`
   - label: `Frequent app checking`

### Fallback logic

If no explicit rule matches, the engine falls back to:

- `high`
- `moderate_stress`
- `moderate`
- `low`

The specific moderate-stress fallback is triggered when:

- `riskScore > 0.3`
- and `stress_level >= 7`

### Recommendation generation process

At runtime:

1. `AIController.runInference()` completes
2. `_generateRecommendation()` builds a canonical feature map from `_featureOrder`
3. `RecommendationEngine.build(...)` evaluates priority-ordered rules
4. the selected rule or fallback returns:
   - label
   - message
5. the output is shown in:
   - `ResultScreen`
   - `AnalyticsScreen`
   - `AIAnalysisScreen`

### Why lightweight mappings are used

The current implementation uses lightweight mappings because the app architecture is designed for:

- low-cost local inference
- simple deployment on mobile
- stable rule execution without on-device SHAP overhead

An automated notebook export step that generates `assets/shap_recommendation_map.json` directly was not found in the current implementation. The app consumes a static JSON rule file.

[INSERT FIGURE HERE - recommendation rule flow]  
Suggested chapter location: Implementation chapter, recommendation subsystem subsection.

## 8. Local Storage and Privacy Architecture

### Hive usage

The current app uses Hive through:

- `lib/services/hive_service.dart`

Boxes opened at startup:

- `user`
- `categories`
- `features`

### Persisted data

The current implementation persists:

- onboarding/profile values
- latest prediction snapshot
- analysis history
- category overrides
- selected feature values
- startup flags such as onboarding state and smart-tracking settings

Examples from `HiveService`:

- `saveUserProfile(...)`
- `saveOnboardingInputs(...)`
- `saveFeature(...)`
- `saveAnalysisSnapshot(...)`

### Analysis history persistence

`HiveService.saveAnalysisSnapshot(...)`:

- stores per-day snapshots
- replaces the same day's entry if needed
- sorts by timestamp
- keeps the latest 120 entries
- respects `localHistoryEnabled`

### Recommendation persistence

The latest analysis snapshot includes:

- `recommendation`
- `recommendationContext`

These are restored through:

- `AIController._loadSavedAnalysis()`

### Onboarding/profile persistence

Onboarding/profile values stored include:

- `profile_age`
- `profile_gender`
- `profile_sleep_hours`
- `profile_work_study_hours`
- `profile_stress_level`
- `profile_academic_impact`

### Category override persistence

`CategoryService` stores category overrides in the `categories` Hive box. User-defined categories are therefore preserved locally across launches unless explicitly reset.

### Reset/delete functionality

The current app includes implemented local reset functions:

- `HiveService.clearAnalysisHistory()`
- `HiveService.clearLatestAnalysis()`
- `HiveService.clearStoredFeatures()`
- `HiveService.clearCategoryOverrides()`
- `HiveService.clearLocalInsights()`
- `HiveService.clearProfileData()`

UI entry point:

- `lib/view/setting/data_management_screen.dart`

The data-management flow also:

- sets `onboardingCompleted` to false
- sets `needsFreshStart` to true
- resets `AIController`
- redirects to `FreshStartScreen`

### Local-first architecture

The current architecture is local-first in the following sense:

- ONNX inference is local
- result persistence is local
- category overrides are local
- analytics/history are local

### Absence of cloud dependency

Firebase was not found in the current implementation.  
Remote model inference APIs were not found in the current implementation.  
External analytics SDKs were not found in the current implementation.

### External links currently present

External interactions currently found:

- privacy policy URL: `https://ai-wellbeing.web.app`
- feedback form URL: Google Forms, opened through `url_launcher`

These external links are not used for model inference or local history storage.

### Encryption

Encryption at rest was not found in the current implementation.

`flutter_secure_storage` is declared in `pubspec.yaml`, and `lib/util/secure_storage.dart` exists, but active use of this utility was not found in the main app flow inspected here.

[INSERT FIGURE HERE - local storage and privacy architecture]  
Suggested chapter location: Methodology or discussion chapter, privacy subsection.

## 9. Testing and Validation

### Automated testing evidence

The current repository includes:

- `test/widget_test.dart`

This appears to be the default Flutter scaffold test and does not reflect the present app architecture. Robust automated end-to-end or integration test suites were not found in the current implementation.

### Code-supported validation activities

The implementation contains code paths that support manual validation of:

- onboarding and profile persistence
- manual assessment flow
- smart-tracking flow
- permission return handling
- local model loading
- recommendation generation
- category override storage
- state restoration from Hive
- parity checking in the Python notebook

### Manual mode testing

The manual path is fully wired in code:

- `PermissionScreen` -> `ManualEstimationScreen`
- manual values are mapped through `AIController.setUsageData(...)`
- the app runs local inference without requiring usage access

### Smart-tracking testing

The smart-tracking path is also implemented in code:

- permission check
- usage feature collection
- local inference
- result persistence

Smart tracking depends on the Android usage-access setting and is therefore partly dependent on device-level behaviour outside the Dart layer.

### Permission-flow testing

The permission flow contains dedicated resume handling:

- `PermissionLifecycleService`

This supports the user returning from system settings and continuing the smart-tracking flow without restarting the app manually.

### ONNX inference verification

The strongest explicit inference validation evidence is in the notebook:

- Random Forest prototype ONNX parity check
- XGBoost ONNX parity check
- app-style input parity check

Saved parity outputs are `PASS` for the selected XGBoost deployment candidate.

### Recommendation validation

Recommendation validation exists as deterministic rule execution in code:

- `RecommendationEngine.build(...)`

No separate automated rule-validation test suite was found in the current implementation.

### Category override testing

The app includes a concrete category-management UI and persistence layer:

- `CategoryScreen`
- `CategoryService.saveUserCategory(...)`
- `CategoryService.removeUserCategory(...)`

This indicates that user override behaviour is implemented rather than only planned.

### State restoration testing

State restoration support exists in code through:

- `AIController._loadSavedProfile()`
- `AIController._loadSavedAnalysis()`
- startup screen selection in `main.dart`

This supports persistence across relaunches, but automated restoration tests were not found.

### Lifecycle and background execution

Lifecycle-sensitive areas currently implemented:

- permission resume handling
- WorkManager-based daily scheduling

Background scheduling is implemented in:

- `lib/services/smart_tracking_service.dart`

Its real-world execution characteristics depend on Android OS behaviour. Dedicated instrumentation or long-run background validation logs were not found in the current implementation files.

### Internal testing evidence

Evidence for 12+ tester internal testing was not found in the current implementation files.

### Implementation limitations visible during validation review

- notification and app-open telemetry are approximate
- automated tests for the main production flow were not found
- notebook export artifacts and Flutter asset artifacts are not automatically synchronized
- some legacy or inactive files remain in the codebase

## 10. Recommended Dissertation Figures

The following figures can be referenced directly in the dissertation. Where existing exported screenshots are not present, these can be generated from the implemented screens or notebook outputs.

1. **Figure X - Onboarding flow**
   - Source: `WelcomeScreen`, `OnboardingScreen`
   - Reference in dissertation: Implementation chapter, user flow subsection
   - Marker: [INSERT FIGURE HERE]

2. **Figure X - Android usage permission flow**
   - Source: `PermissionScreen`, `PermissionLifecycleService`
   - Reference: Implementation chapter, Android data-collection subsection
   - Marker: [INSERT FIGURE HERE]

3. **Figure X - Feature extraction pipeline**
   - Source: `UsageFeatureService.getUsageFeatures()`
   - Reference: Methodology chapter, feature engineering subsection
   - Marker: [INSERT FIGURE HERE]

4. **Figure X - AI inference pipeline**
   - Source: `AIController.runInference()`
   - Reference: Methodology chapter, AI inference subsection
   - Marker: [INSERT FIGURE HERE]

5. **Figure X - Comparative model evaluation**
   - Source: notebook comparison plots and tables
   - Reference: Results chapter, model comparison subsection
   - Marker: [INSERT FIGURE HERE]

6. **Figure X - SHAP summary plot**
   - Source: notebook SHAP output
   - Reference: Results chapter, explainability subsection
   - Marker: [INSERT FIGURE HERE]

7. **Figure X - Local SHAP explanation example**
   - Source: notebook XGBoost waterfall example
   - Reference: Results chapter, case-based interpretability subsection
   - Marker: [INSERT FIGURE HERE]

8. **Figure X - ONNX deployment workflow**
   - Source: notebook export/parity workflow plus app asset loading path
   - Reference: Implementation chapter, deployment subsection
   - Marker: [INSERT FIGURE HERE]

9. **Figure X - Prediction result screen**
   - Source: `ResultScreen`
   - Reference: Implementation chapter, user-facing inference output subsection
   - Marker: [INSERT FIGURE HERE]

10. **Figure X - Dashboard analytics screen**
    - Source: `AnalyticsScreen`
    - Reference: Implementation chapter, analytics subsection
    - Marker: [INSERT FIGURE HERE]

11. **Figure X - Recommendation explanation screen**
    - Source: `AIAnalysisScreen`
    - Reference: Implementation chapter, recommendation and explainability subsection
    - Marker: [INSERT FIGURE HERE]

12. **Figure X - Category override interface**
    - Source: `CategoryScreen`
    - Reference: Implementation chapter, app classification subsection
    - Marker: [INSERT FIGURE HERE]

13. **Figure X - Usage analytics interface**
    - Source: `AppDetailsScreen` or `UsageReportScreen`
    - Reference: Implementation chapter, behaviour analytics subsection
    - Marker: [INSERT FIGURE HERE]

## 11. Research Contribution Summary

The implemented work supports the following grounded contribution summary.

### Privacy-preserving mobile AI

The project demonstrates a mobile AI prototype where prediction is executed on device through ONNX Runtime rather than remote inference. This supports a local-first design for behavioural risk estimation.

### On-device behavioural prediction

The app operationalizes a 12-feature behavioural and contextual model that can be populated through:

- Android usage-derived features
- self-reported inputs from onboarding and manual estimation

### Explainability-aware recommendation design

The research workflow does not stop at prediction. The Python experimentation includes SHAP-based interpretation and ablation analysis, and the mobile implementation translates these findings into a lightweight recommendation engine suitable for mobile deployment.

### Lightweight deployment pathway

The prototype includes:

- model experimentation in Python
- ONNX export
- parity verification
- Flutter-side ONNX inference integration

This creates a full path from model training to mobile inference, even though deployment asset synchronization still requires careful handling in the current project layout.

### AI-assisted digital wellbeing support

The current architecture links prediction, usage interpretation, recommendations, and local dashboard analytics in a single behavioural self-regulation workflow.

These contributions are implementation-grounded rather than framed as a clinical or large-scale commercial system.

## 12. Known Limitations and Future Work

### Prototype limitations

- automated end-to-end testing was not found
- some inactive or legacy files remain in the repository
- deployment artifacts are not automatically synchronized between notebook outputs and app assets

### Android API limitations

- notification counts are estimated, not exact
- app-open counts are estimated, not exact
- usage-based metrics depend on Android usage-access permission and OS behaviour

### Approximation limitations

- social/gaming hours depend on a local category map and user overrides
- weekend usage is implemented as a simplified recent-period approximation
- confidence score shown in the app is a heuristic derived from feature coverage, not a probabilistic model uncertainty estimate

### Dataset and experimentation limitations

- target-label generation is not defined in the notebook and appears to be inherited from the source CSV
- the train/test split is not stratified in the current notebook code
- no larger external real-world validation dataset was found in the current implementation files

### Explainability limitations

- full SHAP inference is not implemented on device
- the mobile explanation layer is rule-based and therefore lower fidelity than direct per-user SHAP evaluation
- the notebook shows that different importance methods emphasize similar but not perfectly identical signals

### Mobile inference limitations

- the app currently expects a different feature-map JSON schema from the notebook root export
- the deployed ONNX asset in `assets/` is not automatically proven to be the same file as the root export artifact

### Future work

The following items were not found in the current implementation and are therefore future-work directions rather than implemented features:

- real-time on-device explainability beyond lightweight rule mappings
- event-accurate notification and app-open telemetry
- federated learning or privacy-preserving distributed model updates
- adaptive intervention learning based on longitudinal response
- personalized continual learning on-device
- longitudinal user studies with larger real-world deployment cohorts
- explicit encryption at rest for locally stored data

