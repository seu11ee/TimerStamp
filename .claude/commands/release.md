Submit the app to App Store review using Fastlane.

Steps:
1. Check the current git branch — abort if not on `main`
2. Check for uncommitted changes — abort if dirty
3. Confirm the current version number in the project and ask the user to verify before proceeding
4. Run `bundle exec fastlane release`

After completion, report:
- Version and build number submitted
- App Store submission success or failure
- Any errors encountered
