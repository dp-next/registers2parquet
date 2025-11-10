# Get the year of database from the file name

This function extracts the year of the database from the file name.

## Usage

``` r
get_database_year(path)
```

## Arguments

- path:

  Path to the database file.

## Value

An integer with the year.

## Examples

``` r
get_database_year("path/to/database2025.sas")
#> [1] 2025
```
