# Get path with year in the file name

Get path with year in the file name

## Usage

``` r
get_path_with_year(path)
```

## Arguments

- path:

  Path to to get if there's a year in the file name.

## Value

The path, if the file name contains a year.

## Examples

``` r
get_path_with_year(c("path/with/year2025", "path/without/year"))
#> [1] "path/with/year2025"
```
