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
list_sas_files(fs::path_package("fastreg", "extdata"))
#> /home/runner/work/_temp/Library/fastreg/extdata/test.sas7bdat
```
