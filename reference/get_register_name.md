# Get register name from a group of file paths

Extracts the register name from the path in a group. Intended for use
with groups created by
[`split_paths_by_register()`](https://dp-next.github.io/fastreg/reference/split_paths_by_register.md)
in the targets template.

## Usage

``` r
get_register_name(path)
```

## Arguments

- path:

  A character vector of one or more paths from the same register.

## Value

A character scalar with the register name.

## Examples

``` r
path <- c("data/bef2020.sas7bdat", "data/bef2021.sas7bdat")
get_register_name(path)
#> [1] "bef"
```
