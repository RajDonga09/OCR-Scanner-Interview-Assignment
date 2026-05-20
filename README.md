# OCR Scanner — Flutter Interview Assignment

A production-quality Flutter application that scans **credit / debit cards** and **bank passbooks**, runs on-device OCR via Google ML Kit and extracts **structured fields with manually-written parsers** (no parsing libraries used).

The project is deliberately built to interview-grade standards: clean architecture, feature-first folders, Cubit state management, full DI, reusable widgets, comprehensive unit tests and rich edge-case handling.

---

## Features

- Scan **credit / debit cards** from the camera or gallery and extract:
  - Card number (+ masked form `XXXX XXXX XXXX 1234`)
  - Card holder name
  - Expiry date (supports `12/25`, `12-25`, `1225`)
  - Card brand (Visa / MasterCard / Amex / RuPay / Discover)
  - **Luhn validation** result
- Scan **bank passbooks** and extract:
  - Account holder name
  - Account number (with mobile-number / IFSC-tail exclusion)
  - IFSC code (`[A-Z]{4}0[A-Z0-9]{6}` with O↔0 repair)
  - Bank name & branch
- Manual OCR text normalisation (O→0, I→1, l→1, S→5, B→8, noise removal, duplicate-line collapse).
- Material 3 UI with reusable widgets and theme tokens.
- Comprehensive unit tests for parsers, validators, normalizer and cubits.

---

## Tech stack

| Layer        | Library |
| ------------ | ------- |
| State        | `flutter_bloc`, `bloc`, `equatable` |
| DI           | `get_it` |
| Image input  | `image_picker`, `image_cropper` |
| OCR          | `google_mlkit_text_recognition` |
| Permissions  | `permission_handler` |
| Testing      | `flutter_test`, `bloc_test`, `mocktail` |

---

## Setup

### 1. Prerequisites
- Flutter `>= 3.24` (stable channel)
- Dart `>= 3.5`
- Android SDK 21+ (ML Kit requirement)
- iOS 13+ (ML Kit requirement)

### 2. Install
```bash
flutter pub get
```

### 3. Android
The `AndroidManifest.xml` already declares:
- `CAMERA`
- `READ_EXTERNAL_STORAGE` (`maxSdkVersion 32`)
- `READ_MEDIA_IMAGES`

`minSdk` is bumped to **21** because ML Kit text recognition requires it.

### 4. iOS
`Info.plist` includes the usage strings:
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSMicrophoneUsageDescription` (declared because the `camera` plugin requests it)

Run `cd ios && pod install` after the first `pub get`.

### 5. Run
```bash
flutter run
```

### 6. Test
```bash
flutter test
```

---

## Folder structure

```
lib/
├── core/                           # Cross-cutting concerns
│   ├── constants/                  # Colours, dimensions, strings, regex, assets
│   ├── theme/                      # Material 3 ThemeData
│   ├── widgets/                    # Reusable widgets (AppText, AppCard, …)
│   ├── services/                   # OCR, image picking, permissions
│   ├── utils/                      # Text cleaner, validators, parser helpers
│   └── di/                         # GetIt service locator
│
├── features/
│   ├── home/                       # Landing page with navigation tiles
│   │   └── presentation/
│   ├── card_scanner/
│   │   ├── domain/
│   │   │   ├── models/             # CardDetails (Equatable, copyWith, JSON)
│   │   │   ├── parsers/            # CardParser + manual LuhnValidator
│   │   │   └── repositories/       # CardScannerRepository
│   │   └── presentation/
│   │       ├── cubit/              # CardScannerCubit + state
│   │       ├── pages/              # CardScannerPage, CardResultPage
│   │       └── widgets/            # CardVisual, RawTextView, actions
│   │
│   └── passbook_scanner/
│       ├── domain/
│       │   ├── models/             # BankDetails (Equatable, copyWith, JSON)
│       │   ├── parsers/            # PassbookParser
│       │   └── repositories/       # PassbookScannerRepository
│       └── presentation/
│           ├── cubit/              # PassbookScannerCubit + state
│           ├── pages/              # PassbookScannerPage, PassbookResultPage
│           └── widgets/            # PassbookVisual, actions
│
└── main.dart
```

The `test/` directory mirrors `lib/` so each unit-tested file is easy to locate.

---

## Architecture

The app follows **Clean Architecture** + **Feature-First** organisation:

```
UI (pages/widgets)  ──▶  Cubit  ──▶  Repository  ──▶  Services (OCR, image, permissions)
                                          │
                                          └────▶  Parsers (pure, manual)
```

- **Domain layer** (`features/<feature>/domain`) contains pure Dart: models, parsers, repository interfaces. **Zero Flutter dependencies → 100% unit-testable.**
- **Data/Repository layer** orchestrates services and feeds the parser.
- **Presentation layer** (`cubit` + `pages` + `widgets`) only knows about the cubit state machine.
- **Core layer** holds cross-feature concerns: theme, constants, shared widgets, DI container, utilities.

State management uses **`Cubit`** because the scanning flow has 4 finite states (`initial`, `loading`, `success`, `failure`). A full `Bloc` would only add boilerplate without value.

All dependencies are wired in `lib/core/di/injection.dart` using `get_it` — feature code never news-up its own services, which keeps everything trivially mockable in tests.

---

## OCR pipeline

1. **Pick image** via `ImageService` (camera or gallery → `dart:io.File`).
2. **Crop** with `ImageCropService` (card or passbook aspect ratio) to exclude side text.
3. **Request permissions** through `PermissionService`.
4. **Extract raw text** with `MlKitOcrService` (`google_mlkit_text_recognition`).
5. **Normalise text** with `TextCleaner.clean`:
   - Strip non-alphanumeric noise (`★ # @ …`)
   - Collapse multi-space runs
   - Drop duplicate lines (case-insensitive)
6. **Parse** with the feature parser (`CardParser` or `PassbookParser`).
7. **Validate** with `LuhnValidator` (cards) and the IFSC regex (passbooks).
8. **Emit success** with a typed model + cleaned raw text for the result screen.

The OCR confusable map (O↔0, I↔1, S↔5, …) is **only applied inside numeric contexts** so we never mangle a name. Inside an IFSC token the mapping is reversed (digits become letters in positions 0-3, `0` is forced at position 4).

---

## Manual Luhn algorithm

The Luhn check lives in `features/card_scanner/domain/parsers/luhn_validator.dart` and is implemented from scratch:

1. Reverse the digits.
2. Walk left-to-right; every digit at an odd index (every second digit from the right) is doubled.
3. If the doubled value > 9, subtract 9.
4. Sum all (possibly doubled / corrected) digits.
5. The number is valid when `sum % 10 == 0`.

The validator additionally rejects PAN lengths outside `13–19` digits so a stray 4-digit string can't accidentally satisfy the modular check.

See `test/features/card_scanner/luhn_validator_test.dart` for the test matrix (Visa, MasterCard, Amex, Discover, malformed, padded, dashed, empty).

---

## Assumptions

- The OCR target is **printed Latin text on Indian cards / passbooks**. RTL scripts and CJK are out of scope.
- The application runs on a real device (ML Kit relies on platform channels — emulator-on-Mac requires an x86 image).
- A "valid" card is one that passes the Luhn check **and** falls within the 13–19 digit PAN range.
- The IFSC standard considered is RBI's `[A-Z]{4}0[A-Z0-9]{6}` (older fully-numeric branches and the newer alphanumeric ones are both accepted).
- Names are extracted heuristically — false negatives are preferred over false positives (we surface `Not detected` rather than picking the wrong line).

---

## Edge cases handled

| Scenario | Behaviour |
| --- | --- |
| Empty OCR result | `OcrEmptyException` → friendly error UI |
| Blurry / partial card | Falls back to longest digit candidate, surfaces `Luhn: Failed` |
| Multiple numbers on a passbook | Prefers `ACCOUNT NO` / `A/C` keyword line, then longest plausible |
| Mobile number in passbook | Skipped via `Validators.isMobileNumber` |
| IFSC tail appearing in account candidate | Excluded via substring check |
| OCR confused `O ↔ 0`, `I ↔ 1` in card number | Normalised in numeric contexts |
| OCR confused `0 ↔ O` in IFSC | Reversed inside `TextCleaner.normaliseIfsc` |
| Duplicate lines from OCR (shadows, reflections) | Collapsed |
| `VALID THRU` / `VISA` / `MASTERCARD` lines | Excluded from name detection |
| Bank / branch lines | Excluded from passbook name detection |
| Missing expiry | Returns `null`, UI shows `Not detected` |
| Missing name / account | Returns `null`, UI shows `Not detected` |
| Camera permission denied | `CardScanPermissionFailure` → settings prompt |
| Image picker cancelled | `CardScanNoImageFailure` → silent retry |
| ML Kit exception | Wrapped in `OcrFailureException` |

---

## Testing

```bash
flutter test
```

The test suite covers:

| Area | File |
| --- | --- |
| OCR normalisation | `test/core/utils/text_cleaner_test.dart` |
| Field validators (card length, IFSC, mobile, expiry, account length) | `test/core/utils/validators_test.dart` |
| Parser helpers (`digitsOnly`, `maskCardNumber`, `bestNameCandidate`) | `test/core/utils/parser_helper_test.dart` |
| Luhn validator | `test/features/card_scanner/luhn_validator_test.dart` |
| Card parser (number, expiry, holder, brand, OCR noise) | `test/features/card_scanner/card_parser_test.dart` |
| Card scanner cubit | `test/features/card_scanner/card_scanner_cubit_test.dart` |
| Passbook parser (IFSC, account, holder, edge cases) | `test/features/passbook_scanner/passbook_parser_test.dart` |
| Passbook scanner cubit | `test/features/passbook_scanner/passbook_scanner_cubit_test.dart` |

Cubit tests use `bloc_test` + `mocktail` so we never touch the camera, gallery or ML Kit during unit testing.

---

## Code quality

- Single-source-of-truth constants (`AppColors`, `AppStrings`, `AppDimensions`, `AppRegex`, `AppConstants`).
- Reusable widgets (`AppText`, `AppButton`, `AppCard`, `AppImagePreview`, `AppErrorView`, `AppEmptyView`, `AppLoader`, `AppTextField`, `AppSpacing`, `InfoRow`, `CommonScaffold`).
- `Equatable` models with `copyWith`, `toJson`, `fromJson`.
- All parsers are **stateless** and **pure** → trivial to test.
- Null-safe end-to-end.
- Lint-clean against `package:flutter_lints`.
