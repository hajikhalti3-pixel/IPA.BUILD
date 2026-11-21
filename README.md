# NumberKeys – GitHub Actions iOS build

This repository is arranged for an XcodeGen-generated iOS app + custom keyboard extension and a GitHub Actions IPA build.

## Before the first build (important)

1. Change the example bundle IDs in `project.yml`:
   - `com.example.NumberKeys`
   - `com.example.NumberKeys.Keyboard`
   Use IDs you control and that are registered/available for your Apple Developer team.
2. Change the App Group in BOTH entitlements and `NumberKeys/SharedSettings.swift` from `group.com.example.NumberKeys` to the exact App Group you create in the Apple Developer portal.
3. Enable the **App Groups** capability for both App IDs and register the same App Group.
4. Ensure the keyboard extension App ID is registered and associated with the containing app as required by Apple's developer portal.
5. Commit and push this folder to a GitHub repository.

## GitHub repository secrets

Create these under **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Value |
|---|---|
| `APPLE_TEAM_ID` | Your 10-character Apple Developer Team ID |
| `APPLE_KEY_ID` | Key ID of an App Store Connect API key |
| `APPLE_ISSUER_ID` | Issuer ID for that API key |
| `APPLE_API_PRIVATE_KEY_BASE64` | Base64 of the downloaded `.p8` private key |

To create the base64 value on macOS:
```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | tr -d '\\n'
```

Create an App Store Connect API key with a role that can access certificates, identifiers and profiles / manage signing assets. The Apple Developer account must have the required program membership and permissions. Automatic signing may need the App IDs and App Group configured in the Apple Developer portal first.

## Run the workflow

- Push to `main`, or
- GitHub → Actions → **Build NumberKeys IPA** → **Run workflow**.

When successful, open the workflow run and download the `NumberKeys-IPA` artifact.

## Build output

The workflow exports an App Store Connect-signed IPA. This is not automatically installed on an iPhone. For App Store distribution, the app must also pass Apple's App Store review. For direct device testing, use an appropriate development/ad hoc distribution workflow and provisioning profile.

## Local project generation

Install XcodeGen, then:
```bash
brew install xcodegen
xcodegen generate
open NumberKeys.xcodeproj
```

## Current feature scope / limitations

- Layout choices: QWERTY, QWERTZ, AZERTY.
- Persistent 0–9 row setting and shared preferences through App Groups.
- Saved language preference list populated from iOS locale language identifiers.
- Globe key advances among keyboards the user has enabled in iOS Settings.

The language catalogue is not equivalent to 160 fully implemented input methods. It does not automatically install system dictionaries or implement autocorrect, prediction, transliteration, or complex-script IMEs for every language. A third-party keyboard cannot silently add system keyboards; users enable the extension in iOS Settings. Secure text fields and some system contexts use Apple's keyboard.
