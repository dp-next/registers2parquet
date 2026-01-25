# Get year from file name

The year is determined as the first four consecutive numbers starting
with 19 or 20 in the file name (i.e., years 1900-2099).

## Usage

``` r
get_year_from_filename(file_path)
```

## Arguments

- file_path:

  A character vector with file path to extract year from.

## Value

An integer vector with the extracted years, or NA if no year is found.
