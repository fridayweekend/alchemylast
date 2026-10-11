# MT Alchemy Platform

A Flutter prototype combining the corporate website, learning portal, store, employer workspace and admin screens.

## Run

Requires Dart 3.11 or newer because of shared_preferences 2.5.6. Verified with Flutter 3.47.7 / Dart 3.13.5.

```powershell
cd "C:\Users\user\OneDrive\Desktop\Alchemy"
flutter pub get
flutter run -d edge
```

Use `flutter run -d chrome` if Chrome is installed. Release: `flutter build web`.

## Demo sign-in

Use the shared Login page. Roles come from the account; registration cannot create administrators or trainers.

| Role | Email | Password |
| --- | --- | --- |
| Learner | learner@mtalchemy.demo | AlchemyLearner!26 |
| Trainer | trainer@mtalchemy.demo | AlchemyTrainer!26 |
| Employer | employer@mtalchemy.demo | AlchemyEmployer!26 |
| Admin | admin@mtalchemy.demo | AlchemyAdmin!26 |

These are public prototype credentials, not production authentication. Newly registered accounts exist until the app restarts; use fictional details. Sessions are not persisted. Local browser storage is not a security boundary.

## Features and state

- Corporate pages, responsive navigation, sitemap and validated enquiry submission.
- Learning Hub, explicit free prototype enrollment, account-specific progress, quiz and certificate eligibility. Certificate PDF export uses the existing report generator.
- Store, physical/digital products, cart, checkout, pending payment, orders, digital resources and shipping status.
- Employer employees, course assignment and reports. Assignments use the LMS catalogue; an employee using the same email sees assigned courses, and lesson progress/quiz scores update the employer report.
- Admin product/stock, order/payment, quotation and enquiry management.
- Trainer course preview and local sample-assessment feedback.

Commerce records, product images, orders, quotes, enquiries, employees and assignments are saved using shared_preferences on the current device/browser origin. Learner progress is stored separately by email. Employer records are filtered by employer account. The cart is a shared device cart. Trainer feedback is saved locally. Private browsing, clearing site data or changing the localhost port can remove or separate this data. Saving errors appear in the shared site shell.

Checkout does not charge money. Admin can mark a demo order Paid or Failed; digital files unlock only after Paid. Physical stock is reserved at checkout, restored on payment failure, and rechecked before a retry. Shipping and tracking are simulated. Browser export requests a download; Windows exports save to Downloads.

LMS lessons, quizzes, trainer statistics and learners remain sample content. Enrollment does not process the catalogue price. Certificate PDFs are unaccredited demo documents; the QR graphic is a placeholder. There is no real backend, email, payment provider or cross-device synchronization.

## Project map

- `lib/pages.dart`, `lib/widgets.dart`, `lib/theme.dart`: public routes, screens and shared design.
- `lib/screens/lms/`, `lib/data/progress_store.dart`: learning and trainer journeys.
- `lib/commerce/`: catalogue, cart, orders, quotes and persisted commerce state.
- `lib/employer/`, `lib/admin/`: employer and administrative tools.
- `lib/shared/`: role sessions, reusable portal components, PDF and file export.
- `docs/commerce_employer_erd.md`: proposed backend ERD.
- `docs/completion_report.md`: changes, validation evidence, limitations and changed files.

## Verification

```powershell
flutter analyze
flutter test
flutter build web
```

Tests include auth restrictions, selected-course redirects, certificate eligibility, quiz completion, enquiry validation, persistence, stock/payment transitions, digital entitlements, employer isolation and public/portal rendering at 390 and 1440 pixels.
