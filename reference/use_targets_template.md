# Use a targets pipeline template for converting SAS registers to Parquet

Copies a template to the given path.

## Usage

``` r
use_targets_template(path = "_targets.R", open = rlang::is_interactive())
```

## Arguments

- path:

  Path to the file to create. Defaults to `_targets.R`.

- open:

  Whether to open the file for editing.

## Value

The `path`, invisibly.
