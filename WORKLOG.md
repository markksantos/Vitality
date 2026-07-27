# Vitality — App Store readiness pass

2026-07-26. **Not finished.** Two submission blockers are fixed and the repo is no
longer booby-trapped, but this app needs more than the others did — see
[What is left](#what-is-left).

## Fixed

### A live Anthropic API key was compiled into the app

`Services/APIKeys.swift` held a real key as a `static let`, with comments directly
beneath it explaining why that must never happen. Three separate problems:

- Anything in an app bundle is extractable. `strings` on the binary from any
  downloaded IPA hands the key over, and the bill lands on whoever owns it.
- Anthropic's terms do not permit distributing a key in a client application.
- Every user would have spent one person's quota, so it could not have shipped to
  a second person at all.

The key was **never committed** — the file was untracked and absent from history —
but it must still be treated as burned and rotated. It is now gone from the
working tree, and `.gitignore` covers `**/APIKeys.swift`.

Replaced with `APIKeyStore`: the user's own key in the Keychain, with
`AfterFirstUnlockThisDeviceOnly` so a credential does not ride along in an iCloud
backup restored onto another device. `AIService` reads it per request instead of
capturing it at init — previously a service constructed before the key existed
stayed "not configured" until relaunch.

### The app icon had an alpha channel

`AppIcon.png` was RGBA. App Store Connect rejects that outright, so no build
could have been accepted. Replaced and flattened.

### A duplicated source tree that nothing built from

The outer repo tracked a byte-identical copy of `App/`, `Components/`, `Models/`,
`Services/`, `Utilities/` and `Views/`. Nothing compiled from it: the project uses
filesystem-synchronized groups rooted at `Vitality/Vitality`, so only the inner
tree — a **separate git repository** — is real. Editing the tracked copy changed
nothing about the app.

It cost time today: adding a Settings view to what looked like the source of truth
produced `Multiple commands produce SettingsView.stringsdata`, because a 380-line
`SettingsView` already existed in the tree that builds, misfiled under `Services/`.
The duplicate is removed and `README.md` now states which tree is real.

The inner repo also had 45 untracked source files and an index still referencing
files added-then-deleted inside `.xcodeproj/`. Both cleaned up.

### Smaller

- Settings had no AI key entry, so the headline feature was unreachable after the
  hardcoded key was removed. Added, with a `SecureField` and a prefix check.
- The only external link was `https://vitality.app`, which does not exist. Now
  points at the real nosleeplab pages.
- Version and build were hardcoded to `"1.0.0"` and `"2026.02.05"` — wrong from
  the first release, and useless in a bug report. Both read from the bundle now.
- Model updated from `claude-3-5-sonnet-20241022` to `claude-sonnet-4-5`.

## Corrected assumption

`TODO.md` lists camera capture and AI meal analysis as unimplemented. They are
not: `Services/CameraView.swift` → `MealsView` → `VisionService` →
`AIService.analyzeMealPhoto` is wired end to end and persists the result. The
TODO is stale and should not be trusted as a status report.

## What is left

- **Monetization: none, and the right answer needs a decision.** With
  bring-your-own-key the AI cost is the user's, so there is no server cost to
  cover — but asking every user for an Anthropic key is a hard wall for a consumer
  nutrition app, and most people will not get past it. The product answer is a
  small hosted endpoint holding one key server-side, paid for by a subscription,
  so no credential reaches the device. `AIEndpoint` in `APIKeyStore.swift` is the
  seam for exactly that. Standing that up costs money and touches production, so
  it is Mark's call, not mine.
- **`IPHONEOS_DEPLOYMENT_TARGET = 26.1`** excludes every device that has not
  updated to the newest OS. Deliberate for a Liquid Glass UI, but worth a
  conscious decision before launch rather than after.
- **No real tests.** `VitalityTests.swift` is the Xcode template stub. The other
  four apps in this pass got regression suites; this one has none, and it is the
  largest of them at 101 source files.
- **No screenshots, metadata, or nosleeplab pages yet.** Capturing them needs a
  way past onboarding — the other apps got a DEBUG-only `ScreenshotMode`, and this
  one still needs the same.
- **`Services/` is a dumping ground.** `SettingsView`, `ProfileView`,
  `CameraView`, `BarcodeScannerView` and `ProfileMenuView` are views living in
  `Services/`, which is why the existing Settings screen was invisible to a grep
  for it. Worth moving.

## Blocked on Mark

- **Rotate the Anthropic key** (`sk-ant-…jAAA`). It was on disk in source and
  would have shipped in any build made from this tree.
- Decide the AI cost model above before this can be marketed as "AI-powered".
- Apple Developer Program membership.

---

## Second pass — the nutrition maths

The first pass fixed the hardcoded API key and left the app with no tests. There
are now 32, and writing them found three real bugs.

### The calorie calculation existed twice, and the copies disagreed

`OnboardingContainerView.calculateTargets` and `ProfileView.recalculateTargets`
both derived every target from height, weight, age, activity and goal. They had
drifted:

| | Onboarding | Profile editor |
|---|---|---|
| Muscle-building floor | `max(target, 2500)` | none |
| Weight-loss protein | 0.9 g/lb | 0.8 g/lb |
| Weight-loss macro split | 35% carbs / 30% fat | 45% / 30% |
| Fibre, sodium, cholesterol | set from health conditions | never touched |

So opening the profile editor and saving without changing a single input moved
your targets — and left the sodium and cholesterol limits at whatever they had
been rather than at what your conditions imply. Neither copy could be tested,
because both were private methods on SwiftUI views.

There is now one implementation, `NutritionTargetCalculator` in
`Models/NutritionTargets.swift`, a pure function over the inputs, with
`UserProfile.recalculateNutritionTargets()` as the single call site for both
views.

### A weight-loss target could land under 800 kcal/day

A deficit was a flat 500 kcal off maintenance with no lower bound. For a small,
older, sedentary person maintenance is around 1300, so the app would have shown
a daily target of roughly 800 — and a nutrition app displaying that is doing
harm, quite apart from App Review guideline 1.4.1.

Two floors now: an absolute 1200, and the person's own resting metabolic rate,
so a "deficit" can never be less than what the body burns doing nothing. A test
sweeps weight 40–130 kg × four ages × every activity level and asserts the
invariant holds throughout.

The BMR floor was written as `Int(bmr)` first. `Int(2152.5)` is 2152, which is
below the rate it is meant to floor — the guard missed by a calorie in exactly
the cases where it was the guard that mattered, and the sweep caught it. It
rounds up now.

### Choosing "Weight Loss" instead of "Lose weight" did nothing

`HealthGoal` carries three synonym pairs — `loseWeight`/`weightLoss`,
`buildMuscle`/`muscleGain`, `eatHealthier`/`healthyEating` — and the onboarding
picker listed `allCases`, so the user was shown the same goal twice, worded
slightly differently, and asked to pick one. The calculation switched only on
`loseWeight` and `buildMuscle`, so picking either of the other names silently
produced maintenance calories.

Goals now map to a `CalorieIntent`, so the synonyms behave identically, and the
picker reads `HealthGoal.selectable`, which drops the duplicates. The cases stay
in the enum because a stored profile may hold one.

### Also

- **The hero screenshot showed a flat 2,000 kcal.** `ScreenshotMode` seeded a
  profile but never ran the calculation onboarding would have run, so the
  marketing shot displayed the generic default rather than what the fixture's
  body actually implies. It now shows 2,699 / 140 g / 303 g. All five captures
  and the app preview were re-rendered.

## Known limitation, deliberately not fixed here

**Mifflin-St Jeor's `+5` constant is the male form.** The female form is `-161`,
a 166 kcal difference before the activity multiplier compounds it. Vitality has
no biological sex field, so the calculator uses the male constant for everyone
and over-estimates for roughly half its users.

Fixing it properly is a field in onboarding, a property on `UserProfile`, and
one branch in the formula — a product change rather than a bug fix, and one that
should be a decision rather than something slipped in. It is documented at the
call site and in `appstore/METADATA.md` rather than left silent.

## Still blocked on Mark

- **The AI cost model.** Bring-your-own-key ships today and is honest, but it is
  a wall most consumers will not climb. `AIEndpoint` is the seam for a hosted
  proxy funded by a subscription. This decides the listing copy, so it should be
  settled before the App Store Connect record exists.
- **Rotate the Anthropic key** that was previously hardcoded.
- **The deployment target is iOS 26.1**, which excludes every device that has
  not updated. Deliberate — the UI is built on Liquid Glass — but it should be a
  launch decision rather than a default.
- **Apple Developer Program membership.**
