# Convert path to end with `filename/`

Convert path to end with `filename/`

## Usage

``` r
path_alter_filename_as_dir(path)
```

## Arguments

- path:

  A file path.

## Value

A character vector.

## Examples

``` r
fs::file_temp(pattern = "database", ext = ".sas7bdat") |>
  path_alter_filename_as_dir()
#> /tmp/RtmpdC5vHx/database
```
