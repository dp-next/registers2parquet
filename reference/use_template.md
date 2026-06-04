# Use a targets pipeline for converting SAS registers to Parquet

Copies a `_targets.R` template and a conversion log Quarto Markdown file
to the given directory.

## Usage

``` r
use_template(path = ".", open = rlang::is_interactive())
```

## Arguments

- path:

  Path to the directory where the targets pipeline and conversion log
  will be created. Defaults to the current directory.

- open:

  Whether to open the file for editing.

## Value

The path to the created `_targets.R` file, invisibly.

## Examples

``` r
use_template(path = fs::path_temp(""))
#> ✔ Created /tmp/RtmpIkZOmd/_targets.R
#> ✔ Created /tmp/RtmpIkZOmd/_targets.R
#> ℹ Edit the `config` section to set your paths.
```
