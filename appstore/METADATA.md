# Vitality — App Store Connect submission

Copy fields verbatim; all are inside their character limits.

> **Not ready to submit.** Two decisions block this listing — see
> [Before this can be submitted](#before-this-can-be-submitted). Everything else
> below is done.

## App information

| Field | Value |
|---|---|
| Name (30 max) | `Vitality: Nutrition & Pantry` (28) |
| Subtitle (30 max) | `Meals, macros and what's in` (27) |
| Bundle ID | `com.mark.vitality.Vitality` |
| SKU | `VITALITY-IOS-001` |
| Primary category | Health & Fitness |
| Secondary category | Food & Drink |
| Content rights | Does not contain, show, or access third-party content |
| Age rating | 4+ |
| Price | Free |
| Devices | iPhone |
| Minimum iOS | **26.1** — see the note below |

## Promotional text (170 max)

```
Logging meals, the pantry, workouts and analytics all work with no account and no key. The optional AI photo scanning uses an Anthropic key you supply and control.
```
(163 characters)

## Description

```
Vitality keeps the three things that actually decide how you eat in one place: what you ate, what is in the house, and what you did about it.

WHAT YOU ATE
Log a meal and Vitality does the maths — calories, protein, carbs, fat and fibre, per item and per meal, against targets set from your own height, weight, age and activity level. The day's snapshot is three rings and a list, not a spreadsheet.

WHAT IS IN THE HOUSE
A pantry that knows the difference between the cupboard, the fridge and the freezer. Items are grouped by category with quantities and expiry dates, so "what do I already have" has an answer before you shop.

WHAT YOU DID
Workouts logged next to your food rather than in a separate app, with Apple Health for steps and activity, and a weekly view that puts training and eating on the same page.

TRENDS WORTH READING
Averages over a week, a month, or three months. Nutrition trends by calories or by macro. A breakdown of where the calories actually came from.

OPTIONAL AI, ON YOUR TERMS
Photo scanning, pantry scanning and recipe suggestions run on Anthropic's API using a key you supply in Settings. It is stored in your device's Keychain, is sent only to Anthropic, and never reaches us. We do not resell it, meter it, or mark it up — you pay Anthropic directly for exactly what you use, and you can remove the key at any time.

Every other feature — logging, the pantry, fitness, analytics — works with no key at all.

YOUR DATA STAYS YOURS
No account. No sign-in. No analytics, no advertising, no third-party SDKs. Everything is stored locally on your iPhone.
```

## Keywords (100 max, comma-separated, no spaces)

```
nutrition,calorie counter,macros,pantry,meal tracker,food diary,protein,fitness,expiry,groceries
```
(96 characters)

## URLs

| Field | Value |
|---|---|
| Support URL | https://nosleeplab.com/vitality/support |
| Marketing URL | https://nosleeplab.com/apps/vitality |
| Privacy Policy URL | https://nosleeplab.com/vitality/privacy |

## In-App Purchase

**None, deliberately, for now.** See below.

## App privacy

Data collection: **none**. Answer "No" to "Do you or your third-party partners
collect data from this app?" — no analytics, no accounts, no advertising
identifier, and no server of ours.

Declare the Anthropic call honestly in review notes (below): meal and pantry
photos are transmitted to Anthropic's API for analysis when the user has supplied
their own key and taps to scan. That is a user-initiated transmission to a third
party the user has their own contract with, not collection by us — but it must be
described rather than omitted.

**HealthKit**: the app reads steps and activity. Declare the HealthKit usage and
make sure the Info.plist strings explain it. Vitality does not write to Health.

Export compliance: no encryption beyond what iOS provides — answer "No".

## Review notes

```
No account, no sign-in. The app opens into a five-step onboarding that collects
height, weight, age and activity level purely to compute local calorie and macro
targets; none of it is transmitted.

AI FEATURES AND THE API KEY
Meal photo analysis, pantry scanning and recipe suggestions call Anthropic's API
using a key the *user* supplies in Settings > AI Features. The app ships with no
key and there is no key embedded in the binary. To test those features you will
need to paste an Anthropic key (console.anthropic.com); without one the app shows
a clear "not configured" state rather than failing.

Every other feature — meal logging, the pantry, fitness logging, and analytics —
works fully with no key and no network.

The key is stored in the Keychain with kSecAttrAccessibleAfterFirstUnlockThis
DeviceOnly and is transmitted only to api.anthropic.com.
```

## Screenshots

Delivered: 6.9" iPhone, five frames, in `screenshots/iphone-6.9/`.

| File | Caption |
|---|---|
| 01-home.png | Calories and macros, already counted |
| 02-meals.png | Every meal broken down to the gram |
| 03-pantry.png | Know what you already have |
| 04-fitness.png | Training and eating, in one app |
| 05-analytics.png | A week you can actually read |

App preview: `../marketing/out/app-preview-6.9.mp4`.

Regenerate with:

```sh
UDID=$(xcrun simctl list devices booted | grep -o '[0-9A-F-]\{36\}' | head -1)
cd Vitality
DIR=$(xcodebuild -project Vitality.xcodeproj -scheme Vitality \
  -destination "platform=iOS Simulator,id=$UDID" -configuration Debug \
  -showBuildSettings | awk -F' = ' '/ BUILT_PRODUCTS_DIR /{print $2; exit}')
xcrun simctl install "$UDID" "$DIR/Vitality.app"

for screen in home meals pantry fitness analytics; do
  xcrun simctl terminate "$UDID" com.mark.vitality.Vitality
  xcrun simctl launch "$UDID" com.mark.vitality.Vitality \
    -hasCompletedOnboarding YES -scSeed YES -scScreen "$screen"
  sleep 4
  xcrun simctl io "$UDID" screenshot "../marketing/shots/$screen.png"
done

cd ../../_pipeline/marketing && node scripts/render.mjs --app ../../Vitality
```

## Before this can be submitted

### 1. The AI cost model (blocking the listing copy, not the build)

The description above sells bring-your-own-key honestly, and that is shippable.
But it is a hard wall for a consumer nutrition app — most people do not have an
Anthropic key, and the headline feature will go unused by the majority of
installs.

The alternative is a small hosted endpoint holding one key server-side, funded by
a subscription. `AIEndpoint` in `Services/APIKeyStore.swift` is the seam for it.
That changes this listing materially (it would gain an IAP and different copy), so
it should be decided before the App Store Connect record is created rather than
after.

**No IAP was added in the meantime, on purpose.** With bring-your-own-key there is
no cost to recover, and bolting a paywall onto features I had not verified would
risk exactly the failure BabyHQ shipped with — a purchase that unlocks nothing.

### 2. The deployment target

`IPHONEOS_DEPLOYMENT_TARGET = 26.1` excludes every device that has not updated to
the newest OS. That is a deliberate consequence of building on Liquid Glass, but
it should be a conscious launch decision rather than a default. Lowering it is not
trivial — the UI depends on APIs that do not exist earlier.

### 3. The usual

- [ ] Rotate the Anthropic key that was previously hardcoded (`sk-ant-…jAAA`)
- [ ] Apple Developer Program membership
- [ ] Create the App Store Connect record
- [ ] Deploy the three nosleeplab pages so the URLs above resolve
- [ ] Write real tests — `VitalityTests.swift` is still the Xcode template stub
