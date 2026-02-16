# List Parquet files in a directory

Lists all Parquet register files (with the extension `.parquet` or
`.parq` case-insensitively) in the specified directory and its
subdirectories.

## Usage

``` r
list_parquet_files(path)
```

## Arguments

- path:

  Directory to search.

## Value

The path(s) to the found Parquet file(s).

## Examples

``` r
list_parquet_files(fs::path_package("fastreg", "extdata"))
#> /home/runner/work/_temp/Library/fastreg/extdata/test.parquet
```
