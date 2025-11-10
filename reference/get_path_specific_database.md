# Get path with specific database file

Get path with specific database file

## Usage

``` r
get_path_specific_database(path, name)
```

## Arguments

- path:

  Path to get specific database from.

- name:

  Name of the specific database to look for.

## Value

A character containing a path with the specific database.

## Examples

``` r
get_path_specific_database("path/to/bef2025.sas", "bef")
#> [1] "path/to/bef2025.sas"
get_path_specific_database("path/to/bef2025.sas", "lpr2")
#> character(0)
```
