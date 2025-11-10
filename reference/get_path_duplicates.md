# Get paths with duplicate file names

Get paths with duplicate file names

## Usage

``` r
get_path_duplicates(path)
```

## Arguments

- path:

  Path to look for duplicate file names in.

## Value

A character with duplicate paths, an empty character if no duplicates.

## Examples

``` r
get_path_duplicates(c("path/duplicate.parquet", "path/duplicate.parquet"))
#> [1] "path/duplicate.parquet" "path/duplicate.parquet"
get_path_duplicates(c("path/no/duplicate.parquet", "path/no/identical.parquet"))
#> character(0)
```
