# Vitality

AI-powered health and nutrition companion for iOS 26+ — meal tracking, pantry
management, and fitness, built with SwiftUI and SwiftData in Apple's Liquid Glass
design language.

## Repository layout — read this first

**The project of record is `Vitality/`, which is its own git repository.**

```
Vitality/                     <- this repo: documentation only
├── README.md, ARCHITECTURE.md, SETUP_GUIDE.md, TODO.md
└── Vitality/                 <- a separate git repo; the app lives here
    ├── Vitality.xcodeproj
    ├── Vitality/             <- sources (App, Models, Services, Views, …)
    ├── VitalityTests/
    └── VitalityUITests/
```

Until 2026-07-26 this outer repo also tracked a byte-identical copy of `App/`,
`Components/`, `Models/`, `Services/`, `Utilities/`, and `Views/`. Nothing built
from it: the Xcode project uses filesystem-synchronized groups rooted at
`Vitality/Vitality`, so it compiles the inner tree only. Editing the outer copy
changed nothing about the app, which is a very expensive way to lose an afternoon.
The duplicate has been removed. `Resources/` and `ViewModels/` were empty and went
with it.

## Building

```sh
cd Vitality
xcodebuild -project Vitality.xcodeproj -scheme Vitality \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
```

Requires iOS 26.1 or later (`IPHONEOS_DEPLOYMENT_TARGET = 26.1`) — the UI is built
on Liquid Glass.

## AI features and the API key

Meal photo analysis, pantry scanning, and recipe suggestions call Anthropic's API.
**The app ships with no key.** Each user supplies their own in Settings → AI
Features, and it is stored in the device Keychain (`APIKeyStore`).

This is deliberate. A key compiled into the binary is extractable from any IPA,
is not permitted by Anthropic's terms, and would bill one person for every user.

It is also a hard wall for a consumer app — most people do not have an Anthropic
key. The intended answer is a small hosted endpoint holding one key server-side,
paid for by a subscription, so no credential ever reaches the device.
`AIEndpoint` in `APIKeyStore.swift` is the seam for that: swapping to a proxy is a
change of configuration, not a rewrite.

Everything else — logging meals, the pantry, fitness, analytics — works with no
key at all.
