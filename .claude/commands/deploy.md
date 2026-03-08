Deploy the app to TestFlight using Fastlane.

Steps:
1. Check the current git branch — warn if not on `main`
2. Check for uncommitted changes — warn if dirty
3. Run `bundle exec fastlane test` first and abort if tests fail
4. Run `bundle exec fastlane beta`

After completion, report:
- Build number uploaded
- TestFlight upload success or failure
- Any errors encountered
