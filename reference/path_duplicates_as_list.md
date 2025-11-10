# Get duplicate paths as a list

Get duplicate paths as a list

## Usage

``` r
path_duplicates_as_list(path)
```

## Arguments

- path:

  Paths to list.

## Value

A list with input path(s) where duplicate file names are grouped in the
same list.

## Examples

``` r
path_duplicates_as_list(c("path/data.parquet", "path/another.parquet", "path/to/another.parquet"))
#> [[1]]
#> [1] "path/another.parquet"    "path/to/another.parquet"
#> 
#> [[2]]
#> [1] "path/data.parquet"
#> 
```
