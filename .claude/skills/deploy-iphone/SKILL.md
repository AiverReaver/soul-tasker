---
name: deploy-iphone
description: Use when the user wants Hearthrise on their real iPhone ("install on my phone", "deploy to iphone", "test on device"), or pastes a device build, signing or install error.
argument-hint: "[--demo]"
---

# deploy-iphone

Run `app/tool/deploy_iphone.sh`. It checks signing and the phone, builds a release app, installs it with `devicectl` (steadier over Wi-Fi than `flutter run`) and launches it. Each failure prints its own fix.

1. Preflight first, which is quick:
   ```bash
   cd app && tool/deploy_iphone.sh --check
   ```
2. If it passes, run the build and install in the background, because a release build takes 1 to 3 minutes:
   ```bash
   cd app && tool/deploy_iphone.sh            # real app, the user's data
   cd app && tool/deploy_iphone.sh --demo     # seeded demo data
   ```
   Use `--demo` only when the user asks for test data. It fills an empty database, so on a phone that already has data it changes nothing.
3. On a failure, relay the `✗` line and its `Fix:` line exactly. Steps on the phone or in Xcode (Trust, Developer Mode, signing in) are the user's to do. Don't retry until they say it's done.
4. When it succeeds, say which build went on (`main.dart` or `main_demo.dart`) and that the app is running. Installing over an existing app keeps its data. To reset the app, the user deletes it from the home screen.

Errors seen before on this project and what fixed them:

| Error | Fix |
| --- | --- |
| `Uncategorized (Xcode): Exited with status code 255` over Wi-Fi | Open `ios/Runner.xcworkspace` and run Product > Build once, or plug in by USB. |
| `No valid code signing certificates were found` | Xcode > Settings > Accounts: sign in, then Runner > Signing & Capabilities > Team `258S337596`. |
| `Could not run build/ios/iphoneos/Runner.app` | Unlock the phone, then trust the developer under Settings > General > VPN & Device Management. |
