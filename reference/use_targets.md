# Use a targets pipeline template for converting SAS registers to Parquet

Copies a template to your project root.

## Usage

``` r
use_targets(path = "_targets.R", open = rlang::is_interactive())
```

## Arguments

- path:

  Path to the file to create. Defaults to `_targets.R`.

- open:

  Whether to open the file for editing. Defaults to `TRUE` in
  interactive sessions.

## Value

The path to the created file (invisibly).
