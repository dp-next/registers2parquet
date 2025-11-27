# Changelog

Since we follow [Conventional
Commits](https://decisions.seedcase-project.org/why-conventional-commits)
when writing commit messages, we're able to automatically create formal
"releases" of the website based on the commit messages. Releases in the
context of websites are simply snapshots in time of the website
content. We use
[Commitizen](https://decisions.seedcase-project.org/why-semantic-release-with-commitizen)
to be able to automatically create these releases, which uses
[SemVar](https://semverdoc.org) as the version numbering scheme.

Because releases are created based on commit messages, we release quite
often, sometimes several times in a day. This also means that any
individual release will not have many changes within it. Below is a list
of the releases we've made so far, along with what was changed within
each release.

## 0.3.0 (2025-11-27)

### Feat

- ✨ implement `convert_to_parquet()` (#84)

## 0.2.4 (2025-11-13)

### Refactor

- :fire: remove deprecated functions (#70)

## 0.2.3 (2025-11-10)

### Fix

- :bug:no visible binding for global variable (#62)

## 0.2.2 (2025-11-07)

### Refactor

- :recycle: export get helper functions (#51)

## 0.2.1 (2025-11-07)

### Refactor

- :fire: remove icd related functions and vignette (#50)

## 0.2.0 (2025-11-06)

### Feat

- :tada: start of project (copied from DST servers)
