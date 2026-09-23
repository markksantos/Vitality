# Vitality — App Store Connect submission

Copy fields verbatim; all are inside their character limits.

> **Rewritten 2026-09-23 to match the binary.** The app is free to download and
> sells **one** in-app purchase: Vitality Pro, a $2.99 non-consumable
> (`com.mark.vitality.pro.lifetime`). The previous version of this file said
> "In-App Purchase: None" — that predates `ProManager.swift` / `Vitality.storekit`
> (28 Jul) and would have produced a listing whose paywall requests a product
> that does not exist. Remaining decisions are under
> [Before this can be submitted](#before-this-can-be-submitted).

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
| Price (the app) | Free — **leave the app itself Free**; revenue is the IAP below |
| In-app purchases | Yes — one non-consumable, $2.99 (see In-App Purchase) |
| Devices | iPhone |
| Minimum iOS | **26.1** — see the note below |

## Promotional text (170 max)

```
Log meals, the pantry, workouts and weekly trends with no account and no key. One optional purchase, Vitality Pro, lifts the pantry limit and adds long-range trends.
```
(165 characters)

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

FREE, AND ONE OPTIONAL UPGRADE
Everything above is free, with no account and no trial clock. The pantry holds up to 25 items and trends cover the last week.
Vitality Pro is a single one-time purchase — not a subscription, nothing renews. It lifts the pantry limit and adds the month and three-month trend windows. It is shared with your Family Sharing group and restores on any device signed in to your Apple Account.

OPTIONAL AI, ON YOUR TERMS
Photo scanning, pantry scanning and recipe suggestions run on Anthropic's API using a key you supply in Settings. It is stored in your device's Keychain, is sent only to Anthropic, and never reaches us. We do not resell it, meter it, or mark it up — you pay Anthropic directly for exactly what you use, and you can remove the key at any time.

The AI features are not part of Vitality Pro, and every other feature — logging, the pantry, fitness, analytics — works with no key at all.

YOUR DATA STAYS YOURS
No account. No sign-in. No analytics, no advertising, no third-party SDKs. Everything you log is stored locally on your iPhone. Barcode scans and food searches look the product up in the free Open Food Facts database; only the barcode or search words are sent.
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
| Copyright | 2026 Mark Studios LLC |
| Privacy Policy URL | https://nosleeplab.com/vitality/privacy |

## In-App Purchase

One product. Create it in App Store Connect → your app → Monetization → In-App
Purchases before submitting the first build, then attach it to the version
("In-App Purchases and Subscriptions" section of the 1.0 version page).

| Field | Value |
|---|---|
| Type | **Non-Consumable** |
| Reference name (64 max) | `Vitality Pro (Lifetime)` (23) |
| Product ID | `com.mark.vitality.pro.lifetime` — must match `ProManager.proProductID` and `Vitality.storekit` exactly |
| Price | USD **$2.99** (let App Store Connect derive the other storefronts) |
| Family Sharing | **On** (`familyShareable: true` in `Vitality.storekit`; the paywall promises it. Cannot be turned off once on.) |
| Availability | All storefronts the app is in |
| Display name (30 max) | `Vitality Pro` (12) |
| Description (45 max) | `Unlimited pantry, month and 3-month trends` (42) |
| Review screenshot | the paywall — `ProPaywallView` (Settings → Vitality Pro → Upgrade to Pro). A capture is in the overnight kit: `iap-review-paywall.png` |
| Review notes | `Non-consumable. Unlocks unlimited pantry items (free tier: 25) and the Month / 3 Months analytics windows (Week is always free). Paywall: Settings > Vitality Pro > Upgrade to Pro, or add a 26th pantry item, or tap Month in Analytics. Restore Purchase is in the paywall and in Settings.` |

What the binary actually gates (`Services/ProManager.swift`):

- `freePantryItemLimit = 25` → `canAddPantryItem(existingCount:)`
- `canView(_ range:)` → `isPro || range == .week` (month and 3-month analytics are Pro)
- AI features and manual target overrides are **not** gated (deliberately — see
  the doc comment at the top of `ProManager.swift`).

Paywall copy the listing must not contradict (`Services/ProPaywallView.swift`):
"One-time purchase. Not a subscription, and nothing renews." · "Pro unlocks on
every device signed in to your Apple Account." · links to
`nosleeplab.com/vitality/privacy` and `nosleeplab.com/vitality/terms`.

## App privacy

Data collection: **none**. Answer "No" to "Do you or your third-party partners
collect data from this app?" — no analytics, no accounts, no advertising
identifier, and no server of ours.

Declare the Anthropic call honestly in review notes (below): meal and pantry
photos are transmitted to Anthropic's API for analysis when the user has supplied
their own key and taps to scan. That is a user-initiated transmission to a third
party the user has their own contract with, not collection by us — but it must be
described rather than omitted.

**Open Food Facts**: barcode lookups (`BarcodeScannerView.swift` →
`world.openfoodfacts.org/api/v2/product/<barcode>.json`) and food search
(`FoodDatabaseService.swift` → `world.openfoodfacts.org/cgi/search.pl`) send the
barcode or the typed search words, and nothing else, to a public database. Not
linked to the user, not stored by us, served in real time — it does not change
the "No data collected" answer, but it is disclosed in the description and the
privacy policy.

**Purchases**: StoreKit 2 directly, no purchase SDK. Apple handles payment; the app
stores only a local unlocked flag. Nothing to declare beyond that.

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
works fully with no key. Barcode scanning and food search look products up in
the public Open Food Facts database and need a connection; nothing else does.

IN-APP PURCHASE
One non-consumable, Vitality Pro (com.mark.vitality.pro.lifetime). It unlocks
unlimited pantry items (the free tier holds 25) and the Month and 3 Months
analytics windows (Week is always free). To reach the paywall: Settings >
Vitality Pro > Upgrade to Pro, or tap Month in Analytics. Restore Purchase is on
the paywall and in Settings. The AI features are not part of Pro.

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
A hosted endpoint would add a *subscription* alongside the existing Pro unlock
(ProManager's doc comment says so), so it should be decided before the App Store
Connect record is created rather than after. Shipping 1.0 as it is — free app,
$2.99 Pro for pantry + trends, AI on the user's own key — is coherent and is what
this file now describes.

### 2. The deployment target

`IPHONEOS_DEPLOYMENT_TARGET = 26.1` excludes every device that has not updated to
the newest OS. That is a deliberate consequence of building on Liquid Glass, but
it should be a conscious launch decision rather than a default. Lowering it is not
trivial — the UI depends on APIs that do not exist earlier.

### 3. The BMR formula uses the male constant for everyone

Mifflin-St Jeor takes `+5` for males and `-161` for females, a 166 kcal
difference on the resting rate before the activity multiplier compounds it.
Vitality has no biological sex field, so `NutritionTargetCalculator` uses the
male constant unconditionally and over-estimates for roughly half of its users.

That is a product gap, not an arithmetic one — the fix is a field in onboarding
and one branch in the formula — but a nutrition app that shows a calorie target
should not be quietly wrong for half the people it shows it to. Either add the
field or say so in the app.

### 4. The usual

- [ ] Rotate the Anthropic key that was previously hardcoded (`sk-ant-…jAAA`)
- [ ] Apple Developer Program membership
- [ ] Create the App Store Connect record **and the Vitality Pro IAP** (section above)
- [ ] Run `PurchaseFlowTests` with ⌘U in Xcode — 9 cases skip under headless `xcodebuild`, so the purchase flow has not been executed end to end
- [ ] Confirm `DEVELOPMENT_TEAM = 8W75GJ2YQ3` is the team paying the $99
- [ ] Confirm the nosleeplab privacy/support/terms pages mention Pro and Open Food Facts (drafts: overnight kit `legal/Vitality/`)
- [ ] Decide whether to add a biological sex field to onboarding (section 3 above)
