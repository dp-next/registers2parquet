# List Parquet registers in a directory

This function lists all Parquet register files (with the extension
`.parquet` or `.parq` case-insensitively) in the specified directory and
its subdirectories.

## Usage

``` r
list_parquet_files(path)
```

## Arguments

- path:

  The path to the directory to search for Parquet files.

## Value

A character vector of paths to the Parquet files found.

## Examples

``` r
list_parquet_files(fs::path_package("registers2parquet", "extdata"))
#> /home/runner/work/_temp/Library/registers2parquet/extdata/test_register.parquet
```
