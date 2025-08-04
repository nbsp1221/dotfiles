Analyze git log to understand this project's commit convention, then create an appropriate commit message in English for the current changes.

Convention rules:
- If using Conventional Commits (feat:, fix:, etc.), follow the same pattern:
  - feat: new feature
  - fix: bug fix
  - docs: documentation only
  - style: formatting, missing semicolons, etc.
  - refactor: code change that neither fixes a bug nor adds a feature
  - test: adding or updating tests
  - chore: updating build tasks, package manager configs, etc.
  - perf: performance improvements
  - ci: changes to CI configuration files and scripts
  - build: changes affecting build system or external dependencies
  - revert: reverting a previous commit
- If using gitmoji style [emoji] [message], follow the same pattern:
  - 🐛 (:bug:) Fix a bug
  - ✨ (:sparkles:) Introduce new features
  - 📝 (:memo:) Add or update documentation
  - ⚡ (:zap:) Improve performance
  - 🔥 (:fire:) Remove code or files
  - 🎨 (:art:) Improve structure/format of code
  - ♻️ (:recycle:) Refactor code
  - ✅ (:white_check_mark:) Add or update tests
  - 🚀 (:rocket:) Deploy stuff
  - 💄 (:lipstick:) Add or update UI and style
  - 🔧 (:wrench:) Add or update configuration files
  - ➕ (:heavy_plus_sign:) Add a dependency
  - ➖ (:heavy_minus_sign:) Remove a dependency
  - 🚧 (:construction:) Work in progress
  - 🚑️ (:ambulance:) Critical hotfix
  - 🔒️ (:lock:) Fix security or privacy issues
  - 💚 (:green_heart:) Fix CI Build
  - 🏗️ (:building_construction:) Make architectural changes
  - 🩹 (:adhesive_bandage:) Simple fix for a non-critical issue
  - 📦️ (:package:) Add or update compiled files or packages
  - 🔀 (:twisted_rightwards_arrows:) Merge branches
  - ⏪️ (:rewind:) Revert changes
  - 🏷️ (:label:) Add or update types
  - 🌐 (:globe_with_meridians:) Internationalization and localization
  - ✏️ (:pencil2:) Fix typos
- Otherwise, follow the most commonly used style in the project

Check git diff and create a commit message that accurately describes the changes.
