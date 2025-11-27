# Read SAS files

This function reads one or more SAS files and adds a `source_file`
column indicating the file each row came from.

## Usage

``` r
read_sas_files(path)
```

## Arguments

- path:

  A character vector with the absolute path to the SAS file(s).

## Value

A data frame with the contents of the SAS file(s) plus a `source_file`
column.
