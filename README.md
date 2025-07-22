# GitHubApp

## Inspiration
This Repository is intended to be a new pattern based on Clean, Redux and MVVM, so from time to time, i'll update this readme with all implementation samples and testability.

## Git Hooks Setup

This project uses a versioned pre-commit hook to enforce SwiftFormat linting before every commit.

### How to enable the pre-commit hook

After cloning the repository, run:

```sh
sh setup-git-hooks.sh
```

This will install the pre-commit hook locally. The hook will block any commit if SwiftFormat finds files that need to be reformatted. To fix formatting issues, run:

```sh
mint run swiftformat .
```

Then stage the changes and commit again.
