# Get register name from a group of file paths

Extracts the register name from the path in a group. Intended for use
with groups created by
[`split_paths_by_register()`](https://dp-next.github.io/fastreg/reference/split_paths_by_register.md)
in the targets template.

## Usage

``` r
get_register_name(file_paths)
```

## Arguments

- file_paths:

  A character vector of file file_paths from the same register.

## Value

A character scalar with the register name.

## Examples

``` r
file_paths <- c("data/bef2020.sas7bdat", "data/bef2021.sas7bdat")
get_register_name(file_paths)
#> [1] "bef"
```
