# Convert file name of a path to end in `/year=YYYY`

To follow the Parquet partitioning style
(`{input_path_dir}/year=####/`).

## Usage

``` r
path_alter_filename_year_as_dir(path)
```

## Arguments

- path:

  A file path.

## Value

A character vector.

## Examples

``` r
fs::file_temp(pattern = "database2020-", ext = ".sas7bdat") |>
  path_alter_filename_year_as_dir()
#> /tmp/RtmpQbU3Vc/database/year=2020
```
