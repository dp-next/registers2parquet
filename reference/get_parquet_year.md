# Get the year of the parquet file from the file name

This function extracts the year of the database from the file name.

## Usage

``` r
get_parquet_year(path)
```

## Arguments

- path:

  Path to the parquet file.

## Value

An integer with the year.

## Examples

``` r
get_parquet_year("path/to/year=2025/file.parquet")
#> [1] 2025
```
