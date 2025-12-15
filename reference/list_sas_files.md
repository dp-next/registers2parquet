# List SAS registers in a directory

This function lists all SAS register files (with the extension
`.sas7bdat` case-insensitively) in the specified directory and its
subdirectories.

## Usage

``` r
list_sas_files(path)
```

## Arguments

- path:

  The path to the directory to search for SAS files.

## Value

A character vector of paths to the SAS files found.

## Examples

``` r
# Returns an empty character vector as there are no SAS files in the extdata folder.
list_sas_files(fs::path_package("registers2parquet", "extdata"))
#> character(0)
```
