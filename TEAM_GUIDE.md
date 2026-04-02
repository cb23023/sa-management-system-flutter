# Team Guide

## Branch Ownership

Each person should only work inside their assigned module folder unless explicitly asked to handle shared files.

- Module 1 branch: `feature/open-registration-and-subject-registration`
  Folder: `lib/src/modules/open_registration_and_subject_registration`
- Module 2 branch: `feature/co-curriculum-activity-and-credit-claim`
  Folder: `lib/src/modules/co_curriculum_activity_and_credit_claim`
- Module 3 branch: `feature/tuition-fee-and-payment`
  Folder: `lib/src/modules/tuition_fee_and_payment`
- Module 4 branch: `feature/attendance`
  Folder: `lib/src/modules/attendance`

Do not edit these shared files unless the team agrees first:

- `lib/src/screens/main_shell_screen.dart`
- `lib/src/widgets/*`
- `lib/src/theme/*`
- `pubspec.yaml`

## First Time Setup

```bash
git clone <REPO_URL>
cd sa_management_system_flutter
flutter pub get
git checkout main
git pull origin main
```

## Create Your Branch

Module 1:
```bash
git checkout -b feature/open-registration-and-subject-registration
```

Module 2:
```bash
git checkout -b feature/co-curriculum-activity-and-credit-claim
```

Module 3:
```bash
git checkout -b feature/tuition-fee-and-payment
```

Module 4:
```bash
git checkout -b feature/attendance
```

## Daily Workflow

Before starting work:

```bash
git checkout main
git pull origin main
git checkout <your-branch>
git rebase main
flutter analyze
```

After finishing work:

```bash
git add .
git commit -m "Update <module-name> UI"
git push origin <your-branch>
```

## Before Opening a Pull Request

```bash
git checkout main
git pull origin main
git checkout <your-branch>
git rebase main
flutter analyze
```

If rebase shows conflicts, only keep your changes inside your own module folder. Ask before touching shared files.

## Codex Prompt Template

Use this prompt in Codex and replace only the module name, branch name, and folder path.

```text
You are working on a Flutter project for SA Management System.

Rules:
- Only edit files inside this folder: <MODULE_FOLDER>
- Do not edit shared files such as lib/src/screens/main_shell_screen.dart, lib/src/widgets, lib/src/theme, pubspec.yaml, or another module folder.
- Preserve the existing app visual style.
- Use the same design language already in the app: modern, clean, professional, rounded cards, soft shadows, blue-teal brand direction based on the SAMS logo, concise English copy only.
- Keep layouts mobile-first and consistent with the current UI.
- Do not add random placeholder text or assignment-style labels.
- Keep the module bottom navigation pattern already used in the project.
- Do not rename routes, shared widgets, or app structure unless explicitly told.
- Run flutter analyze after changes.

My task:
Design and implement the UI for <MODULE_NAME> inside <MODULE_FOLDER> only.
Create polished, production-style screens and keep the content relevant to this module.
```

## Module Prompt Examples

Module 1:
```text
You are working on a Flutter project for SA Management System.

Rules:
- Only edit files inside this folder: lib/src/modules/open_registration_and_subject_registration
- Do not edit shared files such as lib/src/screens/main_shell_screen.dart, lib/src/widgets, lib/src/theme, pubspec.yaml, or another module folder.
- Preserve the existing app visual style.
- Use the same design language already in the app: modern, clean, professional, rounded cards, soft shadows, blue-teal brand direction based on the SAMS logo, concise English copy only.
- Keep layouts mobile-first and consistent with the current UI.
- Do not add random placeholder text or assignment-style labels.
- Keep the module bottom navigation pattern already used in the project.
- Run flutter analyze after changes.

My task:
Design and implement the UI for Open Registration and Subject Registration inside lib/src/modules/open_registration_and_subject_registration only.
```

Module 2:
```text
You are working on a Flutter project for SA Management System.

Rules:
- Only edit files inside this folder: lib/src/modules/co_curriculum_activity_and_credit_claim
- Do not edit shared files such as lib/src/screens/main_shell_screen.dart, lib/src/widgets, lib/src/theme, pubspec.yaml, or another module folder.
- Preserve the existing app visual style.
- Use the same design language already in the app: modern, clean, professional, rounded cards, soft shadows, blue-teal brand direction based on the SAMS logo, concise English copy only.
- Keep layouts mobile-first and consistent with the current UI.
- Do not add random placeholder text or assignment-style labels.
- Keep the module bottom navigation pattern already used in the project.
- Run flutter analyze after changes.

My task:
Design and implement the UI for Co Curriculum Activity and Credit Claim inside lib/src/modules/co_curriculum_activity_and_credit_claim only.
```

Module 3:
```text
You are working on a Flutter project for SA Management System.

Rules:
- Only edit files inside this folder: lib/src/modules/tuition_fee_and_payment
- Do not edit shared files such as lib/src/screens/main_shell_screen.dart, lib/src/widgets, lib/src/theme, pubspec.yaml, or another module folder.
- Preserve the existing app visual style.
- Use the same design language already in the app: modern, clean, professional, rounded cards, soft shadows, blue-teal brand direction based on the SAMS logo, concise English copy only.
- Keep layouts mobile-first and consistent with the current UI.
- Do not add random placeholder text or assignment-style labels.
- Keep the module bottom navigation pattern already used in the project.
- Run flutter analyze after changes.

My task:
Design and implement the UI for Tuition Fee and Payment inside lib/src/modules/tuition_fee_and_payment only.
```

Module 4:
```text
You are working on a Flutter project for SA Management System.

Rules:
- Only edit files inside this folder: lib/src/modules/attendance
- Do not edit shared files such as lib/src/screens/main_shell_screen.dart, lib/src/widgets, lib/src/theme, pubspec.yaml, or another module folder.
- Preserve the existing app visual style.
- Use the same design language already in the app: modern, clean, professional, rounded cards, soft shadows, blue-teal brand direction based on the SAMS logo, concise English copy only.
- Keep layouts mobile-first and consistent with the current UI.
- Do not add random placeholder text or assignment-style labels.
- Keep the module bottom navigation pattern already used in the project.
- Run flutter analyze after changes.

My task:
Design and implement the UI for Attendance inside lib/src/modules/attendance only.
```
