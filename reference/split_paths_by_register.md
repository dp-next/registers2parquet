# Group file paths by register name

Groups a vector of file paths by their register name, where the register
name is derived from the file name with all non-letter characters
removed.

## Usage

``` r
split_paths_by_register(paths)
```

## Arguments

- paths:

  A character vector of file paths.

## Value

A list of character vectors, where each element contains paths belonging
to the same register.

## Examples

``` r
paths <- c("data/bef2020.sas7bdat", "data/bef2021.sas7bdat", "data/ind2020.sas7bdat")
split_paths_by_register(paths)
#> [[1]]
#> [1] "data/bef2020.sas7bdat" "data/bef2021.sas7bdat"
#> 
#> [[2]]
#> [1] "data/ind2020.sas7bdat"
#> 
```
