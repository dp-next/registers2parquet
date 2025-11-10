# Get paths with no duplicate file names

Get paths with no duplicate file names

## Usage

``` r
get_path_no_duplicates(path)
```

## Arguments

- path:

  Path to look for non-duplicate file names in.

## Value

A character with unique paths, an empty character if duplicates.

## Examples

``` r
get_path_no_duplicates(c("path/duplicate.parquet", "path/duplicate.parquet"))
#> character(0)
get_path_no_duplicates(c("path/no/duplicate.parquet", "path/no/identical.parquet"))
#> [1] "path/no/duplicate.parquet" "path/no/identical.parquet"
```
