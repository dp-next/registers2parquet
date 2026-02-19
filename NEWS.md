# Changelog

Since we follow
[Conventional Commits](https://decisions.seedcase-project.org/why-conventional-commits)
when writing commit messages, we're able to automatically create formal
"releases" of the website based on the commit messages. Releases in the
context of websites are simply snapshots in time of the website content.
We use
[Commitizen](https://decisions.seedcase-project.org/why-semantic-release-with-commitizen)
to be able to automatically create these releases, which uses
[SemVar](https://semverdoc.org) as the version numbering scheme.

Because releases are created based on commit messages, we release quite
often, sometimes several times in a day. This also means that any
individual release will not have many changes within it. Below is a list
of the releases we've made so far, along with what was changed within
each release.

## 0.8.17 (2026-02-19)

### Fix

- :bug: always clean up targets template `output_dir` before converting
  to Parquet (#224)

## 0.8.16 (2026-02-18)

### Fix

- :bug: use `pipeline_dir` as `output_path` to avoid macOS temp dir
  permission errors (#219)

## 0.8.15 (2026-02-18)

### Refactor

- ♻️ change simdata to `bef` and `lmdb` (#218)

## 0.8.14 (2026-02-18)

### Refactor

- :fire: not using `list_parquet_files()` anymore (#213)

## 0.8.13 (2026-02-13)

### Refactor

- ♻️ change `use_targets_template()` to use dir as input (#193)

## 0.8.12 (2026-02-13)

### Refactor

- :coffin: remove `is_same_register()` (#187)

## 0.8.11 (2026-02-13)

### Refactor

- :recycle: add input checks in simulate (#184)

## 0.8.10 (2026-02-13)

### Fix

- 🐛 abort `use_targets_template()` if file name is not `_targets.R`
  (#181)

## 0.8.9 (2026-02-13)

### Refactor

- ♻️ use `assert_string()` to check character scalars (#180)
- :recycle: add internal `check_parquet_path` (#179)
- ♻️ use Tidyverse functions instead of base and stats (#178)

## 0.8.8 (2026-02-13)

### Refactor

- :fire: remove `split_paths_by_register()` (#177)

## 0.8.7 (2026-02-13)

### Refactor

- ♻️ `convert_register()` and `convert_file()` (#174)

## 0.8.6 (2026-02-12)

### Refactor

- :recycle: add internal `read_sas_chunk()` (#171)

## 0.8.5 (2026-02-12)

### Refactor

- :recycle: add internal `create_partition_path()` (#170)

## 0.8.4 (2026-02-10)

### Refactor

- ♻️ update targets template (#164)

## 0.8.3 (2026-02-10)

### Refactor

- :recycle: update success msg in `convert_to_parquet()` (#167)

## 0.8.2 (2026-02-10)

### Refactor

- ♻️ get register name internally in `convert_to_parquet` from `path`
  (#161)

## 0.8.1 (2026-02-06)

### Refactor

- ♻️ simplify simulation in single function `simulate_register()` (#153)

## 0.8.0 (2026-02-06)

### Feat

- :sparkles: simulate register functions; test clean-up (#146)

## 0.7.9 (2026-02-06)

### Refactor

- :truck: align `path` param name in internal functions (#151)

## 0.7.8 (2026-02-06)

### Refactor

- :truck: `use_targets()` -> `use_targets_template()` (#149)

## 0.7.7 (2026-02-06)

### Fix

- :bug: update `convert_*()` param name in template; `file_paths` ->
  `path` (#150)

## 0.7.6 (2026-02-05)

### Refactor

- 🚚 `use_targets_pipeline()` -> `use_targets()` (#145)

## 0.7.5 (2026-02-04)

### Refactor

- :recycle: simplify parameter naming to use `path` (#140)

## 0.7.4 (2026-02-04)

### Refactor

- :recycle: longer UUIDs for less chance of duplicates (#141)

## 0.7.3 (2026-02-03)

### Refactor

- ♻️ side effect functions return invisibly (#131)

## 0.7.2 (2026-02-03)

### Refactor

- :fire: remove unused functions (#135)

## 0.7.1 (2026-02-03)

### Fix

- 🐛 partitioning with missing year (#132)

## 0.7.0 (2026-02-02)

### Feat

- ✨ targets pipeline (#124)

## 0.6.5 (2026-02-02)

### Refactor

- ♻️ rename parameters in `convert_to_parquet()` (#129)

## 0.6.4 (2026-01-29)

### Refactor

- ♻️ give error when no file is found in `list_*()` (#122)

## 0.6.3 (2026-01-28)

### Refactor

- ♻️ add internal `get_register_names()` (#123)

## 0.6.2 (2026-01-27)

### Refactor

- :adhesive_bandage: ensure `source_file` is character before Arrow
  schema creation (#120)

## 0.6.1 (2026-01-25)

### Refactor

- ♻️ ensure same register `paths` in `convert_to_parquet()` (#116)

## 0.6.0 (2026-01-23)

### Feat

- ✨ read SAS files in chunks; lowercase column names; align Arrow
  schemas (#112)

## 0.5.0 (2025-12-15)

### Feat

- ✨ add `list_*()` functions (#96)

## 0.4.0 (2025-12-12)

### Feat

- ✨ add `read_register()` (#90)

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
