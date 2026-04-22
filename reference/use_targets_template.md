# Use a targets pipeline template for converting SAS registers to Parquet

Copies a `_targets.R` template to the given directory.

## Usage

``` r
use_targets_template(path = ".", open = rlang::is_interactive())
```

## Arguments

- path:

  Path to the directory where `_targets.R` will be created. Defaults to
  the current directory.

- open:

  Whether to open the file for editing.

## Value

The path to the created `_targets.R` file, invisibly.

## Examples

``` r
use_targets_template(path = fs::path_temp(""))
#> ✔ Created /tmp/RtmpdBOnFv/_targets.R
#> ℹ Edit the `config` section to set your paths.
```
