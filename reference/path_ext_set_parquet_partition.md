# Convert file path to Parquet Partition

Convert file path to Parquet Partition

## Usage

``` r
path_ext_set_parquet_partition(path)
```

## Arguments

- path:

  A file path.

## Value

A character vector.

## Examples

``` r
fs::file_temp(ext = ".sas7bdat") |> path_ext_set_parquet_partition()
#> /tmp/RtmpMUEyZY/file1a401559d72a.sas7bdat/part-0.parquet
```
