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
