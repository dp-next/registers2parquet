# Alter the path of a file to a Parquet partition in another directory

Alter the path of a file to a Parquet partition in another directory

## Usage

``` r
path_set_dir(path, output_dir)
```

## Arguments

- path:

  A file path.

- output_dir:

  New directory the file should be in.

## Value

A character vector.

## Examples

``` r
fs::file_temp(ext = ".sas7bdat") |> path_set_dir(fs::path_temp())
#> /tmp/Rtmp6tApRg/file1973116a790c.sas7bdat
```
