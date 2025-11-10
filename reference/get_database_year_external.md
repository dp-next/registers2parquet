# Get the years from the external database's name of the file path.

Only for the external raw data files. Only years with four digits (e.g.,
2025, 1990) are recognised as years. Digits like 25 and 90 are not
recognised as years and will not be included.

## Usage

``` r
get_database_year_external(path)
```

## Arguments

- path:

  Path to the database.

## Value

A character vector of years.

## Examples

``` r
if (FALSE) { # \dontrun{
get_database_year_external("path/to/external/database2025.csv")
} # }
```
