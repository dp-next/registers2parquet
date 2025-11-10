# Create dataframe with path and file name

Create a dataframe (tibble) with columns "path" and "file", with the
full path and file name respectively.

## Usage

``` r
path_as_df(path)
```

## Arguments

- path:

  Path to data.

## Value

A tibble with the path(s).

## Examples

``` r
path_as_df(c("path/data.parquet", "path/another.parquet"))
#> # A tibble: 2 × 2
#>   path                 file           
#>   <chr>                <chr>          
#> 1 path/data.parquet    data.parquet   
#> 2 path/another.parquet another.parquet
```
