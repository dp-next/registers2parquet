# Set up a targets pipeline for converting SAS registers to Parquet

Copies the targets pipeline template to your project root.

## Usage

``` r
use_targets_pipeline(path = "_targets.R", open = rlang::is_interactive())
```

## Arguments

- path:

  Path to the file to create. Defaults to `_targets.R`.

- open:

  Whether to open the file for editing. Defaults to `TRUE` in
  interactive sessions.

## Value

The path to the created file (invisibly).
