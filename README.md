# AI Wellbeing

AI Wellbeing is an MSc Artificial Intelligence project focused on digital wellbeing risk prediction using behavioural and self-reported smartphone usage features. The project combines supervised machine learning, explainable AI (XAI), and privacy-preserving mobile deployment to support a mobile wellbeing application.

## Project Scope

The project was developed in two connected parts:

1. A Python research workflow for dataset analysis, feature preparation, model training, comparative evaluation, explainability, and ONNX export.
2. A Flutter mobile application that uses the exported model for on-device inference and user-facing digital wellbeing insights.

The core objective is to predict digital wellbeing risk from smartphone-related behavioural patterns while preserving user privacy through local inference on the device.

## Research Workflow

The main experimental workflow is documented in:

- `digital_wellbeing_ai_model.ipynb`

The notebook follows a two-phase structure:

### Part I: Prototype Development and Exploratory Modelling
- dataset loading and inspection
- exploratory data analysis
- preprocessing and behavioural feature engineering
- initial Random Forest prototype
- early SHAP explainability exploration
- recommendation and nudge logic
- initial ONNX deployment exploration

### Part II: Comparative Evaluation and Model Selection
- comparative evaluation of Logistic Regression, Random Forest, and XGBoost
- cross-validation and stability analysis
- comparative visual evaluation
- ablation analysis
- XGBoost explainability analysis
- model selection for deployment
- XGBoost ONNX export and parity validation
- summary of findings

## Dataset

The notebook uses the dataset:

- `Smartphone_Usage_And_Addiction_Analysis_7500_Rows.csv`

The predictive pipeline is based on the following 12 features:

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

These variables combine behavioural usage signals with self-reported lifestyle and wellbeing indicators.

## Models Compared

The main comparative evaluation includes:

- Logistic Regression
- Random Forest
- XGBoost

The comparison considers:

- accuracy
- precision
- recall
- F1-score
- ROC-AUC
- inference latency

Logistic Regression is used as an interpretable baseline, Random Forest is retained as the first strong ensemble benchmark and early deployment candidate, and XGBoost is used as the selected model for deployment following comparative evaluation.

## Explainable AI

The project uses SHAP to improve model transparency at both global and local levels.

The notebook includes:

- global SHAP importance analysis
- local SHAP explanation examples
- prototype-stage Random Forest explainability
- selected-model XGBoost explainability

Ablation analysis and permutation-style importance analysis are also used to examine the stability of feature relevance beyond model-internal importance rankings.

Across the current dataset, `social_media_hours` emerges as the dominant behavioural signal, with `daily_screen_time_hours` acting as a secondary contributor and the remaining features providing smaller complementary information.

## Exported Deployment Assets

The root directory contains exported model assets used for mobile inference:

- `wellbeing_model.onnx`
- `feature_map.json`

The earlier prototype export is also retained for research progression and comparison:

- `wellbeing_model_random_forest_prototype.onnx`
- `feature_map_random_forest_prototype.json`

The ONNX export path is intended to support privacy-preserving on-device inference in the mobile application.

## Mobile Application

The Flutter application is located in:

- `wellbeing/`

That folder contains the mobile interface, permission handling, local storage, dashboard views, activity analysis, recommendation presentation, and ONNX inference integration.

The app README should be used for:

- Flutter setup
- running the mobile app
- Android permissions
- model asset integration
- privacy and support flow

## Privacy and Deployment Intent

A central design goal of the project is privacy-preserving architecture.

Key principles include:

- no mandatory login
- local storage for app-side insights
- on-device inference using ONNX
- optional smart tracking alongside manual assessment
- user-facing feedback derived from interpretable model behaviour

A hosted privacy policy site for the app is included in:

- `privacy_policy_site/`

## Repository Layout

```text
archive/
├─ README.md
├─ digital_wellbeing_ai_model.ipynb
├─ Smartphone_Usage_And_Addiction_Analysis_7500_Rows.csv
├─ wellbeing_model.onnx
├─ feature_map.json
├─ wellbeing_model_random_forest_prototype.onnx
├─ feature_map_random_forest_prototype.json
├─ privacy_policy_site/
└─ wellbeing/
```

## Current Project Position

At this stage, the project provides:

- a complete notebook-based MSc AI research workflow
- comparative evaluation across candidate models
- explainable AI analysis using SHAP
- a selected XGBoost deployment candidate
- ONNX export for mobile inference
- a Flutter application that integrates the model into a digital wellbeing experience

## Notes

The reported results are based on the available dataset and notebook experiments. Broader validation with additional real-world usage data would be required before making stronger claims about generalisation beyond the current study setting.
